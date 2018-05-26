%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Product block
%
% Computes the multiplication of the values provided at its inputs. The
% inputs parameter contains the operators ( /, *) to be applied for each
% input.
%
% This block can be used with one input, it will then compute the product of the
% elements of the input according to a collapse_mode parameter stating if
% the product is computed on a specific dimension of the input (the result
% is then a vector or a row_matrix). If the operator is / then the output
% of the block is the product of the invert of each element of the input,
% if it is '*' then the output of the block is the product of the elements of the input.
% In matrix mode, if the block has one input and the operator is / then the
% block computes the invert of the matrix which is not handled in our
% backend.
%
% If the block has multiple inputs then the computation is done according
% to the algorithm provided in the multiplication parameter. IT can either
% be an element wise multiplication or a matrix multiplication (with
% variants).
%
%% Original documentation
%
% Please refer to the Simulink documentation for additional details:
% <http://www.mathworks.com/help/simulink/slref/product.html>
%
%% Generation scheme
%
%%% One input, and the multiplication parameter is set to 'Element-Wise(.*)' The inputs parameter is set to '**/'.
% We take here the example of a product block with inputs of size 3.
%
%  Output_1_1 = Input_1_1 * Input_1_2 * (one / Input_1_3);
%
%%% Multiple inputs, the multiplication parameter is set to 'Matrix(*)'.
% We take here the example of a 2 elements row matrix as first input and the
% second input is a 2*2 matrix.
%
%  Output_1_1 = Input_1_1 * Input_2_1 + Input_1_2 * Input_2_3;
%  Output_1_2 = Input_1_1 * Input_2_2 + Input_1_2 * Input_2_4;
%
%%% Multiple inputs, the multiplication parameter is set to 'Matrix(*)'.
% We take the example of a 3 inputs product block. The first input is a 2
% elements row matrix, the second is a 2*2 matrix and the third one is a
% 2*3 matrix. The computation algorithm uses temporary variables to store
% the result of the intermediary matrix multiplications.
%
%  BlockName_tmp1 = Input_1_1 * Input_2_1 + Input_1_2 * Input_2_3;
%  BlockName_tmp2 = Input_1_1 * Input_2_2 + Input_1_2 * Input_2_4;
%  Output_1_1 = BlockName_tmp1 * Input_3_1 + BlockName_tmp2 * Input_3_4;
%  Output_1_2 = BlockName_tmp1 * Input_3_2 + BlockName_tmp2 * Input_3_5;
%  Output_1_3 = BlockName_tmp1 * Input_3_3 + BlockName_tmp2 * Input_3_6;
%
% varargin{1} = xml_trace
%% Code
%
function [output_string, var_out] = write_Product(block, ir_struct, varargin)

inputs = block.Inputs;
% If the inputs parameter is a number then replace it with the
% correct number of '*'
if str2num(inputs) >= 1
    res = '';
    for idx_inputs=1:eval(inputs)
        res = [res '*'];
    end
    inputs = res;
end

collapse_mode = block.CollapseMode;
collapse_dim = str2num(block.CollapseDim);

multiplication = block.Multiplication;

output_string = '';
var_str = '';
extern_funs = {};

[list_out] = list_var_sortie(block);
[list_in] = list_var_entree(block, ir_struct);

if strcmp(block.CompiledPortDataTypes.Inport(1), 'double') || strcmp(block.CompiledPortDataTypes.Inport(1), 'single')
    one = '1.0';
else
    one = '1';
end

dt = LusUtils.get_lustre_dt(block.CompiledPortDataTypes.Outport(1));

% Complex values management
is_complex = false;
if block.CompiledPortComplexSignals.Outport(1)
    is_complex = true;
    extern_funs{1} = ['complex_arith_' dt];
    pred_dim = 0;
    % Convert non-complex inputs to complex
    for idx_in=1:block.Ports(1)
        [dim_r, dim_c] = Utils.get_port_dims_simple(block.CompiledPortDimensions.Inport, idx_in);
        dim_size = dim_r * dim_c;
        dt = LusUtils.get_lustre_dt(block.CompiledPortDataTypes.Inport(idx_in));
        if ~block.CompiledPortComplexSignals.Inport(idx_in)
            for idx_dim=1:dim_size
                list_in{pred_dim + idx_dim} = LusUtils.real_to_complex_str(list_in{pred_dim + idx_dim}, dt);
            end
        end
        pred_dim = pred_dim + dim_size;
    end
end

block_full_name = regexp(block.Path, '/', 'split');
block_name = Utils.concat_delim(block_full_name(end - block.name_level : end), '_');

