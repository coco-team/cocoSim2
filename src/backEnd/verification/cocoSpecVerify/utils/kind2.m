%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function kind2(lustre_file_name, property_node_names, property_file_base_name, ir_struct, xml_trace, mapping_file)
     
    cocosim_config;
    try
       kind2_option = evalin('base','kind2_option');
    catch
       kind2_option  = '';
    end
    try
       timeout = evalin('base','timeout');
    catch
       timeout = '60.0';
    end
    if exist(KIND2,'file') && exist(Z3,'file')        
        
        % properties in the mapping file                        
        if exist(mapping_file) == 2
        
            date_value = datestr(now, 'ddmmyyyyHHMMSS');
            [~,file_name,~] = fileparts(lustre_file_name);
            
            % load preferences
            CoCoSimPreferences = loadCoCoSimPreferences();     
            % check whether to use compositional analysis
            if CoCoSimPreferences.compositionalAnalysis
                command = sprintf('%s --z3_bin %s -xml --timeout %s %s %s --modular true --compositional true',...
                    KIND2, Z3, timeout, kind2_option, lustre_file_name);
            else
                command = sprintf('%s --z3_bin %s -xml --timeout %s %s %s --modular true',...
                    KIND2, Z3, timeout, kind2_option, lustre_file_name);
            end
            
            
            display_msg(['KIND2_COMMAND ' command], Constants.DEBUG, 'write_code', '');
            [~, kind2_out] = system(command);
            display_msg(kind2_out, Constants.DEBUG, 'write_code', '');
            
            results_file_name = strrep(lustre_file_name,'.lus','.xml');
            fid = fopen(results_file_name, 'w');
            fprintf(fid, kind2_out);
            fclose(fid);            
            s = dir(results_file_name);
            
            %ToDo: enhance this code to execute only when there is counter
            %examples
            
            % support multiple counter examples
            pathParts = strsplit(mfilename('fullpath'),'/');
            %set cocoSim_path to be ~/CoCoSim/src
            cocoSim_path = strjoin(pathParts(1 :end - 5), '/');            
            annot_text = fileread([cocoSim_path filesep 'backEnd' filesep 'templates' filesep 'header.html']);
            css_source = fullfile(cocoSim_path,'backEnd' , 'templates' , 'materialize.css');
            annot_text = strrep(annot_text, '[css_source]', css_source);
            
            % read the mapping file
            fid = fopen(mapping_file);
            raw = fread(fid, inf);                
            str = char(raw');  
            fclose(fid); 
            json = jsondecode(str);
            %convert to cell if it json is struct 
            if isstruct(json)
                json = num2cell(json);
            end
            
            verificationResults = {};
            
            if s.bytes ~= 0                
                xml_doc = xmlread(results_file_name);
                xml_analysis_elements = xml_doc.getElementsByTagName('AnalysisStart');     
                for i = 0:(xml_analysis_elements.getLength-1)
                    xmlAnalysis = xml_analysis_elements.item(i);
                    analysisStruct.top = char(xmlAnalysis.getAttribute('top'));
                    analysisStruct.abstract = char(xmlAnalysis.getAttribute('abstract'));
                    analysisStruct.concrete= char(xmlAnalysis.getAttribute('concrete'));
                    analysisStruct.assumptions = char(xmlAnalysis.getAttribute('assumptions'));                    
                    analysisStruct = handleAnalysis(json, xmlAnalysis, ir_struct, date_value, ...
                               lustre_file_name, xml_trace, annot_text, analysisStruct);
                    verificationResults.analysisResults{i+1} = analysisStruct;
                end
                
                %store the verification results in the model workspace
                [verificationResults, compositionalMap] = saveVerificationResults(verificationResults);
                displayVerificationResults(verificationResults, compositionalMap);
            end
                        
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        msg = 'Kind2: Impossible to find Kind2';
        display_msg(msg, Constants.ERROR, 'Kind2', '');
    end
    
    %% for modular execution
end

function [verificationResults, compositionalMap] = saveVerificationResults(verificationResults)
    
    modelWorkspace = get_param(gcs,'ModelWorkspace');
    assignin(modelWorkspace,'verificationResults',verificationResults);                    
     % extract the top field from each analysis result      
    analysisNames = cellfun(@(x) x.top, verificationResults.analysisResults,'UniformOutput', 0);
    % group the analysis results by top field
    groups = findgroups(analysisNames);    
    % get the name of each group
    distinctAnalysisNames = splitapply(@(x) x(1),analysisNames,groups); 

    % get the options for compositional analysis    
    compositionalOptions = cell(1, length(distinctAnalysisNames));    
    for i = 1: length(verificationResults.analysisResults)        
        index = find(strcmp(distinctAnalysisNames,verificationResults.analysisResults{i}.top));
        optionIndex = length(compositionalOptions{index}) + 1;
        compositionalOptions{index}{optionIndex} = verificationResults.analysisResults{i}.abstract;        
    end    

    % by default, display the last analysis for each group
    selectedOptions = cellfun(@(x) length(x), compositionalOptions);

    %map options and selected options with each distinct name
    compositionalMap.analysisNames = distinctAnalysisNames;
    compositionalMap.compositionalOptions = compositionalOptions;
    compositionalMap.selectedOptions = selectedOptions;

    %store the options in the model workspace
    modelWorkspace = get_param(bdroot(gcs),'ModelWorkspace');
    assignin(modelWorkspace,'compositionalMap',compositionalMap);      
end


function [analysisStruct] = handleAnalysis(json, xml_analysis_start, ir_struct, date_value, ...
                               lustre_file_name, xml_trace, annot_text, analysisStruct)
    xml_element = xml_analysis_start;
    analysisStruct.properties ={};
    contractColor = 'green';
    index = 0;
    %ToDo: make sure the loop terminates when there are parsing errors
    while ~strcmp(xml_element.getNodeName,'AnalysisStop')
        
        xml_element = xml_element.getNextSibling;
        if strcmp(xml_element.getNodeName,'Property')            
            propertyStruct = {};
            index = index + 1;
            % get the property name
            propertyStruct.propertyName = char(xml_element.getAttribute('name'));
            %ToDo: fix the naming difference between kind2 xml file and
            %translator mapping file for compositional assume blocks
            if contains (propertyStruct.propertyName,'.assume')
                propertyStruct.propertyName 
                %ToDo delete this line
                index = index - 1;
                continue
            end
            propertyStruct.answer = xml_element.getElementsByTagName('Answer').item(0).getTextContent;
            if strcmp(propertyStruct.answer, 'valid')  
                propertyStruct.answer = 'SAFE';
            elseif strcmp(propertyStruct.answer, 'falsifiable')
                propertyStruct.answer = 'CEX';
            else
                propertyStruct.answer = 'UNKNOWN';
            end

            msg = [' result for property node [' propertyStruct.propertyName ']: ' propertyStruct.answer];
            display_msg(msg, Constants.RESULT, 'Property checking', '');

            % Change the block display according to answer
        %                     display = sprintf('color(''black'')\n');
        %                     display = [display sprintf('text(0.5, 0.5, [''Property: '''''' get_param(gcb,''name'') ''''''''], ''horizontalAlignment'', ''center'');\n')];
        %                     display = [display 'text(0.99, 0.03, ''{\bf\fontsize{12}'];
        %                     display = [display char(upper(answer))];
        %                     display = [display '}'', ''hor'', ''right'', ''ver'', ''bottom'', ''texmode'', ''on'');'];
        %                     obs_mask = Simulink.Mask.get(property_node_names{idx_prop}.annotation);
        %                     obs_mask.Display = sprintf('%s',display);

            % get the json mapping
            jsonName = regexprep(propertyStruct.propertyName,'\[l\S*?\]',''); 
            originPath = '';
            if contains(jsonName,  '._one_mode_active')
                % get the validator block
                for i = 1 : length(json)
                    if isfield(json{i,1},'ContractName')
                        path = json{i,1}.OriginPath;
                        contractPath = fileparts(path);
                        originPath = strcat(contractPath, '/validator');

                        if strcmp(propertyStruct.answer, 'CEX')
                            set_param(originPath, 'BackgroundColor', 'red');
                            contractColor = 'red';
                            oneModeActiveAnnotation = strcat(contractPath, '/contract has non-exhaustive modes');                                    
                            note = Simulink.Annotation(oneModeActiveAnnotation);
                            validatorPosition = get_param(originPath, 'Position');
                            validatorPosition(2) = validatorPosition(2) + 20;                                    
                            note.position = [validatorPosition(1) validatorPosition(4) + 20]; 
                            note.ForegroundColor = 'red';
                            % set the color of the contract
                            set_param(contractPath, 'BackgroundColor', 'red');     

                            % display the counter example box                                              
                            counterExampleElement = xml_element.getElementsByTagName('CounterExample');                        
                            if counterExampleElement.getLength > 0                                
                                propertyStruct.counterExample = parseCounterExample(counterExampleElement.item(0));
                                [~,annot_text] = display_cex(counterExampleElement, originPath, ir_struct, date_value, ...
                                   lustre_file_name, index, xml_trace, ir_struct, annot_text);                               
                               analysisStruct.properties{index} = propertyStruct;
                            else
                                msg = [solver ': FAILURE to get counter example: '];
                                msg = [msg property_name '\n'];
                                display_msg(msg, Constants.WARNING, 'Property Checking', '');
                            end                                
                            break;
                        end
                    end
                end
                % check other properties
                continue;
            end
            for i = 1 : length(json)
                if isfield(json{i,1},'ContractName')
                    propertyJsonName = json{i,1}.ContractName;
                    if strcmp(json{i,1}.PropertyName, 'guarantee')
                        propertyJsonName = strcat(propertyJsonName, '.guarantee');
                    end
                    if strcmp(json{i,1}.PropertyName, 'ensure')
                        propertyJsonName = strcat(propertyJsonName,'.', json{i,1}.ModeName ,'.ensure');
                    end
                    if strcmp(json{i,1}.PropertyName, 'assume')
                        propertyJsonName = strcat(propertyJsonName, '.assume');
                    end
                    if isfield(json{i,1},'Index')
                        propertyJsonName = strcat(propertyJsonName,'[', json{i,1}.Index ,']');
                    end
                else
                    propertyJsonName = json{i,1}.PropertyName;
                end
                %if strcmp(propertyJsonName, jsonName)                           
                if contains(jsonName, propertyJsonName)   

                    propertyStruct.originPath = json{i,1}.OriginPath;                            

                    if strcmp(propertyStruct.answer, 'SAFE')
                        set_param(propertyStruct.originPath, 'BackgroundColor', 'green');
                        set_param(propertyStruct.originPath, 'ForegroundColor', 'green');                                
                    elseif strcmp(propertyStruct.answer, 'TIMEOUT')
                        set_param(propertyStruct.originPath, 'BackgroundColor', 'gray');
                        set_param(propertyStruct.originPath, 'ForegroundColor', 'gray');
                        % set the color of the contract
                        if isfield(json{i,1},'ContractName') && strcmp(contractColor, 'green')
                            contractColor = 'yellow';
                        end
                    elseif strcmp(propertyStruct.answer, 'UNKNOWN')
                        set_param(propertyStruct.originPath, 'BackgroundColor', 'yellow');
                        set_param(propertyStruct.originPath, 'ForegroundColor', 'yellow');
                         % set the color of the contract
                        if isfield(json{i,1},'ContractName') && strcmp(contractColor, 'green')
                            contractColor = 'yellow';
                        end
                    elseif strcmp(propertyStruct.answer, 'CEX')
                        set_param(propertyStruct.originPath, 'BackgroundColor', 'red');
                        set_param(propertyStruct.originPath, 'ForegroundColor', 'red');   

                         % set the color of the contract
                        if isfield(json{i,1},'ContractName')
                            contractColor = 'red';                                                            
                        end

                        % get the counter example                                        
                        counterExampleElement = xml_element.getElementsByTagName('CounterExample');                        
                        if counterExampleElement.getLength > 0                            
                            
                            propertyStruct.counterExample = parseCounterExample(counterExampleElement.item(0));
                            
                            [~,annot_text] = display_cex(counterExampleElement, propertyStruct.originPath, ir_struct, date_value, ...
                               lustre_file_name, index, xml_trace, ir_struct, annot_text);                            
                        else
                            msg = [solver ': FAILURE to get counter example: '];
                            msg = [msg property_name '\n'];
                            display_msg(msg, Constants.WARNING, 'Property Checking', '');
                        end

                    end
                    analysisStruct.properties{index} = propertyStruct;
                    if isfield(json{i,1},'ContractName')                            
                            contractBlock = fileparts(json{i,1}.OriginPath);
                            set_param(contractBlock, 'BackgroundColor', contractColor);
                            ancestorBlock = fileparts(contractBlock);
                            while contains(ancestorBlock, '/')
                                ancestorBlockColor = get_param(ancestorBlock, 'BackgroundColor');
                                if strcmp(ancestorBlockColor, 'white') || ...
                                        (strcmp(ancestorBlockColor, 'green') && strcmp(ancestorBlockColor, 'yellow')) || ...
                                        strcmp(contractColor, 'red')
                                set_param(ancestorBlock, 'BackgroundColor', contractColor);
                                end
                                ancestorBlock = fileparts(ancestorBlock);
                            end
                    end                    
                end
            end
        end
    end
end

function [counterExampleStruct] = parseCounterExample(counterExampleElement)
    counterExampleStruct = {};    
    nodeElement = counterExampleElement.getElementsByTagName('Node').item(0); 
    counterExampleStruct.node = parseCounterExampleNode(nodeElement);        
end

function [nodeStruct] = parseCounterExampleNode(nodeElement)
    nodeStruct = {};
    nodeStruct.name = char(nodeElement.getAttribute('name'));  
    children = nodeElement.getChildNodes;        
    streamIndex = 0;
    nodeIndex = 0;
    
    for childIndex = 0 : (children.getLength - 1)
    
        xmlElement = children.item(childIndex);
        
        if strcmp(xmlElement.getNodeName,'Stream')                                              
            streamStruct = {};                     
            streamStruct.name = char(xmlElement.getAttribute('name'));
            streamStruct.type = char(xmlElement.getAttribute('type'));
            streamStruct.class = char(xmlElement.getAttribute('class'));             
            valueElements = xmlElement.getElementsByTagName('Value');
            streamStruct.values = [];
            nodeStruct.timeSteps = valueElements.getLength;
            for valueIndex=0:(valueElements.getLength-1)
                value = char(valueElements.item(valueIndex).getTextContent);
                if strcmp(value, 'false')
                    streamStruct.values(valueIndex + 1) = false;
                elseif strcmp(value, 'true')
                    streamStruct.values(valueIndex + 1) = true;
                else
                    streamStruct.values(valueIndex + 1) = str2num(value);
                end
            end
            streamIndex = streamIndex + 1;
            nodeStruct.streams{streamIndex} = streamStruct;    
        elseif strcmp(xmlElement.getNodeName,'Node')   
            % for parsing nested nodes and their streams inside
            % the counter example            
            nestedNodeStruct = parseCounterExampleNode(xmlElement);
            nodeIndex = nodeIndex + 1;
            nodeStruct.nodes{nodeIndex} = nestedNodeStruct;   
        end            
    end        
end 


function [status,annot_text] = display_cex(cex, origin_path, model, date_value, lustre_file_name, idx_prop,xml_trace, ir_struct, annot_text)
   status = 1;
  [path, lustre_file, ext] = fileparts(lustre_file_name);
   prop_name = Utils.name_format(origin_path);
   prop_name = strrep(prop_name, '/','_');
   mat_file_name = ['config_' prop_name '_' date_value '.mat'];
   mat_full_file = fullfile(path, mat_file_name);

   % Initialisation of the IO_struct
   IO_struct = mk_IO_struct(model, origin_path);
   try
       % Definition of the values and variable names
       [IO_struct, found] = parseCEX(cex, IO_struct, origin_path, xml_trace);
   catch ERR
       found = false;
       msg = ['KIND2: FAILURE to parse the CEX : ' prop_name '\n' getReport(ERR)];
       display_msg(msg, Constants.INFO, 'Kind2', '');
   end
   if found
       try
           % Simulation configuration
           IO_struct = create_configuration(IO_struct, lustre_file, origin_path, mat_full_file, idx_prop);
           config_created = true;
       catch ERR
           msg = ['FAILURE to create the Simulink simulation configuration\n' getReport(ERR)];
           display_msg(msg, Constants.INFO, 'Kind2', '');
           config_created = false;
       end
       if config_created
           try
               % Create the annotation with the links to setup and launch the simulation
               [annot_text] = createAnnotation(lustre_file_name, origin_path, IO_struct, mat_full_file, path, ir_struct, annot_text);
           catch ERR
               msg = ['FAILURE to create the Simulink CEX replay annotation\n' getReport(ERR)];
               display_msg(msg, Constants.INFO, 'Kind2', '');
           end
       end
   end
end

% Builds the IO structure for the counter example:
function IO_struct = mk_IO_struct(model_inter_blk, origin_path)
	IO_struct = '';
	cpt_in = 1;
	cpt_out = 1;
    
	parent_block_name = fileparts(origin_path);
	if numel(regexp(parent_block_name, filesep, 'split')) == 1
		main_model_name = parent_block_name;
        sub_blk = model_inter_blk;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Bug fix for sub_blk.Content which is null
        sub_blk_fields = fieldnames(sub_blk);
        % modify sub_blk to be its model which is the second field
        sub_blk = getfield(sub_blk, char(sub_blk_fields(2)));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
	else
		par_name_comp = regexp(parent_block_name, filesep, 'split');
		main_model_name = par_name_comp{1};
        sub_blk = get_struct(model_inter_blk, Utils.name_format(parent_block_name));
	end

	
	warning off;
	code_compile = sprintf('%s([], [], [], ''compile'')', main_model_name);
	eval(code_compile);
            
    fields = fieldnames(sub_blk.Content);
    fields(cellfun('isempty', regexprep(fields, '^Annotation.*', ''))) = [];
	for idx_blk=1:numel(fields)
        ablock = sub_blk.Content.(fields{idx_blk});
		if strcmp(ablock.BlockType, 'Inport')
			block_full_name = regexp(ablock.Origin_path, filesep, 'split');
			block_name = block_full_name{end};
			block_name = strrep(block_name, ' ', '_');
			IO_struct.inputs{cpt_in}.name = block_name;
			IO_struct.inputs{cpt_in}.origin_name = ablock.Origin_path;
			[dim_r dim_c] = Utils.get_port_dims_simple(ablock.CompiledPortDimensions.Outport, 1);
			IO_struct.inputs{cpt_in}.dim_r = dim_r;
			IO_struct.inputs{cpt_in}.dim_c = dim_c;
			inpu_ports_compiled_dt = ablock.CompiledPortDataTypes;
			IO_struct.inputs{cpt_in}.dt = inpu_ports_compiled_dt.Outport;
			cpt_in = cpt_in + 1;
		elseif strcmp(ablock.BlockType, 'Outport')
			block_full_name = regexp(ablock.Origin_path, filesep, 'split');
			block_name = block_full_name{end};
			block_name = strrep(block_name, ' ', '_');
			IO_struct.outputs{cpt_out}.name = block_name;
			IO_struct.outputs{cpt_out}.origin_name = ablock.Origin_path;
			[dim_r dim_c] = Utils.get_port_dims_simple(ablock.CompiledPortDimensions.Inport, 1);
			IO_struct.outputs{cpt_out}.dim_r = dim_r;
			IO_struct.outputs{cpt_out}.dim_c = dim_c;
			cpt_out = cpt_out + 1;
		end
	end

	code_term = sprintf('%s([], [], [], ''term'')', main_model_name);
	eval(code_term);
	warning on;

end


function [IO_struct, found] = parseCEX(cex, IO_struct, origin_path, xml_trace)
	first_cex = cex.item(0); % Only one CounterExample for now, do we will need more ?
    nodes = first_cex.getElementsByTagName('Node');
    prop_name = Utils.name_format(origin_path);  
    prop_name = strrep(prop_name, '/', '_');
	parent_block_name = fileparts(origin_path);
    time_steps = 0;
	found = false;
    
    % Browse through all the nodes
	for idx=0:(nodes.getLength-1)
		node = nodes.item(idx);
        streams = node.getElementsByTagName('Stream');
        for i=0:(streams.getLength-1)
            stream = streams.item(i);
            stream_name = stream.getAttribute('name');
            input_names = cellfun(@(x) x.origin_name, IO_struct.inputs, 'UniformOutput', 0);
			output_names = cellfun(@(x) x.origin_name, IO_struct.outputs, 'UniformOutput', 0);
			%var_name = xml_trace.get_block_name_from_variable(parent_block_name, char(stream_name));
            var_name = strcat(parent_block_name,'/', char(stream_name));
            if numel(find(strcmp(input_names, var_name))) ~= 0
				index = find(strcmp(input_names, var_name));
				[IO_struct.inputs{index}, time_steps] = addValue_IO_struct(IO_struct.inputs{index}, stream, prop_name, time_steps);		
                found = true;
			elseif numel(find(strcmp(output_names, var_name))) ~= 0
				index = find(strcmp(output_names, var_name));
				[IO_struct.outputs{index}, time_steps] = addValue_IO_struct(IO_struct.outputs{index}, stream, prop_name, time_steps);
                found = true;
			end
        end
    end
    
	if ~found
		display_msg('Impossible to parse correctly the generated CEX', Constants.WARNING, 'CEX replay', '');
    end
	IO_struct.time_steps = time_steps;
end


function [out, time_step] = addValue_IO_struct(struct, signal, prop_name, time_steps)
	out = struct;
	values = signal.getElementsByTagName('Value');
    for idx=0:(values.getLength-1)
		val = char(values.item(idx).getTextContent);
		if strcmp(val, 'false')
			out.value(idx+1) = false;
		elseif strcmp(val, 'true')
			out.value(idx+1) = true;
		else
			out.value(idx+1) = str2num(val);
		end
    end

	time_step = max(time_steps, idx);
	out.var_name = sprintf('%s_%s', out.name, prop_name);
end

% Create simulation configuration and attach it to the model
% Saves the simulation input values to an external mat file to ease replay
% TODO: This function structure should be improved
function IO_struct = create_configuration(IO_struct, file, origin_path, mat_file, idx_prop)
	configSet = copy(getActiveConfigSet(file));
	set_param(configSet, 'Solver', 'FixedStepDiscrete');
	set_param(configSet, 'FixedStep', '1.0');
	set_param(configSet, 'SaveState', 'on');
    set_param(configSet, 'SaveOutput', 'on');
	set_param(configSet, 'StateSaveName', 'xout');
	set_param(configSet, 'OutputSaveName', 'yout');
	set_param(configSet, 'StartTime', '0.0');
	set_param(configSet, 'StopTime', [num2str(IO_struct.time_steps + 1) '.0']);
	set_param(configSet, 'SaveFormat', 'Structure');
	set_param(configSet, 'SaveTime', 'on');
    
	prop_name = regexp(origin_path, '/', 'split');
	prop_name = [prop_name{end} '_' num2str(idx_prop)];
    prop_name = Utils.name_format(prop_name);
	IO_struct.prop_name = prop_name;

	IO_struct.prop_name = regexprep(IO_struct.prop_name, '[\s#{}[]&]', '_');
    
	config_var_name = ['Config_' IO_struct.prop_name];
	IO_struct.configSet_name = config_var_name;
	set_param(configSet, 'Name', config_var_name);

	input_struct_name = ['Inputs_' IO_struct.prop_name];
	output_struct_name = ['Outputs_' IO_struct.prop_name];
    
	time_set = sprintf('%s.time = (0:%s);', input_struct_name, num2str(IO_struct.time_steps));
	evalin('base', time_set);
	time_set = sprintf('%s.time = (0:%s);', output_struct_name, num2str(IO_struct.time_steps));
	evalin('base', time_set);
    
    try
        for idx_in=1:numel(IO_struct.inputs)
            var_name = IO_struct.inputs{idx_in}.name;
            value = IO_struct.inputs{idx_in}.value;
            dim_r = IO_struct.inputs{idx_in}.dim_r;
            dim_c = IO_struct.inputs{idx_in}.dim_c;
            dt = char(IO_struct.inputs{idx_in}.dt);
            signals_values_set = sprintf('%s.signals(%s).values = %s(%s)'';', input_struct_name, num2str(idx_in),dt, mat2str(value));
            if dim_r == 1 || dim_c == 1
                signals_dimensions_set = sprintf('%s.signals(%s).dimensions = %d;', input_struct_name, num2str(idx_in), max(dim_r,dim_c));
            else
                signals_dimensions_set = sprintf('%s.signals(%s).dimensions = [%d %d];', input_struct_name, num2str(idx_in), dim_r, dim_c);
            end
            var_name_set = sprintf('%s.signals(%s).var_name = ''%s'';', input_struct_name, num2str(idx_in), var_name);
            
            evalin('base', signals_values_set);
            evalin('base', signals_dimensions_set);
            evalin('base', var_name_set);
        end
        
        a.(input_struct_name) = evalin('base', input_struct_name);
    catch Me
        display_msg('No Input Signal in CEX', Constants.WARNING, 'CEX', '');
    end
    
    try
        for idx_out=1:numel(IO_struct.outputs)
            var_name = IO_struct.outputs{idx_out}.name;
            %ToDo: avoid using the name 'contract/valid', use the parameter
            %ContractBlockType instead
            if contains(IO_struct.outputs{1, 1}.origin_name,'contract/valid')
                value = ones(IO_struct.outputs{idx_out}.dim_r);
                value(end) = 0; % valid is false in the last step
                %value = value';
            else
                value = IO_struct.outputs{idx_out}.value;
            end            
            dim_r = IO_struct.outputs{idx_out}.dim_r;
            dim_c = IO_struct.outputs{idx_out}.dim_c;
            signals_values_set = sprintf('%s.signals(%s).values = %s'';', output_struct_name, num2str(idx_out), mat2str(value));
            if dim_r == 1 || dim_c == 1
                signals_dimensions_set = sprintf('%s.signals(%s).dimensions = %d;', output_struct_name, num2str(idx_out), max(dim_r,dim_c));
            else
                signals_dimensions_set = sprintf('%s.signals(%s).dimensions = [%d %d];', output_struct_name, num2str(idx_out), dim_r, dim_c);
            end
            var_name_set = sprintf('%s.signals(%s).var_name = ''%s'';', output_struct_name, num2str(idx_out), var_name);
            
            evalin('base', time_set);
            evalin('base', signals_values_set);
            evalin('base', signals_dimensions_set);
            evalin('base', var_name_set);
        end
	a.(output_struct_name) = evalin('base', output_struct_name);
    catch
        display_msg('No Outputs Signal in CEX', Constants.WARNING, 'CEX', '');
    end
	
	set_param(configSet, 'ExtMode', 'on');
	set_param(configSet, 'LoadExternalInput', 'on');
	set_param(configSet, 'ExternalInput', input_struct_name);
    
	IO_struct.configSet = configSet;

	% Add the configSet variable to the workspace
	assignin('base', config_var_name, configSet);
	a.(config_var_name) = evalin('base', config_var_name);

	% Save variables to mat file
	save(mat_file, '-struct', 'a');
end

% Add an annotation to display the Counter example replay/config
function [annot_text] = createAnnotation(lustre_file_name, origin_path, IO_struct, config_mat_full_file, path, ir_struct, annot_text)
	% Load cocoSim_path variable
	%load 'tmp_data'   
    pathParts = strsplit(mfilename('fullpath'),'/');
    %set cocoSim_path to be ~/CoCoSim/src
    cocoSim_path = strjoin(pathParts(1 :end - 5), '/');
    

	property_node_name = origin_path;
    
	[lus_dir, file_name, ~] = fileparts(lustre_file_name);
    %header
    css_source = fullfile(cocoSim_path,'backEnd' , 'templates' , 'materialize.css');
	html_text = fileread([cocoSim_path filesep 'backEnd' filesep 'templates' filesep 'header.html']);
    html_text = strrep(html_text, '[css_source]', css_source);
	
   
    
    %title
	title = fileread([cocoSim_path filesep 'backEnd' filesep 'templates' filesep 'title.html']);
	title = strrep(title, '[observer_full_name]', property_node_name);
	annot_text = [annot_text title];
    html_text = [html_text title];
    
	list_title = fileread([cocoSim_path filesep 'backEnd' filesep 'templates' filesep 'list_title.html']);
	list_title = strrep(list_title, '[Title]', 'Actions');
	
	% Define clear, load and replay actions
	actions = createActions(lustre_file_name, origin_path, config_mat_full_file, IO_struct, cocoSim_path);
	list_title_html = strrep(list_title, '[List_Content]', actions);
    html_text = [html_text list_title_html];
    
    title = 'open Counter example actions';
    action = fileread([cocoSim_path filesep 'backEnd' filesep 'templates' filesep 'list_item_mat_code.html']);
    action = strrep(action, '[Item]', title);
    prop_name = Utils.name_format(origin_path);
    prop_name = strrep(prop_name, '/','_');
    html_output = fullfile(lus_dir, strcat(file_name, prop_name,'.html'));
    content = sprintf('open(''%s'')\n;',html_output);
    action = strrep(action, '[Matlab_code]', content);
    list_title_ann = strrep(list_title, '[List_Content]', action);
	annot_text = [annot_text list_title_ann '<br/>'];
    
	footer = fileread([cocoSim_path filesep 'backEnd' filesep 'templates' filesep 'footer.html']);
	
    html_text = [html_text footer];
    %Delete the previous CEX annotations. So the user can run the model many
    %times
	delete(find_system(file_name, 'FindAll', 'on', 'type', 'annotation',...
            'Description', 'CEX'));
% 	annot = Simulink.Annotation([file_name '/Counter example annotation']);
% 
% 	% Find correct position for the annotation
% 	blocks = find_system(file_name, 'SearchDepth', 1, 'FindAll', 'on', 'Type', 'Block');
%     
%     % blocks is array of doubles, not strings
%     %for i=1:numel(blocks)
%     %   blocks(i) = Utils.name_format(blocks(i));
%     %end
% 	positions = cocoget_param(ir_struct, blocks, 'Position');
% 	max_x = 0;
% 	min_x = 0;
% 	min_y = 0;
% 	for idx_pos=1:numel(positions)
% 		max_x = max(max_x, positions{idx_pos}(3));
% 		if idx_pos == 1
% 			min_x = positions{idx_pos}(3);
% 			min_y = positions{idx_pos}(2);
% 		else
% 			min_x = min(min_x, positions{idx_pos}(3));
% 			min_y = min(min_y, positions{idx_pos}(2));
% 		end
% 	end
% 	annot.position = [(max_x + abs(min_x) - 200) min_y];
% 	annot.name = annot_text;
% 	annot.DropShadow = 'on';
% 	annot.ForegroundColor = 'white' ;
%     annot.Description = 'CEX';
% 	annot.BackgroundColor = 'red';
% 	annot.InternalMargins = [5, 5, 5, 5];
% 	annot.Interpreter = 'rich';
    
    %save the annotation as an html file, it is more clear for the user
    % Open file for writing
    fid = fopen(html_output, 'w+');
    if ~strcmp(html_text, '')
        fprintf(fid, html_text);
    end
end

%% Create actions to be added to the generated Annotation as the callback code executed when the hyperlinks are clicked.
function actions = createActions(lustre_file_name, origin_path, config_mat_full_file, IO_struct, cocoSim_path)
	actions = '';
	matlab_code = '';
	[output_full_path, file_name, ext] = fileparts(lustre_file_name);
	pwd_path = pwd;
	if ~strcmp(pwd_path(1), output_full_path(1))
		output_full_path = fullfile(pwd, output_full_path);
		config_mat_full_file = fullfile(pwd, config_mat_full_file);
	end
    
	property_name = origin_path;
	config_name = IO_struct.configSet_name;
    
	% Display values action
    code_display = sprintf('load(''%s'');\n', config_mat_full_file);
    if isfield(IO_struct.outputs{1},'value')
        code_display = app_sprintf(code_display, 'values = {Inputs_%s , Outputs_%s};\n', IO_struct.prop_name, IO_struct.prop_name);
        title = 'Display counter example Input/Output values';
    else
        code_display = app_sprintf(code_display, 'values = {Inputs_%s};\n', IO_struct.prop_name);
        title = 'Display counter example Input values';
    end
    code_display = app_sprintf(code_display, 'addpath(''%s'');\n', output_full_path);
    code_display = app_sprintf(code_display, 'plotting(''CEX values for %s'', values);\n', property_name);
    createMaskAction(title, code_display, origin_path);
    action = createAction(title, code_display, cocoSim_path);
    actions = [actions action];
    add_plotting_function(cocoSim_path, output_full_path);
    
    %Display table action        
    cex_table = fileread([cocoSim_path filesep 'backEnd' filesep 'templates' filesep 'display_cex_table.m']);
    cex_table = strrep(cex_table, '[(matFile)]', config_mat_full_file);
    cex_table = strrep(cex_table, '[(propertyName)]', IO_struct.prop_name);       
    cex_table = strrep(cex_table, '[(originPath)]', origin_path);    
    displayOutput = isfield(IO_struct.outputs{1},'value');
    cex_table = strrep(cex_table, '[(displayOutput)]', num2str(displayOutput));       
    createMaskAction('Display counter example as a table', cex_table, origin_path);
    
	% Clear action
	code_clear = sprintf('%s;\n', 'clear');
	matlab_code = [matlab_code code_clear];

    createMaskAction('Clear workspace', code_clear, origin_path);
	action = createAction('Clear workspace', code_clear, cocoSim_path);
	actions = [actions action];

	% Find system code
	code_find_system = sprintf('%s;\n', 'model = find_system(gcs)');
	matlab_code = [matlab_code code_find_system];

	% Load action
	code_load = sprintf('load(''%s'');\n', config_mat_full_file);
	matlab_code = [matlab_code code_load];

    createMaskAction('Load counter example input values and sim configuration', code_load, origin_path);
	action = createAction('Load counter example input values and sim configuration', code_load, cocoSim_path);
	actions = [actions action];

	% Here we need to know if we are working on the complete system or on a subsystem
	if numel(regexp(origin_path, '/', 'split')) == 2
		main_system_simu = true;
	else
		main_system_simu = false;
	end
    
	if main_system_simu

		% Launch simulation action
		code_launch = sprintf('simOut = sim(model{1},%s);\n',config_name);
        code_launch = app_sprintf(code_launch, 'yout = get(simOut,''yout'');\n', '');
        % fix the dimensionality of yout
        code_launch = app_sprintf(code_launch, 'yout.signals.values=squeeze(yout.signals.values);','');
		code_launch = app_sprintf(code_launch, 'addpath(''%s'');\n', output_full_path);
		code_launch = app_sprintf(code_launch, 'values = {Inputs_%s};\n', IO_struct.prop_name);
  
		for idx_out=1:numel(IO_struct.outputs)
			out = IO_struct.outputs{idx_out};
			code_launch = app_sprintf(code_launch, 'yout.signals(%s).var_name = ''%s'';\n', num2str(idx_out), out.name);
		end
		code_launch = app_sprintf(code_launch, 'values{2} = yout;\n', num2str(numel(IO_struct.inputs) + 1));
		code_launch = app_sprintf(code_launch, 'plotting(''CEX values for %s'', values);\n', property_name);

		action_code = [code_find_system code_launch];
		matlab_code = [matlab_code code_launch];
        createMaskAction('Launch simulation', action_code, origin_path);
		action = createAction('Launch simulation', action_code, cocoSim_path);
		actions = [actions action];

		% Launch all action
        createMaskAction('All', matlab_code, origin_path);
		action = createAction('All', matlab_code, cocoSim_path);
		actions = [actions action];
	else
		% Create CEX Model
        parent_node_name = fileparts(origin_path);
        parent_node_name = Utils.name_format(parent_node_name);
        parent_node_name = strrep(parent_node_name,'/','');
        parent_block_name = fileparts(origin_path);
		code_create_cex_model = sprintf('close_system(''%s'', 0);\n', parent_node_name);
		code_create_cex_model = app_sprintf(code_create_cex_model, 'cex_model = new_system(''%s'');\n', parent_node_name);
		code_create_cex_model = app_sprintf(code_create_cex_model, 'Simulink.SubSystem.copyContentsToBlockDiagram(''%s'', cex_model);\n', parent_block_name);
		code_create_cex_model = app_sprintf(code_create_cex_model, 'open_system(''%s'');\n', parent_node_name);
		code_create_cex_model = app_sprintf(code_create_cex_model, 'save_system(''%s.mdl'');\n', parent_node_name);
		code_create_cex_model = app_sprintf(code_create_cex_model, 'clear cex_model;\n', parent_node_name);

        createMaskAction('Create CEX model for observed subsystem', code_create_cex_model, origin_path);
		action = createAction('Create CEX model for observed subsystem', code_create_cex_model, cocoSim_path);
		actions = [actions action];

		% Launch simulation action
		code_launch = sprintf('cex_model = find_system(''%s'');\n', parent_node_name);
        code_launch = app_sprintf(code_launch,'simOut = sim(''%s'',%s);\n',parent_node_name,config_name);
        code_launch = app_sprintf(code_launch, 'yout = get(simOut,''yout'');\n', '');
        % fix the dimensionality of yout
        code_launch = app_sprintf(code_launch, 'yout.signals.values=squeeze(yout.signals.values);','');
		code_launch = app_sprintf(code_launch, 'addpath(''%s'');\n', output_full_path);
		code_launch = app_sprintf(code_launch, 'values = {Inputs_%s};\n', IO_struct.prop_name);
  
		for idx_out=1:numel(IO_struct.outputs)
			out = IO_struct.outputs{idx_out};
			code_launch = app_sprintf(code_launch, 'yout.signals(%s).var_name = ''%s'';\n', num2str(idx_out), out.name);
		end
		code_launch = app_sprintf(code_launch, 'values{2} = yout;\n', num2str(numel(IO_struct.inputs) + 1));
		code_launch = app_sprintf(code_launch, 'plotting(''CEX values for %s'', values);\n', property_name);
		code_launch = app_sprintf(code_launch, 'clear cex_model;\n');

        createMaskAction('Launch simulation', code_launch, origin_path);
		action = createAction('Launch simulation', code_launch, cocoSim_path);
		actions = [actions action];
        
		code_clean = sprintf('close_system(''%s'');\n', parent_node_name);
		code_clean = app_sprintf(code_clean, 'delete ''%s.mdl'';\n', parent_node_name);
        createMaskAction('Delete CEX model', code_clean, origin_path);
		action = createAction('Delete CEX model', code_clean, cocoSim_path);
		actions = [actions action];

    end
    
    
    if exist('parent_node_name','var') == 0
        parent_node_name = bdroot (gcs);
    end
    inputs_matfile_name = strrep(config_name,'Config','Inputs');
    code_signalBuilder = fileread([cocoSim_path filesep 'backEnd' filesep 'templates' filesep 'signalBuilder.m']);
    code_signalBuilder = strrep(code_signalBuilder, '[(model_name)]', parent_node_name);
    code_signalBuilder = strrep(code_signalBuilder, '[(inputs_matfile_name)]', inputs_matfile_name);       
    createMaskAction('Replace inports with signal builders', code_signalBuilder, origin_path);
    
end

%% Create the html content for one action in the Annotation
function action = createAction(title, content, cocoSim_path)
	action = fileread([cocoSim_path filesep 'backEnd' filesep 'templates' filesep 'list_item_mat_code.html']);
	action = strrep(action, '[Item]', title);
	disp_content = sprintf('disp(''[CEX annotation] (%s) action done'');\n', title);
	content = [content disp_content];
	action = strrep(action, '[Matlab_code]', content);
end

function add_plotting_function(cocoSim_path, path)
	src = [cocoSim_path filesep 'backEnd' filesep 'templates' filesep 'plotting.m'];
	copyfile(src, path);
end

function createMaskAction(title, content, origin_path)
    mask = Simulink.Mask.get(origin_path);    
    name = regexprep(title,'[/\s'']','_');    
    button = mask.addDialogControl('pushbutton', name);
    button.Prompt = title;
    button.Callback = content;    
end