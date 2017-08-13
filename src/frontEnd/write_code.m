%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [output_string, extern_s_functions_string, extern_functions, properties_nodes, additional_variables, property_node_names, extern_matlab_functions, c_code,external_math_functions] = ...
    write_code(nblk, inter_blk, blks, main_blks, myblk, nom_lustre_file, print_node, trace, xml_trace)

output_string = '';
extern_s_functions_string = '';
extern_matlab_functions = {};
extern_functions = '';
properties_nodes = '';
cpt_extern_functions = 1;
additional_variables = '';
c_code = '';

pre_annot = '';
post_annot = '';
property_node_names = {};
external_math_functions = [];

for idx_block=1:nblk
    sub_blk = get_struct(myblk, blks{idx_block});
    msg = sprintf('Processing %s:%s', sub_blk.Path, sub_blk.BlockType);
    display_msg(msg, Constants.DEBUG, 'write_code', '');
    
    block_string = '';
    extern_funs = {};
    var_str = '';
    is_Chart = false;
    if strcmp(sub_blk.BlockType, 'SubSystem')
        sf_sub = sub_blk.SFBlockType;
        if strcmp(sf_sub, 'Chart')
            is_Chart = true;
        end
    end
    
    %%%%%%%%%%% Gain %%%%%%%%%%%%%%%%%%%%%%
    if strcmp(sub_blk.BlockType, 'Gain')
        K = evalin('base', sub_blk.Gain);
        multiplication = sub_blk.Multiplication;
        
        block_string = write_gain(nom_lustre_file, sub_blk, K, multiplication, inter_blk, myblk);
        
        %%%%%%%%% Abs %%%%%%%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Abs')
        [block_string extern_funs] = write_abs(sub_blk, inter_blk, myblk);
        
        %%%%%%%%%%%%% Logic %%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Logic')
        operator = sub_blk.Operator;
        block_string = write_logic(sub_blk, operator, inter_blk, myblk);
        
        %%%%%%%%%%% Product %%%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Product')
        
        inputs = sub_blk.Inputs;
        % If the inputs parameter is a number then replace it with the
        % correct number of '*'
        if str2num(inputs) >= 1
            res = '';
            for idx_inputs=1:eval(inputs)
                res = [res '*'];
            end
            inputs = res;
        end
        
        collapse_mode = sub_blk.CollapseMode;
        collapse_dim = str2num(sub_blk.CollapseDim);
        
        multiplication = sub_blk.Multiplication;
        
        [block_string, var_str, extern_funs] = write_product(sub_blk, inputs, multiplication, collapse_mode, collapse_dim, inter_blk, xml_trace, myblk);
        
        %%%%%%%%%%%%% Polyval %%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Polyval')
        
        coefs = evalin('base', sub_blk.Coefs);
        
        block_string = write_polyval(sub_blk, inter_blk, coefs, myblk);
        
        %%%%%%%%%%%% MinMax %%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'MinMax')
        
        fun = sub_blk.Function;
        
        [block_string var_str] = write_minmax(nom_lustre_file, sub_blk, fun, inter_blk, xml_trace, myblk);
        
        %%%%%%%%%%%%%%%% Switch %%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Switch')
        
        criteria = sub_blk.Criteria;
        threshold = '';
        if strcmp(criteria, 'u2 >= Threshold') || strcmp(criteria, 'u2 > Threshold')
            threshold = evalin('base', sub_blk.Threshold);
        end
        
        block_string = write_switch(sub_blk, inter_blk, criteria, threshold, myblk);
        
        %%%%%%%%%%%%% DiscreteIntegrator %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'DiscreteIntegrator')
        %Gain
        K = evalin('base', sub_blk.gainval);
        
        %Method
        method = sub_blk.IntegratorMethod;
        if strcmp(method,'Integration: Forward Euler')
            %Sample Time
            msg = sprintf('Make sure that the sample time of block %s is the same as the sample time of the simulation'...
                , sub_blk.Origin_path);
            display_msg(msg,Constants.WARNING,'DiscreteIntegrator','');
            try
                T = sub_blk.CompiledSampleTime;
                T = T(1);
            catch
                T = evalin('base', sub_blk.SampleTime);
            end
        elseif strcmp(method,'Accumulation: Forward Euler')
            T = 1;
        else
            msg = sprintf('method : %s is not supported yet in block %s',char(method), sub_blk.Origin_path);
            display_msg(msg,Constants.ERROR,'DiscreteIntegrator','');
            %             return;
        end
        
        % The initial condition is defined unsing an external constant block
        if strcmp(sub_blk.InitialConditionSource, 'external')
            vinit = '';
        else
            vinit = evalin('base', sub_blk.InitialCondition);
        end
        external_reset =  sub_blk.ExternalReset;
        
        
        limited_int=sub_blk.LimitOutput;
        if strcmp(limited_int,'on')
            sat_int.on=1;
            sat_int.min=eval(sub_blk.LowerSaturationLimit);
            sat_int.max=eval(sub_blk.UpperSaturationLimit);
        else
            sat_int.on=0;
        end
        if sat_int.on==1
            [list_in] = list_var_entree(sub_blk,inter_blk, myblk);
            [list_out]=list_var_sortie(sub_blk);
            list_var={};
            for ki=1:numel(list_out)
                list_var{numel(list_var)+1}=strcat(list_out{ki},'_v');
            end
            sat_int.list_var=list_var;
        end
        
        [block_string, var_str] = write_discreteintegrator(sub_blk, K, external_reset,...
            T, vinit, inter_blk,sat_int, myblk);
        
        %%%%%%%%%%%%%%%% Sum %%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Sum')
        % Remove '|' character from the list of signs parameter value
        signs = sub_blk.Inputs;
        
        %Test if 'listof signs' is a scalar, i.e. signs==2 => signs='++'
        is_scalar= str2num(signs);
        if ~isempty(is_scalar)
            new_signs='';
            for num_add=1:is_scalar
                new_signs=[new_signs '+'];
            end
            signs=new_signs;
        end
        list_signs = [];
        % check the case where signs is a integer (ie. the number of plus)
        [nb_plus, was_uint] = str2num(['uint16(' signs ')']);
        if was_uint && nb_plus > 0
            list_signs=repmat('+',1,nb_plus);
        else % the is a classical ++-- string
            for sign_iter=1:numel(signs)
                if not(strcmp(signs(sign_iter), '|'))
                    list_signs = [list_signs signs(sign_iter)];
                end
            end
        end
        
        collapse_mode = sub_blk.CollapseMode;
        collapse_dim = str2num(sub_blk.CollapseDim);
        
        block_string = write_sum(sub_blk, list_signs, collapse_mode, collapse_dim, inter_blk, myblk);
        
        %%%%%%%%%%%%%%%%%%%% Bias %%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Bias')
        
        bias = sub_blk.Bias;
        bias = evalin('base', bias);
        
        block_string = write_bias(sub_blk, bias, inter_blk, myblk);
        
        %%%%%%%%%%%%%%%%%%%% Concatenate %%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Concatenate')
        
        mode = sub_blk.Mode;
        dim = sub_blk.ConcatenateDimension;
        block_string = write_concatenate(sub_blk, mode, dim, inter_blk, myblk);
        
        %%%%%%%%%%%%%%%%%%% MultiPortSwitch %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'MultiPortSwitch')
        
        order = sub_blk.DataPortOrder;
        indices = sub_blk.DataPortIndices;
        inputs = sub_blk.Inputs;
        default_dp = sub_blk.DataPortForDefault;
        
        diff_input_size = sub_blk.AllowDiffInputSizes;
        if strcmp(diff_input_size, 'on')
            msg = 'MultiPortSwitch is not allowed to have different sizes of inputs ports:\n';
            msg = [msg sub_blk.Origin_path];
            display_msg(error_msg, Constants.ERROR, 'write_code', '');
        else
            block_string = write_multiportswitch(sub_blk, order, indices, inputs, default_dp, inter_blk, myblk);
        end
        
        %%%%%%%%%%%%%%%% Discrete state space %%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType,'DiscreteStateSpace')
        
        dss_A = evalin('base', sub_blk.A);
        dss_B = evalin('base', sub_blk.B);
        dss_C = evalin('base', sub_blk.C);
        dss_D = evalin('base', sub_blk.D);
        X0 = evalin('base', sub_blk.X0);
        
        [block_string, var_str] = write_dss(sub_blk, dss_A, dss_B, dss_C,dss_D, X0, inter_blk, xml_trace, myblk);
        
        %%%%%%%%%%%%%%%% Function %%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Fcn')
        
        fun_expr = sub_blk.Expr;
        
        [block_string, ext_node, var_str, external_math_functions_i] = write_function_block(sub_blk, inter_blk, fun_expr, xml_trace, myblk);
        extern_s_functions_string = [extern_s_functions_string, ext_node];
        external_math_functions = [external_math_functions, external_math_functions_i];
        
        %%%%%%%%%%%%% Saturation %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Saturate')
        sat_min = sub_blk.LowerLimit;
        sat_max = sub_blk.UpperLimit;
        rndmeth = sub_blk.RndMeth;
        
        block_string = write_saturation(nom_lustre_file, sub_blk, sat_min, sat_max, rndmeth, inter_blk, myblk);
        
        %%%%%%%%%%%%% RelationalOperator %%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'RelationalOperator')
        
        operator = sub_blk.Operator;
        
        block_string = write_relationaloperator(sub_blk, operator, inter_blk, myblk);
        
        %%%%%%%%%%%%% Demux %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType,'Demux')
        
        block_string = write_demux(nom_lustre_file, sub_blk, inter_blk, myblk);
        
        %%%%%%%%%%%%% IF ELSE IF ELSE %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType,'If')
        
        if_expr = sub_blk.IfExpression;
        elseif_expr = sub_blk.ElseIfExpressions;
        num_var = evalin('base', sub_blk.NumInputs);
        show_else = sub_blk.ShowElse;
        
        block_string = write_ifelseif(sub_blk, inter_blk, if_expr, elseif_expr, num_var, show_else, myblk);
        
        %%%%%%%%%%%%% UnitDelay %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'UnitDelay')
        init = sub_blk.X0;
        init = evalin('base', init);
        Ts = sub_blk.SampleTime;
        
        block_string = write_unitdelay(sub_blk, init, Ts, inter_blk, myblk);
        
        %%%%%%%%%%%%% Delay %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Delay')
        init = sub_blk.X0;
        init = evalin('base', init);
        delay_length = sub_blk.DelayLength;
        block_string = write_delay(sub_blk, init, delay_length, inter_blk, myblk);
        
        %%%%%%%%%%%%% Memory %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType,'Memory')
        init = sub_blk.X0;
        init = evalin('base', init);
        block_string = write_memory(sub_blk, init, inter_blk, myblk);
        
        %%%%%%%%%%%%% Bloc constant %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Constant')
        Kvalue = evalin('base', sub_blk.Value);
        [block_string,var_str] = write_constant(nom_lustre_file, sub_blk, inter_blk, Kvalue);
        
        %%%%%%%%%%% DataTypeConversion %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'DataTypeConversion')
        
        block_string = write_datatypeconversion(sub_blk, inter_blk, myblk);
        
        %%%%%%%%%%% SignalSpecification %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'SignalSpecification')
        
        block_string = write_signalspecification(sub_blk, inter_blk, myblk);
        
        %%%%%%%%%%% Goto/From %%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Goto') || strcmp(sub_blk.BlockType, 'From')
        
        tag_value = sub_blk.GotoTag;
        
        [block_string, var_str] = write_goto_from(sub_blk, inter_blk, tag_value, xml_trace, myblk);
        
        %%%%%%%%%%%%% Merge %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Merge')
        
        block_string = write_merge(sub_blk, inter_blk, myblk);
        
        %%%%%%%%%%%%% Mux %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Mux')
        
        block_string = write_mux(sub_blk, inter_blk, myblk);
        
        %%%%%%%%%%%%% BusSelector %%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'BusSelector')
        
        output_signals = sub_blk.OutputSignals;
        out_as_bus = sub_blk.OutputAsBus;
        block_string = write_busselector(sub_blk, inter_blk, output_signals, out_as_bus, myblk);
        
        %%%%%%%%%%%%% BusCreator %%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'BusCreator')
        
        non_virtual = sub_blk.NonVirtualBus;
        
        block_string = write_buscreator(sub_blk, inter_blk, non_virtual, myblk);
        
        %%%%%%%%%%%%% BusAssignment %%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'BusAssignment')
        
        assigned = sub_blk.AssignedSignals;
        
        block_string = write_busassignment(sub_blk, inter_blk, assigned, myblk);
        
        %%%%%%%%%%%% Reshape %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Reshape')
        
        block_string = write_reshape(sub_blk, inter_blk, myblk);
        
        %%%%%%%%%%%%% Trigonometry %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Trigonometry')
        
        op_trigo = sub_blk.Operator;
        
        [block_string, extern_funs] = write_trigo(nom_lustre_file, sub_blk, op_trigo, inter_blk, myblk);
        
        %%%%%%%%%%%%% DotProduct %%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'DotProduct')
        
        [block_string, var_str] = write_dotproduct(sub_blk, inter_blk, xml_trace, myblk);
        
        %%%%%%%%%%%%% Maths function & Sqrt %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Math') || strcmp(sub_blk.BlockType, 'Sqrt')
        
        % exp, log, 10^u, log10, magnitude ^2, square, sqrt, pow, conj, reciprocal, hypot, rem, mod, transpose, hermitian
        math_op = sub_blk.Operator;
        if strcmp(math_op, 'hermitian') || strcmp(math_op, 'transpose')
            error_msg = ['Unhandled Math block operation: ' math_op];
            error_msg = [error_msg '\n' sub_blk.Origin_path];
            display_msg(error_msg, Constants.ERROR, 'write_code', '');
        else
            [block_string extern_funs] = write_math_fun(sub_blk, inter_blk, math_op, myblk);
        end
        
        %%%%%%%%%%%%% Step %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Step')
        
        start = sub_blk.Time;
        before = sub_blk.Before;
        after = sub_blk.After;
        
        write_step(nom_lustre_file,sub_blk,math_op, myblk);
        
        %%%%%%%%%%%%% Bitwise Operator %%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Bitwise Operator')
        
        operator = sub_blk.logicop;
        bit_mask = evalin('base', sub_blk.BitMask);
        use_bit_mask = sub_blk.UseBitMask;
        num_input = evalin('base', sub_blk.NumInputPorts);
        real_world = sub_blk.BitMaskRealWorld;
        
        [block_string extern_funs] = write_bitwise(sub_blk, inter_blk, operator, bit_mask, use_bit_mask, num_input, real_world, myblk);
        
        %%%%%%%%%%% Reference %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Reference')
        
        source_type = sub_blk.SourceType;
        
        %%%%%%%%%%%%%%%%% Saturation Dynamic %%%%%%%%%%%%%%%%
        if strcmp(source_type, 'Saturation Dynamic')
            
            outMin = sub_blk.OutMin;
            outMin = evalin('base', outMin);
            outMax = sub_blk.OutMax;
            outMax = evalin('base', outMax);
            
            block_string = write_saturation_dynamic(sub_blk, inter_blk, outMin, outMax, myblk);
            
        else
            
            error_msg = ['Reference block not handled in the generation - Source:' source_type '\n'];
            error_msg = [error_msg sub_blk.Origin_path];
            display_msg(error_msg, Constants.ERROR, 'write_code', '');
            
        end
        
        %%%%%%%%%%%%%%%%%%% S-Function %%%%%%%%%%%%%%%%%%%%%
        
        %% It needs major revision %%
    elseif strcmp(sub_blk.BlockType, 'S-Function')
        function_name = sub_blk.FunctionName;
        % get port connectivity
        props = sub_blk.PortConnectivity;
        n_blocks =numel(props);
        for k=1:n_blocks
            s=get(props(k).SrcBlock);
            f='Source';
            if isempty(s)
                s=get(props(k).DstBlock);
                f='Destination';
            end
            prop_conn{k,1}=f;
            prop_conn{k,2}=s.BlockType;
            prop_conn{k,3}=s.Name;
        end
        block_string = write_s_function(sub_blk, function_name, prop_conn, inter_blk, myblk);
        
        % Write S-Function extern node
        [extern_s_function, c_code] = write_extern_s_function(sub_blk, inter_blk, function_name, prop_conn, myblk);
        extern_s_functions_string = [extern_s_functions_string extern_s_function];
        
        %%%%%%%%%%%%%% Zero-Pole %%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, Constants.zero_pole_discrete)
        
        zero = sub_blk.Zeros;
        zero = evalin('base', zero);
        poles = sub_blk.Poles;
        poles = evalin('base', poles);
        gain = sub_blk.Gain;
        gain = evalin('base', gain);
        
        block_string = write_zero_pole(sub_blk, inter_blk, zero, poles, gain, myblk);
        
        %%%%%%%%%%%%%% Assignment %%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Assignment')
        
        nb_dim = evalin('base', sub_blk.NumberOfDimensions);
        index_opt = sub_blk.IndexOptions;
        indices = sub_blk.Indices;
        index_mode = sub_blk.IndexMode;
        
        block_string = write_assignment(sub_blk, inter_blk, nb_dim, index_opt, indices, index_mode, myblk);
        
        %%%%%%%%%%%%%% Selector %%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Selector')
        
        nb_dim = evalin('base', sub_blk.NumberOfDimensions);
        index_opt = sub_blk.IndexOptions;
        indices = sub_blk.Indices;
        index_mode = sub_blk.IndexMode;
        output_sizes = sub_blk.OutputSizes;
        
        nb_select_all = numel(strfind(index_opt, 'Select all'));
        nb_index_vect = numel(strfind(index_opt, 'Index vector (dialog)'));
        nb_index_vect_port = numel(strfind(index_opt, 'Index vector (port)'));
        nb_start_index = numel(strfind(index_opt, 'Starting index (dialog)'));
        
        if nb_select_all + nb_index_vect + nb_index_vect_port + nb_start_index == nb_dim
            block_string = write_selector(sub_blk, inter_blk, nb_dim, index_opt, indices, index_mode, output_sizes, myblk);
        else
            error_msg = 'Selector block implementation does not handle all these modes\n';
            error_msg = [error_msg sub_blk.Origin_path];
            display_msg(error_msg, Constants.ERROR, 'write_code', '');
        end
        
        %%%%%%%%%%%%%% ForIterator %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'ForIterator')
        
        iter_source = sub_blk.IterationSource;
        if strcmp(iter_source, 'external')
            error_msg = 'ForIterator block implementation does not support external iteration limit\n';
            error_msg = [error_msg sub_blk.Origin_path];
            display_msg(error_msg, Constants.ERROR, 'write_code', '');
        end
        ext_incr = sub_blk.ExternalIncrement;
        show_iter_port = sub_blk.ShowIterationPort;
        index_mode = sub_blk.IndexMode;
        iter_dt = sub_blk.IterationVariableDataType;
        
        block_string = write_foriterator(sub_blk, inter_blk, ext_incr, show_iter_port, iter_dt, index_mode, myblk);
        
        %%%%%%%%%%% Switch case %%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'SwitchCase')
        
        cond = evalin('base', sub_blk.CaseConditions);
        default_case = sub_blk.ShowDefaultCase;
        
        block_string = write_switchcase(sub_blk, inter_blk, cond, default_case, myblk);
        
        %%%%%%%%%%% ActionPort %%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'ActionPort')
        
        %%%%%%%%%%% TriggerPort %%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'TriggerPort')
        
        show_port = sub_blk.ShowOutputPort;
        if strcmp(show_port, 'on')
            trigger_type = sub_blk.TriggerType;
            block_string = write_triggerport(sub_blk, inter_blk, trigger_type);
        end
        
        %%%%%%%%%%% EnablePort %%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'EnablePort')
        
        show_port = sub_blk.ShowOutputPort;
        if strcmp(show_port, 'on')
            block_string = write_enableport(sub_blk, inter_blk);
        end
        
        %     	%%%%%%%%%%% ROUNDING %%%%%%%%%%%%%%%%%
        %     elseif strcmp(sub_blk.BlockType, 'Rounding')
        %
        %                 operation = sub_blk.Operator;
        %                  block_string = write_rounding(sub_blk, inter_blk, operation, myblk);
        %
        %                  %%%%%%%%% Combinatory logic %%%%%%%%%%%%%%%%%%%%%%%%
        %     elseif strcmp(sub_blk.BlockType, 'CombinatorialLogic')
        %
        %         truth_table=sub_blk.TruthTable;
        %
        %         [block_string] = write_CmbLogic(sub_blk, inter_blk, truth_table, myblk);
        %
        %         %%%%%%%%%lookup table %%%%%%%%%%%%%%%%%%%%%%%%
        %     elseif strcmp(sub_blk.BlockType, 'Lookup')
        %
        % %UNFINISHED WORK CHECK write_function
        %         [block_string] = write_lookup(sub_blk, inter_blk, myblk);
        
        %%%%%%%%%%%%%%%%% SubSystem %%%%%%%%%%%%%%%%%%%%%%%%
        % Print SubSystem as a node call only if it is not the first of the list (aka the current SubSystem)
        
    elseif (strcmp(sub_blk.BlockType, 'SubSystem') || strcmp(sub_blk.BlockType, 'ModelReference')) && (not(idx_block == 1) || is_Chart)
                
        if ~strcmp(sub_blk.MaskType, '')
            %%%%%%%%%%%% Reference masked blocks %%%%%%%%%%%%%
            if Constants.is_ref_mask(sub_blk.MaskType)
                
                %%%%%%%%%%%%%% Implication %%%%%%%%%%%%%%%%
                if strcmp(sub_blk.MaskType, 'CoCoSim-Implies')
                    block_string = write_logic(sub_blk, 'IMPLIES', inter_blk, myblk);
                    
                    %%%%%%%%%%%%%% Dynamic saturation %%%%%%%%%%%%%%%%
                elseif strcmp(sub_blk.MaskType, Constants.sat_dyn_ref)
                    outMin = sub_blk.OutMin;
                    outMin = evalin('base', outMin);
                    outMax = sub_blk.OutMax;
                    outMax = evalin('base', outMax);
                    block_string = write_saturation_dynamic(sub_blk, inter_blk, outMin, outMax, myblk);
                    
                    %%%%%%%%%%%%%% Zero Pole %%%%%%%%%%%%%%%%%%%
                elseif strcmp(sub_blk.MaskType, Constants.zero_pole_ref)
                    
                    zero = sub_blk.Zeros;
                    zero = evalin('base', zero);
                    poles = sub_blk.Poles;
                    poles = evalin('base', poles);
                    gain = sub_blk.Gain;
                    gain = evalin('base', gain);
                    block_string = write_zero_pole(sub_blk, inter_blk, zero, poles, gain, myblk);
                    
                    %%%%%%%%%%%%% CompareTo family of blocks %%%%%%%%%%%%
                elseif Constants.isCompareToMask(sub_blk.MaskType)
                    
                    relop = sub_blk.relop;
                    if strcmp(sub_blk.MaskType, Constants.compare_to_constant)
                        const = evalin('base', sub_blk.const);
                    else
                        in_dt = Utils.get_lustre_dt(sub_blk.CompiledPortDataTypes.Inport{1});
                        if strcmp(in_dt, 'real')
                            const = 0.0;
                        else
                            const = 0;
                        end
                    end
                    
                    outdtstr = sub_blk.OutDataTypeStr;
                    [block_string, var_str] = write_compareto(sub_blk, inter_blk, relop, const, outdtstr, xml_trace, myblk);
                    
                else
                    error_msg = ['Unhandled masked block: ' sub_blk.Origin_path];
                    error_msg = [error_msg '\nMask type: ' sub_blk.MaskType];
                    display_msg(error_msg, Constants.ERROR, 'write_code', '');
                    
                end
                
                %%%%%%%%%%%%%%%%%% Observer Property %%%%%%%%%%%%%%%%%
            elseif Constants.is_property(sub_blk.MaskType)
                
                annot_type = sub_blk.AnnotationType;
                annotations = sub_blk.Annotation;
                disp(annotations)
                observer_type = sub_blk.ObserverType;
                try
                    [property_node, ext_node, extern_funs, property_name,external_math_functions_i] = write_property(sub_blk, ...
                        inter_blk, myblk, main_blks, nom_lustre_file, print_node, trace, annot_type, observer_type, xml_trace);
                    
                    properties_nodes = [properties_nodes property_node];
                    extern_s_functions_string = [extern_s_functions_string, ext_node];
                    nb = numel(property_node_names)+1;
                    property_node_names{nb}.prop_name = property_name;
                    property_node_names{nb}.origin_block_name = sub_blk.Origin_path;
                    property_node_names{nb}.annotation = sub_blk.Handle;
                    external_math_functions = [external_math_functions, external_math_functions_i];
                catch ME
                    %                     disp(ME.getReport())
                    if strcmp(ME.identifier, 'MATLAB:badsubscript')
                        msg= 'Bad encoding of the property. Make sure to link the main input of the model into the observer';
                        display_msg(msg, Constants.ERROR, 'cocoSim', '');
                        
                    else
                        display_msg(ME.getReport(), Constants.ERROR, 'cocoSim', '');
                    end
                end
                
                %%%%%%%%%%%%%%%%% Detect %%%%%%%%%%
            elseif Constants.isDetectMask(sub_blk.MaskType)
                
                vinit = evalin('base', sub_blk.vinit);
                
                block_string = write_detect(sub_blk, inter_blk, vinit, myblk);
                
                %%%%%%%%%%%%% CrossProduct %%%%%%%%%%%%%%%%%
            elseif strcmp(sub_blk.MaskType, 'Cross Product')
                
                block_string = write_crossproduct(sub_blk, inter_blk, myblk);
                
            elseif strcmp(sub_blk.MaskType, 'Create 3x3 Matrix')
                block_string = write_3x3_Matrix(sub_blk, inter_blk, myblk);
            else
                error_msg = ['Unhandled masked block: ' sub_blk.Origin_path];
                error_msg = [error_msg '\nMask type: ' sub_blk.MaskType];
                display_msg(error_msg, Constants.ERROR, 'write_code', '');
            end
            
            %%%%%%%%%%%%%%%%%% Classical SubSystem %%%%%%%%%%%%
        elseif sub_blk.Ports(2) ~= 0
            display_msg('Classical Susbsystem', Constants.DEBUG, 'write_code', '');
            [block_string, var_str] = write_subsystem(sub_blk, inter_blk, myblk, xml_trace);
            
        end
        
        %%%%%%%%%%%%%%%%%% Outport %%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Outport')
        
        block_string = write_outport(nom_lustre_file, sub_blk, inter_blk, myblk);
        
        %%%%%%%%%%%%%%%%%% LookupNDDirect %%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'LookupNDDirect')
        
        nb_dim = evalin('base', sub_blk.NumberOfTableDimensions);
        select = sub_blk.InputsSelectThisObjectFromTable;
        is_input = sub_blk.TableIsInput;
        table = evalin('base', sub_blk.Table);
        
        block_string = write_lookupnddirect(sub_blk, inter_blk, nb_dim, select, is_input, table, myblk);
        
        %%%%%%%%%%%%%%%%%% Signum %%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Signum')
        
        [block_string extern_funs] = write_signum(sub_blk, inter_blk, myblk);
        
        %%%%%%%%%%%%%%%%%% FromWorkspace %%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'FromWorkspace')
        
        data = evalin('base', sub_blk.VariableName);
        
        block_string = write_fromworkspace(sub_blk, inter_blk, data, myblk);
        
        %%%%%%%%%%%%%%%%%% SignalConversion %%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'SignalConversion')
        block_string = write_SignalConversion(sub_blk, inter_blk, myblk);
        error_msg = [' SignalConversion block could be not well translated.\n'];
        display_msg(error_msg, Constants.WARNING, 'write_code', '');
        
        %%%%%%%%%%%%%%%%%% Lookup %%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Lookup')
        
        error_msg = ['There should not be a Lookup block in this model. It has been pre-processed.\n'];
        error_msg = [error_msg 'Please remove the Lookup block and connect the replacement SubSystem:\n'];
        error_msg = [error_msg sub_blk.Origin_path];
        display_msg(error_msg, 3, 'write_code', '');
        
        %%%%%%%%%%%%%%%%%% TransferFcn %%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'TransferFcn')
        
        error_msg = ['There should not be a TransferFcn block in this model. It has been pre-processed.\n'];
        error_msg = [error_msg 'Please remove the original TransferFcn block and connect the replacement SubSystem:\n'];
        error_msg = [error_msg sub_blk.Origin_path];
        display_msg(error_msg, 3, 'write_code', '');
        
        %%%%%%%%%%%%%%% Scope %%%%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Scope')
        
        warning_msg = ['A Scope block have been found. No code will be generated for it:\n' sub_blk.Origin_path];
        display_msg(warning_msg, 2, 'write_code', '');
        
        %%%%%%%%%%%%%%% Terminator %%%%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Terminator')
        
        warning_msg = ['A Terminator block have been found. No code will be generated for it:\n' sub_blk.Origin_path];
        display_msg(warning_msg, 2, 'write_code', '');
        
        %%%%%%%%%%%%%%% ToWorkspace %%%%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'ToWorkspace')
        
        warning_msg = ['A ToWorkspace block have been found. No code will be generated for it:\n' sub_blk.Origin_path];
        display_msg(warning_msg, 2, 'write_code', '');
        
        %%%%%%%%%%%%%%%%%%% Any other block %%%%%%%%%%%%%%%%
    elseif ~strcmp(sub_blk.BlockType, 'Inport') && ~((strcmp(sub_blk.BlockType, 'SubSystem') || strcmp(sub_blk.BlockType, 'ModelReference')) && idx_block == 1)
        
        block_type = sub_blk.BlockType;
        error_msg = ['Block compilation not implemented for block type: ' block_type];
        error_msg = [error_msg '\n' sub_blk.Origin_path];
        display_msg(error_msg, 2, 'write_code', '');
        
    end
    
    %%%% Final addition of the block values to the return values %%%%
    
    % Add traceability annotations as comments on the code
    if trace
        [pre_annot post_annot] = traceability_annotation(sub_blk);
    end
    output_string = [output_string pre_annot block_string post_annot];
    
    % Add extern functions to the main return list
    for idx_ext_funs=1:numel(extern_funs)
        extern_functions{cpt_extern_functions} = extern_funs{idx_ext_funs};
        cpt_extern_functions = cpt_extern_functions + 1;
    end
    
    % Add additional variables definitions to the main return string
    if ~strcmp(var_str, '')
        additional_variables = [additional_variables var_str];
    end
    
end

end


