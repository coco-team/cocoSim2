%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% SignalSpecification block
%
% This block is used to ensure that an input signal has the correct type.
% It is then used for debug purposes and has no impact on the generated
% code. We thus encode it as a signal.
%
%% Generation scheme
%
%%% 
%
%  Output = Input;
%
%% Code
%
function [output_string, var_out] = write_SignalSpecification(block, ir_struct, varargin)

var_out = {};

output_string = '';

[list_out] = list_var_sortie(block);
[list_in] = list_var_entree(block, ir_struct);

for idx_dim=1:numel(list_out)
	output_string = app_sprintf(output_string, '\t%s = %s;\n', list_out{idx_dim}, list_in{idx_dim});
end

end
