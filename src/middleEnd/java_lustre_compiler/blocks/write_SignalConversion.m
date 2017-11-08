%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% SignalConversion block
%
% The mux block is grouping the values on its input as values on its
% output. The backend only consist in assigning the values of the output to
% the values of the inputs. The whole muxing is handled in the generation
% of the names of the variables.
%
%% Code
%
function [output_string, var_out] = write_SignalConversion(block, ir_struct, varargin)

var_out = {};
output_string = '';

[list_out] = list_var_sortie(block);
[list_in] = list_var_entree(block, ir_struct);

for k1 = 1:numel(list_out)
    output_string = app_sprintf(output_string,'\t%s = %s ;\n',list_out{k1}, list_in{k1});
end

error_msg = [' SignalConversion block could be not well translated.\n'];
display_msg(error_msg, Constants.WARNING, 'write_code', '');

end

