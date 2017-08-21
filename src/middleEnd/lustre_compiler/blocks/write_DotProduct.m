%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% DotProduct block
%
% Computes a dot product of the values of the two inputs
%
%% Generation scheme
% We take here the example of a vector with 3 elements for both inputs of
% the block
%
%%% If the input is a real
%
%  Output_1_1 = Input_1_1 * Input_2_1 + Input_1_2 * Input_2_2 + Input_1_3 * Input_2_3;
%
%%% If the input is a complex
% We generate a set of temporary variables containing the element wise
% products
%
%  tmp_blockname_real_prod_1 = Input_1_1.r * Input_2_1.r - Input_1_1.i * Input_2_1.i;
%  tmp_blockname_imag_prod_1 = Input_1_1.r * Input_2_1.i - Input_1_1.i * Input_2_1.r;
%  tmp_blockname_real_prod_2 = Input_1_2.r * Input_2_2.r - Input_1_2.i * Input_2_2.i;
%  tmp_blockname_imag_prod_2 = Input_1_2.r * Input_2_2.i - Input_1_2.i * Input_2_2.r;
%  tmp_blockname_real_prod_3 = Input_1_3.r * Input_2_3.r - Input_1_3.i * Input_2_3.i;
%  tmp_blockname_imag_prod_3 = Input_1_3.r * Input_2_3.i - Input_1_3.i * Input_2_3.r;
%
% And finally we set the output value to the sum of the temporary variables
% for each field of the output.
%
%  Output_1_1.r = tmp_blockname_real_prod_1 + tmp_blockname_real_prod_2 + tmp_blockname_real_prod_3;
%  Output_1_1.i = tmp_blockname_imag_prod_1 + tmp_blockname_imag_prod_2 + tmp_blockname_imag_prod_3;
%
%% Code
%
function [output_string, var_out] = write_DotProduct(block, ir_struct, varargin)

output_string = '';
tmp_vars = '';

[list_out] = list_var_sortie(block);
[list_in] = list_var_entree(block, ir_struct);

block_full_name = regexp(block.Path, filesep, 'split');
block_name = Utils.concat_delim(block_full_name(end - block.name_level : end), '_');

dim = block.CompiledPortWidths.Inport(1);
dt = LusUtils.get_lustre_dt(block.CompiledPortDataTypes.Outport);

if ~block.CompiledPortComplexSignals.Outport(1)
	% Output is a real value (dummy but allowed)
	prod_str = {};
	for idx_dim=1:dim
		prod_str{idx_dim} = sprintf('%s * %s', list_in{idx_dim}, list_in{idx_dim+dim});
	end
	rhs_str = Utils.concat_delim(prod_str, ' + ');
	output_string = sprintf('\t%s = %s;\n', list_out{1}, rhs_str);
else
	% Output is a complex value
	tmp_real_prod_vars = {};
	tmp_imag_prod_vars = {};
	for idx_dim=1:dim
		if block.CompiledPortComplexSignals.Inport(1) && block.CompiledPortComplexSignals.Inport(2)
			tmp_real_prod_str = sprintf('(%s.r * %s.r) - (%s.i * %s.i)', list_in{idx_dim}, list_in{idx_dim+dim}, list_in{idx_dim}, list_in{idx_dim+dim});
			tmp_imag_prod_str = sprintf('(%s.r * %s.i) + (%s.i * %s.r)', list_in{idx_dim}, list_in{idx_dim+dim}, list_in{idx_dim}, list_in{idx_dim+dim});
		elseif block.CompiledPortComplexSignals.Inport(1)
			tmp_real_prod_str = sprintf('(%s.r * %s)', list_in{idx_dim}, list_in{idx_dim+dim});
			tmp_imag_prod_str = sprintf('(%s.i * %s)', list_in{idx_dim}, list_in{idx_dim+dim});
		else
			tmp_real_prod_str = sprintf('(%s * %s.r)', list_in{idx_dim}, list_in{idx_dim+dim});
			tmp_imag_prod_str = sprintf('(%s * %s.i)', list_in{idx_dim}, list_in{idx_dim+dim});
		end
		% Real part of the product
		tmp_real_prod_vars{idx_dim} = sprintf('tmp_%s_real_prod_%d', block_name, idx_dim);
		output_string = app_sprintf(output_string, '\t%s = %s;\n', tmp_real_prod_vars{idx_dim}, tmp_real_prod_str);
		
		% Imaginary part of the product
		tmp_imag_prod_vars{idx_dim} = sprintf('tmp_%s_imag_prod_%d', block_name, idx_dim);
		output_string = app_sprintf(output_string, '\t%s = %s;\n', tmp_imag_prod_vars{idx_dim}, tmp_imag_prod_str);

		% Add traceability for additional variables
		varargin{1}.add_Variable(tmp_real_prod_vars{idx_dim}, block.Origin_path, 1, idx_dim, true);
		varargin{1}.add_Variable(tmp_imag_prod_vars{idx_dim}, block.Origin_path, 1, idx_dim, true);
	end
	
	real_sum_str = Utils.concat_delim(tmp_real_prod_vars, ' + ');
	imag_sum_str = Utils.concat_delim(tmp_imag_prod_vars, ' + ');
	
	output_string = app_sprintf(output_string, '\t%s.r = %s;\n', list_out{1}, real_sum_str);
	output_string = app_sprintf(output_string, '\t%s.i = %s;\n', list_out{1}, imag_sum_str);
	
	tmp_vars = ['\t' Utils.concat_delim(tmp_real_prod_vars, sprintf(': %s; ', dt)) ': ' dt ';\n'];
	tmp_vars = [tmp_vars '\t' Utils.concat_delim(tmp_imag_prod_vars, sprintf(': %s; ', dt)) ': ' dt ';\n'];

end

var_out{1} = 'additional_variables';
var_out{2} = tmp_vars;

end
