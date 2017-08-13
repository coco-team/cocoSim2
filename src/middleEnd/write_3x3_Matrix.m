%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [output_string] = write_3x3_Matrix(unbloc, inter_blk, myblk)

output_string = '';

[list_out] = list_var_sortie(unbloc);
[list_in] = list_var_entree(unbloc,inter_blk, myblk);

for k1 = 1:numel(list_out)
	output_string = app_sprintf(output_string,'\t%s = %s ;\n',list_out{k1}, list_in{k1});
end
 
end