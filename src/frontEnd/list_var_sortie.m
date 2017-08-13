%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [list_out] = list_var_sortie(unbloc)

block_full_name = regexp(unbloc.Path, filesep, 'split');
%if unbloc.name_level >= numel(block_full_name{1})
block_name = Utils.concat_delim(block_full_name, '_');
%else
%	block_name = Utils.concat_delim(block_full_name{1}(end - unbloc.name_level : end), '_');
%end

dims = unbloc.CompiledPortDimensions.Outport;
num_pred = 0;
idx_dim = 1;

for k1=1:unbloc.Ports(2)
	[is_bus, ~] = BusUtils.is_bus(unbloc.CompiledPortDataTypes.Outport{k1});
	if is_bus
		for idx=1:unbloc.CompiledPortWidths.Outport(k1)
			list_out{num_pred + 1} = [block_name '_' num2str(k1) '_' num2str(idx)];
			num_pred = num_pred + 1;
			idx_dim = idx_dim + 1;
		end
	else
		if dims(idx_dim) == -2
			% Here we have a virtual bus, the shape of dims is:
			% [-2 <nb_bus_fields> <nb_dim_field dims_field>{nb_bus_fields}]
			nb_bus_fields = dims(idx_dim + 1);
            cpt = 0;
			for idx=1:nb_bus_fields
				[dim_r, dim_c] = Utils.get_port_dims_simple(dims((idx_dim+2:numel(dims))), 1);
				for idx_row=1:dim_r
					for idx_col=1:dim_c
						in_out_idx = idx_col + ((idx_row-1) * dim_c);
						list_out{num_pred + in_out_idx} = [block_name '_' num2str(k1) '_' num2str(cpt + 1)];
                        cpt = cpt + 1;
					end
				end
				num_pred = num_pred + (dim_r * dim_c);
				[nb_dims, ~] = Utils.get_port_dims(dims((idx_dim+2:numel(dims))), 1);
				idx_dim = idx_dim + nb_dims + 1;
            end
            %correction of the old code (Hamza)
            idx_dim = idx_dim+2;
		else
			% This is a normal output
			[dim_r, dim_c] = Utils.get_port_dims_simple(dims((idx_dim:numel(dims))), 1);
			for idx_row=1:dim_r
				for idx_col=1:dim_c
					in_out_idx = idx_col + ((idx_row-1) * dim_c);
					list_out{num_pred + in_out_idx} = [block_name '_' num2str(k1) '_' num2str(in_out_idx)];
				end
			end
			num_pred = num_pred + (dim_r * dim_c);
			[nb_dims, ~] = Utils.get_port_dims(dims((idx_dim:numel(dims))), 1);
			idx_dim = idx_dim + nb_dims + 1;
		end
	end
end

end
