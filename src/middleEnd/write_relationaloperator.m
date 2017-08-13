%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Relational Operator block
%
% Applies the relational operation specified in the operator parameter to
% the inputs of the block. If the comparison is done between complex values
% then only == and ~= operators are allowed and we compare separately the
% real and imaginary parts.
%
%% Generation scheme
% We take the example of scalar values comparisons
%
%%% If the inputs are real and operator is ~=
%
%  Output_1_1 = not (Input_1_1 = Input_2_1);
%
%%% If the inputs are real, op is ==, <=, <, >, >=
%
%  Output_1_1 = Input_1_1 op Input_2_1;
%
%%% If the inputs are complex and operator is ~=
%
%  Output_1_1 = not (Input_1_1.r = Input_2_1.r) and not (Input_1_1.i = Input_2_1.i);
%
%%% If the inputs are real and operator is ==
%
%  Output_1_1 = (Input_1_1.r = Input_2_1.r) and (Input_1_1.i = Input_2_1.i);
%
%% Code
%
function [output_string] = write_relationaloperator(unbloc, operator, inter_blk, myblk)

output_string = '';

[list_out] = list_var_sortie(unbloc);
[list_in] = list_var_entree(unbloc, inter_blk, myblk);

% Expand inputs if necessary
list_in = Utils.expand_all_inputs(unbloc, list_in);

not_op = strcmp(operator, '~=');
if strcmp(operator, '==') || strcmp(operator, '~=')
	operator = '=';
end

is_complex = false;
if unbloc.CompiledPortComplexSignals.Inport(1) || unbloc.CompiledPortComplexSignals.Inport(2)
	is_complex = true;
	dt = Utils.get_lustre_dt(unbloc.conversion{1});
	% Convert the real input value to complex if necessary
	if ~unbloc.CompiledPortComplexSignals.Inport(1)
		for idx=1:numel(list_out)
			list_in{idx} = Utils.real_to_complex_str(list_in{idx}, dt);
		end
	elseif ~unbloc.CompiledPortComplexSignals.Inport(2)
		for idx=1:numel(list_out)
			list_in{numel(list_in)/2 + idx} = Utils.real_to_complex_str(list_in{numel(list_in)/2 + idx}, dt);
		end
	end
end

dim = unbloc.CompiledPortWidths.Outport(1);
for idx_out=1:numel(list_out)
	output_string = app_sprintf(output_string,'\t%s = ', list_out{idx_out});
	if is_complex
		if not_op
			output_string = app_sprintf(output_string, 'not(%s.r %s %s.r) and not(%s.i %s %s.i);\n', list_in{idx_out}, operator, list_in{idx_out + dim}, list_in{idx_out}, operator, list_in{idx_out + dim});
		else
			output_string = app_sprintf(output_string, '(%s.r %s %s.r) and (%s.r %s %s.r) ;\n', list_in{idx_out}, operator, list_in{idx_out + dim}, list_in{idx_out}, operator, list_in{idx_out + dim});
		end
	else
		if not_op
			output_string = app_sprintf(output_string, 'not(%s %s %s);\n', list_in{idx_out}, operator, list_in{idx_out + dim});
		else
			output_string = app_sprintf(output_string, '%s %s %s;\n', list_in{idx_out}, operator, list_in{idx_out + dim});
		end
	end
end

end
