%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Memory block
%
% This block output the previous value of the input. The initial value for
% the block output is set according tot he init parameter.
%
%% Generation scheme
%
%%% The input is a 3 elements vector
%
%  Output_1_1 = init{1} -> pre Input_1_1;
%  Output_1_2 = init{2} -> pre Input_1_2;
%  Output_1_3 = init{3} -> pre Input_1_3;
%
%% Code
%
function [output_string] = write_memory(unbloc, init, inter_blk, myblk)

output_string = '';

[list_out] = list_var_sortie(unbloc);
[list_in] = list_var_entree(unbloc, inter_blk, myblk);

[is_bus bus] = BusUtils.is_bus(unbloc.CompiledPortDataTypes.Outport{1});
if is_bus
	[list_ic, list_fields] = BusUtils.list_cst(init, bus);
else
	[list_ic] = Utils.list_cst(init, unbloc.CompiledPortDataTypes.Outport{1});
end

if unbloc.CompiledPortComplexSignals.Outport(1)
	% The output is complex so both input and init should be complex too
	dt = Utils.get_lustre_dt(unbloc.CompiledPortDataTypes.Outport{1});
	for idx=1:numel(list_ic)
		list_ic{idx} = Utils.get_complex_def_str(list_ic{idx}, dt);
	end
end

[out_dim_r out_dim_c] = Utils.get_port_dims_simple(unbloc.CompiledPortDimensions.Outport, 1);

[ic_dim_r ic_dim_c] = size(list_ic);

[is_reset reset_var_name] = Utils.is_reset(inter_blk);

% Expand IC if necessary
if numel(list_ic) < numel(list_out)
    value = list_ic{1};
    for idx_out=1:numel(list_out)
        new_ic{idx_out} = value;
    end
    list_ic = new_ic;
end

% Expand inputs if necessary
if numel(list_in) < numel(list_out)
    value = list_in{1};
    for idx_out=1:numel(list_out)
        new_in{idx_out} = value;
    end
    list_in = new_in;
end

if is_bus
	for idx=1:numel(list_ic)
		assign_str = sprintf('%s -> pre %s.%s', list_ic{idx}, list_in{1}, list_fields{idx});
		reset_cond = '';
		if is_reset
			reset_cond = sprintf('if %s then %s else ', reset_var_name, list_ic{idx});
		end
		output_string = app_sprintf(output_string, '\t%s.%s = %s%s;\n', list_out{1}, list_fields{idx}, reset_cond, assign_str);
	end
else
	for idx_out=1:numel(list_out)
		assign_str = sprintf('%s -> pre %s', list_ic{idx_out}, list_in{idx_out});
		reset_cond = '';
		if is_reset
			reset_cond = sprintf('if %s then %s else ', reset_var_name, list_ic{idx_out});
		end
		output_string = app_sprintf(output_string, '\t%s = %s%s;\n', list_out{idx_out}, reset_cond, assign_str);
	end
end

end
