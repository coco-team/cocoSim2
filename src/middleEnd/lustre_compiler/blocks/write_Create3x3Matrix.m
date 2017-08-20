%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [output_string, var_out] = write_Create3x3Matrix(block, ir_struct, varargin)

output_string = '';
var_out = {};

[list_out] = list_var_sortie(block);
[list_in] = list_var_entree(block, ir_struct);

for k1 = 1:numel(list_out)
	output_string = app_sprintf(output_string,'\t%s = %s ;\n',list_out{k1}, list_in{k1});
end
 
end
