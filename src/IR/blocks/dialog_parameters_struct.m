function [ S ] = dialog_parameters_struct( block_path, block_type )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DIALOG_PARAMETERS_STRUCT - create the internal representation of dialog
% box parameters' blocks
%
%   This function create the structure for the internal representation's
%   dialog box' parameters of a block_type
%   
%   S = DIALOG_PARAMETERS_STRUCT(file_name, block_type)

% load config to filter blocks' params
IR_config;

S = struct();

dialog_param = get_param(block_path, 'DialogParameters');
if ~isempty(dialog_param)
    if isKey(block_param_map, block_type) && isempty(block_param_map(block_type).DialogParameters)
        %do nothing
    elseif isKey(block_param_map, block_type) && ~strcmp(block_param_map(block_type).DialogParameters{1}, 'all')
        %filter with what is in the map
        value = block_param_map(block_type);
        for i=1:numel(value.DialogParameters)
            S.(value.DialogParameters{i}) = get_param(block_path, value.DialogParameters{i});
        end
    else
        %no filter, print all
        fields = fieldnames(dialog_param);
        for i=1:numel(fields)
            S.(fields{i}) = get_param(block_path, fields{i});
        end
    end
end

end

