function [ S ] = common_struct( file_name )
% COMMON_STRUCT - common internal representation for all blocks
%
%   This function create the structure for the internal representation's
%   parameters common to all blocks
%
%   S = COMMON_STRUCT(file_name)

%% Construction of the internal representation
S = struct();
S.Path = file_name;
S.BlockType = get_param(file_name, 'BlockType');
S.Name = get_param(file_name, 'Name');

% Calculate the name of the pre and post blocks
ports = get_param(file_name, 'PortConnectivity');
pre = {};
post = {};
[parent, ~, ~] = fileparts(file_name);
if ~isempty(ports)
    try
        for i=1:numel(ports)
            block = get(ports(i).SrcBlock);
            if (~isempty(block))
                pre(numel(pre) + 1) = cellstr(cell2mat([cellstr(parent) cellstr('/') {block.Name}]));
            else
                block = get(ports(i).DstBlock);
                post(numel(post) + 1) = cellstr(cell2mat([cellstr(parent) cellstr('/') {block.Name}]));
            end
        end
    catch
        warning('Some ports are not linked.');
    end
end

S.Pre = pre;
S.Post = post;

% Calculate the sample time
CompiledSampleTime = get_param(file_name, 'CompiledSampleTime');
S.CompiledSampleTime = CompiledSampleTime(1);

end

