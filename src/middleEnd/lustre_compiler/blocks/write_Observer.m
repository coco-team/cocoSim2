%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Property block
%
% This block is special as it prints a complete node containing the
% computation for the inside of the Property block. It thus calls the
% write_code function. A limitation is that a Property block cannot be
% included inside a Property node.
% The Property node as exaclty the same inputs as the observed subsystem.
% These inputs are used in an additional line of code at the end calling the
% node in which the Property block is embedded. The outputs of this call
% are used for the values of the inputs of the Property that are connected
% to outputs of the enclosing block.
% In addition, the generated node (property_node) will be ended with a set
% of annotations: --! Property: Output{i} = true; for each output of the
% property node. As a limitation, the number of outputs is necessarily one
% in order to be able to actually do the verification with Zustre.
%
%% Generation scheme
% We take the example of a Property node with two scalar inputs and one
% boolean output.
%
%  node Property_Name (in1: in_1_dt; in2: in_2_dt)
%  returns (out1: out_1_dt)
%  let
%     ... classical node code with ParentBlockOutput_1_1 used ...
%     ParentBlockOutput_1_1 = ParentBlock (in1, in2);
%     --! Property: out1 = true;
%  tel
%
%% Code
%

function [property_node,extern_s_functions_string, extern_functions, node_call_name, external_math_functions] = ...
    write_Observer(block, ir_struct, nom_lustre_file, trace, xml_trace)

annot_type = block.AnnotationType;
observer_type = block.ObserverType;
inter_blk = get_subsystem_struct(ir_struct, block);

