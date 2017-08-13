%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [lo] = list_var_action(unbloc, inter_blk, type, myblk)

if strcmp(type, 'Action')
	for idx=1:numel(unbloc.action)
        action_block = get_struct(myblk, unbloc.action{idx});
		preceding_block_full_name = regexp(action_block.Path, filesep, 'split');
		pre_block_level = action_block.name_level;
		preceding_block_name = Utils.concat_delim(preceding_block_full_name{1}(end - pre_block_level : end), '_');
		[dim_r dim_c] = Utils.get_port_dims_simple(unbloc.CompiledPortdimensions.Ifaction, 1);
		dim = dim_r * dim_c;
		for idx_dim=1:dim
			lo{idx_dim} = [preceding_block_name '_' num2str(unbloc.actionport(idx) + 1) '_' num2str(idx_dim)];
		end
	end
elseif strcmp(type, 'Trigger')
	for idx=1:numel(unbloc.trigger)
        trigger_block = get_struct(myblk, unbloc.trigger{idx});
		preceding_block_full_name = regexp(trigger_block.Path, filesep, 'split');
		pre_block_level = trigger_block.name_level;
		preceding_block_name = Utils.concat_delim(preceding_block_full_name{1}(end - pre_block_level : end), '_');
		[dim_r dim_c] = Utils.get_port_dims_simple(unbloc.CompiledPortDimensions.Trigger, 1);
		dim = dim_r * dim_c;
		for idx_dim=1:dim
			lo{idx_dim} = [preceding_block_name '_' num2str(unbloc.triggerport(idx) + 1) '_' num2str(idx_dim)];
		end
	end
elseif strcmp(type, 'Enable')
	for idx=1:numel(unbloc.enable)
        enable_block = get_struct(myblk, unbloc.enable{idx});
		preceding_block_full_name = regexp(enable_block.Path, filesep, 'split');
		pre_block_level = enable_block.name_level;
		preceding_block_name = Utils.concat_delim(preceding_block_full_name{1}(end - pre_block_level : end), '_');
		[dim_r dim_c] = Utils.get_port_dims_simple(unbloc.CompiledPortDimensions.Enable, 1);
		dim = dim_r * dim_c;
		for idx_dim=1:dim
			lo{idx_dim} = [preceding_block_name '_' num2str(unbloc.enableport(idx) + 1) '_' num2str(idx_dim)];
		end
	end
end

end
