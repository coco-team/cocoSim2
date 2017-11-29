%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [output_string, extern_s_functions_string, extern_functions, properties_nodes, additional_variables, property_node_names, extern_matlab_functions, c_code,external_math_functions] = ...
    write_code(nblk, inter_blk, blks, ir_struct, nom_lustre_file, print_node, trace, xml_trace)

%% Initialisation
write_config;

output_string = '';
extern_s_functions_string = '';
extern_matlab_functions = {};
extern_functions = '';
properties_nodes = '';
cpt_extern_functions = 1;
additional_variables = '';
c_code = '';

pre_annot = '';
post_annot = '';
property_node_names = {};
external_math_functions = [];

%% Treatment for each block
for idx_block=1:nblk
    sub_blk = get_struct(ir_struct, blks{idx_block});
    msg = sprintf('Processing %s:%s', sub_blk.Path, sub_blk.BlockType);
    display_msg(msg, Constants.DEBUG, 'write_code', '');
    
    block_string = '';
    extern_funs = {};
    var_str = '';
    
    %% Set of what will be used to write the block
    % there is special or generic treatment
    % special is if you don't want to respect the inputs/outputs of the
    % generic write_X function.
    special = false;
    func_name = '';
    type = '';
    
    % if you want to make special treatment, you have to set special to
    % 'true' for your special block
    if strcmp(sub_blk.BlockType, 'SubSystem') &&...
            BlockUtils.is_property(sub_blk.MaskType) && ~strcmp(sub_blk.MaskType, '')
        type = sub_blk.MaskType;
        % Special treatment for observer property blocks
        special = true;
    elseif strcmp(sub_blk.BlockType, 'Reference')
        type = sub_blk.SourceType;
    elseif strcmp(sub_blk.BlockType, 'SubSystem') && strcmp(sub_blk.Mask, 'on')
        if ~strcmp(sub_blk.MaskType, '');
            % check if the block is handled
            if isKey(write_func_map, sub_blk.MaskType)
                func_name = write_func_map(type);
            else
                func_name = ['write_' blockType_format(sub_blk.MaskType)];
            end
            if ~exist(func_name, 'file')
                % Block not handled, so we will open it like a SubSystem.
                % The intern blocks may be handled.
                % BlockType is SubSystem here, normally
                type = sub_blk.BlockType;
            else
                %Block handle, direct treatment
                type = sub_blk.MaskType;
            end
        else
            type = sub_blk.BlockType;
        end
    else
        if strcmp(sub_blk.BlockType, 'ModelReference')
            type = 'SubSystem';
        else
            type = sub_blk.BlockType;
        end
    end
    
    if isKey(write_func_map, type)
        func_name = write_func_map(type);
        special = false;
    else
        func_name = ['write_' blockType_format(type)];
    end
    
    %% write each blocks
    %try
    if ~special
        
        % Generic treatment
        
        if exist(func_name, 'file')
            [parent, file_name, ~] = fileparts(func_name);
            PWD = pwd;
            if ~isempty(parent); cd(parent); end
            func_handle = str2func(file_name);
            if ~isempty(parent); cd(PWD); end
            % Add inputs if you need here
            
            [block_string, var_out] = func_handle(sub_blk, ir_struct, xml_trace);
            
        else
            msg= sprintf('No function specified for %s. Be sure to check the output for soundness', func_name);
            display_msg(msg, Constants.WARNING, 'lustre-generator', '');
            block_string = '';
            var_out = {};
        end
        
        %% Varargout treatment
        % Add more varargouts treatment here
        for i=1:2:numel(var_out)
            switch var_out{i}
                case 'extern_functions'
                    extern_funs = var_out{i+1};
                case 'additional_variables'
                    var_str = var_out{i+1};
                case 'extern_s_functions'
                    extern_s_functions_string = [extern_s_functions_string, var_out{i+1}];
                case 'extern_math_functions'
                    external_math_functions = [external_math_functions, var_out{i+1}];
                case 'c_code'
                    c_code = var_out{i+1};
                    % add other case here
                otherwise
                    error('Couple Name-Value not defined in varargout of write_X functions');
            end
        end
    else
        % Special treatment
        if (strcmp(sub_blk.BlockType, 'SubSystem') || strcmp(sub_blk.BlockType, 'ModelReference')) && ~strcmp(sub_blk.MaskType, '')
            
            %%%%%%%%%%%%%%%%%% Observer Property %%%%%%%%%%%%%%%%%
            if BlockUtils.is_property(sub_blk.MaskType)
                try
                    [property_node, ext_node, extern_funs, property_name,external_math_functions_i] = write_Observer(sub_blk, ...
                        ir_struct, nom_lustre_file, trace, xml_trace);
                    
                    properties_nodes = [properties_nodes property_node];
                    extern_s_functions_string = [extern_s_functions_string, ext_node];
                    nb = numel(property_node_names)+1;
                    property_node_names{nb}.prop_name = property_name;
                    property_node_names{nb}.origin_block_name = sub_blk.Origin_path;
                    property_node_names{nb}.annotation = sub_blk.Handle;
                    external_math_functions = [external_math_functions, external_math_functions_i];
                catch ME
                    disp(ME.getReport())
                    if strcmp(ME.identifier, 'MATLAB:badsubscript')
                        msg= 'Bad encoding of the property. Make sure to link the main input of the model into the observer';
                        display_msg(msg, Constants.ERROR, 'cocoSim', '');
                    else
                        display_msg(ME.getReport(), Constants.ERROR, 'cocoSim', '');
                    end
                end
            else
                error_msg = ['Block not handled in the special generation - Type:' sub_blk.MaskType '\n'];
                error_msg = [error_msg '\n' sub_blk.Origin_path];
                display_msg(error_msg, Constants.ERROR, 'write_code', '');
            end
        else
            error_msg = ['Block not handled in the special generation - Type:' sub_blk.BlockType '\n'];
            error_msg = [error_msg '\n' sub_blk.Origin_path];
            display_msg(error_msg, Constants.ERROR, 'write_code', '');
        end
    end
    %catch ME
    %disp(ME);
    %error_msg = ['Block not handled in the generic generation - Type:' func_name(7:end) '\n'];
    %error_msg = [error_msg '\n' sub_blk.Origin_path];
    %display_msg(error_msg, Constants.ERROR, 'write_code', '');
    %end
    
    
    %% Final addition of the block values to the return values %%%%
    
    % Add traceability annotations as comments on the code
    if trace
        [pre_annot post_annot] = traceability_annotation(sub_blk);
    end
    output_string = [output_string pre_annot block_string post_annot];
    
    % Add extern functions to the main return list
    for idx_ext_funs=1:numel(extern_funs)
        extern_functions{cpt_extern_functions} = extern_funs{idx_ext_funs};
        cpt_extern_functions = cpt_extern_functions + 1;
    end
    
    % Add additional variables definitions to the main return string
    if ~strcmp(var_str, '')
        additional_variables = [additional_variables var_str];
    end
end
end