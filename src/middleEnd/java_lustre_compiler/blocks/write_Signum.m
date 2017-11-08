%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Signum block
%
% For real values provides the output -1, 0, 1, if the input is negative,
% null or positive.
% For complex values computes the values of Input / abs(Input).
%
%% Generation scheme
%
%%% Input is real
% Example provided for a 2 elements vector
%
%  Output_1_1 = if Input_1_1 = zero then zero else if Input_1_1 < zero then -one else one;
%  Output_1_2 = if Input_1_2 = zero then zero else if Input_1_2 < zero then -one else one;
%
%%% Input is complex
% Example provided for a 2 elements vector
%
%  Output_1_1.r = Input_1_1.r / sqrt((Input_1_1.r * Input_1_1.r) + (Input_1_1.i * Input_1_1.i));
%  Output_1_1.i = Input_1_1.i / sqrt((Input_1_1.r * Input_1_1.r) + (Input_1_1.i * Input_1_1.i));
%  Output_1_2.r = Input_1_2.r / sqrt((Input_1_2.r * Input_1_2.r) + (Input_1_2.i * Input_1_2.i));
%  Output_1_2.i = Input_1_2.i / sqrt((Input_1_2.r * Input_1_2.r) + (Input_1_2.i * Input_1_2.i));
%
%% Code
%
function [output_string, var_out] = write_Signum(block, ir_struct, varargin)

output_string = '';
ext_funs = '';

[list_out] = list_var_sortie(block);
[list_in] = list_var_entree(block, ir_struct);

dt = LusUtils.get_lustre_dt(block.CompiledPortDataTypes.Inport(1));
if ~block.CompiledPortComplexSignals.Inport(1)
	if strcmp(dt, 'real')
		zero = '0.0';
		one = '1.0';
	else
		zero = '0';
		one = '1';
	end
	for idx=1:numel(list_out)
		output_string = app_sprintf(output_string, '\t%s = if %s = %s then %s else if %s < %s then -%s else %s;\n', list_out{idx}, list_in{idx}, zero, zero, list_in{idx}, zero, one, one);
	end
else
	for idx=1:numel(list_out)
		sqrt_val = sprintf('%s.r * %s.r + %s.i * %s.i', list_in{idx}, list_in{idx}, list_in{idx}, list_in{idx});
		output_string = app_sprintf(output_string, '\t%s.r = %s.r / sqrt(%s);\n', list_out{idx}, list_in{idx}, sqrt_val);
	end
	ext_funs{1} = ['sqrt ' dt];
end
var_out{1} = 'extern_functions';
var_out{2} = ext_funs;
end
