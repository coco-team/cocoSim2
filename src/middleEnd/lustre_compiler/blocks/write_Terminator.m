function [ output_string, var_out ] = write_Terminator( block, ir_struct, varargin )
%WRITE_TERMINATOR

warning_msg = ['A Terminator block have been found. No code will be generated for it:\n' block.Origin_path];
display_msg(warning_msg, 2, 'write_code', '');

output_string = '';
var_out = {};

end

