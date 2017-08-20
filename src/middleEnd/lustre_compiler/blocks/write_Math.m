%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Math block
%
% Computes the value of the mathematical function. Handled mathematical
% functions are:
%
%%% For real numbers
%
% * sqrt, rSqrt, signedSqrt
% * exp, log, log10, mod, rem, 10^u, square, magnitude^2, reciprocal, conj, hypot
%
%%% For complex numbers
%
% * magnitude^2, exp, log, 10^u, square, log10, pow, conj, reciprocal, hypot
%
%% Generation scheme
%
%%% Native handling of functions on real inputs
%
%%% + square and magnitude^2
%
%  Output_1_1 = Input_1_1 * Input_1_1;
%
%%% + reciprocal
%
%  Output_1_1 = one / Input_1_1;
%
%%% + conjugate
%
%  Output_1_1 = Input_1_1;
%
%%% Native handling of functions on complex inputs
%
%%% + magnitude^2
%
%  Output_1_1 = Input_1_1.r * Input_1_1.r + Input_1_1.i * Input_1_1.i;
%
%%% + square
%
%  Output_1_1.r = Input_1_1.r * Input_1_1.r - Input_1_1.i * Input_1_1.i;
%  Output_1_1.i = two * Input_1_1.r * Input_1_1.i;
%
%%% + conjugate
%
%  Output_1_1.r = Input_1_1.r;
%  Output_1_1.i = -Input_1_1.i;
%
%%% + reciprocal
%
%  Output_1_1.r = Input_1_1.r / (Input_1_1.r * Input_1_1.r - Input_1_1.i * Input_1_1.i);
%  Output_1_1.i = -Input_1_1.i / (Input_1_1.r * Input_1_1.r - Input_1_1.i * Input_1_1.i);
%
%% For all the others functions, calls to external functions are used.
%% Code
%
function [output_string, var_out] = write_Math(block, ir_struct, varargin)

math_op = block.Operator;
if strcmp(math_op, 'hermitian') || strcmp(math_op, 'transpose')
    error_msg = ['Unhandled Math block operation: ' math_op];
    error_msg = [error_msg '\n' block.Origin_path];
    display_msg(error_msg, Constants.ERROR, 'write_code', '');
end

output_string = '';
extern_funs = {};

[list_out] = list_var_sortie(block);
[list_in] = list_var_entree(block, ir_struct);

if block.Ports(1) == 2
    list_in = LusUtils.expand_all_inputs(block, list_in);
end

% Handle output data type for Sqrt functions
convert_fun = '';
needs_convert = false;
if strcmp(math_op, 'sqrt') || strcmp(math_op, 'rSqrt') || strcmp(math_op, 'signedSqrt')
	out_dt = LusUtils.get_lustre_dt(block.CompiledPortDataTypes.Outport(1));
    in_dt = LusUtils.get_lustre_dt(block.CompiledPortDataTypes.Inport(1));
% 	if ~strcmp('real', out_dt) &&  ~(strcmp('int', in_dt) || strcmp('bool', in_dt))
% 		convert_fun = get_param(unbloc.annotation, 'RndMeth');
% 		needs_convert = true;
% 		if exist('tmp_dt_conv.mat', 'file') == 2
% 			load 'tmp_dt_conv'
% 			if exist('rounding', 'var')
% 				rounding = [rounding ' ' convert_fun];
% 			else
% 				rounding = convert_fun;
% 			end
% 			save('tmp_dt_conv.mat', 'rounding', '-append');
% 		else
% 			rounding = convert_fun;
% 			save('tmp_dt_conv.mat', 'rounding');
%         end
%     end
    if strcmp('int', out_dt)
        needs_convert = true;
        convert_fun = 'real_to_int';
        real_to_int = convert_fun;
        if exist('tmp_dt_conv.mat', 'file') == 2
            save('tmp_dt_conv.mat', 'real_to_int', '-append');
        else
            save('tmp_dt_conv.mat', 'real_to_int');
        end
    end
end

dim = block.CompiledPortWidths.Outport(1);
if iscell(block.CompiledPortDataTypes.Outport)
    dt = block.CompiledPortDataTypes.Outport{1};
