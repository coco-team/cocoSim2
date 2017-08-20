%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Sum block
%
% Sums the values of the inputs.
% If there is only one input, the output may be the sum of the input
% elements (collapse_mode set to 'All dimensions') or the output may be the
% sum of the elements on over a specific dimension (collapse_mode set to
% 'Specify dimension').
% In the block has mutiple inputs then the block computes the sum of the
% elements of the inputs element-wise.
%
%% Generation scheme
%
%%% One input composed of real values
% We take the example of a 3 element vector as input of the block
%
%  Output_1_1 = Input_1_1 + Input_1_2 + Input_1_3;
%
%%% One input composed of complex values
% We take the example of a 3 element vector as input of the block
%
%  Output_1_1.r = Input_1_1.r + Input_1_2.r + Input_1_3.r;
%  Output_1_1.i = Input_1_1.i + Input_1_2.i + Input_1_3.i;
%
%%% Two inputs composed of real 3 elements vectors
%
%  Output_1_1 = Input_1_1 + Input_2_1;
%  Output_1_2 = Input_1_2 + Input_2_2;
%
%%% Two inputs composed of complex 2 elements vectors
%
%  Output_1_1.r = Input_1_1.r + Input_2_1.r;
%  Output_1_1.i = Input_1_1.i + Input_2_1.i;
%  Output_1_2.r = Input_1_2.r + Input_2_2.r;
%  Output_1_2.i = Input_1_2.i + Input_2_2.i;
%
%% Code
%
function [output_string, var_out] = write_Sum(block, ir_struct, varargin)

var_out = {};

% Remove '|' character from the list of signs parameter value
signs = block.Inputs;

%Test if 'listof signs' is a scalar, i.e. signs==2 => signs='++'
is_scalar= str2num(signs);
if ~isempty(is_scalar)
    new_signs='';
    for num_add=1:is_scalar
        new_signs=[new_signs '+'];
    end
    signs=new_signs;
end
list_sign = [];
% check the case where signs is a integer (ie. the number of plus)
[nb_plus, was_uint] = str2num(['uint16(' signs ')']);
if was_uint && nb_plus > 0
    list_sign=repmat('+',1,nb_plus);
else % the is a classical ++-- string
    for sign_iter=1:numel(signs)
        if not(strcmp(signs(sign_iter), '|'))
            list_sign = [list_sign signs(sign_iter)];
        end
    end
end

collapse_mode = block.CollapseMode;
collapse_dim = str2num(block.CollapseDim);

output_string = '';

[list_out] = list_var_sortie(block);
[list_in] = list_var_entree(block, ir_struct);

if strcmp(block.CompiledPortDataTypes.Inport(1), 'double') || strcmp(block.CompiledPortDataTypes.Inport(1), 'single')
    zero = '0.0';
else
    zero = '0';
end

if block.Ports(1) == 1
    sign_str = [' ' list_sign(1) ' '];
    if strcmp(collapse_mode, 'All dimensions')
        if block.CompiledPortComplexSignals.Outport(1)
            str_real = '';
            str_imag = '';
            for idx=1:numel(list_in)
                if idx == 1 && strcmp(list_sign(1), '+')
                    str_real = [list_in{idx} '.r'];
                    str_imag = [list_in{idx} '.i'];
                else
                    str_real = [str_real sign_str list_in{idx} '.r'];
                    str_imag = [str_imag sign_str list_in{idx} '.i'];
                end
            end
            output_string = app_sprintf(output_string, '\t%s.r = %s;\n', char(list_out{1}), str_real);
            output_string = app_sprintf(output_string, '\t%s.i = %s;\n', char(list_out{1}), str_imag);
        else
            str = '';
            for idx=1:numel(list_in)
                if idx == 1 && strcmp(list_sign(1), '+')
                    str = list_in{idx};
                else
                    str = [str sign_str list_in{idx}];
                end
            end
            output_string = app_sprintf(output_string, '\t%s = %s;\n', char(list_out{1}), str);
        end
    else
        [in_dim_r in_dim_c] = Utils.get_port_dims_simple(block.CompiledPortDimensions.Inport, 1);
        if collapse_dim == 1
            % Sum over the columns
            for idx=1:numel(list_out)
                if block.CompiledPortComplexSignals.Outport(1)
                    str_real = '';
                    str_imag = '';
                    for idx_row=1:in_dim_r
                        idx_in = idx + (idx_row-1) * in_dim_c;
                        if idx_row == 1 && strcmp(list_sign(1), '+')
                            str_real = [list_in{idx_in} '.r'];
                            str_imag = [list_in{idx_in} '.i'];
                        else
                            str_real = [str_real sign_str list_in{idx_in} '.r'];
                            str_imag = [str_imag sign_str list_in{idx_in} '.i'];
                        end
                    end
                    output_string = app_sprintf(output_string, '\t%s.r = %s;\n', char(list_out{idx}), str_real);
                    output_string = app_sprintf(output_string, '\t%s.i = %s;\n', char(list_out{idx}), str_imag);
                else
                    str = '';
                    for idx_row=1:in_dim_r
                        idx_in = idx + (idx_row-1) * in_dim_c;
                        if idx_row == 1 && strcmp(list_sign(1), '+')
                            str = list_in{idx_in};
                        else
                            str = [str sign_str list_in{idx_in}];
                        end
                    end
                    output_string = app_sprintf(output_string, '\t%s = %s;\n', char(list_out{idx}), str);
                end
            end
        else
            % Sum over the rows
            for idx=1:numel(list_out)
                if block.CompiledPortComplexSignals.Outport(1)
                    str_real = '';
                    str_imag = '';
                    for idx_col=1:in_dim_c
                        idx_in = idx_col + (idx-1) * in_dim_c;
                        if idx_col == 1 && strcmp(list_sign(1), '+')
                            str_real = [list_in{idx_in} '.r'];
                            str_imag = [list_in{idx_in} '.i'];
                        else
                            str_real = [str_real sign_str list_in{idx_in} '.r'];
                            str_imag = [str_imag sign_str list_in{idx_in} '.i'];
                        end
                    end
                    output_string = app_sprintf(output_string, '\t%s.r = %s;\n', char(list_out{idx}), str_real);
                    output_string = app_sprintf(output_string, '\t%s.i = %s;\n', char(list_out{idx}), str_imag);
                else
                    str = '';
                    for idx_col=1:in_dim_c
                        idx_in = idx_col + (idx-1) * in_dim_c;
                        if idx_col == 1 && strcmp(list_sign(1), '+')
                            str = list_in{idx_in};
                        else
                            str = [str sign_str list_in{idx_in}];
                        end
                    end
                    output_string = app_sprintf(output_string, '\t%s = %s;\n', char(list_out{idx}), str);
                end
            end
        end
    end
