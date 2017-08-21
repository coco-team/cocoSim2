%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Trigonometric block
%
% Prints a call to a node to compute the value of the trigonometric
% function. The function name is contained in the op_trigo parameter.
%
%% Generation scheme
%
%%% If the output is real and op_trigo is 'sincos'
%
%  Output_1_1 = sin(Input_1);
%  Output_2_1 = cos(Input_1);
%
%%% If the output is real
%
%  Output_1_1 = op_trigo(Input_1_1);
%
%%% If the output is complex and op_trigo is 'cos + jsin'
%
%  Output_1_1 = complex_real{ r = cos(Input_1_1); i = sin(Input_1_1)};
%
%%% If the output is complex and op_trigo is 'sincos'
%
%  Output_1_1 = sin_complex(Input_1);
%  Output_2_1 = cos_complex(Input_1);
%
%%% If the output is complex
%
%  Output_1_1 = op_trigo_complex(Input_1_1);
%
%% Code
%
function [output_string, var_out] = write_Trigonometry(block, ir_struct, varargin)

output_string = '';
extern_funs = '';

[list_out] = list_var_sortie(block);
[list_in] = list_var_entree(block, ir_struct);

op_trigo = block.Operator;
        
% Expand if necessary
if strcmp(op_trigo, 'atan2')
	list_in = LusUtils.expand_all_inputs(block, list_in);
end

dim = block.CompiledPortWidths.Outport(1);

if ~block.CompiledPortComplexSignals.Outport(1)
	if strcmp(op_trigo, 'atan2')
		for idx_dim=1:numel(list_out)
			in_str = [list_in{idx_dim} ', ' list_in{idx_dim + dim}];
			output_string = app_sprintf(output_string,'\t%s = z%s(%s);\n', list_out{idx_dim}, op_trigo, in_str);
		end
		extern_funs{1} = [op_trigo ' real'];
	elseif strcmp(op_trigo, 'sincos')
		for idx_dim=1:numel(list_in)
			output_string = app_sprintf(output_string,'\t%s = zsin(%s);\n', list_out{idx_dim}, list_in{idx_dim});
			output_string = app_sprintf(output_string,'\t%s = zcos(%s);\n', list_out{idx_dim + dim}, list_in{idx_dim});
		end
		extern_funs{1} = 'cos real';
		extern_funs{2} = 'sin real';
	else
		for idx_dim=1:numel(list_out)
			output_string = app_sprintf(output_string,'\t%s = z%s(%s);\n', list_out{idx_dim}, op_trigo, list_in{idx_dim});
		end
		extern_funs{1} = [op_trigo ' real'];
	end
else
	if strcmp(op_trigo, 'cos + jsin')
		for idx_dim=1:numel(list_in)
			output_string = app_sprintf(output_string,'\t%s = complex_real{ r = zcos(%s); i = zsin(%s)};\n', list_out{idx_dim}, list_in{idx_dim}, list_in{idx_dim});
		end
		extern_funs{1} = 'cos real';
		extern_funs{2} = 'sin real';
	elseif strcmp(op_trigo, 'sincos')
		for idx_dim=1:numel(list_in)
			output_string = app_sprintf(output_string,'\t%s = sin_complex(%s);\n', list_out{idx_dim}, list_in{idx_dim});
			output_string = app_sprintf(output_string,'\t%s = cos_complex(%s);\n', list_out{idx_dim + dim}, list_in{idx_dim});
		end
		extern_funs{1} = 'cos complex';
		extern_funs{2} = 'sin complex';
	else
		for idx_dim=1:numel(list_in)
			output_string = app_sprintf(output_string,'\t%s = %s_complex(%s);\n', list_out{idx_dim}, op_trigo, list_in{idx_dim});
		end
		extern_funs{1} = [op_trigo ' complex'];
	end
end

var_out{1} = 'extern_functions';
var_out{2} = extern_funs;
end
