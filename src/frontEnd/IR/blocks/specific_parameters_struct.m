function [ S ] = specific_parameters_struct( block_path, block_type )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPECIFIC_PARAMETERS_STRUCT - create the internal representation of
% specific parameters' blocks
%
%   This function create the structure for the internal representation of the
%   specific parameters of a block_type
%   
%   S = SPECIFIC_PARAMETERS_STRUCT(file_name, block_type)

% load config to filter blocks' params
global block_param_map;
unwanted_params = block_param_map('UnwantedParameters');
S = struct();

if isKey(block_param_map, block_type)
    value = block_param_map(block_type);
    for i=1:numel(value)
        index = find(strcmp(unwanted_params, value{i}), 1);
        if isempty(index)
            S.(value{i}) = get_param(block_path, value{i});
        end
    end
else
    % no filter, print all dialog parameters
    dialog_param = get_param(block_path, 'DialogParameters');
    if ~isempty(dialog_param)
        fields = fieldnames(dialog_param);
        for i=1:numel(fields)
            index = find(strcmp(unwanted_params, fields{i}), 1);
            if isempty(index)
                S.(fields{i}) = get_param(block_path, fields{i});
            end
        end
    end
    % for masked blocks: masked Sum block, add IntrinsicDialogParameters
    intrinsic_dialog_param = get_param(block_path, 'IntrinsicDialogParameters');
    if ~isempty(intrinsic_dialog_param)
        fields = fieldnames(intrinsic_dialog_param);
        for i=1:numel(fields)
            index = find(strcmp(unwanted_params, fields{i}), 1);
            if isempty(index)
                try
                    S.(fields{i}) = get_param(block_path, fields{i});
                catch
                    % ignore
                end
            end
        end
    end
end

end
