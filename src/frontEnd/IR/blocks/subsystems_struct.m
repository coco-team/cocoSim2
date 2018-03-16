function [ S, all_blocks, subsyst_blocks, handle_struct_map ] = subsystems_struct( block_path, is_subsystem, model_ref_parent )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBSYSTEMS_STRUCT - internal representation of subsystems
%
%   This function construct recursivly the internal representation of
%   subsystems or block_diagrams
%
%   S = SUBSYSTEMS_STRUCT(file_name) for the IR of a simulink block
%   diagrams
%   S = SUBSYSTEMS_STRUT(file_name, is_subsystem) precise if 'file_name' is
%   a subsystem or not. Default value is false.

IR_config;

%% Set of default value
if nargin < 2
    is_subsystem = false;
end
if nargin < 3
    model_ref_parent = '';
end
%% Construction of the struct
S = struct();
all_blocks = {};
handle_struct_map = containers.Map('KeyType','double', 'ValueType','any');
subsyst_blocks = {IRUtils.name_format(block_path)};

% Recovery of all blocks/comments in the subsystem/block_diagram
if is_subsystem && strcmp(get_param(block_path, 'Mask'), 'on')
    % Masked subsystems
    content = find_system(block_path, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'SearchDepth', '1');
    content(1) = []; %the first one is file_name, we already have it
    comment = find_system(block_path, 'FindAll', 'on', 'LookUnderMasks', 'all', 'Type', 'Annotation', 'SearchDepth', '1');
else
    % subsystems not masked or block_diagram
    content = find_system(block_path, 'SearchDepth', '1');
    content(1) = []; %the first one is file_name, we already have it
    comment = find_system(block_path, 'FindAll', 'on', 'Type', 'Annotation');
end

% IR of all comments in the subsystem or block_diagram
if ~isKey(block_param_map, 'Annotation')
    for i=1:numel(comment)
        S.Annotation = comment;
        nom = ['Annotation', num2str(i)];
        S.(nom).Text = get_param(comment(i), 'Text');
        S.(nom).Handle = comment(i);
    end
end

% IR of all blocks contained in the subsystem or block_diagram
for i=1:numel(content)
    all_blocks = [all_blocks, IRUtils.name_format(content(i))];
    [parent, sub_name, ~] = fileparts(content{i});
    sub_name = IRUtils.name_format(sub_name); %modified name to be a valid field name
    sub_type = get_param(content{i}, 'BlockType');    
    % Common IR
    Common = common_struct(content{i}, model_ref_parent);
    
    % Specific IR
    if strcmp(get_param(content{i}, 'Mask'), 'on')
        % masked subsystems
        mask_type = get_param(content{i}, 'MaskType');
        SpecificParameters = specific_parameters_struct(content{i}, mask_type);
        if strcmp(sub_type, 'SubSystem')
            SpecificParameters = catstruct(SpecificParameters, specific_parameters_struct(content{i}, sub_type));
        end
    elseif strcmp(sub_type, 'SubSystem') || strcmp(sub_type, 'ModelReference')
        % non masked subsystems
        mask_type = get_param(content{i}, 'MaskType');
        SpecificParameters = specific_parameters_struct(content{i}, sub_type);
    else
        % other blocks
        SpecificParameters = specific_parameters_struct(content{i}, sub_type);
    end
    
    S.(sub_name) = catstruct(Common, SpecificParameters);
    handle_struct_map(get_param(content{i}, 'Handle')) = S.(sub_name);
    
    % Inner SubSystems/model struct
    if strcmp(sub_type, 'SubSystem') ...
        ||  (  strcmp(get_param(content{i}, 'Mask'), 'on' ) ... % validatr has type 'M-S-Function'
            && ~strcmp(get_param(content{i}, 'MaskType'), 'KindContractValidator'))
        S.(sub_name).Mask = get_param(content{i}, 'Mask');
        S.(sub_name).MaskType = mask_type;        
        if strcmp(S.(sub_name).SFBlockType, 'Chart') && ~isempty(stateflow_treatment)
            if iscell(stateflow_treatment)
                fun_name = stateflow_treatment{1};
            else
                fun_name = stateflow_treatment;
            end
            if exist(fun_name, 'file')
                [parent, file_name, ~] = fileparts(fun_name);
                PWD = pwd;
                if ~isempty(parent); cd(parent); end
                func_handle = str2func(file_name);
                if ~isempty(parent); cd(PWD); end
                S.(sub_name).SFContent = func_handle(content{i});
            else
                S.(sub_name).SFContent = struct();
            end
            S.(sub_name).Content = struct();
        else            
            [S.(sub_name).Content, next_blocks, next_subsyst, handle_struct_map_next] = subsystems_struct(content{i}, true);
            all_blocks = [all_blocks, next_blocks];
            subsyst_blocks = [subsyst_blocks, next_subsyst];
            handle_struct_map = [handle_struct_map; handle_struct_map_next];
        end
        
    elseif strcmp(sub_type, 'ModelReference')
        S.(sub_name).Mask = get_param(content{i}, 'Mask');
        S.(sub_name).MaskType = mask_type;
        model_ref = get_param(content{i}, 'ModelFile');
        load_system(model_ref);
        try
            Cmd = [model_ref, '([], [], [], ''compile'');'];
            eval(Cmd);
        catch
            warning('Simulation of the model referenced failed. The model doesn''t compile.');
        end
        [~, model_name, ~] = fileparts(model_ref);
        [S.(sub_name).Content, next_blocks, next_subsyst, handle_struct_map_next] = subsystems_struct(model_name, false, content{i});
        try
            Cmd = [model_ref, '([], [], [], ''term'');'];
            eval(Cmd);
        catch
            %do nothing
        end
        all_blocks = [all_blocks, next_blocks];
        subsyst_blocks = [subsyst_blocks, next_subsyst];
        handle_struct_map = [handle_struct_map; handle_struct_map_next];
    end
end
end
