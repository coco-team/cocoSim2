function [ sub_struct ] = get_subsystem_struct( ir_struct, block )
%GET_SUBSYSTEM_STRUCT

% Model_name
block_path = block.Path;
sub_path = fileparts(block_path);
sub_struct = get_struct(ir_struct, sub_path);

end