if strcmp(multiplication, 'Element-wise(.*)')
    if block.Ports(1) == 1
        if strcmp(collapse_mode, 'All dimensions')
            str = '';
            if is_complex
                if strcmp(inputs(1), '/')
                    str = ['complex_inv_' dt '(' list_in{1} ')'];
                else
                    str = list_in{1};
                end
                for idx=2:numel(list_in)
                    if strcmp(inputs(1), '/')
                        str = sprintf('complex_mult_%s(%s, complex_inv_%s(%s))', dt, str, dt, list_in{idx});
                    else
                        str = sprintf('complex_mult_%s(%s, %s)', dt, str, list_in{idx});
                    end
                end
            else
                if strcmp(inputs(1), '/')
                    str = [str '(' one ' / '  list_in{1} ')'];
                else
                    str = [str list_in{1}];
                end
                for idx=2:numel(list_in)
                    if strcmp(inputs(1), '/')
                        str = [str ' * (' one ' / ' list_in{idx} ')'];
                    else
                        str = [str ' * ' list_in{idx}];
                    end
                end
            end
            output_string = app_sprintf(output_string, '\t%s = %s;\n', char(list_out{1}), str);
        else
            [in_dim_r in_dim_c] = Utils.get_port_dims_simple(block.CompiledPortDimensions.Inport, 1);
            if collapse_dim == 1
                % Product over the columns
                for idx=1:numel(list_out)
                    if is_complex
                        str = '';
                        for idx_row=1:in_dim_r
                            idx_in = idx + (idx_row-1) * in_dim_c;
                            if idx_row == 1
                                if strcmp(inputs(1), '/')
                                    str = ['complex_inv_' dt '(' list_in{idx_in} ')'];
                                else
                                    str = list_in{idx_in};
                                end
                            else
                                if strcmp(inputs(1), '/')
                                    str = sprintf('complex_mult_%s(%s, complex_inv_%s(%s))', dt, str, dt, list_in{idx_in});
                                else
                                    str = sprintf('complex_mult_%s(%s, %s)', dt, str, list_in{idx_in});
                                end
                            end
                        end
                    else
                        str = '';
                        for idx_row=1:in_dim_r
                            idx_in = idx + (idx_row-1) * in_dim_c;
                            if idx_row == 1
                                if strcmp(inputs(1), '/')
                                    str = [str '(' one ' / '  list_in{idx_in} ')'];
                                else
                                    str = [str list_in{idx_in}];
                                end
                            else
                                if strcmp(inputs(1), '/')
                                    str = [str ' * (' one ' / '  list_in{idx_in} ')'];
                                else
                                    str = [str ' * ' list_in{idx_in}];
                                end
                            end
                        end
                    end
                    output_string = app_sprintf(output_string, '\t%s = %s;\n', char(list_out{idx}), str);
                end
            else
                % Product over the rows
                for idx=1:numel(list_out)
                    if is_complex
                        str = '';
                        for idx_col=1:in_dim_c
                            idx_in = idx_col + (idx-1) * in_dim_c;
                            if idx_col == 1
                                if strcmp(inputs(1), '/')
                                    str = ['complex_inv_' dt '(' list_in{idx_in} ')'];
                                else
                                    str = list_in{idx_in};
                                end
                            else
                                if strcmp(inputs(1), '/')
                                    str = sprintf('complex_mult_%s(%s, complex_inv_%s(%s))', dt, str, dt, list_in{idx_in});
                                else
                                    str = sprintf('complex_mult_%s(%s, %s)', dt, str, list_in{idx_in});
                                end
                            end
                        end
                    else
                        str = '';
                        for idx_col=1:in_dim_c
                            idx_in = idx_col + (idx-1) * in_dim_c;
                            if idx_col == 1
                                if strcmp(inputs(1), '/')
                                    str = [str '(' one ' / '  list_in{idx_in} ')'];
                                else
                                    str = [str list_in{idx_in}];
                                end
                            else
                                if strcmp(inputs(1), '/')
                                    str = [str ' * (' one ' / '  list_in{idx_in} ')'];
                                else
                                    str = [str ' * ' list_in{idx_in}];
                                end
                            end
                        end
                    end
                    output_string = app_sprintf(output_string, '\t%s = %s;\n', char(list_out{idx}), str);
                end
            end
        end
    else
        srcport_size = block.CompiledPortWidths.Inport;
        if max(srcport_size) >1
            ind_size =  1;
            ind_input = 0;
            while ind_size<= numel(srcport_size)
                ind_input = ind_input + srcport_size(ind_size);
                if srcport_size(ind_size) == 1
                    scalar = list_in{ind_input};
                    for i=2:max(srcport_size)
                        l{i-1} = scalar;
                    end
                    list_in = [list_in(1:ind_input) l list_in(ind_input+1:end)];
                    break;
                end
                ind_size = ind_size + 1;
            end
        end
        for idx_output=1:numel(list_out)
            if is_complex
                str = '';
                for idx_input=idx_output:block.CompiledPortWidths.Outport:numel(list_in)
                    if (idx_input <= block.CompiledPortWidths.Outport)
                        if strcmp(inputs(1), '/')
                            str = ['complex_inv_' dt '(' list_in{idx_input} ')'];
                        else
                            str = list_in{idx_input};
                        end
                    elseif (idx_input > idx_output)
                        idx_sign = ceil(idx_input/block.CompiledPortWidths.Outport);
                        if strcmp(inputs(idx_sign), '/')
                            str = sprintf('complex_mult_%s(%s, complex_inv_%s(%s))', dt, str, dt, list_in{idx_input});
                        else
                            str = sprintf('complex_mult_%s(%s, %s)', dt, str, list_in{idx_input});
                        end
                    end
                end
            else
                str = '';
                for idx_input=idx_output:block.CompiledPortWidths.Outport:numel(list_in)
                    if (idx_input <= block.CompiledPortWidths.Outport)
                        if strcmp(inputs(1), '/')
                            str = [str '(' one ' / ' list_in{idx_input} ')'];
                        else
                            str = [str list_in{idx_input}];
                        end
                    elseif (idx_input > idx_output)
                        idx_sign = ceil(idx_input/block.CompiledPortWidths.Outport);
                        str = [str ' ' inputs(idx_sign) ' ' list_in{idx_input}];
                    end
                end
            end
            output_string = app_sprintf(output_string,'\t%s = %s;\n', char(list_out{idx_output}), str);
        end
    end
