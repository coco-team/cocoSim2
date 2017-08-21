function [ output_string, var_out ] = write_ToWorkspace( block, ir_struct, varargin )
%WRITE_TOWORKSPACE
output_string = '';
var_out = {};

warning_msg = ['A ToWorkspace block have been found. No code will be generated for it:\n' block.Origin_path];
display_msg(warning_msg, 2, 'write_code', '');

end