else
    dt = block.CompiledPortDataTypes.Outport(1);
end
out_dt_lus = LusUtils.get_lustre_dt(dt);

is_complex = block.CompiledPortComplexSignals.Outport(1) || block.CompiledPortComplexSignals.Inport(1);

if ~is_complex
    % Output is not complex
	if strcmp(math_op, 'sqrt') 
		for idx_dim=1:dim
			if needs_convert
				output_string = app_sprintf(output_string, '\t%s = %s(%s(%s));\n', list_out{idx_dim}, convert_fun, math_op, list_in{idx_dim});
			else
				output_string = app_sprintf(output_string, '\t%s = %s(%s);\n', list_out{idx_dim}, math_op, list_in{idx_dim});
			end
		end
		extern_funs{1} = sprintf('%s double', math_op);
    elseif strcmp(math_op, 'rSqrt')
		for idx_dim=1:dim
			if needs_convert
				output_string = app_sprintf(output_string, '\t%s = %s(1.0/sqrt(%s));\n', list_out{idx_dim}, convert_fun, list_in{idx_dim});
			else
				output_string = app_sprintf(output_string, '\t%s = 1.0/sqrt(%s);\n', list_out{idx_dim}, list_in{idx_dim});
			end
		end
		extern_funs{1} = sprintf('%s double', math_op);
	elseif strcmp(math_op, 'signedSqrt')
		if strncmp(block.CompiledPortDataTypes.Inport(1), 'int', 3) || strncmp(block.CompiledPortDataTypes.Inport(1), 'uint', 4)
			zero = '0';
		else
			zero = '0.0';
		end
		for idx_dim=1:dim
			if needs_convert
				output_string = app_sprintf(output_string, '\t%s = %s(if %s >= %s then sqrt(%s) else -sqrt(-%s));\n', list_out{idx_dim}, convert_fun, list_in{idx_dim}, zero, list_in{idx_dim}, list_in{idx_dim});
			else
				output_string = app_sprintf(output_string, '\t%s = if %s >= %s then sqrt(%s) else -sqrt(-%s);\n', list_out{idx_dim}, list_in{idx_dim}, zero, list_in{idx_dim}, list_in{idx_dim});
			end
		end
		extern_funs{1} = sprintf('sqrt double');
    elseif strcmp(math_op, 'exp') || strcmp(math_op, 'log') || strcmp(math_op, 'log10')
        for idx_dim=1:dim
            output_string = app_sprintf(output_string, '\t%s = %s(%s);\n', list_out{idx_dim}, math_op, list_in{idx_dim});
        end
        extern_funs{1} = sprintf('%s %s', math_op, dt);
    elseif strcmp(math_op, 'mod') && strcmp(LusUtils.get_lustre_dt(dt), 'int')
        for idx_dim=1:dim
            output_string = app_sprintf(output_string, '\t%s = %s mod %s;\n', list_out{idx_dim}, list_in{idx_dim}, list_in{idx_dim + dim});
        end
    elseif strcmp(math_op, 'mod')
        for idx_dim=1:dim
            output_string = app_sprintf(output_string, '\t%s = modulo(%s, %s);\n', list_out{idx_dim}, list_in{idx_dim}, list_in{idx_dim + dim});
        end
        extern_funs{1} = sprintf('modulo %s', dt);
    elseif strcmp(math_op, 'rem') || strcmp(math_op, 'pow')
        for idx_dim=1:dim
            output_string = app_sprintf(output_string, '\t%s = %s(%s, %s);\n', list_out{idx_dim}, math_op, list_in{idx_dim}, list_in{idx_dim + dim});
        end
        extern_funs{1} = sprintf('%s %s', math_op, dt);
    elseif strcmp(math_op, '10^u')
        for idx_dim=1:dim
            output_string = app_sprintf(output_string, '\t%s = ArrayPowerBase10(%s);\n', list_out{idx_dim}, list_in{idx_dim});
        end
        extern_funs{1} = sprintf('ArrayPowerBase10 %s', dt);
    elseif strcmp(math_op, 'square')
        for idx_dim=1:dim
            output_string = app_sprintf(output_string, '\t%s = %s * %s;\n', list_out{idx_dim}, list_in{idx_dim}, list_in{idx_dim});
        end
    elseif strcmp(math_op, 'magnitude^2')
        % Same as square as we are working on non-complex values
        for idx_dim=1:dim
            output_string = app_sprintf(output_string, '\t%s = %s * %s;\n', list_out{idx_dim}, list_in{idx_dim}, list_in{idx_dim});
        end
    elseif strcmp(math_op, 'reciprocal')
        if strcmp(LusUtils.get_lustre_dt(dt), 'int')
            one = '1';
        else
            one = '1.0';
        end
        for idx_dim=1:dim
            output_string = app_sprintf(output_string, '\t%s = %s / %s;\n', list_out{idx_dim}, one, list_in{idx_dim});
        end
    elseif strcmp(math_op, 'conj')
        for idx_dim=1:dim
            output_string = app_sprintf(output_string, '\t%s = %s;\n', list_out{idx_dim}, list_in{idx_dim});
        end
    elseif strcmp(math_op, 'hypot')
        for idx_dim=1:dim
            in1_str = list_in{idx_dim};
            in2_str = list_in{idx_dim + dim};
            in1_square = sprintf('(%s * %s)', in1_str, in1_str);
            in2_square = sprintf('(%s * %s)', in2_str, in2_str);
            output_string = app_sprintf(output_string, '\t%s = sqrt(%s + %s);\n', list_out{idx_dim}, in1_square, in2_square);
        end
        extern_funs{1} = sprintf('sqrt %s', dt);
    end
