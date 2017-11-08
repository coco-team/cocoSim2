function [ output_string, var_out ] = write_CoCoSimImplies( block, ir_struct, varargin )
%WRITE_COCOSIMIMPLIES
var_out = {};

output_string = '';

[list_out] = list_var_sortie(block);
[list_in] = list_var_entree(block, ir_struct);

list_in = LusUtils.expand_all_inputs(block, list_in);
for idx_dim=1:block.CompiledPortWidths.Outport
    list_in_nth = LusUtils.get_elem_nth_shift(list_in, idx_dim, block.CompiledPortWidths.Outport(1));
    right_string = Utils.concat_delim(list_in_nth, [' ' '=>' ' ']);
    output_string = app_sprintf(output_string, '\t%s = %s;\n', list_out{idx_dim}, right_string);
end

end