try
    property_node = '';
    extern_functions = '';
    xml_trace_node = '';
    
    [list_out] = list_var_sortie(block);
    [original_list_in] = list_var_entree(block, ir_struct);
    
    % Get the observer block
    % inter_blk = subsystem de block
    %obs_idx_subsys = get_subsys_index(myblk, block.Origin_path);
    %obs_inter_blk = myblk{obs_idx_subsys};
    fields = fieldnames(block.Content);
    fields(cellfun('isempty', regexprep(fields, '^Annotation.*', ''))) = [];
    obs_nblk = numel(fields);
    obs_blks = {};
    for i=1:numel(fields)
        obs_blks = [obs_blks block.Content.(fields{i}).Path];
    end
    % Get parent subsystem
    parent_subsystem = inter_blk;
    full_observer_name = regexp(block.Origin_path, filesep, 'split');
    if numel(full_observer_name(1:end-1)) == 1%%
        %	parent_subsystem = myblk;
        [~, parent_node_name, ~] = fileparts(nom_lustre_file);
    else
        %	idx_parent_subsystem = get_subsys_index(myblk, Utils.concat_delim(full_observer_name{1}(1:end-1), filesep));
        if idx_parent_subsystem == 0
            %        idx_parent_subsystem = 1;
            %        parent_subsystem = myblk{idx_parent_subsystem};
            [~, parent_node_name, ~] = fileparts(nom_lustre_file);
        else
            %        parent_subsystem = myblk{idx_parent_subsystem};
            %        full_parent_name = regexp(parent_subsystem{1}.name, '/', 'split');
            parent_node_name = Utils.concat_delim(inter_blk.Path, '_');
        end
    end
    
    % Prepare observer node header
    blk_path_elems = regexp(block.Path, filesep, 'split');
    node_call_name = Utils.concat_delim(blk_path_elems, '_');
    
    header = sprintf('node %s (',node_call_name);
    
    xml_trace_node = xml_trace.create_Node_Element(block.Origin_path, node_call_name);
    
    cpt_in = 1;
    cpt_not_in = 1;
    list_in = '';
    list_in_header = '';
    obs_inputs_outputs_idxs = '';
    obs_inputs_outputs_dims = '';
    obs_inputs_outputs_dt = '';
    assertions = '';
    
    % Get observer inputs
    obs_inputs_pre_as_inport = {};
    for idx_in=1:numel(block.Pre)
        inport_block = block.Content.(fields{idx_in});
        pre_block = get_struct(ir_struct, block.Pre(idx_in));
        in_type = pre_block.BlockType;
        inport_block_full_name = regexp(inport_block.Path, filesep, 'split');
        pre_block_level = pre_block.name_level;
        preceding_block_name = Utils.concat_delim(inport_block_full_name(end - pre_block_level : end), '_');
        
        if strcmp(in_type, 'Inport')
            if cpt_in == 1
                % Create the "Inputs" traceability information element
                xml_trace.create_Inputs_Element();
            end
            % Get the number of the inport block connected to this input of the observer
            number = str2num(pre_block.Port);
            for idx_dim=1:block.CompiledPortWidths.Inport(idx_in)
                list_in{cpt_in} = [preceding_block_name '_' num2str(block.PortConnectivity(idx_in).SrcPort + 1) '_' num2str(idx_dim)];
                list_in_header{cpt_in} = [list_in{cpt_in} ' : ' LusUtils.get_lustre_dt(block.CompiledPortDataTypes.Inport(idx_in))];
                %			list_in_to_delete = find(strcmp(list_in{cpt_in}, original_list_in));
                %			if numel(list_in_to_delete) > 0
                %				original_list_in(list_in_to_delete(1)) = [];
                %			end
                obs_inputs_pre_as_inport{number}{idx_dim} = list_in{cpt_in};
                
                % Add trace
                xml_trace.add_Input(list_in{cpt_in}, inport_block.Origin_path, 1, idx_dim);
                
                cpt_in = cpt_in + 1;
            end
        else
            
            % Keep track of the inputs that are not plugged on inputs of the observed block
            %pre_block_idx = get_block_index(parent_subsystem, cocoget_param(ir_struct, block.Pre(idx_in), 'Path'));
            pre_block = get_struct(ir_struct, block.Pre(idx_in));
            pre_block_out_idx = block.PortConnectivity(idx_in).SrcPort+1;
            
            % Get the number of the outport on which the observer input is connected on the observed block
            type = cocoget_param(ir_struct, pre_block.Post, 'BlockType');
            outport_index = find(strcmp(type, 'Outport'));
            post_id = pre_block.Post(outport_index);
            pre_outport_block = get_struct(ir_struct, post_id);
            
            %pre_outport_block_idx = get_block_index(parent_subsystem, parent_subsystem{pre_block_idx}.postname{pre_block_out_idx}(outport_index(1)));
            number = str2num(pre_outport_block.Port);
            
            input_dt = LusUtils.get_lustre_dt(block.CompiledPortDataTypes.Inport(idx_in));
            input_block = block.Content.(fields{idx_in});
            input_block_full_name = regexp(input_block.Path, filesep, 'split');
            input_block_level = LusUtils.get_pre_block_level(input_block.Path, inter_blk);
            input_block_name = Utils.concat_delim(input_block_full_name(end - input_block_level : end), '_');
            
            str = '';
            cpt_str = 1;
            for idx_dim=1:input_block.CompiledPortWidths.Outport(1)
                % We order the outputs according to the number of the port in the observed subsystem
                list_in_outport{cpt_not_in} = [input_block_name '_1_' num2str(idx_dim)];
                list_in_outport_parent_call_declaration{cpt_not_in} = [list_in_outport{cpt_not_in} ' : ' input_dt];
                
                obs_inputs_pre_as_outport{number}{idx_dim} = list_in_outport{cpt_not_in};
                
                % Add trace
                xml_trace.add_Input(list_in_outport{cpt_not_in}, inport_block.Origin_path, 1, idx_dim);
                
                cpt_not_in = cpt_not_in + 1;
            end
            %		obs_inputs_outputs_idxs{cpt_not_in} = idx_in;
            %		obs_inputs_outputs_dims{cpt_not_in} = block.CompiledPortWidths.Inport(idx_in);
            %		obs_inputs_outputs_dt{cpt_not_in} = LusUtils.get_lustre_dt(block.CompiledPortDataTypes.Inport{idx_in});
        end
    end
    
    
    % Add potentially missing outport of the observed subsystem
    unused_outports_variables = '';
    fields = fieldnames(parent_subsystem.Content);
    fields(cellfun('isempty', regexprep(fields, '^Annotation.*', ''))) = [];
    for idx_parent_blocks=1:numel(fields)
        if strcmp(parent_subsystem.Content.(fields{idx_parent_blocks}).BlockType, 'Outport')
            outport = parent_subsystem.Content.(fields{idx_parent_blocks});
            number = str2num(outport.Port);
            if numel(obs_inputs_pre_as_outport) < number || numel(obs_inputs_pre_as_outport{number}) == 0
                outport_block_full_name = regexp(outport.Path, filesep, 'split');
                outport_block_name = Utils.concat_delim(outport_block_full_name(end - 1 : end), '_');
                outport_dt = LusUtils.get_lustre_dt(outport.CompiledPortDataTypes.Inport(1));
                for idx_dim=1:outport.CompiledPortWidths.Inport(1)
                    outport_var_name = [outport_block_name '_1_' num2str(idx_dim)];
                    outport_var_declaration = [outport_var_name ' : ' outport_dt];
                    obs_inputs_pre_as_outport{number}{idx_dim} = outport_var_name;
                    unused_outports_variables{numel(unused_outports_variables) + 1} = outport_var_declaration;
                end
            end
        end
    end
    
    inputs_string = Utils.concat_delim(list_in_header, '; ');
    header = app_sprintf(header, '%s)\nreturns (', inputs_string);
    
    % Get observers outputs
    list_output = '';
    list_outputs = '';
    list_output_names = '';
    cpt_outports = 0;
    fields = fieldnames(block.Content);
    fields(cellfun('isempty', regexprep(fields, '^Annotation.*', ''))) = [];
    for idx_block=1:obs_nblk
        ablock = get_struct(ir_struct, block.Content.(fields{idx_block}).Path);
        if strcmp(ablock.BlockType, 'Outport')
            if cpt_outports == 0
                % Create the "Outputs" traceability information element
                xml_trace.create_Outputs_Element();
            end
            cpt_outports = cpt_outports + 1;
            block_name = regexp(ablock.Path, filesep, 'split');
            for k2=1:ablock.CompiledPortWidths.Inport
                list_output_names{k2} = [block_name{end} '_' ablock.Port '_' num2str(k2)];
                outport_dt = LusUtils.get_lustre_dt(ablock.CompiledPortDataTypes.Inport(1));
                list_output{k2} = [list_output_names{k2} ' : ' outport_dt];
                
                % Add trace
                xml_trace.add_Output(list_output_names{k2}, ablock.Origin_path, 1, k2);
            end
            list_outputs{cpt_outports} = Utils.concat_delim(list_output, '; ');
            
            clear list_output
        end
    end
    list_output = Utils.concat_delim(list_outputs, ';\n\t');
    header = app_sprintf(header, '%s);\n', list_output);
    
    % Get observer variables
    cpt_var=1;
    cptn=1;
    header = app_sprintf(header, 'var\n');
    for idx_block=1:obs_nblk
        ablock = get_struct(ir_struct, block.Content.(fields{idx_block}).Path);
        list_output = '';
        noutput = ablock.Ports(2);
        % Only for the blocks that are not fby
        if noutput ~= 0 && ~strcmp(ablock.BlockType, 'Inport')
            if cpt_var == 1
                % Create the "Variables" traceability information element
                xml_trace.create_Variables_Element();
            end
            list_output = list_var_input(ablock, xml_trace, 'Variable');
            list_output_final = Utils.concat_delim(list_output, '; ');
            header = app_sprintf(header, '\t%s;\n', char(list_output_final));
            cpt_var = cpt_var+1;
        end
    end
    
    
    % Get cocospec
    assertions = convert_cocospec(block, list_in, list_in_outport, xml_trace, ir_struct);
    
    % Add the additional variables for the output of the call to the observed system
    inputs_str = Utils.concat_delim(list_in_outport_parent_call_declaration, ';\n\t');
    header = app_sprintf(header, '\t%s;\n', inputs_str);
    
    % Also add the unused ones
    if numel(unused_outports_variables) ~= 0
        unused_vars_str = Utils.concat_delim(unused_outports_variables, ';\n\t');
        header = app_sprintf(header, '\t%s;\n', unused_vars_str);
    end
    %cpt = 1;
    %for idx_add_inputs=1:numel(obs_inputs_outputs_idxs)
    %	str = '';
    %	cpt_str = 1;
    %	input_dt = obs_inputs_outputs_dt{idx_add_inputs};
    %	input_block = obs_inter_blk{obs_inputs_outputs_idxs{idx_add_inputs} + 1};
    %	input_block_full_name = regexp(input_block.name, '/', 'split');
    %	pre_block_level = LusUtils.get_pre_block_level(input_block.name, obs_inter_blk);
    %	input_block_name = Utils.concat_delim(input_block_full_name{1}(end - pre_block_level : end), '_');
    %
    %	for idx_add_inputs_dim=0:(obs_inputs_outputs_dims{idx_add_inputs}-1)
    %		% We order the outputs according to the number of the port in the observed subsystem
    %		str{cpt_str} = sprintf('%s : %s', var_out_names{parent_sub_outport_number}, input_dt);
    %		cpt_str = cpt_str + 1;
    %	end
    %	inputs_str = Utils.concat_delim(str, '; ');
    %	header = app_sprintf(header, '\t%s;\n', inputs_str);
    %end
    %
    
    % Get observer content code
    let_tel_code_string = '';
    extern_s_functions_string = '';
    extern_functions = '';
    properties_nodes = '';
    additional_variables = '';
    
    [let_tel_code_string, extern_s_functions_string, extern_functions, properties_nodes, additional_variables, external_math_functions] = ...
        write_code(obs_nblk, inter_blk, obs_blks, ir_struct, nom_lustre_file, false, trace, xml_trace);
    
    header = app_sprintf(header, additional_variables);
    header = app_sprintf(header, '\t%s;\n', 'i_virtual_local : real');
    let_tel_code_string = app_sprintf(let_tel_code_string, '\t%s;\n', 'i_virtual_local= 0.0 -> 1.0');
    
    property_node = app_sprintf(header, 'let\n%s%s', assertions, let_tel_code_string);
    
    % Print the inputs of the call to the observed system
    list_parent_call_in_array = '';
    for idx_in=1:numel(obs_inputs_pre_as_inport)
        list_parent_call_in_array{idx_in} = Utils.concat_delim(obs_inputs_pre_as_inport{idx_in}, ', ');
    end
    list_parent_call_in = Utils.concat_delim(list_parent_call_in_array, ', ');
    
    % Add call to observed node
    list_parent_call_out_array = '';
    % More than one input
    multiple = (numel(obs_inputs_pre_as_outport) > 1);
    for idx_out=1:numel(obs_inputs_pre_as_outport)
        list_parent_call_out_array{idx_out} = Utils.concat_delim(obs_inputs_pre_as_outport{idx_out}, ', ');
        if numel(obs_inputs_pre_as_outport{idx_out}) > 1
            % An input has multiple dimensions
            multiple = true;
        end
    end
    list_parent_call_out = Utils.concat_delim(list_parent_call_out_array, ', ');
    
    if multiple
        list_parent_call_out = ['(' list_parent_call_out ')'];
    end
    property_node = app_sprintf(property_node, '\n\t%s = %s(%s);\n', list_parent_call_out, parent_node_name, list_parent_call_in);
    
    
    % Add property
    for idx_prop=1:numel(list_output_names)
        
        prop_str = sprintf('\t--%%%%%%%%PROPERTY %s; \n \ntel\n\n', list_output_names{idx_prop});
        
        property_node = app_sprintf(property_node, prop_str);
    end
catch ME
    disp(ME.getReport())
    if strcmp(ME.identifier, 'MATLAB:badsubscript')
        msg= 'Bad encoding of the property. Make sure to link the main input of the model into the observer';
        display_msg(msg, Constants.ERROR, 'cocoSim', '');
        
    else
        display_msg(ME.getReport(), Constants.ERROR, 'cocoSim', '');
    end
end
end

