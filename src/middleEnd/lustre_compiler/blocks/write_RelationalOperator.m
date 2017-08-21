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
function [output_string, var_out] = write_RelationalOperator(block, ir_struct, varargin)

var_out = {};

operator = block.Operator;

output_string = '';

[list_out] = list_var_sortie(block);
[list_in] = list_var_entree(block, ir_struct);

% Expand inputs if necessary
list_in = LusUtils.expand_all_inputs(block, list_in);

not_op = strcmp(operator, '~=');
if strcmp(operator, '==') || strcmp(operator, '~=')
    operator = '=';
end

is_complex = false;
if block.CompiledPortComplexSignals.Inport(1) || block.CompiledPortComplexSignals.Inport(2)
    is_complex = true;
    dt = LusUtils.get_lustre_dt(block.conversion{1});
    % Convert the real input value to complex if necessary
    if ~block.CompiledPortComplexSignals.Inport(1)
        for idx=1:numel(list_out)
            list_in{idx} = LusUtils.real_to_complex_str(list_in{idx}, dt);
        end
    elseif ~block.CompiledPortComplexSignals.Inport(2)
        for idx=1:numel(list_out)
            list_in{numel(list_in)/2 + idx} = LusUtils.real_to_complex_str(list_in{numel(list_in)/2 + idx}, dt);
        end
    end
end

dim = block.CompiledPortWidths.Outport(1);
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
