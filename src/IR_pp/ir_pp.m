function [ new_ir, complex_structs ] = ir_pp( old_ir, root_name )
%IR_PP

new_ir = old_ir;

fields = fieldnames(new_ir.(root_name).Content);

complex_data = {};

for i=1:numel(fields)
    sub_blk = new_ir.(root_name).Content.(fields{i});
    % obliged to modify from the root. If not, doesn't modify anything
    new_ir.(root_name).Content.(fields{i}).Pre = [sub_blk.PortConnectivity.SrcBlock];
    new_ir.(root_name).Content.(fields{i}).Post = [sub_blk.PortConnectivity.DstBlock];
    new_ir.(root_name).Content.(fields{i}).name_level = 0;
	new_ir.(root_name).Content.(fields{i}).conversion = compute_conversion(sub_blk);
    if isfield(sub_blk, 'Content')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%% just don't ask, I don't know why I am doing this.
        if strcmp(sub_blk.BlockType, 'SubSystem') && strcmp(sub_blk.IsSubsystemVirtual, 'on')
            fields_sub = fieldnames(sub_blk.Content);
            fields_sub = fields_sub(sub_blk.Ports(1):(end-sub_blk.Ports(2)));
            for j=1:numel(fields_sub)
                new_ir.(root_name).Content.(fields{i}).Content.fields_sub{j}.name_level = new_ir.(root_name).Content.(fields{i}).Content.(fields{j}).name_level + 1;
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%% Verify for what that is (cf flatten_subsystems...)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%% Verify that it is that or not
        if strcmp(sub_blk.BlockType, 'ModelReference')
            new_ir.(root_name).Content.(fields{i}).isref = true;
        else
            new_ir.(root_name).Content.(fields{i}).isref = false;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if strcmp(sub_blk.BlockType, 'SubSystem')
            fields_sub = fieldnames(sub_blk.Content);
            new_ir.(root_name).Content.(fields{i}).foriter = false;
            found = false;
            j = 1;
            while j <= numel(fields_sub) && ~found
                if strcmp(sub_blk.Content.(fields_sub{j}).BlockType, 'ForIterator')
                    found = true;
                    new_ir.(root_name).Content.(fields{i}).foriter = true;
                end
                j = j + 1;
            end
        end
        new_ir.(root_name).Content = ir_pp(new_ir.(root_name).Content, Utils.name_format(sub_blk.Name));
    end
    
    indexes = find(arrayfun(@(x) strcmp(x.Type, 'ifaction'), sub_blk.PortConnectivity));
    if ~isempty(indexes)
        new_ir.(root_name).Content.(fields{i}).action = sub_blk.PortConnectivity(indexes).SrcBlock;
        %myblk{idx_block}.actionport = port_connection{idx_block}(indexes).SrcPort;
    else
        new_ir.(root_name).Content.(fields{i}).action = [];
        %myblk{idx_block}.actionport = [];
    end
    indexes = find(arrayfun(@(x) strcmp(x.Type, 'trigger'), sub_blk.PortConnectivity));
    if ~isempty(indexes)
        new_ir.(root_name).Content.(fields{i}).trigger = sub_blk.PortConnectivity(indexes).SrcBlock;
    else
        new_ir.(root_name).Content.(fields{i}).trigger = [];
    end
    indexes = find(arrayfun(@(x) strcmp(x.Type, 'enable'), sub_blk.PortConnectivity));
    if ~isempty(indexes)
        new_ir.(root_name).Content.(fields{i}).enable = sub_blk.PortConnectivity(indexes).SrcBlock;
    else
        new_ir.(root_name).Content.(fields{i}).enable = [];
    end

    indexes_in = find(sub_blk.CompiledPortComplexSignals.Inport);
    [inport_complex_data] = sub_blk.CompiledPortDataTypes.Inport(indexes_in);
    indexes_out = find(sub_blk.CompiledPortComplexSignals.Outport);
    [outport_complex_data] = sub_blk.CompiledPortDataTypes.Outport(indexes_out);
    complex_data = [complex_data inport_complex_data outport_complex_data];