else
    % Convert real values to complex where needed
    if block.CompiledPortComplexSignals.Outport(1)
        prev_dims = 0;
        dt = LusUtils.get_lustre_dt(block.CompiledPortDataTypes.Outport(1));
        for idx_in=1:block.Ports(1)
            [in_dim_r in_dim_c] = Utils.get_port_dims_simple(block.CompiledPortDimensions.Inport, idx_in);
            if ~block.CompiledPortComplexSignals.Inport(idx_in)
                for idx_dim=1:in_dim_r * in_dim_c
                    list_in{prev_dims+idx_dim} = LusUtils.real_to_complex_str(list_in{prev_dims+idx_dim}, dt);
                end
            end
            prev_dims = prev_dims + in_dim_r * in_dim_c;
        end
    end
    
    % Perform expansion if necessary
    dim = 1;
    dims = '';
    for idx_in=1:block.Ports(1)
        [in_dim_r in_dim_c] = Utils.get_port_dims_simple(block.CompiledPortDimensions.Inport, idx_in);
        if in_dim_r ~= 1
            dim = in_dim_r;
            if in_dim_c ~= 1
                dim = in_dim_r * in_dim_c;
            end
        end
        dims{idx_in} = num2str(in_dim_r);
    end
    
    if dim ~= 1
        to_be_modified = strcmp(dims, '1');
        new_list_in = '';
        counter_new_in = 1;
        counter_old_in = 1;
        for idx=1:numel(to_be_modified)
            if to_be_modified(idx)
                for idx_in=0:(dim - 1)
                    new_list_in{counter_new_in} = list_in{counter_old_in};
                    counter_new_in = counter_new_in + 1;
                end
                counter_old_in = counter_old_in + 1;
            else
                for idx_in=0:(dim - 1)
                    new_list_in{counter_new_in} = list_in{counter_old_in};
                    counter_old_in = counter_old_in + 1;
                    counter_new_in = counter_new_in + 1;
                end
            end
        end
        list_in = new_list_in;
    end
    
    for idx_output=1:numel(list_out)
        in_idx = 1;
        if block.CompiledPortComplexSignals.Outport(1)
            str_real = '';
            str_imag = '';
            for idx_input=idx_output:block.CompiledPortWidths.Outport:numel(list_in)
                sign_str = [' ' list_sign(in_idx) ' '];
                if (idx_input <= block.CompiledPortWidths.Outport) && strcmp(list_sign(1), '+')
                    str_real = [list_in{idx_input} '.r'];
                    str_imag = [list_in{idx_input} '.i'];
                else
                    str_real = [str_real sign_str list_in{idx_input} '.r'];
                    str_imag = [str_imag sign_str list_in{idx_input} '.i'];
                end
                in_idx = in_idx + 1;
            end
            output_string = app_sprintf(output_string, '\t%s.r = %s;\n', char(list_out{idx_output}), str_real);
            output_string = app_sprintf(output_string, '\t%s.i = %s;\n', char(list_out{idx_output}), str_imag);
        else
            str = '';
            for idx_input=idx_output:block.CompiledPortWidths.Outport:numel(list_in)
                sign_str = [' ' list_sign(in_idx) ' '];
                if (idx_input <= block.CompiledPortWidths.Outport) && strcmp(list_sign(1), '+')
                    str = list_in{idx_input};
                else
                    str = [str sign_str list_in{idx_input}];
                end
                in_idx = in_idx + 1;
            end
            output_string = app_sprintf(output_string, '\t%s = %s;\n', char(list_out{idx_output}), str);
        end
    end
end

