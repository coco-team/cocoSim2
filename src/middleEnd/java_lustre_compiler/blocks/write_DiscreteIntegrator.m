%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% DiscreteIntegrator block
% Please refer to the Documentation here :
% https://fr.mathworks.com/help/simulink/slref/discretetimeintegrator.html
%  There are Two modes : integration and accumulation.
%
% Perform discrete-time integration or accumulation of signal
% We only support two methodes :
% Accumulation: Forward Euler and Integration: Forward Euler
%
% K is the gain of the integration
%
% The External reset parameter lets you determine the attribute
% of the reset signal that triggers the reset.
% The trigger options include:rising, falling, either, level, sampled level
% please refer to documentation (url above) for more explanation
%
% T is the sample time of the block:
%  In integration mode,
% T is the block sample time (delta T in the case of triggered sample time).
% In accumulation mode, T = 1.
% As you see the user should make sure that the sample time is the same as
% the simulation, in integration mode the sample time  determines when the
% output is computed but not the output value !!!!!!!
%
% vinit is the initial value (used if the value is constant)
%
%% Generation scheme
% Y is the output, x is the input, y0 is the initial condition, reset is
% the reset input signal
% Example 1 :
% Reset type : Level, Data Type : boolean
% Level_bool_Reset_Trigger =
%           false -> reset or (pre(reset)!= reset);
% y = yo -> if Level_bool_Reset_Trigger
%     then yo
%     else (1.0 * 0.1)*(pre x) + pre y;
%
%
% Example 1bis :
% Reset type : Level, Data Type : int
% Level_int_Reset_Trigger =
%     false -> (reset!=0) or (pre(reset) != 0 and reset =0);
% 	y = yo -> if Level_int_Reset_Trigger
%             then yo
%                 else (1.0 * 0.10)*(pre x) + pre y;
%%%
%% Code
%
function [output_string, var_out] = write_DiscreteIntegrator(block, ir_struct, varargin)

output_string = '';

sub_blk = get_subsystem_struct(ir_struct, block);

%Gain
K = getParamValue(ir_struct, block, block.gainval);

%Method
method = block.IntegratorMethod;
if strcmp(method,'Integration: Forward Euler')
    %Sample Time
    msg = sprintf('Make sure that the sample time of block %s is the same as the sample time of the simulation'...
        , block.Origin_path);
    display_msg(msg,Constants.WARNING,'DiscreteIntegrator','');
    try
        T = block.CompiledSampleTime;
        T = T(1);
    catch
        T = getParamValue(ir_struct, block, block.SampleTime);
    end
elseif strcmp(method,'Accumulation: Forward Euler')
    T = 1;
else
    msg = sprintf('method : %s is not supported yet in block %s',char(method), block.Origin_path);
    display_msg(msg,Constants.ERROR,'DiscreteIntegrator','');
end

% The initial condition is defined unsing an external constant block
if strcmp(block.InitialConditionSource, 'external')
    vinit = '';
else
    vinit = getParamValue(ir_struct, block, block.InitialCondition);
end
external_reset =  block.ExternalReset;

% sat_int
limited_int=block.LimitOutput;
if strcmp(limited_int,'on')
    sat_int.on=1;
    sat_int.min=eval(block.LowerSaturationLimit);
    sat_int.max=eval(block.UpperSaturationLimit);
else
    sat_int.on=0;
end

[list_in] = list_var_entree(block, ir_struct);
[list_out] = list_var_sortie(block);

if sat_int.on==1
    list_var={};
    for ki=1:numel(list_out)
        list_var{numel(list_var)+1}=strcat(list_out{ki},'_v');
    end
    sat_int.list_var=list_var;
end

cst_type = block.CompiledPortDataTypes.Outport(1);
[list_const] = Utils.list_cst(K, cst_type);
[list_T] = Utils.list_cst(T, cst_type);

[dim_r, dim_c] = Utils.get_port_dims_simple(block.CompiledPortDimensions.Outport, 1);

% Expand inputs if necessary
list_in = LusUtils.expand_all_inputs_according_output(block, list_in, 1);

[is_reset, reset_var_name] = LusUtils.is_reset(sub_blk);

% Expand gain if necessary
if numel(list_const) == 1 && block.CompiledPortWidths.Outport ~= 1
    value = list_const{1, 1};
    for idx_row=1:dim_r
        for idx_col=1:dim_c
            value_idx = idx_col + ((idx_row-1) * dim_c);
            list_const{value_idx} = value;
        end
    end
end

% Expand vinit if necessary

if ~strcmp(vinit, '') && ~strcmp(class(vinit),'cell') % If vinit non-empty and is not a cell
    [list_init] = Utils.list_cst(vinit, cst_type);
    if numel(list_init) == 1 && block.CompiledPortWidths.Outport ~= 1
        value = list_init{1, 1};
        for idx_row=1:dim_r
            for idx_col=1:dim_c
                value_idx = idx_col + ((idx_row-1) * dim_c);
                list_init{value_idx} = value;
            end
        end
    end
    
