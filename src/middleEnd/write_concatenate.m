%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Concatenate block
%
% Concatenates the input values according to the mode parameter.
% If mode parameter is 'Vector' then just concatenates the input vectors
% (or scalars) into a vector if all inputs are vectors or scalar or as a
% row matrix if any input is a row matrix.
% If mode parameter is 'Multidimensional array' then concatenate the input
% values on the dimension specified in the dim parameter.
%
%% Generation scheme
%
%%% mode is 'Vector'
% We take here the example of a Concatenate block with 3 inputs, the first
% one is a scalar, the second one is a 3 elements vector and the third one
% is a scalar.
%
%  Output_1_1 = Input_1_1;
%  Output_1_2 = Input_2_1;
%  Output_1_3 = Input_2_2;
%  Output_1_4 = Input_2_3;
%  Output_1_5 = Input_3_1;
%
%%% mode is 'Multidimensional array'
% We take here the example of a Concatenate block with 2 inputs, both
% inputs are 2 elements vectors, and dim parameter is set to 2.
% The result is then a 2*2 matrix
%
%  Output_1_1 = Input_1_1;
%  Output_1_2 = Input_2_1;
%  Output_1_3 = Input_1_2;
%  Output_1_4 = Input_2_2;
%
%% Code
%
function [output_string] = write_concatenate(unbloc, mode, dim, inter_blk, myblk)

output_string = '';

[list_out] = list_var_sortie(unbloc);
[list_in] = list_var_entree(unbloc, inter_blk, myblk);

cpx_mode = false;
if unbloc.CompiledPortComplexSignals.Outport(1)
	cpx_mode = true;
	cpt_in = 0;
	dt = Utils.get_lustre_dt(unbloc.CompiledPortDataTypes.Outport{1});
	for idx_in=1:unbloc.Ports(1)
		[dim_r dim_c] = Utils.get_port_dims_simple(unbloc.CompiledPortDimensions.Inport, idx_in);
		nb = dim_r * dim_c;
		if ~unbloc.CompiledPortComplexSignals.Inport(idx_in)
			for idx=1:nb
				list_in{cpt_in + idx} = Utils.real_to_complex_str(list_in{cpt_in + idx}, dt);
			end
		end
		cpt_in = cpt_in + nb;
	end
end

if strcmp(mode, 'Vector')
	for idx=1:numel(list_out)
		output_string = app_sprintf(output_string, '\t%s = %s;\n', list_out{idx}, list_in{idx});
	end
else
	if strcmp(dim, '1')
        %previous code
% 		idx_out = 1;
% 		[dim_r dim_c] = Utils.get_port_dims_simple(unbloc.inports_dim, 1);
% 		for idx_c=1:dim_c
% 			prec = 0;
% 			for idx_in=1:unbloc.num_input
% 				[in_dim_r in_dim_c] = Utils.get_port_dims_simple(unbloc.inports_dim, idx_in);
% 				for idx_r=1:in_dim_r
% 					idx = (idx_c - 1) * in_dim_r + idx_r + prec;
% 					output_string = app_sprintf(output_string, '\t%s = %s;\n', list_out{idx_out}, list_in{idx});
% 					idx_out = idx_out + 1;
% 				end
% 				prec = prec + in_dim_r * in_dim_c;
% 			end
%         end

        %new code
		for idx=1:numel(list_out)
			output_string = app_sprintf(output_string, '\t%s = %s;\n', list_out{idx}, list_in{idx});
		end
    else
        %previous code
% 		for idx=1:numel(list_out)
% 			output_string = app_sprintf(output_string, '\t%s = %s;\n', list_out{idx}, list_in{idx});
% 		end

        %new code
        ind_in = 1;
        res = [];
        nb_col = 0;
        for idx_in=1:unbloc.Ports(1)
            [in_dim_r, in_dim_c] = Utils.get_port_dims_simple(unbloc.CompiledPortDimensions.Inport, idx_in);
            for dim1=1:in_dim_r
                for dim2=1:in_dim_c
                    res(dim1,nb_col+dim2) = ind_in;
                    ind_in = ind_in + 1;
                end
            end
            nb_col = nb_col + in_dim_c;
        end
        [r,c] = size(res);
        k = 1;
        indexes =[];
        for i=1:r
            for j=1:c
                indexes(k) = res(i,j);
                k = k+1;
            end
        end
        
        for idx=1:numel(list_out)
			output_string = app_sprintf(output_string, '\t%s = %s;\n', list_out{idx}, list_in{indexes(idx)});
        end
	end
end

end
