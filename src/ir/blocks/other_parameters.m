function [ S ] = other_parameters( block_path, block_type )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OTHER_PARAMETERS - create the internal representation of misc
% parameters' blocks
%
%   This function create the structure for the internal representation's
%   misc parameters of a block_type
%   
%   S = OTHER_PARAMETERS(file_name, block_type)

% load config to print other parameters
IR_config;

S = struct();

if isKey(block_param_map, block_type)
    % there are 'other' parameters that need to be represented
    value = block_param_map(block_type);
    for i=1:numel(value.Others)
        S.(value.Others{i}) = get_param(block_path, value.Others{i});
    end
end

end