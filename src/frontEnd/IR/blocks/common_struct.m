function [ S ] = common_struct( block_path, model_ref_parent )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMMON_STRUCT - common internal representation for all blocks
%
%   This function create the structure for the internal representation's
%   parameters common to all blocks
%
%   S = COMMON_STRUCT(file_name)

% load config
IR_config;
if nargin < 2
    model_ref_parent = '';
end
unwanted_params = block_param_map('UnwantedParameters');

%% Construction of the internal representation
S = struct();

if ~isempty(model_ref_parent)
    full_path_model_ref = regexp(block_path, '/', 'split');
    full_path_model_ref{1} = model_ref_parent;
    S.Path = IRUtils.name_format(fullfile(full_path_model_ref{1}, full_path_model_ref{2:end}));
else
    S.Path = IRUtils.name_format(block_path); %modified path of the block to be a valid name
end
S.BlockType = get_param(block_path, 'BlockType');
S.Name = get_param(block_path, 'Name');
S.Origin_path = block_path; %origin_path of the block
index = find(strcmp(unwanted_params, 'Handle'), 1);
if isempty(index)
    S.Handle = get_param(block_path, 'Handle');
end
index = find(strcmp(unwanted_params, 'LineHandles'), 1);
if isempty(index)
    S.LineHandles = get_param(block_path, 'LineHandles');
end

%% Common properties added
if isKey(block_param_map, 'CommonParameters')
    values = block_param_map('CommonParameters');
    for i=1:numel(values)
        index = find(strcmp(unwanted_params, values{i}), 1);
        if isempty(index)
            S.(values{i}) = get_param(block_path, values{i});
        end
    end
end

end

