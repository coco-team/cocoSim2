function new_ir = conversion(new_ir)

% Model's name
    model_path = new_ir.meta.file_path;
    [~, model_name, ~] = fileparts(model_path);
    new_ir = conversion_aux(new_ir, model_name);
end

function new_ir = conversion_aux(old_ir, model_name)

new_ir = old_ir;
if nargin >= 2
    ir_struct = old_ir.(model_name);
else
    ir_struct = old_ir;
end

fields = fieldnames(ir_struct.Content);
fields(cellfun('isempty', regexprep(fields, '^Annotation.*', ''))) = [];

for i=1:numel(fields)
    sub_blk = ir_struct.Content.(fields{i});
    
    ir_struct.Content.(fields{i}).conversion = {};
    if ~isfield(sub_blk, 'BlockType')
        break;
    end
    %%%%%%%%% Gain %%%%%%%%%%%%%%%%%%%%%%%%
    if strcmp(sub_blk.BlockType, 'Gain')
        ir_struct.Content.(fields{i}).conversion{1} = sub_blk.CompiledPortDataTypes.Outport(1);
        
        %%%%%%%%% Abs %%%%%%%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Abs')
        ir_struct.Content.(fields{i}).conversion{1} = sub_blk.CompiledPortDataTypes.Outport(1);
        if sub_blk.CompiledPortComplexSignals.Outport(1) && ~sub_blk.CompiledPortComplexSignals.Inport(1)
            ir_struct.Content.(fields{i}).conversion{1} = ['complex|' ir_struct.Content.(fields{i}).conversion{1}];
        end
        
        %%%%%%%%%%%%% Logic %%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Logic')
        for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
            ir_struct.Content.(fields{i}).conversion{idx_in} = 'boolean';
        end
        
        
        %%%%%%%%%%% Product %%%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Product')
        for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
            ir_struct.Content.(fields{i}).conversion{idx_in} = sub_blk.CompiledPortDataTypes.Outport(1);
        end
        
        %%%%%%%%%%% Product %%%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Polyval')
        ir_struct.Content.(fields{i}).conversion{1} = sub_blk.CompiledPortDataTypes.Outport(1);
        
        %%%%%%%%%%%% MinMax %%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'MinMax')
        for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
            ir_struct.Content.(fields{i}).conversion{idx_in} = sub_blk.CompiledPortDataTypes.Outport(1);
        end
        
        %%%%%%%%%%%%%%%% Switch %%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Switch')
        %criteria = get_param(blks{idx_block}, 'Criteria');
        ir_struct.Content.(fields{i}).conversion{1} = sub_blk.CompiledPortDataTypes.Outport(1);
        ir_struct.Content.(fields{i}).conversion{2} = 'no';
        ir_struct.Content.(fields{i}).conversion{3} = sub_blk.CompiledPortDataTypes.Outport(1);
        
        %%%%%%%%%%%%% Discrete intgrator %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'DiscreteIntegrator')
        ir_struct.Content.(fields{i}).conversion{1} = sub_blk.CompiledPortDataTypes.Outport(1);
        external_reset = sub_blk.ExternalReset;
        ic_source = sub_blk.InitialConditionSource;
        if ~strcmp(external_reset, 'none') && strcmp(ic_source, 'external')
            ir_struct.Content.(fields{i}).conversion{2} = sub_blk.CompiledPortDataTypes.Inport(2);
            ir_struct.Content.(fields{i}).conversion{3} = sub_blk.CompiledPortDataTypes.Inport(3);
        elseif ~strcmp(external_reset, 'none')
            ir_struct.Content.(fields{i}).conversion{2} = sub_blk.CompiledPortDataTypes.Inport(2);
        elseif strcmp(ic_source, 'external')
            ir_struct.Content.(fields{i}).conversion{2} = sub_blk.CompiledPortDataTypes.Inport(2);
        end
        
        %%%%%%%%%%%%%%%% SUM %%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Sum')
        for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
            ir_struct.Content.(fields{i}).conversion{idx_in} = sub_blk.CompiledPortDataTypes.Outport(1);
        end
        
        %%%%%%%%%%%%%%%% Bias %%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Bias')
        ir_struct.Content.(fields{i}).conversion{1} = sub_blk.CompiledPortDataTypes.Outport(1);
        
        %%%%%%%%%%%%%%%% Concatenate %%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Concatenate')
        for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
            ir_struct.Content.(fields{i}).conversion{idx_in} = sub_blk.CompiledPortDataTypes.Outport(1);
        end
        
        %%%%%%%%%%%%%%% MultiPortSwitch %%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'MultiPortSwitch')
        ir_struct.Content.(fields{i}).conversion{1} = 'int32';
        for idx_in=2:numel(sub_blk.CompiledPortDataTypes.Inport)
            ir_struct.Content.(fields{i}).conversion{idx_in} = sub_blk.CompiledPortDataTypes.Outport(1);
        end
        
        %%%%%%%%%%%%%%%% Discrete state space %%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType,'DiscreteStateSpace')
        
        %%%%%%%%%%%%%%%% Function bloc parameter %%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType,'Fcn')
        %fun_expr= block.Expr;
        for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
            ir_struct.Content.(fields{i}).conversion{idx_in} = 'double';
        end
        
        %%%%%%%%%%%%% Saturation %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType,'Saturate')
        ir_struct.Content.(fields{i}).conversion{1} = sub_blk.CompiledPortDataTypes.Outport(1);
        
        %%%%%%%%%%%%% RelationalOperator %%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType,'RelationalOperator')
        res = '';
        dt = '';
        for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
            dt{idx_in} = LusUtils.get_lustre_dt(sub_blk.CompiledPortDataTypes.Inport(idx_in));
        end
        if ismember('real', dt)
            res = 'real';
        elseif ismember('int', dt)
            res = 'int';
            sub_blk.rounding = 'Floor';
        else
            res = 'int';
            sub_blk.rounding = 'Floor';
        end
        for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
            ir_struct.Content.(fields{i}).conversion{idx_in} = res;
        end
        
        %%%%%%%%%%%%% Demux %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType,'Demux')
        ir_struct.Content.(fields{i}).conversion{1} = sub_blk.CompiledPortDataTypes.Outport(1);
        
        %%%%%%%%%%%%% IF ELSE IF ELSE %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType,'If')
        %if_expr = get_param(blks{idx_block},'ifexpression');
        %elseif_expr = get_param(blks{idx_block},'elseifexpressions');
        %num_var  = get_param(blks{idx_block},'Numinputs');
        for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
            ir_struct.Content.(fields{i}).conversion{idx_in} = 'no';
        end
        
        %%%%%%%%%%%%% UnitDelay and Memory %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType,'UnitDelay') || strcmp(sub_blk.BlockType,'Memory')
        ir_struct.Content.(fields{i}).conversion{1} = sub_blk.CompiledPortDataTypes.Outport(1);
        
        %%%%%%%%%%%%% Constant %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType,'Constant')
        %Kvalue = evalin('base', get_param(blks{idx_block} ,'Value'));
        for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
            ir_struct.Content.(fields{i}).conversion{idx_in} = 'no';
        end
        
        %%%%%%%%%%%% DataTypeConversion %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'DataTypeConversion')
        ir_struct.Content.(fields{i}).conversion{1} = sub_blk.CompiledPortDataTypes.Outport(1);
        
        %%%%%%%%%%%% SignalSpecification %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'SignalSpecification')
        ir_struct.Content.(fields{i}).conversion{1} = sub_blk.CompiledPortDataTypes.Outport(1);
        
        %%%%%%%%%%%%% Merge %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType,'Merge')
        for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
            ir_struct.Content.(fields{i}).conversion{idx_in} = sub_blk.CompiledPortDataTypes.Outport(1);
        end
        
        %%%%%%%%%%%%% MUX %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType,'Mux')
        for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
            ir_struct.Content.(fields{i}).conversion{idx_in} = sub_blk.CompiledPortDataTypes.Outport(1);
        end
        
        %%%%%%%%%%%%% Reshape %%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Reshape')
        for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
            ir_struct.Content.(fields{i}).conversion{idx_in} = sub_blk.CompiledPortDataTypes.Outport(1);
        end
        
        %%%%%%%%%%%%% Operation trigo %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType,'Trigonometry')
        ir_struct.Content.(fields{i}).conversion{1} = sub_blk.CompiledPortDataTypes.Outport(1);
        operator = sub_blk.Operator;
        if strcmp(operator, 'atan2')
            ir_struct.Content.(fields{i}).conversion{2} = sub_blk.CompiledPortDataTypes.Outport(1);
        end
        
        %%%%%%%%%%%%% Maths function %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType,'Math')
        math_op = sub_blk.Operator;
        if strcmp(math_op, 'sqrt') || strcmp(math_op, 'rSqrt') || strcmp(math_op, 'signedSqrt')
            dt = 'double';
        else
            dt = sub_blk.CompiledPortDataTypes.Outport(1);
        end
        for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
            ir_struct.Content.(fields{i}).conversion{idx_in} =dt;
        end
        
        %%%%%%%%%%%% Sqrt %%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Sqrt')
        ir_struct.Content.(fields{i}).conversion{1} = 'double';
        
        %%%%%%%%%%%%% Step %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType,'Step')
        %start = get_param(blks{idx_block},'Time');
        %before = get_param(blks{idx_block},'Before');
        %after = get_param(blks{idx_block},'After');
        for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
            ir_struct.Content.(fields{i}).conversion{idx_in} = 'no';
        end
        
        %%%%%%%%%%%% Bitwise Operator %%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Bitwise Operator')
        for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
            ir_struct.Content.(fields{i}).conversion{idx_in} = sub_blk.CompiledPortDataTypes.Outport(1);
        end
        
        %%%%%%%%%%%%% Zero-Pole %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, BlockUtils.zero_pole_discrete)
        for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
            ir_struct.Content.(fields{i}).conversion{idx_in} = sub_blk.CompiledPortDataTypes.Outport(1);
        end
        
        %%%%%%%%%%%%%%%%%%% S-Function %%%%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType,'S-Function')
        %function_name = get_param(blks{idx_block}, 'FunctionName');
        %parameters = get_param(blks{idx_block}, 'Parameters');
        for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
            ir_struct.Content.(fields{i}).conversion{idx_in} = 'no';
        end
        
        %%%%%%%%%%%%%%%%%% DotProduct %%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'DotProduct')
        for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
            ir_struct.Content.(fields{i}).conversion{idx_in} = sub_blk.CompiledPortDataTypes.Outport(1);
        end
        
        %%%%%%%%%%%%%%%%% SubSystem %%%%%%%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'SubSystem') || strcmp(sub_blk.BlockType, 'ModelReference')
        if isfield(sub_blk, 'Mask') && strcmp(sub_blk.Mask, 'on')
            %%%%%%%%%%%%%% Saturation Dynamic %%%%%%%%%%%%%%%%%%%
            if strcmp(sub_blk.MaskType, 'Saturation Dynamic')
                for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
                    ir_struct.Content.(fields{i}).conversion{idx_in} = sub_blk.CompiledPortDataTypes.Outport(1);
                end
                
                %%%%%%%%%%%%%% DiscretizedZeroPole %%%%%%%%%%%%%%%%
            elseif strcmp(sub_blk.MaskType, BlockUtils.zero_pole_ref)
                ir_struct.Content.(fields{i}).conversion{1} = sub_blk.CompiledPortDataTypes.Outport(1);
                
                %%%%%%%%%%%%%% CompareTo Family of blocks %%%%%%%%%%%
            elseif BlockUtils.isCompareToMask(sub_blk.MaskType)
                in_dt = LusUtils.get_lustre_dt(sub_blk.CompiledPortDataTypes.Inport(1));
                dt = 'no';
                if strcmp(in_dt, 'bool')
                    dt = 'real';
                end
                ir_struct.Content.(fields{i}).conversion{1} = dt;
                
                %%%%%%%%%%%%%% Detect Family of blocks %%%%%%%%%%%%
            elseif BlockUtils.isDetectMask(sub_blk.MaskType)
                ir_struct.Content.(fields{i}).conversion{1} = 'no';
                
                %%%%%%%%%%%%%%% Observer %%%%%%%%%%%%
            elseif BlockUtils.is_property(sub_blk.MaskType)
                for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
                    ir_struct.Content.(fields{i}).conversion{idx_in} = 'no';
                end
                
                %%%%%%%%%%%%%%% Implications %%%%%%%%%%%%
            elseif strcmp(sub_blk.MaskType, 'CoCoSim-Implies')
                for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
                    ir_struct.Content.(fields{i}).conversion{idx_in} = 'no';
                end
                
                %%%%%%%%%%%%%% Subsystems with a simple graphical mask %%%%%%
            elseif strcmp(sub_blk.MaskType, '')
                for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
                    ir_struct.Content.(fields{i}).conversion{idx_in} = 'no';
                end
                
                %%%%%%%%%%%%%%%%% Cross Product %%%%%%%%%%%%%%%%%%
            elseif strcmp(sub_blk.MaskType, 'Cross Product')
                ir_struct.Content.(fields{i}).conversion{1} = sub_blk.CompiledPortDataTypes.Outport(1);
                ir_struct.Content.(fields{i}).conversion{2} = sub_blk.CompiledPortDataTypes.Outport(1);
                
            elseif strcmp(sub_blk.MaskType,'Create 3x3 Matrix')
                for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
                    ir_struct.Content.(fields{i}).conversion{idx_in} = sub_blk.CompiledPortDataTypes.Outport(1);
                end
            else
                msg = ['Data type conversion mechanism not supported for block: ' sub_blk.MaskType];
                display_msg(msg, Constants.ERROR, 'conversion', '');
            end
        end
        
        %%%%%%%%%%%%%%%%% ForIterator %%%%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'ForIterator')
        dt = sub_blk.IterationVariableDataType;
        for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
            ir_struct.Content.(fields{i}).conversion{idx_in} = dt;
        end
        
        %%%%%%%%%%%%%%%%% Assigment %%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Assignment')
        ir_struct.Content.(fields{i}).conversion{1} = sub_blk.CompiledPortDataTypes.Outport(1);
        ir_struct.Content.(fields{i}).conversion{2} = sub_blk.CompiledPortDataTypes.Outport(1);
        if sub_blk.CompiledPortComplexSignals.Outport(1) && ~sub_blk.CompiledPortComplexSignals.Inport(2)
            ir_struct.Content.(fields{i}).conversion{2} = ['complex|' ir_struct.Content.(fields{i}).conversion{2}];
        end
        for idx_in=3:numel(sub_blk.CompiledPortDataTypes.Inport)
            ir_struct.Content.(fields{i}).conversion{idx_in} = 'int32';
        end
        
        %%%%%%%%%%%%%%%%% Selector %%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Selector')
        ir_struct.Content.(fields{i}).conversion{1} = sub_blk.CompiledPortDataTypes.Outport(1);
        for idx_in=2:numel(sub_blk.CompiledPortDataTypes.Inport)
            ir_struct.Content.(fields{i}).conversion{idx_in} = 'int32';
        end
        
        %%%%%%%%%%%%%%%%%% Outport %%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Outport')
        for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
            ir_struct.Content.(fields{i}).conversion{idx_in} = 'no';
        end
        
        %%%%%%%%%%%%%%%%%% DiscreteStateSpace %%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'DiscreteStateSpace')
        ir_struct.Content.(fields{i}).conversion{1} = sub_blk.CompiledPortDataTypes.Outport(1);
        
        %%%%%%%%%%%%%%%%%% LookupNDDirect %%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'LookupNDDirect')
        is_input = sub_blk.TableIsInput;
        if strcmp(is_input, 'off')
            for idx=1:sub_blk.Ports(1)
                ir_struct.Content.(fields{i}).conversion{idx} = 'int32';
            end
        else
            ir_struct.Content.(fields{i}).conversion{sub_blk.Ports(1)} = sub_blk.CompiledPortDataTypes.Outport(1);
            for idx=1:sub_blk.Ports(1)-1
                ir_struct.Content.(fields{i}).conversion{idx} = 'int32';
            end
        end
        
        %%%%%%%%%%%%%%%%% Goto %%%%%%%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Goto')
        ir_struct.Content.(fields{i}).conversion{1} = 'no';
        
        %%%%%%%%%%%%%%%%% SwitchCase %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'SwitchCase')
        ir_struct.Content.(fields{i}).conversion{1} = 'int32';
        
        %%%%%%%%%%%%%%%%% Signum %%%%%%%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Signum')
        ir_struct.Content.(fields{i}).conversion{1} = sub_blk.CompiledPortDataTypes.Outport(1);
        
        %%%%%%%%%%%%%%%% ActionPort %%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'ActionPort')
        
        %%%%%%%%%%%%%%%% TriggerPort %%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'TriggerPort')
        
        %%%%%%%%%%%%%%%% EnablePort %%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'EnablePort')
        
        %%%%%%%%%%%%%%%% BusSelector %%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'BusSelector')
        ir_struct.Content.(fields{i}).conversion{1} = 'no';
        
        %%%%%%%%%%%%%%%% BusCreator %%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'BusCreator')
        for idx=1:sub_blk.Ports(1)
            ir_struct.Content.(fields{i}).conversion{idx} = 'no';
        end
        
        %%%%%%%%%%%%%%%% BusAssignment %%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'BusAssignment')
        for idx=1:sub_blk.Ports(1)
            ir_struct.Content.(fields{i}).conversion{idx} = 'no';
        end
        
        %%%%%%%%%%%%% SignalConversion %%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType,'SignalConversion')
        for idx_in=1:numel(sub_blk.CompiledPortDataTypes.Inport)
            ir_struct.Content.(fields{i}).conversion{idx_in} = sub_blk.CompiledPortDataTypes.Outport(1);
        end
        %%%%%%%%%%%%%%%%%% Blocks with nothing specific to do %%%%%%%%%%%%%%%%%%%
    elseif strcmp(sub_blk.BlockType, 'Inport') || strcmp(sub_blk.BlockType, 'ToWorkspace') || strcmp(sub_blk.BlockType, 'Terminator') || strcmp(sub_blk.BlockType, 'Scope') || strcmp(sub_blk.BlockType, 'From') || strcmp(sub_blk.BlockType, 'FromWorkspace')
        
    else
        msg = ['Data type conversion mechanism not supported for block: ' sub_blk.BlockType];
        display_msg(msg, Constants.WARNING, 'conversion', '');
    end
    if isfield(sub_blk, 'Content')
        ir_struct.Content.(fields{i}) = conversion_aux(ir_struct.Content.(fields{i}));
    end
end

if nargin >= 2
    new_ir.(model_name) = ir_struct;
else
    new_ir = ir_struct;
end
end
