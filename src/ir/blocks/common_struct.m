function [ S ] = common_struct( block_path )
% COMMON_STRUCT - common internal representation for all blocks
%
%   This function create the structure for the internal representation's
%   parameters common to all blocks
%
%   S = COMMON_STRUCT(file_name)

%% Construction of the internal representation
S = struct();
S.Path = Utils.name_format(block_path);
S.BlockType = get_param(block_path, 'BlockType');
S.Name = get_param(block_path, 'Name');
S.Handle = get_param(block_path, 'Handle');

% Calculate the id of the pre and post blocks
ports = get_param(block_path, 'LineHandles');

S.Pre = ports.Inport;
S.Post = ports.Outport;

% Calculate the sample time
CompiledSampleTime = get_param(block_path, 'CompiledSampleTime');
S.CompiledSampleTime = CompiledSampleTime(1);
S.CompiledPortDataTypes = get_param(block_path, 'CompiledPortDataTypes');

end