end

complex_data = unique(complex_data);
for i=1:numel(complex_data)
    complex_data{i} = Utils.get_lustre_dt(complex_data{i});
end
complex_data = unique(complex_data);

complex_structs = '';
for i=1:numel(complex_data)
    complex_structs = [complex_structs BusUtils.get_complex_struct(complex_data{i})];
end
end

function conversion = compute_conversion(block)
    
	conversion = {};
	%%%%%%%%% Gain %%%%%%%%%%%%%%%%%%%%%%%%
	if strcmp(block.BlockType, 'Gain')
		conversion{1} = block.CompiledPortDataTypes.Outport{1};

	%%%%%%%%% Abs %%%%%%%%%%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'Abs')
		conversion{1} = block.CompiledPortDataTypes.Outport{1};
		if block.CompiledPortComplexSignals.Outport(1) && ~block.CompiledPortComplexSignals.Inport(1)
			conversion{1} = ['complex|' conversion{1}];
		end

	%%%%%%%%%%%%% Logic %%%%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'Logic')
		for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
			conversion{idx_in} = 'boolean';
        end


	%%%%%%%%%%% Product %%%%%%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'Product')
		for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
			conversion{idx_in} = block.CompiledPortDataTypes.Outport{1};
		end
	
	%%%%%%%%%%% Product %%%%%%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'Polyval')
		conversion{1} = block.CompiledPortDataTypes.Outport{1};

	%%%%%%%%%%%% MinMax %%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'MinMax')
		for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
			conversion{idx_in} = block.CompiledPortDataTypes.Outport{1};
		end

	%%%%%%%%%%%%%%%% Switch %%%%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'Switch')
		%criteria = get_param(blks{idx_block}, 'Criteria');
		conversion{1} = block.CompiledPortDataTypes.Outport{1};
		conversion{2} = 'no';
		conversion{3} = block.CompiledPortDataTypes.Outport{1};

	%%%%%%%%%%%%% Discrete intgrator %%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'DiscreteIntegrator')
		conversion{1} = block.CompiledPortDataTypes.Outport{1};
		external_reset = block.ExternalReset;
		ic_source = block.InitialConditionSource;
		if ~strcmp(external_reset, 'none') && strcmp(ic_source, 'external')
			conversion{2} = block.CompiledPortDataTypes.Inport{2};
			conversion{3} = block.CompiledPortDataTypes.Inport{3};
		elseif ~strcmp(external_reset, 'none')
			conversion{2} = block.CompiledPortDataTypes.Inport{2};
		elseif strcmp(ic_source, 'external')
			conversion{2} = block.CompiledPortDataTypes.Inport{2};
		end

	%%%%%%%%%%%%%%%% SUM %%%%%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'Sum')
		for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
			conversion{idx_in} = block.CompiledPortDataTypes.Outport{1};
		end

	%%%%%%%%%%%%%%%% Bias %%%%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'Bias')
		conversion{1} = block.CompiledPortDataTypes.Outport{1};

	%%%%%%%%%%%%%%%% Concatenate %%%%%%%%%%%
	elseif strcmp(block.BlockType, 'Concatenate')
		for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
			conversion{idx_in} = block.CompiledPortDataTypes.Outport{1};
		end

	%%%%%%%%%%%%%%% MultiPortSwitch %%%%%%%%
	elseif strcmp(block.BlockType, 'MultiPortSwitch')
		conversion{1} = 'int32';
		for idx_in=2:numel(block.CompiledPortDataTypes.Inport)
			conversion{idx_in} = block.CompiledPortDataTypes.Outport{1};
		end

	%%%%%%%%%%%%%%%% Discrete state space %%%%%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType,'DiscreteStateSpace')
  
	%%%%%%%%%%%%%%%% Function bloc parameter %%%%%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType,'Fcn')
		%fun_expr= block.Expr;
		for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
			conversion{idx_in} = 'double';
		end
		
	%%%%%%%%%%%%% Saturation %%%%%%%%%%%%%
	elseif strcmp(block.BlockType,'Saturate')     
		conversion{1} = block.CompiledPortDataTypes.Outport{1};

	%%%%%%%%%%%%% RelationalOperator %%%%%%%%%%%%%%%        
	elseif strcmp(block.BlockType,'RelationalOperator')
		res = '';
		dt = '';
		for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
			dt{idx_in} = Utils.get_lustre_dt(block.CompiledPortDataTypes.Inport{idx_in});
		end
		if ismember('real', dt)
			res = 'real';
		elseif ismember('int', dt)
			res = 'int';
			block.rounding = 'Floor';
		else
			res = 'int';
			block.rounding = 'Floor';
		end
		for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
			conversion{idx_in} = res;
		end

	%%%%%%%%%%%%% Demux %%%%%%%%%%%%%
	elseif strcmp(block.BlockType,'Demux')
		conversion{1} = block.CompiledPortDataTypes.Outport{1};
		
	%%%%%%%%%%%%% IF ELSE IF ELSE %%%%%%%%%%%%%
	elseif strcmp(block.BlockType,'If')
		%if_expr = get_param(blks{idx_block},'ifexpression');
		%elseif_expr = get_param(blks{idx_block},'elseifexpressions');
		%num_var  = get_param(blks{idx_block},'Numinputs');
		for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
			conversion{idx_in} = 'no';
		end
        
	%%%%%%%%%%%%% UnitDelay and Memory %%%%%%%%%%%%%
	elseif strcmp(block.BlockType,'UnitDelay') || strcmp(block.BlockType,'Memory')
		conversion{1} = block.CompiledPortDataTypes.Outport{1};

	%%%%%%%%%%%%% Constant %%%%%%%%%%%%%
	elseif strcmp(block.BlockType,'Constant')
		%Kvalue = evalin('base', get_param(blks{idx_block} ,'Value'));
		for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
			conversion{idx_in} = 'no';
		end

	%%%%%%%%%%%% DataTypeConversion %%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'DataTypeConversion')
		conversion{1} = block.CompiledPortDataTypes.Outport{1};

   %%%%%%%%%%%% SignalSpecification %%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'SignalSpecification')
		conversion{1} = block.CompiledPortDataTypes.Outport{1};
     
	%%%%%%%%%%%%% Merge %%%%%%%%%%%%%
	elseif strcmp(block.BlockType,'Merge')
		for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
			conversion{idx_in} = block.CompiledPortDataTypes.Outport{1};
		end

	%%%%%%%%%%%%% MUX %%%%%%%%%%%%%
	elseif strcmp(block.BlockType,'Mux') 
		for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
			conversion{idx_in} = block.CompiledPortDataTypes.Outport{1};
		end

	%%%%%%%%%%%%% Reshape %%%%%%%%%%
	elseif strcmp(block.BlockType, 'Reshape')
		for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
			conversion{idx_in} = block.CompiledPortDataTypes.Outport{1};
		end

	%%%%%%%%%%%%% Operation trigo %%%%%%%%%%%%%
	elseif strcmp(block.BlockType,'Trigonometry')
		conversion{1} = block.CompiledPortDataTypes.Outport{1};
		operator = block.operator;
		if strcmp(operator, 'atan2')
			conversion{2} = block.CompiledPortDataTypes.Outport{1};
		end
  
	%%%%%%%%%%%%% Maths function %%%%%%%%%%%%%
	elseif strcmp(block.BlockType,'Math')
        math_op = block.Operator;
        if strcmp(math_op, 'sqrt') || strcmp(math_op, 'rSqrt') || strcmp(math_op, 'signedSqrt')
            dt = 'double';
        else
            dt = block.CompiledPortDataTypes.Outport{1};
        end
		for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
			conversion{idx_in} =dt;
		end

	%%%%%%%%%%%% Sqrt %%%%%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'Sqrt')
		conversion{1} = 'double';

	%%%%%%%%%%%%% Step %%%%%%%%%%%%%
	elseif strcmp(block.BlockType,'Step')
		%start = get_param(blks{idx_block},'Time');
		%before = get_param(blks{idx_block},'Before');
		%after = get_param(blks{idx_block},'After');
		for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
			conversion{idx_in} = 'no';
		end
        
    %%%%%%%%%%%% Bitwise Operator %%%%%%%%%%%%%%
    elseif strcmp(block.BlockType, 'Bitwise Operator')
		for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
			conversion{idx_in} = block.CompiledPortDataTypes.Outport{1};
		end

	%%%%%%%%%%%%% Zero-Pole %%%%%%%%%%%%%
	elseif strcmp(block.BlockType, Constants.zero_pole_discrete)
		for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
			conversion{idx_in} = block.CompiledPortDataTypes.Outport{1};
		end

	%%%%%%%%%%%%%%%%%%% S-Function %%%%%%%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType,'S-Function')
		%function_name = get_param(blks{idx_block}, 'FunctionName');
		%parameters = get_param(blks{idx_block}, 'Parameters');
		for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
			conversion{idx_in} = 'no';
		end

	%%%%%%%%%%%%%%%%%% DotProduct %%%%%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'DotProduct')
		for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
			conversion{idx_in} = block.CompiledPortDataTypes.Outport{1};
		end

	%%%%%%%%%%%%%%%%% SubSystem %%%%%%%%%%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'SubSystem') || strcmp(block.BlockType, 'ModelReference')
      
        if strcmp(block.Mask, 'on')
				%%%%%%%%%%%%%% Saturation Dynamic %%%%%%%%%%%%%%%%%%%
            if strcmp(block.MaskType, 'Saturation Dynamic')
                for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
                    conversion{idx_in} = block.CompiledPortDataTypes.Outport{1};
                end
				
				%%%%%%%%%%%%%% DiscretizedZeroPole %%%%%%%%%%%%%%%%
				elseif strcmp(block.MaskType, Constants.zero_pole_ref)
					conversion{1} = block.CompiledPortDataTypes.Outport{1};

				%%%%%%%%%%%%%% CompareTo Family of blocks %%%%%%%%%%%
				elseif Constants.isCompareToMask(block.MaskType)
					in_dt = Utils.get_lustre_dt(block.CompiledPortDataTypes.Inport{1});
					dt = 'no';
					if strcmp(in_dt, 'bool')
						dt = 'real';
					end
					conversion{1} = dt;

				%%%%%%%%%%%%%% Detect Family of blocks %%%%%%%%%%%%
				elseif Constants.isDetectMask(block.MaskType)
					conversion{1} = 'no';

				%%%%%%%%%%%%%%% Observer %%%%%%%%%%%%
				elseif Constants.is_property(block.MaskType)
					for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
						conversion{idx_in} = 'no';
                    end
                    
                %%%%%%%%%%%%%%% Implications %%%%%%%%%%%%
				elseif strcmp(block.MaskType, 'CoCoSim-Implies')
                        for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
                            conversion{idx_in} = 'no';
                        end

				%%%%%%%%%%%%%% Subsystems with a simple graphical mask %%%%%%
				elseif strcmp(block.MaskType, '')
					for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
                       conversion{idx_in} = 'no';
                    end

				%%%%%%%%%%%%%%%%% Cross Product %%%%%%%%%%%%%%%%%%
				elseif strcmp(block.MaskType, 'Cross Product')
					conversion{1} = block.CompiledPortDataTypes.Outport{1};
					conversion{2} = block.CompiledPortDataTypes.Outport{1};
             
                elseif strcmp(block.MaskType,'Create 3x3 Matrix') 
                    for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
                        conversion{idx_in} = block.CompiledPortDataTypes.Outport{1};
                    end
            else
                msg = ['Data type conversion mechanism not supported for block: ' block.MaskType];
                display_msg(msg, Constants.ERROR, 'blocks_dt_conversion', '');
            end
    end

	%%%%%%%%%%%%%%%%% ForIterator %%%%%%%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'ForIterator')
		dt = block.IterationVariableDataType;
		for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
			conversion{idx_in} = dt;
		end

	%%%%%%%%%%%%%%%%% Assigment %%%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'Assignment')
		conversion{1} = block.CompiledPortDataTypes.Outport(1);
		conversion{2} = block.CompiledPortDataTypes.Outport(1);
		if block.CompiledPortComplexSignals.Outport(1) && ~block.CompiledPortComplexSignals.Inport(2)
			conversion{2} = ['complex|' conversion{2}];
		end
		for idx_in=3:numel(block.CompiledPortDataTypes.Inport)
			conversion{idx_in} = 'int32';
		end

	%%%%%%%%%%%%%%%%% Selector %%%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'Selector')
		conversion{1} = block.CompiledPortDataTypes.Outport(1);
		for idx_in=2:numel(block.CompiledPortDataTypes.Inport)
			conversion{idx_in} = 'int32';
		end

	%%%%%%%%%%%%%%%%%% Outport %%%%%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'Outport')
		for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
			conversion{idx_in} = 'no';
		end

	%%%%%%%%%%%%%%%%%% DiscreteStateSpace %%%%%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'DiscreteStateSpace')
		conversion{1} = block.CompiledPortDataTypes.Outport(1);

	%%%%%%%%%%%%%%%%%% LookupNDDirect %%%%%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'LookupNDDirect')
		is_input = block.TableIsInput;
		if strcmp(is_input, 'off')
			for idx=1:block.Ports(1)
				conversion{idx} = 'int32';
			end
		else
			conversion{block.Ports(1)} = block.CompiledPortDataTypes.Outport(1);
			for idx=1:block.Ports(1)-1
				conversion{idx} = 'int32';
			end
		end

	%%%%%%%%%%%%%%%%% Goto %%%%%%%%%%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'Goto')
		conversion{1} = 'no';

	%%%%%%%%%%%%%%%%% SwitchCase %%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'SwitchCase')
		conversion{1} = 'int32';

	%%%%%%%%%%%%%%%%% Signum %%%%%%%%%%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'Signum')
		conversion{1} = block.CompiledPortDataTypes.Outport(1);

	%%%%%%%%%%%%%%%% ActionPort %%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'ActionPort')

	%%%%%%%%%%%%%%%% TriggerPort %%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'TriggerPort')
 
    %%%%%%%%%%%%%%%% EnablePort %%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'EnablePort')

	%%%%%%%%%%%%%%%% BusSelector %%%%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'BusSelector')
		conversion{1} = 'no';

	%%%%%%%%%%%%%%%% BusCreator %%%%%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'BusCreator')
		for idx=1:block.Ports(1)
			conversion{idx} = 'no';
		end

	%%%%%%%%%%%%%%%% BusAssignment %%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'BusAssignment')
		for idx=1:block.Ports(1)
			conversion{idx} = 'no';
        end
        
    %%%%%%%%%%%%% SignalConversion %%%%%%%%%%%%%
	elseif strcmp(block.BlockType,'SignalConversion') 
		for idx_in=1:numel(block.CompiledPortDataTypes.Inport)
			conversion{idx_in} = block.CompiledPortDataTypes.Outport(1);
		end
	%%%%%%%%%%%%%%%%%% Blocks with nothing specific to do %%%%%%%%%%%%%%%%%%%
	elseif strcmp(block.BlockType, 'Inport') || strcmp(block.BlockType, 'ToWorkspace') || strcmp(block.BlockType, 'Terminator') || strcmp(block.BlockType, 'Scope') || strcmp(block.BlockType, 'From') || strcmp(block.BlockType, 'FromWorkspace')
    
    
	else
		msg = ['Data type conversion mechanism not supported for block: ' block.BlockType];
		display_msg(msg, Constants.WARNING, 'blocks_dt_conversion', '');
	end
end

