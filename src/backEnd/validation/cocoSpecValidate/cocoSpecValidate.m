%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [valid, validation_compute,sim_failed, lus_file_path, ...
    sf2lus_time] = cocoSpecValidate(model_full_path, min_max_constraints)
    bdclose('all');

    file_path = fileparts(mfilename('fullpath'));
    cocoSim_path = fileparts(file_path);
    addpath(fullfile(cocoSim_path,'src/'));
    addpath(fullfile(cocoSim_path,'src/utils/'));
    cocosim_config;
    assignin('base', 'SOLVER', 'NONE');
    assignin('base', 'RUST_GEN', 0);
    assignin('base', 'C_GEN', 0);

    OldPwd = pwd;
    [model_path, file_name, ext] = fileparts(char(model_full_path));
    addpath(model_path);   
    
    sim_failed=0;   
    validation_compute = 0;    
    validation_start = tic;

    try
        f_msg = sprintf('Compiling model "%s" to Lustre\n',file_name);
        display_msg(f_msg, Constants.RESULT, 'validation', '');
        Utils.update_status('Runing CocoSim');
        [lus_file_path, sf2lus_time, ~]= cocoSpecCompiler(model_full_path);

        [lus_file_dir, lus_file_name, extension] = fileparts(lus_file_path);
        file_name = lus_file_name;        
        model_full_path = fullfile(model_path,strcat(file_name,ext));        
        cd(lus_file_dir);
    catch ME
        msg = sprintf('Translation Failed for model "%s" :\n%s\n%s',file_name,ME.identifier,ME.message);
        display_msg(msg, Constants.ERROR, 'validation', '');
        display_msg(ME.getReport(), Constants.DEBUG, 'validation', '');
        
        sf2lus_time = -1;
        L.error('validation',[file_name, '\n' getReport(ME,'extended')]);
        rethrow(ME);
    end
    
    Utils.update_status('Generating Simulink output');
    load_system(model_full_path);
    rt = sfroot;
    m = rt.find('-isa', 'Simulink.BlockDiagram');
    events = m.find('-isa', 'Stateflow.Event');
    inputEvents = events.find('Scope', 'Input');
    inputEvents_names = inputEvents.get('Name');
    code_on=sprintf('%s([], [], [], ''compile'')', file_name);
    evalin('base',code_on);
    block_paths = find_system(file_name, 'SearchDepth',1, 'Type', 'Block');
    inports = [];
    for i=1:numel(block_paths)
        block = block_paths{i};
        block_handle = get_param(block, 'handle');

        if strcmp(get_param(block_handle, 'BlockType'), 'Inport')
            block_ports_dts = get_param(block_handle, 'CompiledPortDataTypes');
            DataType = block_ports_dts.Outport;
            tns = regexp(block,'/','split');
            if numel(tns)==2
                dimension = str2num(get_param(block,'PortDimensions'));
                if dimension==-1
                    dimension_struct = get_param(block,'CompiledPortDimensions');
                    dimension = dimension_struct.Outport;
                    if numel(dimension)== 2 && dimension(1)==1
                        dimension = dimension(2);
                    end
                end
                inports = [inports, struct('Name',Utils.naming_alone(block), 'DataType', DataType, 'Dimension', dimension)];
            end
        end
    end
    code_on=sprintf('%s([], [], [], ''term'')', file_name);
    evalin('base',code_on);

    numberOfInports = numel(inports);
  
    IMAX = 100; %IMAX for randi the max born for random number
    IMIN = 0;
    if exist('min_max_constraints', 'var')
            IMIN = min_max_constraints{1,2};
            IMAX = min_max_constraints{1,3};
    end
    
    stop_time = IMAX;
    try
        min = Utils.get_BlockDiagram_SampleTime(file_name); 
        if  min==0 || isnan(min) || min==Inf
            simulation_step = 1;
        else
            simulation_step = min;
        end
    catch
        simulation_step = 1;
    end

    nb_steps = stop_time/simulation_step +1;
   
    input_struct.time = (0:simulation_step:stop_time)';
    input_struct.signals = [];
    number_of_inputs = 0;
    for i=1:numberOfInports
        input_struct.signals(i).name = inports(i).Name;
        dim = inports(i).Dimension;
        
        if find(strcmp(inputEvents_names,inports(i).Name))
            input_struct.signals(i).values = square((numberOfInports-i+1)*rand(1)*input_struct.time);
            input_struct.signals(i).dimensions = 1;%dim;
        elseif strcmp(sT2fT(inports(i).DataType),'bool')
            input_struct.signals(i).values = ValidateUtils.construct_random_booleans(nb_steps, IMIN, IMAX, dim);
            input_struct.signals(i).dimensions = dim;
        elseif strcmp(sT2fT(inports(i).DataType),'int')
            input_struct.signals(i).values = ValidateUtils.construct_random_integers(nb_steps, IMIN, IMAX, inports(i).DataType, dim);
            input_struct.signals(i).dimensions = dim;
        elseif strcmp(inports(i).DataType,'single')
            input_struct.signals(i).values = single(ValidateUtils.construct_random_doubles(nb_steps, IMIN, IMAX,dim));
            input_struct.signals(i).dimensions = dim;
        else
            input_struct.signals(i).values = ValidateUtils.construct_random_doubles(nb_steps, IMIN, IMAX,dim);
            input_struct.signals(i).dimensions = dim;
        end
        if numel(dim)==1
            number_of_inputs = number_of_inputs + nb_steps*dim;
        else
            number_of_inputs = number_of_inputs + nb_steps*(dim(1) * dim(2));
        end
    end
    
    %save kind2 input values in a file    
    if numberOfInports>=1
         values_file = fullfile(lus_file_dir, 'input_values');
        fid = fopen(values_file, 'w');        
        for i=1:numberOfInports 
            valuesString = cellstr(num2str(input_struct.signals(i).values,'%30.16f'));
            valuesString = [input_struct.signals(i).name valuesString'];
            values = strjoin(valuesString, ',');
            values = strcat(values, '\n');
            fprintf(fid, values);
        end  
        fclose(fid);
    end
    
    kind2Output = Kind2Utils.simulate(lus_file_path,values_file);   
    
    fid = fopen('outputs_values', 'w');    
    fprintf(fid, kind2Output);
    fclose(fid);    
    
    simulationStruct = Kind2Utils.parseSimulation('outputs_values');
    
    msg = sprintf('Simulating model "%s"\n',file_name);
    display_msg(msg, Constants.INFO, 'validation', '');
    Utils.update_status('Simulating model');
    try
        configSet = Simulink.ConfigSet;
        set_param(configSet, 'Solver', 'FixedStepDiscrete');
        set_param(configSet, 'FixedStep', num2str(simulation_step));
        set_param(configSet, 'StartTime', num2str(IMIN));
        set_param(configSet, 'StopTime',  num2str(IMAX));
        set_param(configSet, 'SaveFormat', 'Structure');
        set_param(configSet, 'SaveOutput', 'on');
        set_param(configSet, 'SaveTime', 'on');

        if numberOfInports>=1
            set_param(configSet, 'SaveState', 'on');
            set_param(configSet, 'StateSaveName', 'xout');
            set_param(configSet, 'OutputSaveName', 'yout');
            set_param(configSet, 'ExtMode', 'on');
            set_param(configSet, 'LoadExternalInput', 'on');
            set_param(configSet, 'ExternalInput', 'input_struct');
            hws = get_param(file_name, 'modelworkspace');
            hws.assignin('input_struct',eval('input_struct'));
            assignin('base','input_struct',input_struct);                        
            simOut = sim(file_name, configSet);
        else                       
            simOut = sim(file_name, configSet);
        end
        Utils.update_status('Compare Simulink outputs and lustre outputs');
        yout = get(simOut,'yout');
        yout_signals = yout.signals;
        assignin('base','yout',yout);
        assignin('base','yout_signals',yout_signals);
        numberOfOutputs = numel(yout_signals);        
        valid = true;
        error_index = 1;
        eps = 1;
        index_out = 0;
        for i=0:nb_steps-1
            for k=1:numberOfOutputs
                dim = yout_signals(k).dimensions;
                if numel(dim)==2
                    yout_values = [];
                    y = yout_signals(k).values(:,:,i+1);
                    for idr=1:dim(1)
                        yout_values = [yout_values; y(idr,:)'];
                    end
                    dim = dim(1)*dim(2);
                else
                    yout_values = yout_signals(k).values(i+1,:);
                end
                for j=1:dim
                    index_out = index_out + 1;
                    output_value = simulationStruct.node.streams{k}.values(index_out);                                      
                    
                    if yout_values(j)==inf
                        diff=0;
                    else
                        diff = abs(yout_values(j)-output_value);
                    end
                    valid = valid && (diff<eps);
                    if  ~valid
                        diff_name =  Utils.naming_alone(yout_signals(k).blockName);
                        error_index = i+1;
                        break
                    end
                end
                if  ~valid
                    break;
                end
            end
            if  ~valid
                break;
            end
        end
        if ~valid
            Utils.update_status('Translation is not valid');
            f_msg = sprintf('translation for model "%s" is not valid \n',file_name);
            display_msg(f_msg, Constants.RESULT, 'validation', '');
            f_msg = sprintf('Here is the counter example:\n');
            display_msg(f_msg, Constants.RESULT, 'validation', '');
            index_out = 0;
            for i=0:error_index-1
                f_msg = sprintf('*****step : %d**********\n',i+1);
                display_msg(f_msg, Constants.RESULT, 'CEX', '');
                f_msg = sprintf('*****inputs: \n');
                display_msg(f_msg, Constants.RESULT, 'CEX', '');
                for j=1:numberOfInports
                    dim = input_struct.signals(j).dimensions;
                    if numel(dim)==1
                        in = input_struct.signals(j).values(i+1,:);
                        name = input_struct.signals(j).name;
                        for k=1:dim
                            f_msg = sprintf('input %s_%d:%f\n',name,k,in(k));
                            display_msg(f_msg, Constants.RESULT, 'CEX', '');
                        end
                    else
                        in = input_struct.signals(j).values(:,:,i+1);
                        name = input_struct.signals(j).name;
                        for dim1=1:dim(1)
                            for dim2=1:dim(2)
                                f_msg = sprintf('input %s_%d_%d:%10.10f\n',name,dim1,dim2,in(dim1, dim2));
                                display_msg(f_msg, Constants.RESULT, 'CEX', '');
                            end
                        end
                    end
                end
                f_msg = sprintf('*****outputs: \n');
                display_msg(f_msg, Constants.RESULT, 'CEX', '');
                for k=1:numberOfOutputs
                    dim = yout_signals(k).dimensions;
                    if numel(dim)==2                       
                        yout_values = [];
                        y = yout_signals(k).values(:,:,i+1);
                        for idr=1:dim(1)
                            yout_values = [yout_values; y(idr,:)'];
                        end                        
                        dim = dim(1)*dim(2);
                    else
                        yout_values = yout_signals(k).values(i+1,:);
                    end
                    for j=1:dim
                        index_out = index_out + 1;
                        output_value = simulationStruct.node.streams{k}.values(index_out);                           
                        
                        output_name = simulationStruct.node.streams{k}.name;                      
                       
                        output_name1 = Utils.naming_alone(yout_signals(k).blockName);
                        f_msg = sprintf('output %s: %10.16f\n',output_name1,yout_values(j));
                        display_msg(f_msg, Constants.RESULT, 'CEX', '');
                        f_msg = sprintf('Lustre output %s: %10.16f\n',output_name,output_value);
                        display_msg(f_msg, Constants.RESULT, 'CEX', '');                        
                    end
                end

            end
            f_msg = sprintf('difference between outputs %s is :%2.10f\n',diff_name, diff);
            display_msg(f_msg, Constants.RESULT, 'CEX', '');
        else
            Utils.update_status('Translation is valid');
            msg = sprintf('Translation for model "%s" is valid \n',file_name);
            display_msg(msg, Constants.RESULT, 'CEX', '');
        end                    
        cd(OldPwd);
    catch ME
        msg = sprintf('simulation failed for model "%s" :\n%s\n%s',file_name,ME.identifier,ME.message);
        display_msg(msg, Constants.ERROR, 'validation', '');
        display_msg(msg, Constants.DEBUG, 'validation', '');
        sim_failed = 1;
        valid = 0;
        cd(OldPwd);
        L.error('sim',[file_name, '\n' getReport(ME,'extended')]);
        return
    end
      
    f_msg = ['\n Simulation Input (workspace) input_struct \n'];
    f_msg = [f_msg 'Simulation Output (workspace) : yout_signals \n'];
    f_msg = [f_msg 'Lustre binary Input ' fullfile(lus_file_dir,'input_values') '\n'];
    f_msg = [f_msg 'Lustre binary Output ' fullfile(lus_file_dir,'outputs_values') '\n'];
    display_msg(f_msg, Constants.RESULT, 'validation', '');

    cd(OldPwd);
    if sim_failed==1
        validation_compute = -1;
    else
        validation_compute = toc(validation_start);
    end

end

