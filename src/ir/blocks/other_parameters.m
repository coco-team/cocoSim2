function [ S ] = other_parameters( file_name, block_type )

IR_config;

S = struct();

if isKey(block_param_map, block_type)
    value = block_param_map(block_type);
    for i=1:numel(value.Others)
        S.(value.Others{i}) = get_param(file_name, value.Others{i});
    end
end

end