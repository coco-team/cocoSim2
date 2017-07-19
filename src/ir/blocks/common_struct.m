function [ S ] = common_struct( file_name )
%COMMON_STRUCT
S = struct();
S.path = file_name;
S.BlockType = get_param(file_name, 'BlockType');

ports = get_param(file_name, 'PortConnectivity');
pre = {};
post = {};
for i=1:numel(ports)
    block = get(ports(i).SrcBlock);
    if (~isempty(block))
        pre(numel(pre) + 1) = {block.Name};
    else
        block = get(ports(i).DstBlock);
        post(numel(post) + 1) = {block.Name};
    end
end

S.pre = pre;
S.post = post;

end

