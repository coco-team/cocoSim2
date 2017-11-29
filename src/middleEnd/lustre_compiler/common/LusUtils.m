classdef LusUtils
    %LUSUTILS
    
    methods(Static = true)
        function value = getParamValue(ir_struct, unbloc, V)
            parent_subs = get_subsystem_struct(ir_struct, unbloc);
            value = V;
            if isfield(parent_subs, 'Mask') && strcmp(parent_subs.Mask, 'on')
                if isfield(parent_subs, V)
                    value = parent_subs.(V);
                end
            end
            value = evalin('base', value);
        end
        
        function [list_const_r list_const_i] = transform_list_const_to_complex(list_const, dt)
            for idx=1:numel(list_const)
                const_val_real = evalin('base', sprintf('real(%s);', list_const{idx}));
                const_val_imag = evalin('base', sprintf('imag(%s);', list_const{idx}));
                if strcmp(dt, 'real')
                    list_const_r{idx} = sprintf('%10.8f', const_val_real);
                    list_const_i{idx} = sprintf('%10.8f', const_val_imag);
                else
                    list_const_r{idx} = sprintf('%d', const_val_real);
                    list_const_i{idx} = sprintf('%d', const_val_imag);
                end
            end
        end
        
        function [complex_def] = get_complex_def_str(complex_str, dt)
            const_val_real = evalin('base', sprintf('real(%s);', complex_str));
            const_val_imag = evalin('base', sprintf('imag(%s);', complex_str));
            if strcmp(dt, 'real')
                complex_def = sprintf('complex_%s{r=%10.8f; i=%10.10f}', dt, const_val_real, const_val_imag);
            else
                complex_def = sprintf('complex_%s{r=%d; i=%d}', dt, const_val_real, const_val_imag);
            end
        end
        
        function [complex_def] = real_to_complex_str(real_str, dt)
            if strcmp(dt, 'real')
                complex_def = sprintf('complex_%s{r = %s; i = 0.0}', dt, real_str);
            else
                complex_def = sprintf('complex_%s{r = %s; i = 0}', dt, real_str);
            end
        end
        
        function [dt_str] = get_lustre_dt(simulink_dt)
            dt_str = '';
            if strcmp(simulink_dt, 'real') || strcmp(simulink_dt, 'int') || strcmp(simulink_dt, 'bool')
                dt_str = simulink_dt;
            else
                if strcmp(simulink_dt, 'logical') || strcmp(simulink_dt, 'boolean')
                    dt_str = 'bool';
                elseif strncmp(simulink_dt, 'int', 3) || strncmp(simulink_dt, 'uint', 4) || strncmp(simulink_dt, 'fixdt(1,16,', 11) || strncmp(simulink_dt, 'sfix64', 6)
                    dt_str = 'int';
                elseif BusUtils.is_bus(simulink_dt)
                    dt_str = simulink_dt;
                else
                    dt_str = 'real';
                end
            end
        end
        
        function [value] = convert_literal_value(original_value)
            value = '';
            if strcmp(class(evalin('base', original_value)), 'logical')
                matched = regexp(original_value, 'boolean\(((true)|(false))\)', 'tokens');
                if numel(matched) == 1
                    value = matched{1};
                else
                    value = original_value;
                end
            else
                value = original_value;
            end
        end
        
        function [values] = get_elem_nth_shift(original_value, nth, shift)
            cpt_values = 1;
            for idx=nth:shift:numel(original_value)
                values{cpt_values} = original_value{idx};
                cpt_values = cpt_values + 1;
            end
        end
        
        function [level] = get_pre_block_level(prename, inter_blk)
            level = 0;
            fields = fieldnames(inter_blk.Content);
            fields(cellfun('isempty', regexprep(fields, '^Annotation.*', ''))) = [];
            for idx_blk=1:numel(fields)
                if strcmp(inter_blk.Content.(fields{idx_blk}).Path, prename)
                    % TODO : find what name_level is for
                    level = inter_blk{idx_blk}.name_level;
                    return
                end
            end
        end
        
        function [res] = get_rounding_function(rndmeth)
            res = '';
            if strcmp(rndmeth, 'Floor')
                res = 'floor';
            elseif strcmp(rndmeth, 'Ceiling')
                res = 'ceil';
            elseif strcmp(rndmeth, 'Nearest')
                res = 'round';
            elseif strcmp(rndmeth, 'Zero')
                res = 'fix';
            else
                display_msg('Rounding algorithm not handled', Constants.ERROR, 'LusUtils.get_rounding_function', '');
            end
        end
        
        function [list_in_out] = expand_all_inputs(block, list_in)
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
                list_in_out = new_list_in;
            else
                list_in_out = list_in;
            end
        end
        
        function [list_in_out] = expand_all_inputs_according_output(block, list_in, out_nb)
            dim = block.CompiledPortWidths.Outport(out_nb);
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
                list_in_out = new_list_in;
            else
                list_in_out = list_in;
            end
        end
        
        function [res var_name] = is_reset(inter_blk)
            res = false;
            var_name = '';
            fields = fieldnames(inter_blk);
            if numel(fields) > 1 % not a diagram_model
                if strcmp(inter_blk.BlockType, 'SubSystem')
                    if inter_blk.action_reset || inter_blk.foriter_reset || inter_blk.enable_reset
                        res = true;
                    end
                end
                if res
                    blk_path_elems = regexp(inter_blk.Path, filesep, 'split');
                    node_name = Utils.concat_delim(blk_path_elems, '_');
                    if inter_blk.action_reset
                        var_name = [node_name BlockUtils.ACTION_RESET];
                    elseif inter_blk.enable_reset
                        var_name = [node_name BlockUtils.ENABLE_RESET];
                    elseif inter_blk.foriter_reset
                        var_name = [node_name BlockUtils.FOR_ITER_RESET];
                    end
                end
            end
        end
        
        function [res var_name dt] = needs_for_iter_var(myblk, inter_blk)
            res = false;
            var_name = '';
            dt = '';
            if strcmp(inter_blk.BlockType, 'SubSystem')
                fields = fieldnames(inter_blk.Content);
                fields(cellfun('isempty', regexprep(fields, '^Annotation.*', ''))) = [];
                blocks = {};
                for i=1:numel(fields)
                    blocks = [blocks, inter_blk.Content.(fields{i}).Handle];
                end
                block_types = cocoget_param(myblk, blocks, 'BlockType');
                
                index_for_iter = find(ismember(block_types, 'ForIterator'));
                if numel(index_for_iter) > 0
                    blk = get_struct(myblk, blocks{index_for_iter(1)});
                    ext_incr = blk.ExternalIncrement;
                    if strcmp(ext_incr, 'off')
                        dt = LusUtils.get_lustre_dt(blk.IterationVariableDataType);
                        blk_path_elems = regexp(inter_blk.Path, filesep, 'split');
                        node_name = Utils.concat_delim(blk_path_elems, '_');
                        var_name = [node_name BlockUtils.FOR_ITER];
                        res = true;
                    end
                end
            end
        end
        
        function [fun_name, chart] = get_MATLAB_function_name(block_path)
            % Get stateflow chart
            root = sfroot;
            chart = root.find('-isa', 'Stateflow.EMChart', '-and', 'Path', block_path);
            
            % Get the MATLAB function script
            script = chart.Script;
            newline = sprintf('\n');
            script_split = regexp(script, newline, 'split');
            function_line = '';
            for idx=1:numel(script_split)
                line = strtrim(script_split{idx});
                if strncmp(line, 'function ', 9)
                    function_line = line;
                    break;
                end
            end
            
            % Get the MATLAB function name
            idx_eq = strfind(function_line, '=');
            if numel(idx_eq) == 1
                function_line = function_line(idx_eq+1:end);
            else
                function_line = function_line(idx_eq(1)+1:end);
            end
            idx_par = strfind(function_line, '(');
            if numel(idx_par) == 1
                function_line = function_line(1:idx_par-1);
            else
                function_line = function_line(1:idx_par(1)-1);
            end
            
            fun_name = strtrim(function_line);
            
        end
        
        function name = var_naming(unbloc, postfix)
            
            block_full_name = regexp(unbloc.Path, filesep, 'split');
            if unbloc.name_level >= numel(block_full_name{1})
                block_name = Utils.concat_delim(block_full_name{1}, '_');
            else
                block_name = Utils.concat_delim(block_full_name{1}(end - unbloc.name_level : end), '_');
            end
            name = [block_name '_' postfix];
        end
    end
end

