function [ S ] = subsystems_struct( file_name, is_subsystem )

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
IR_config; %TODO : find a way to charge IR_config only once

%% Construction of the struct
S = struct();

if is_subsystem && strcmp(get_param(file_name, 'Mask'), 'on') && ~strcmp(get_param(file_name, 'MaskType'), '')
    % Masked subsystems
    content = find_system(file_name, 'LookUnderMasks', 'all', 'FollowLinks', 'on');
    content(1) = []; %the first one is file_name, we already have it
else
    % subsystems not masked or block_diagram
    content = find_system(file_name, 'SearchDepth', '1');
    content(1) = []; %the first one is file_name, we already have it
end

% Print of all blocks contained in the subsystem or block_diagram
for i=1:numel(content)
    [parent, sub_name, ~] = fileparts(content{i});
    % TODO : trouver un moyen de faire ça en 2 lignes. Faut-il stocker les
    % noms vu qu'on les perd ?
    sub_name = strrep(sub_name, ' ', '_');
    sub_name = regexprep(sub_name, '\n', '_');
    sub_name = strrep(sub_name, '-', '_');
    sub_name = strrep(sub_name, '(', '');
    sub_name = strrep(sub_name, ')', '');
    
    sub_type = get_param(content{i}, 'BlockType');
    S.(sub_name) = common_struct(content{i});
    if strcmp(get_param(content{i}, 'Mask'), 'on')
        % masked subsystems
        mask_type = get_param(content{i}, 'MaskType');
        S.(sub_name).DialogParameters = dialog_parameters_struct(content{i}, mask_type);
        if isKey(block_param_map, mask_type)
            S.(sub_name).Others = other_parameters(content{i}, mask_type);
        end
    else
        % subsystems not masked or block_diagram
        S.(sub_name).DialogParameters = dialog_parameters_struct(content{i}, sub_type);
        if isKey(block_param_map, sub_type)
            S.(sub_name).Others = other_parameters(content{i}, sub_type);
        end
    end
    if strcmp(sub_type, 'SubSystem')
        S.(sub_name).Content = subsystems_struct(content{i}, true);
    end   
end
end