elseif iscell(vinit) % if vinit is a cell issued from an external condition (function block for examle)
    %Onera code
    list_input='';
    list_input_init='';
    
    name_bloc_pre=name_block(sub_blk,cocoget_param(block.Pre(2), 'Path'));
    
    for k2=1:sub_blk.Content.(name_bloc_pre).Ports(1) %test on input number
        
        if k2 > 1
            list_input=strcat(list_input,{', '});
        end
        
        [a b]=regexp (cocoget_param(sub_blk.Content.(name_bloc_pre).Pre(k2), 'Path'), filesep, 'split');
        num_out_pre=sub_blk.Content.(name_bloc_pre).CompiledPortWidths.Inport(k2)+1; % numerotation starts at 0 !!
        
        %[li_index]=list_var_entree_prelude(inter_blk.Content.(nom_bloc_pre));
        
        
        cpt=nom_block(sub_blk, cocoget_param(sub_blk.Content.(name_bloc_pre).Pre(k2), 'Path'));
        
        for k3=1:sub_blk.Content.(name_bloc_pre).CompiledPortWidths.Inport(k2)
            if k3 > 1
                list_input=strcat(list_input,{', '});
            end
            nom_pre_block=nom_block(sub_blk,cocoget_param(sub_blk.Content.(name_bloc_pre).Pre(k2), 'Path'));
            
            list_input=strcat(list_input,{' '}, strcat(a{1}{end},'_',li_index{k3} ));
        end
        
        
        
        if k3 < block.CompiledPortWidths.Inport(k2)
            list_input=strcat(list_input,{', '});
        end
        
    end
    
    vinit=strcat(nommage(sub_blk.Content.(name_bloc_pre).Path),'(',list_input,')');% in this case vinit is a cell
    list_init=vinit;
    
end

out_dt = LusUtils.get_lustre_dt(block.CompiledPortDataTypes.Outport(1));
in_dt = LusUtils.get_lustre_dt(block.CompiledPortDataTypes.Inport(1));
needs_convert = false;
convert_fun = '';
if ~strcmp('real', out_dt) &&  ~(strcmp('int', in_dt) || strcmp('bool', in_dt))
    convert_fun = block.RndMeth;
    needs_convert = true;
    if exist('tmp_dt_conv.mat', 'file') == 2
        load 'tmp_dt_conv'
        if exist('rounding', 'var')
            rounding = [rounding ' ' convert_fun];
        else
            rounding = convert_fun;
        end
        save('tmp_dt_conv.mat', 'rounding', '-append');
    else
        rounding = convert_fun;
        save('tmp_dt_conv.mat', 'rounding');
    end
end
if strcmp('real', out_dt) &&  (strcmp('int', in_dt) || strcmp('bool', in_dt))
    msg = sprintf('The block %s has input of type %s but output of type %s \n', block.Origin_path,in_dt,char(list_out{1}),out_dt);
    msg = [msg sprintf('Be sure to change inputs to %s\n',out_dt)];
    display_msg(msg, Constants.ERROR, 'write_discreteintegrator', '');
end
nb_elem_first = dim_r * dim_c;

if strcmp(block.CompiledPortDataTypes.Outport(1), 'double') || strcmp(block.CompiledPortDataTypes.Outport(1), 'simple') || strncmp(block.CompiledPortDataTypes.Outport(1), 'sfix', 4) || strncmp(block.CompiledPortDataTypes.Outport(1), 'ufix', 4)
    conv_int = false;
else
    conv_int = true;
end
var_str = [];

