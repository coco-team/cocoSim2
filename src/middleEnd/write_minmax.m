%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% MinMax block
%
% Computes the minimum or the maximum of the inputs according to the fun
% parameter. The computation is
% done element-wise meaning that if we provide only one input then the
% computation is done over the elements of the input, if the block has
% multiple inputs then the computation is done for each element of the
% inputs and thus the output of the block is of the same size as the
% inputs.
%
%% Generation scheme
%
%%% One input as a 3 element vector and fun = min
%
%  BlockName_tmp_1 = if Input_1_1 <= Input_1_2 then Input_1_1 else Input_1_2;
%  Output_1_1 = if BlockName_tmp_1 <= Input_1_3 then BlockName_tmp_1 else Input_1_3;
%
%%% Three inputs a 2 elements vectors and fun = max
%
%  BlockName_tmp_1 = if Input_1_1 >= Input_2_1 then Input_1_1 else Input_2_1;
%  Output_1_1 = if BlockName_tmp_1 <= Input_3_1 then BlockName_tmp_1 else Input_3_1;
%  BlockName_tmp_2 = if Input_1_2 >= Input_2_2 then Input_1_2 else Input_2_2;
%  Output_1_2 = if BlockName_tmp_2 <= Input_3_2 then BlockName_tmp_2 else Input_3_2;
%  BlockName_tmp_3 = if Input_1_3 >= Input_2_3 then Input_1_3 else Input_2_3;
%  Output_1_3 = if BlockName_tmp_3 <= Input_3_3 then BlockName_tmp_3 else Input_3_3;
%
%% Code
%
function [output_string, var_str] = write_minmax(nom_lustre_file, unbloc, fun, inter_blk, xml_trace, myblk)

output_string = '';
var_str = '';

[list_out] = list_var_sortie(unbloc);
[list_in] = list_var_entree(unbloc, inter_blk, myblk);

op = '';
if strcmp(fun, 'min')
	op = ' <= ';
else
	op = ' >= ';
end

block_full_name = regexp(unbloc.Path, fielesep, 'split');
block_name = Utils.concat_delim(block_full_name(end - unbloc.name_level : end), '_');

if unbloc.Ports(1) == 1

	[in_dim_r in_dim_c] = Utils.get_port_dims_simple(unbloc.CompiledPortDimensions.Inport, 1);
	if in_dim_r == 1 && in_dim_c == 1
		output_string = app_sprintf(output_string, '\t%s = %s;\n', list_out{1}, list_in{1});
	else
		if numel(list_in) == 2
			if_cond = [list_in{1} op list_in{2}];
			output_string = app_sprintf(output_string, '\t%s = if %s then %s else %s;\n', list_out{1}, if_cond, list_in{1}, list_in{2});
		else
			var_str = '\t';
			out_dt = Utils.get_lustre_dt(unbloc.CompiledPortDataTypes.Outport{1});
			counter = 1;
			pre_var_name = '';

			for idx_in=1:(numel(list_in)-2)
				var_name = [block_name '_tmp_' num2str(counter)];
				var_str = [var_str var_name ' : ' out_dt '; '];
				counter = counter + 1;

				if idx_in == 1
					if_cond = [list_in{idx_in} op list_in{idx_in + 1}];
					then_branch = list_in{idx_in};
				else
					if_cond = [pre_var_name op list_in{idx_in + 1}];
					then_branch = pre_var_name;
				end
				else_branch = [list_in{idx_in + 1}];
				output_string = app_sprintf(output_string, '\t%s = if %s then %s else %s;\n', var_name, if_cond, then_branch, else_branch);
				pre_var_name = var_name;

				% Add traceability for temporary variables
				xml_trace.add_Variable(var_name, unbloc.Origin_path, 1, idx_in, true);

			end

			if_cond = [pre_var_name op list_in{end}];
			then_branch = pre_var_name;
			else_branch = [list_in{end}];
			output_string = app_sprintf(output_string, '\t%s = if %s then %s else %s;\n', list_out{1}, if_cond, then_branch, else_branch);
			
			var_str = [var_str '\n'];
		end
	end

else

	% Perform expansion if necessary
	list_in = Utils.expand_all_inputs(unbloc, list_in);

	dim = unbloc.CompiledPortWidths.Outport(1);
	% Print the block code
	if unbloc.Ports(1) == 2
		for idx_out=1:numel(list_out)
			if_cond = [list_in{idx_out} op list_in{idx_out + dim}];
			output_string = app_sprintf(output_string, '\t%s = if %s then %s else %s;\n', list_out{idx_out}, if_cond, list_in{idx_out}, list_in{idx_out + dim});
		end
	else
		var_str = '\t';
		counter = 1;
		pre_var_name = '';
		out_dt = Utils.get_lustre_dt(unbloc.CompiledPortDataTypes.Outport{1});
		
		for idx_out=1:numel(list_out)
			for idx_in=1:(unbloc.Ports(1) - 2)
				var_name = [block_name '_tmp_' num2str(counter)];
				var_str = [var_str var_name ' : ' out_dt '; '];
				counter = counter + 1;

				if idx_in == 1
					if_cond = [list_in{idx_out} op list_in{idx_out + (idx_in) * dim}];
					then_branch = list_in{idx_out};
				else
					if_cond = [pre_var_name op list_in{idx_out + (idx_in) * dim}];
					then_branch = pre_var_name;
				end
				else_branch = [list_in{idx_out + (idx_in) * dim}];
				output_string = app_sprintf(output_string, '\t%s = if %s then %s else %s;\n', var_name, if_cond, then_branch, else_branch);
				pre_var_name = var_name;

				% Add traceability for temporary variables
				xml_trace.add_Variable(var_name, unbloc.Origin_path, 1, idx_in, true);

			end

			if_cond = [pre_var_name op list_in{idx_out + (unbloc.Ports(1) - 1) * dim}];
			then_branch = pre_var_name;
			else_branch = [list_in{idx_out + (unbloc.Ports(1) - 1) * dim}];
			output_string = app_sprintf(output_string, '\t%s = if %s then %s else %s;\n', list_out{idx_out}, if_cond, then_branch, else_branch);
		end		
		var_str = [var_str '\n'];
	end
end

end