else
    % Matrix multiplication
    if numel(regexp(inputs, '/')) ~= 0
        msg = ['Matrix inversion for product block is not supported\n'];
        msg = [msg block.Origin_path '\n'];
        display_msg(msg, 3, 'write_product', '');
    else
        if block.Ports(1) == 1
            for idx=1:numel(list_out)
                output_string = app_sprintf(output_string, '\t%s = %s;\n', char(list_out{idx}), char(list_in{idx}));
            end
        elseif block.Ports(1) == 2
            [in1_dim_r in1_dim_c] = Utils.get_port_dims_simple(block.CompiledPortDimensions.Inport, 1);
            [in2_dim_r in2_dim_c] = Utils.get_port_dims_simple(block.CompiledPortDimensions.Inport, 2);
            list_in1 = list_in(1:(in1_dim_r*in1_dim_c));
            list_in2 = list_in((in1_dim_r*in1_dim_c + 1):end);
            for idx_row=1:in1_dim_r
                for idx_col=1:in2_dim_c
                    out_idx = idx_col + ((idx_row-1) * in2_dim_c);
                    product_str = '';
                    if is_complex
                        for idx_iter=1:in1_dim_c
                            if idx_iter ~= 1
                                product_str = ['complex_sum_' dt '(' product_str ','];
                            end
                            in1_idx = idx_iter + (idx_row-1) * in1_dim_c;
                            in2_idx = idx_col + (idx_iter-1) * in2_dim_c;
                            product_str = sprintf('%s complex_mult_%s(%s, %s)', product_str, dt, list_in1{in1_idx}, list_in2{in2_idx});
                            if idx_iter ~= 1
                                product_str = [product_str ')'];
                            end
                        end
                    else
                        for idx_iter=1:in1_dim_c
                            if idx_iter ~= 1
                                product_str = [product_str ' + '];
                            end
                            in1_idx = idx_iter + (idx_row-1) * in1_dim_c;
                            in2_idx = idx_col + (idx_iter-1) * in2_dim_c;
                            product_str = sprintf('%s%s * %s', product_str, list_in1{in1_idx}, list_in2{in2_idx});
                        end
                    end
                    output_string = [output_string sprintf('\t%s = %s;\n', list_out{out_idx}, product_str)];
                end
            end
        else
            tmp_prefix = [block_name '_tmp_'];
            [in1_dim_r in1_dim_c] = Utils.get_port_dims_simple(block.CompiledPortDimensions.Inport, 1);
            numel_pred = in1_dim_r*in1_dim_c;
            nb_tmp = 0;
            list_in1 = list_in(1:numel_pred);
            
            out_dt = LusUtils.get_lustre_dt(block.CompiledPortDataTypes.Outport(1));
            for idx_in=2:block.Ports(1)-1
                
                [in2_dim_r in2_dim_c] = Utils.get_port_dims_simple(block.CompiledPortDimensions.Inport, idx_in);
                numel_right = in2_dim_r * in2_dim_c;
                list_in2 = list_in(numel_pred+1:numel_pred+numel_right);
                
                list_tmp_out = cellfun(@(x) [tmp_prefix num2str(x)], num2cell(nb_tmp+1:nb_tmp+in1_dim_r*in2_dim_c), 'UniformOutput', false);
                % Update tmp variables string
                if is_complex
                    var_str = [var_str '\t' Utils.concat_delim(list_tmp_out, [' : complex_' out_dt '; ']) ' : complex_' out_dt ';\n'];
                else
                    var_str = [var_str '\t' Utils.concat_delim(list_tmp_out, [' : ' out_dt '; ']) ' : ' out_dt ';\n'];
                end
                
                for idx_row=1:in1_dim_r
                    for idx_col=1:in2_dim_c
                        out_idx = idx_col + ((idx_row-1) * in2_dim_c);
                        product_str = '';
                        if is_complex
                            for idx_iter=1:in1_dim_c
                                if idx_iter ~= 1
                                    product_str = ['complex_sum_' dt '(' product_str ','];
                                end
                                in1_idx = idx_iter + (idx_row-1) * in1_dim_c;
                                in2_idx = idx_col + (idx_iter-1) * in2_dim_c;
                                product_str = sprintf('%s complex_mult_%s(%s, %s)', product_str, dt, list_in1{in1_idx}, list_in2{in2_idx});
                                if idx_iter ~= 1
                                    product_str = [product_str ')'];
                                end
                            end
                        else
                            for idx_iter=1:in1_dim_c
                                if idx_iter ~= 1
                                    product_str = [product_str ' + '];
                                end
                                in1_idx = idx_iter + (idx_row-1) * in1_dim_c;
                                in2_idx = idx_col + (idx_iter-1) * in2_dim_c;
                                product_str = sprintf('%s%s * %s', product_str, list_in1{in1_idx}, list_in2{in2_idx});
                            end
                        end
                        output_string = [output_string sprintf('\t%s = %s;\n', list_tmp_out{out_idx}, product_str)];
                        
                        % Add traceability for temporary variables
                        varargin{1}.add_Variable(list_tmp_out{out_idx}, block.Origin_path, idx_in, out_idx, true);
                    end
                end
                in1_dim_c = in2_dim_c;
                list_in1 = list_tmp_out;
                nb_tmp = nb_tmp + numel(list_tmp_out);
                numel_pred = numel_pred + numel_right;
            end
            
            [in2_dim_r in2_dim_c] = Utils.get_port_dims_simple(block.CompiledPortDimensions.Inport, block.Ports(1));
            numel_right = in2_dim_r * in2_dim_c;
            list_in2 = list_in(numel_pred+1:numel_pred+numel_right);
            [out_dim_r out_dim_c] = Utils.get_port_dims_simple(block.CompiledPortDimensions.Outport, 1);
            for idx_row=1:out_dim_r
                for idx_col=1:out_dim_c
                    out_idx = idx_col + ((idx_row-1) * out_dim_c);
                    product_str = '';
                    if is_complex
                        for idx_iter=1:in1_dim_c
                            if idx_iter ~= 1
                                product_str = ['complex_sum_' dt '(' product_str ','];
                            end
                            in1_idx = idx_iter + (idx_row-1) * in1_dim_c;
                            in2_idx = idx_col + (idx_iter-1) * out_dim_c;
                            product_str = sprintf('%s complex_mult_%s(%s, %s)', product_str, dt, list_in1{in1_idx}, list_in2{in2_idx});
                            if idx_iter ~= 1
                                product_str = [product_str ')'];
                            end
                        end
                    else
                        for idx_iter=1:in1_dim_c
                            if idx_iter ~= 1
                                product_str = [product_str ' + '];
                            end
                            in1_idx = idx_iter + (idx_row-1) * in1_dim_c;
                            in2_idx = idx_col + (idx_iter-1) * out_dim_c;
                            product_str = sprintf('%s%s * %s', product_str, list_in1{in1_idx}, list_in2{in2_idx});
                        end
                    end
                    output_string = [output_string sprintf('\t%s = %s;\n', list_out{out_idx}, product_str)];
                end
            end
        end
    end
end

var_out{1} = 'extern_functions';
var_out{2} = extern_funs;
var_out{3} = 'additional_variables';
var_out{4} = var_str;


end
