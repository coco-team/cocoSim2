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
IR_config;

S = struct();

if isKey(block_param_map, block_type)
    value = block_param_map(block_type);
    for i=1:numel(value)
        S.(value{i}) = get_param(block_path, value{i});
    end
else
    % no config, print all dialog parameters
    dialog_param = get_param(block_path, 'DialogParameters');
    fields = fieldnames(dialog_param);
    for i=1:numel(fields)
        S.(fields{i}) = get_param(block_path, fields{i});
    end
end

end