else
    % Output is complex
    if strcmp(math_op, 'magnitude^2')
        for idx_dim=1:dim
            output_string = app_sprintf(output_string, '\t%s = %s.r * %s.r + %s.i * %s.i;\n', list_out{idx_dim}, list_in{idx_dim}, list_in{idx_dim}, list_in{idx_dim}, list_in{idx_dim});
        end
    elseif strcmp(math_op, 'exp')
        for idx_dim=1:dim
            output_string = app_sprintf(output_string, '\t%s.r = exp(%s.r) * cos(%s.i);\n', list_out{idx_dim}, list_in{idx_dim}, list_in{idx_dim});
            output_string = app_sprintf(output_string, '\t%s.i = exp(%s.r) * sin(%s.i);\n', list_out{idx_dim}, list_in{idx_dim}, list_in{idx_dim});
        end
        extern_funs{1} = sprintf('exp %s', out_dt_lus);
        extern_funs{2} = sprintf('cos %s', out_dt_lus);
        extern_funs{3} = sprintf('sin %s', out_dt_lus);
    elseif strcmp(math_op, 'log')
        for idx_dim=1:dim
            output_string = app_sprintf(output_string, '\t%s.r = log(%s.r * %s.r + %s.i * %s.i);\n', list_out{idx_dim}, list_in{idx_dim}, list_in{idx_dim}, list_in{idx_dim}, list_in{idx_dim});
            output_string = app_sprintf(output_string, '\t%s.i = atan2(%s.i, %s.r);\n', list_out{idx_dim}, list_in{idx_dim}, list_in{idx_dim});
        end
        extern_funs{1} = sprintf('log %s', out_dt_lus);
        extern_funs{2} = sprintf('atan2 %s', out_dt_lus);
    elseif strcmp(math_op, '10^u')
        if strcmp(out_dt_lus, 'int')
            ten = '10';
        else
            ten = '10.0';
        end
        for idx_dim=1:dim
            output_string = app_sprintf(output_string, '\t%s.r = exp(%s.r * log(%s)) * cos(%s.i * log(%s));\n', list_out{idx_dim}, list_in{idx_dim}, ten, list_in{idx_dim}, ten);
            output_string = app_sprintf(output_string, '\t%s.i = exp(%s.r * log(%s)) * sin(%s.i * log(%s));\n', list_out{idx_dim}, list_in{idx_dim}, ten, list_in{idx_dim}, ten);
        end
        extern_funs{1} = sprintf('exp %s', out_dt_lus);
        extern_funs{2} = sprintf('cos %s', out_dt_lus);
        extern_funs{3} = sprintf('sin %s', out_dt_lus);
        extern_funs{4} = sprintf('log %s', out_dt_lus);
    elseif strcmp(math_op, 'log10')
        if strcmp(out_dt_lus, 'int')
            ten = '10';
        else
            ten = '10.0';
        end
        for idx_dim=1:dim
            output_string = app_sprintf(output_string, '\t%s.r = log(%s.r * %s.r + %s.i * %s.i) / log(%s);\n', list_out{idx_dim}, list_in{idx_dim}, list_in{idx_dim}, list_in{idx_dim}, list_in{idx_dim}, ten);
            output_string = app_sprintf(output_string, '\t%s.i = atan2(%s.i, %s.r) / log(%s);\n', list_out{idx_dim}, list_in{idx_dim}, list_in{idx_dim}, ten);
        end
        extern_funs{1} = sprintf('log %s', out_dt_lus);
        extern_funs{2} = sprintf('atan2 %s', out_dt_lus);
    elseif strcmp(math_op, 'square')
        for idx_dim=1:dim
            output_string = app_sprintf(output_string, '\t%s.r = %s.r * %s.r - %s.i * %s.i;\n',  list_out{idx_dim}, list_in{idx_dim}, list_in{idx_dim}, list_in{idx_dim}, list_in{idx_dim});
            output_string = app_sprintf(output_string, '\t%s.i = 2 * %s.r * %s.i;\n', list_out{idx_dim}, list_in{idx_dim}, list_in{idx_dim});
        end
    elseif strcmp(math_op, 'pow')
        in1_dt = LusUtils.get_lustre_dt(block.CompiledPortDataTypes.Inport(1));
        in2_dt = LusUtils.get_lustre_dt(block.CompiledPortDataTypes.Inport(1));
        
        for idx_dim=1:dim
            output_string = app_sprintf(output_string, '\t%s = pow_complex_%s(%s, %s);\n', list_out{idx_dim}, out_dt_lus, list_in{idx_dim}, list_in{dim+idx_dim});
        end
        extern_funs{1} = sprintf('pow_complex %s %s', in1_dt, in2_dt);
    elseif strcmp(math_op, 'conj')
        for idx_dim=1:dim
            output_string = app_sprintf(output_string, '\t%s.r = %s.r;\n', list_out{idx_dim}, list_in{idx_dim});
            output_string = app_sprintf(output_string, '\t%s.i = -%s.i;\n', list_out{idx_dim}, list_in{idx_dim});
        end
    elseif strcmp(math_op, 'hypot')
        for idx_dim=1:dim
            output_string = app_sprintf(output_string, '\t%s = sqrt(%s.r * %s.r + %s.i * %s.i + %s.r * %s.r + %s.i * %s.i);\n', list_out{idx_dim}, list_in{idx_dim}, list_in{idx_dim}, list_in{idx_dim}, list_in{idx_dim}, list_in{dim+idx_dim}, list_in{dim+idx_dim}, list_in{dim+idx_dim}, list_in{dim+idx_dim});
        end
        extern_funs{1} = sprintf('sqrt %s', out_dt_lus);
    elseif strcmp(math_op, 'reciprocal')
        for idx_dim=1:dim
            output_string = app_sprintf(output_string, '\t%s.r = %s.r / (%s.r * %s.r - %s.i * %s.i);\n', list_out{idx_dim}, list_in{idx_dim}, list_in{idx_dim}, list_in{idx_dim}, list_in{idx_dim}, list_in{idx_dim});
            output_string = app_sprintf(output_string, '\t%s.i = -%s.i / (%s.r * %s.r - %s.i * %s.i);\n', list_out{idx_dim}, list_in{idx_dim}, list_in{idx_dim}, list_in{idx_dim}, list_in{idx_dim}, list_in{idx_dim});
        end
    end
end

var_out{1} = 'extern_functions';
var_out{2} = extern_funs;
end

