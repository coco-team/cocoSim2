%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Saturation block
%
% Saturate the value of the input according to the values provided in the
% sat_min and sat_max parameters.
% If sat_min or sat_max are provided as scalar values, they are expanded to
% match the size of the Input.
%
%% Generation scheme
%
%%% 2 elements vector input
%
%  Output_1_1 = if Input_1_1 >= sat_max{1} then sat_max{1} else if Input_1_1 <= sat_min{1} then sat_min{1} else Input_1_1;
%  Output_1_2 = if Input_1_2 >= sat_max{2} then sat_max{2} else if Input_1_2 <= sat_min{2} then sat_min{2} else Input_1_2;
%
%% Code
%
function [output_string, var_out] = write_Saturate(block, ir_struct, varargin)

var_out = {};

rndmeth = block.RndMeth;

output_string = '';

[list_out] = list_var_sortie(block);
[list_in] = list_var_entree(block, ir_struct);

sat_max = LusUtils.getParamValue(ir_struct, block, block.UpperLimit);
sat_min = LusUtils.getParamValue(ir_struct, block, block.LowerLimit);
[n,m] = size(sat_max);
ind = 1;
for i=1:n
    for j=1:m
        sat(ind) = sat_max(i,j);
        ind = ind+1;
    end
end
sat_max = sat;
sat = [];
[n,m] = size(sat_min);
ind = 1;
for i=1:n
    for j=1:m
        sat(ind) = sat_min(i,j);
        ind = ind+1;
    end
end
sat_min = sat;

dim_sat_max = numel(sat_max);
dim_sat_min = numel(sat_min);

% Expansion of saturation if necessary
if dim_sat_min < dim_sat_max
    % dim_sta_min == 1
    sat_min = ones(1, dim_sat_max) * sat_min;
    dim_sat_min = dim_sat_max;
elseif dim_sat_max < dim_sat_min
    % dim_sta_max == 1
    sat_max = ones(1, dim_sat_min) * sat_max;
    dim_sat_max = dim_sat_min;
end

% Expansion of input if necessary
[in_dim_r in_dim_c] = Utils.get_port_dims_simple(block.CompiledPortDimensions.Inport, 1);

in_dim = in_dim_r*in_dim_c;
if in_dim < dim_sat_max
    % in_dim == 1
    new_list_in = '';
    for idx_dim=1:dim_sat_max
        new_list_in{idx_dim} = list_in{1};
    end
    list_in = new_list_in;
elseif dim_sat_max < in_dim
    % dim_sat_max == dim_sat_min == 1
    sat_min = ones(1, in_dim) * sat_min;
    sat_max = ones(1, in_dim) * sat_max;
end

% Code printing
if strcmp(block.CompiledPortDataTypes.Outport(1), 'double')
    for idx_out=1:numel(list_out)
        if1_str = sprintf([' if %s >= %f'], list_in{idx_out}, sat_max(idx_out));
        then1_str = sprintf(['then %f'], sat_max(idx_out));
        if2_str = sprintf(['\t\telse if %s <= %f'], list_in{idx_out}, sat_min(idx_out));
        then2_str = sprintf(['then %f'], sat_min(idx_out));
        else_str = sprintf('\t\telse %s', list_in{idx_out});
        
        output_string = app_sprintf(output_string,'\t%s = %s %s \n%s %s \n%s ;\n', list_out{idx_out}, if1_str, then1_str, if2_str, then2_str, else_str);
    end
elseif strncmp(block.CompiledPortDataTypes.Outport(1), 'int', 3) || strncmp(block.CompiledPortDataTypes.Outport(1), 'uint', 4)
    rndmeth = LusUtils.get_rounding_function(rndmeth);
    for idx_out=1:numel(list_out)
        max_str = [rndmeth '(' num2str(sat_max(idx_out)) ')'];
        min_str = [rndmeth '(' num2str(sat_min(idx_out)) ')'];
        new_sat_max = eval(max_str);
        new_sat_min = eval(min_str);
        if1_str = sprintf([' if %s >= %d'], list_in{idx_out}, new_sat_max);
        then1_str = sprintf(['then %d'], new_sat_max);
        if2_str = sprintf(['\t\telse if %s <= %d'], list_in{idx_out}, new_sat_min);
        then2_str = sprintf(['then %d'], new_sat_min);
        else_str = sprintf('\t\telse %s', list_in{idx_out});
        
        output_string = app_sprintf(output_string,'\t%s = %s %s \n%s %s \n%s ;\n', list_out{idx_out}, if1_str, then1_str, if2_str, then2_str, else_str);
    end
    
else
    
end

end

