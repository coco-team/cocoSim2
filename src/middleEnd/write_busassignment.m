%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% BusAssignment block
%
% Assigns the value of the first input Bus signal for the selected fields
% (Simulink parameter AssignedSignals - function parameter assigned). The
% number of inputs for the block depends on the number of fields selected
% for assignment, one for each assigned field + one for the bus signal.
%
%% Generation scheme
%
%%% If the first input (assigned bus) is a virtual bus
% Example provided for a bus with two fields (f1, f2) of respective types
% scalar and vector of two elements. Assigning only f2.
%
%  Output_1_1 = Input_1_1;
%  Output_1_2 = Input_2_1;
%  Output_1_3 = Input_2_2;
%
%%% If the first input is a classic bus
% Same example as previously described.
%
%  Output_1_1.f1 = Input_1_1.f1;
%  Output_1_1.f2_1 = Input_2_1;
%  Output_1_1.f2_2 = Input_2_2;
%
%% Code
%
function [output_string] = write_busassignment(unbloc, inter_blk, assigned, myblk)

output_string = '';

[list_out] = list_var_sortie(unbloc);
[list_in] = list_var_entree(unbloc, inter_blk, myblk);

assigned = regexp(assigned, ',', 'split');

[is_bus bus] = BusUtils.is_bus(unbloc.CompiledPortDataTypes.Inport{1});
is_virtual = ~is_bus;

data = {};
cpt_bus_elements = 0;

if is_virtual
	index_first_assignment = unbloc.CompiledPortWidths.Inport(1);
	cpt_bus_dims = 3;
	for idx=1:numel(unbloc.InputSignals)
		elem = unbloc.InputSignals{idx};
		data{idx}.Name = elem;
		data{idx}.struct_idx = cpt_bus_elements;
		if unbloc.CompiledPortDimensions.Inport(cpt_bus_dims) == 1
			cpt_bus_elements = cpt_bus_elements + unbloc.CompiledPortDimensions.Inport(cpt_bus_dims+1);
			data{idx}.Dimensions = unbloc.CompiledPortDimensions.Inport(cpt_bus_dims+1);
			cpt_bus_dims = cpt_bus_dims + 2;
		else
			cpt_bus_elements = cpt_bus_elements + (unbloc.inports_dim(cpt_bus_dims+1) * unbloc.CompiledPortDimensions.Inport(cpt_bus_dims+2));
			data{idx}.Dimensions = [unbloc.CompiledPortDimensions.Inport(cpt_bus_dims+1) unbloc.CompiledPortDimensions.Inport(cpt_bus_dims+2)];
			cpt_bus_dims = cpt_bus_dims + 3;
		end
		index = find(strcmp(elem, assigned));
		if numel(index) == 0
			data{idx}.input_position = 0;
		else
			data{idx}.input_position = index + 1;
		end
	end
	
	for idx=2:unbloc.Ports(1)
		index_data = find(cellfun(@(x) strcmp(x, assigned{idx-1}), unbloc.InputSignals));
		data{index_data}.start_idx = index_first_assignment;
	   index_first_assignment = index_first_assignment + unbloc.CompiledPortWidths.Inport(idx);
	end
else
	index_first_assignment = 1;
	for idx=1:numel(bus.Elements)
		elem = bus.Elements(idx);
		data{idx}.Name = elem.Name;
		data{idx}.Dimensions = elem.Dimensions;
		index = find(strcmp(elem.Name, assigned));
		if numel(index) == 0
			data{idx}.input_position = 0;
		else
			data{idx}.input_position = index + 1;
		end
		data{idx}.struct_idx = cpt_bus_elements;
		if numel(elem.Dimensions) == 1
			cpt_bus_elements = cpt_bus_elements + elem.Dimensions;
		else
			cpt_bus_elements = cpt_bus_elements + (elem.Dimensions(1) * elem.Dimensions(2));
		end
	end
	
	for idx=2:unbloc.Ports(1)
		index_data = find(cellfun(@(x) strcmp(x.Name, assigned{idx-1}), data));
		data{index_data}.start_idx = index_first_assignment;
	   index_first_assignment = index_first_assignment + unbloc.CompiledPortWidths.Inport(idx);
	end
end

for idx_elem=1:numel(data)
	elem = data{idx_elem};
	index = find(strcmp(elem.Name, assigned));
	if numel(index) == 0
		% The element of the input bus is not modified
		if numel(elem.Dimensions) == 1
			for idx_dim=1:elem.Dimensions
				field_assign_str = sprintf('%s_%d', elem.Name, idx_dim);
				if is_virtual
					output_string = app_sprintf(output_string, '\t%s = %s;\n', list_out{elem.struct_idx + idx_dim}, list_in{elem.struct_idx + idx_dim});
				else
					output_string = app_sprintf(output_string, '\t%s.%s = %s.%s;\n', list_out{1}, field_assign_str, list_in{1}, field_assign_str);
				end
			end
		else
			for idx_r=1:elem.Dimensions(1)
				for idx_c=1:elem.Dimensions(2)
					idx = idx_c + (idx_r-1) * elem.Dimensions(2);
					field_assign_str = sprintf('%s_%d', elem.Name, idx);
					if is_virtual
						output_string = app_sprintf(output_string, '\t%s = %s;\n', list_out{elem.struct_idx + idx}, list_in{elem.struct_idx + idx});
					else
						output_string = app_sprintf(output_string, '\t%s.%s = %s.%s;\n', list_out{1}, field_assign_str, list_in{1}, field_assign_str);
					end
				end
			end
		end
	else
		% The element of the input bus is modified
		if numel(elem.Dimensions) == 1
			for idx_dim=1:elem.Dimensions
				if is_virtual
					output_string = app_sprintf(output_string, '\t%s = %s;\n', list_out{elem.struct_idx + idx_dim}, list_in{elem.start_idx + idx_dim});
				else
					output_string = app_sprintf(output_string, '\t%s.%s_%d = %s;\n', list_out{1}, elem.Name, idx_dim, list_in{elem.start_idx + idx_dim});
				end
			end
		else
			for idx_r=1:elem.Dimensions(1)
				for idx_c=1:elem.Dimensions(2)
					idx = idx_c + (idx_r-1) * elem.Dimensions(2);
					if is_virtual
						output_string = app_sprintf(output_string, '\t%s = %s;\n', list_out{elem.struct_idx + idx}, list_in{elem.start_idx + idx});
					else
						output_string = app_sprintf(output_string, '\t%s.%s_%d = %s;\n', list_out{1}, elem.Name, idx, list_in{elem.start_idx + idx});
					end
				end
			end
		end
	end
end
end
