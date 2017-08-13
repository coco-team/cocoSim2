%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Constant block
%
% Assigns a value to its output according to the Constant parameter
% (kvalue).
%
%% Generation scheme
% We take the example of a 3 elements vector for the value of the constant parameter
%
%%% If constant is a real value
%
%  Output_1_1 = Kvalue{1};
%  Output_1_2 = Kvalue{2};
%  Output_1_3 = Kvalue{3};
%
%%% If constant is a complex value
%
%  Output_1_1 = complex_dt{ r = real(Kvalue{1}); i = imag(Kvalue{1})};
%  Output_1_2 = complex_dt{ r = real(Kvalue{2}); i = imag(Kvalue{2})};
%  Output_1_3 = complex_dt{ r = real(Kvalue{3}); i = imag(Kvalue{3})};
%
%%% If constant is a bus value
% We take the example here of a bus value for a bus having two fields (f1,
% f2) of respective data type scalar and vector of 2 elements).
%
%  Output_1_1.f1_1 = Kvalue.f1;
%  Output_1_1.f2_1 = Kvalue.f2{1};
%  Output_1_1.f2_2 = Kvalue.f2{2};
%
%% Code
%
function [output_string, var_str] = write_constant(nom_lustre_file, unbloc, inter_blk, Kvalue)

output_string = '';
var_str = '';
[list_out] = list_var_sortie(unbloc);

[is_bus bus] = BusUtils.is_bus(unbloc.CompiledPortDataTypes.Outport{1});
if is_bus
	[list_const, list_fields] = BusUtils.list_cst(Kvalue, bus);
else
	[list_const] = Utils.list_cst(Kvalue, unbloc.CompiledPortDataTypes.Outport{1});
end

[dim_r dim_c] = Utils.get_port_dims_simple(unbloc.CompiledPortDimensions.Outport, 1);

if is_bus
	for idx=1:numel(list_const)
		output_string = app_sprintf(output_string, '\t%s.%s = %s;\n', list_out{1}, list_fields{idx}, list_const{idx});
	end
else
	if numel(list_const) == 1 && unbloc.CompiledPortWidths.Outport ~= 1
		value = list_const{1, 1};
		for idx_row=1:dim_r
			for idx_col=1:dim_c
				value_idx = idx_col + ((idx_row-1) * dim_c);
				list_const{value_idx} = value;
			end
		end
	end
	
	if unbloc.CompiledPortComplexSignals.Outport(1)
		% Complex constant
		dt = Utils.get_lustre_dt(unbloc.CompiledPortDataTypes.Outport{1});
		for idx_row=1:dim_r
			for idx_col=1:dim_c
				in_out_idx = idx_col + ((idx_row-1) * dim_c);
				real_part = evalin('base', sprintf('real(%s);', num2str(list_const{in_out_idx})));
				imag_part = evalin('base', sprintf('imag(%s);', num2str(list_const{in_out_idx})));
				if strcmp(dt, 'real')
					output_string = [output_string sprintf('\t%s.r = %10.10f;\n', list_out{in_out_idx}, real_part)];
					output_string = [output_string sprintf('\t%s.i = %10.10f;\n', list_out{in_out_idx}, imag_part)];
				else
					output_string = [output_string sprintf('\t%s.r = %s;\n', list_out{in_out_idx}, num2str(real_part))];
					output_string = [output_string sprintf('\t%s.i = %s;\n', list_out{in_out_idx}, num2str(imag_part))];
				end
			end
		end
	else
		% Numerical constant
		for idx_row=1:dim_r
			for idx_col=1:dim_c
				in_out_idx = idx_col + ((idx_row-1) * dim_c);
				output_string = [output_string sprintf('\t%s = %s;\n', list_out{in_out_idx}, list_const{in_out_idx})];
			end
		end
	end
end
blk_type = cocoget_param(unbloc.Post{1}, 'BlockType');
if strcmp(blk_type,'Merge')
    annotation = regexprep(num2str(unbloc.Post{1}),'\.','_');
    name = strcat('Merge_',annotation,'_input',num2str(unbloc.CompiledPortWidths.Outport{1}),'_hasChanged');
    var_str = [var_str '\t' name ': bool;\n'];
    output_string = app_sprintf(output_string, '\t%s = true;\n', name);
end
end
