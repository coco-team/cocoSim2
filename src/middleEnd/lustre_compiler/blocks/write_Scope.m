function [ output_string, var_out ] = write_Scope( block, ir_struct, varargin )
%WRITE_SCOPE

warning_msg = ['A Scope block have been found. No code will be generated for it:\n' block.Origin_path];
display_msg(warning_msg, 2, 'write_code', '');

output_string = '';
var_out = {};

end