for idx_row=1:dim_r
    for idx_col=1:dim_c
        in_out_idx = idx_col + ((idx_row - 1) * dim_c);
        prestate = ['pre ' list_in{in_out_idx}];
        preOut = ['pre ' list_out{in_out_idx}];
        cstate = sprintf('(%s * %s)*(%s) + %s', list_const{in_out_idx}, list_T{1}, prestate,preOut);
        
        if ~strcmp(external_reset, 'none') && strcmp(vinit, '')
            % 3 inputs to the block
            [in2_dim_r, in2_dim_c] = Utils.get_port_dims_simple(block.CompiledPortDimensions.Inport, 2);
            
            nb_elem_second = in2_dim_r * in2_dim_c;
            shift_third_input = nb_elem_first + nb_elem_second;
            
            input_name = list_in{in_out_idx + shift_third_input};
        elseif ~strcmp(external_reset, 'none')
            % 2 inputs and the second input is the reset
            input_name = list_init{in_out_idx};
        elseif strcmp(vinit, '')
            % 2 inputs and the second input is the IC
            input_name = list_in{in_out_idx + nb_elem_first};
        else
            % 1 input
            input_name = list_init{in_out_idx};
        end
        reset_cond = '';
        if is_reset
            reset_cond = sprintf('if %s then %s else ', reset_var_name, input_name);
        end
        
        %new code : add Reset Trigger Types (see description above)
        if ~strcmp(external_reset, 'none')
            cond_var = list_in{in_out_idx + nb_elem_first};
            expression = get_trigger_conditions(block,external_reset, cond_var);
            var_name = LusUtils.var_naming(block, strcat('_Reset_Trigger',num2str(idx_row),'_', num2str(idx_col)));
            %             var_name = strcat(Utils.name_format(Utils.naming_alone(unbloc.origin_name{1})),'_Reset_Trigger',num2str(idx_row),'_', num2str(idx_col));
            output_string = app_sprintf(output_string, '\t%s = %s;\n', var_name,expression);
            var_str = [var_str, sprintf('\t%s: bool;\n',var_name)];
            
            out_str = sprintf('%s%s -> ', reset_cond, input_name);
            out_str = app_sprintf(out_str, 'if %s ', var_name);
            out_str = app_sprintf(out_str, 'then %s ', input_name);
            out_str = app_sprintf(out_str, 'else %s', cstate);
        else
            out_str = sprintf('%s%s -> ', reset_cond, input_name);
            out_str = app_sprintf(out_str, '%s', cstate);
        end
        
        if sat_int.on==1
            output_string = app_sprintf(output_string, '\t%s = %s(%s);\n', sat_int.list_var{in_out_idx}, convert_fun, out_str);
            output_string = app_sprintf(output_string,'\t%s = ',list_out{in_out_idx});
            output_string = app_sprintf(output_string,'\tif %s >= %f then %f \n',sat_int.list_var{in_out_idx},sat_int.max,sat_int.max);
            output_string = app_sprintf(output_string,'\telse if %s <= %f then %f \n',sat_int.list_var{in_out_idx},sat_int.min,sat_int.min );
            output_string = app_sprintf(output_string,'\telse %s ;\n\n',sat_int.list_var{in_out_idx});
        else
            if needs_convert
                output_string = app_sprintf(output_string, '\t%s = %s(%s);\n', list_out{in_out_idx}, convert_fun, out_str);
            else
                output_string = app_sprintf(output_string, '\t%s = %s;\n', list_out{in_out_idx}, out_str);
            end
        end
    end
end

var_out{1} = 'additional_variables';
var_out{2} = var_str;
end
function [expression] = get_trigger_conditions(unbloc, external_reset,cond_var)
trigger_dt = LusUtils.get_lustre_dt(unbloc.CompiledPortDataTypes.Inport(2));
expression = '';

if strcmp(trigger_dt, 'bool')
    if strcmp(external_reset, 'rising')
        expression = sprintf('false -> (not(pre %s) and %s)', cond_var, cond_var);
    elseif strcmp(external_reset, 'falling')
        expression = sprintf('false -> (pre(%s) and not(%s))', cond_var, cond_var);
    elseif strcmp(external_reset, 'either')
        expression = sprintf('false -> (not(pre(%s) = %s))', cond_var, cond_var);
    elseif strcmp(external_reset, 'level')
        expression = sprintf('false -> %s or (pre(%s) <> %s)', cond_var, cond_var, cond_var);
    elseif strcmp(external_reset, 'sampled level')
        expression = cond_var;
    else
        msg = sprintf('%s trigger not supported\n', external_reset);
        display_msg(msg, Constants.ERROR, 'write_discreteintegrator', '');
    end
else
    if strcmp(trigger_dt, 'int')
        zero = '0';
    else
        msg = sprintf('the reset input of block %s is of type double, we suggest to use integer or boolean types',...
            unbloc.Origin_path);
        display_msg(msg,Constants.WARNING, 'Reset Type','');
        zero = '0.0';
    end
    if strcmp(external_reset, 'rising')
        expression = sprintf('false -> (pre(%s) <= %s and %s > %s)', cond_var, zero, cond_var, zero);
    elseif strcmp(external_reset, 'falling')
        expression = sprintf('false -> (pre(%s) > %s and %s <= %s)', cond_var, zero, cond_var, zero);
    elseif strcmp(external_reset, 'either')
        expression = sprintf('false -> ((pre(%s) > %s and %s <= %s) or (pre(%s) <= %s and %s > %s))', ...
            cond_var, zero, cond_var, zero, cond_var, zero, cond_var, zero);
    elseif strcmp(external_reset, 'level')
        expression = sprintf('false -> (%s<>%s) or (pre(%s) <> %s and %s = %s)',...
            cond_var, zero, cond_var, zero, cond_var, zero);
    elseif strcmp(external_reset, 'sampled level')
        expression = sprintf('false -> (%s != %s)', cond_var, zero);
    else
        msg = sprintf('%s trigger not supported\n', external_reset);
        display_msg(msg, Constants.ERROR, 'write_discreteintegrator', '');
    end
end
end

