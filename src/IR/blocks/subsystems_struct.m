function [ S, all_blocks, subsyst_blocks ] = subsystems_struct( block_path, is_subsystem )
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

%% Set of default value
if nargin < 2
    is_subsystem = false;
end

addpath('../');

%% Construction of the struct
S = struct();
all_blocks = {};
subsyst_blocks = {Utils.name_format(block_path)};

if is_subsystem && strcmp(get_param(block_path, 'Mask'), 'on') && ~strcmp(get_param(block_path, 'MaskType'), '')
    % Masked subsystems
    content = find_system(block_path, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'SearchDepth', '1');
    content(1) = []; %the first one is file_name, we already have it
    comment = find_system(block_path, 'FindAll', 'on', 'Type', 'Annotation');
else
    % subsystems not masked or block_diagram
    content = find_system(block_path, 'SearchDepth', '1');
    content(1) = []; %the first one is file_name, we already have it
    comment = find_system(block_path, 'FindAll', 'on', 'Type', 'Annotation');
end

% IR of all comments in the subsystem or block_diagram
for i=1:numel(comment)
    S.Annotation = comment;
    nom = ['Annotation', num2str(i)];
    S.(nom).Text = get_param(comment(i), 'Text');
    S.(nom).Handle = comment(i);
end

% IR of all blocks contained in the subsystem or block_diagram
for i=1:numel(content)
    all_blocks = [all_blocks, Utils.name_format(content(i))];
    [parent, sub_name, ~] = fileparts(content{i});
    sub_name = Utils.name_format(sub_name);
    
    sub_type = get_param(content{i}, 'BlockType');
    Common = common_struct(content{i});
    if strcmp(get_param(content{i}, 'Mask'), 'on')
        % masked subsystems
        mask_type = get_param(content{i}, 'MaskType');
        SpecificParameters = specific_parameters_struct(content{i}, mask_type);
    else
        % subsystems not masked or block_diagram
        SpecificParameters = specific_parameters_struct(content{i}, sub_type);
    end
    S.(sub_name) = catstruct(Common, SpecificParameters);
    if strcmp(sub_type, 'SubSystem')
        [S.(sub_name).Content, next_blocks, next_subsyst] = subsystems_struct(content{i}, true);
        all_blocks = [all_blocks, next_blocks];
        subsyst_blocks = [subsyst_blocks, next_subsyst];
    elseif strcmp(sub_type, 'ModelReference')
        model_ref = get_param(content{i}, 'ModelFile');
        load_system(model_ref);
        try
            Cmd = [model_ref, '([], [], [], ''compile'');'];
            eval(Cmd);
        catch
            warning('Simulation of the model referenced failed. The model doesn''t compile.');
        end
        [~, model_name, ~] = fileparts(model_ref);
        [S.(sub_name).Content, next_blocks, next_subsyst] = subsystems_struct(model_name);
        try
            Cmd = [model_ref, '([], [], [], ''term'');'];
            eval(Cmd);
        catch
            %do nothing
        end
        all_blocks = [all_blocks, next_blocks];
        subsyst_blocks = [subsyst_blocks, next_subsyst];
    end
end
end

