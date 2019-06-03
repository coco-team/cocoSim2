%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef Utils
    methods (Static = true)
        
        function [lc] = list_cst(K, dt)
            [r, c] = size(K);
            dt_lus = LusUtils.get_lustre_dt(dt);
            
            if strcmp(dt, 'write_compareto_bool')
                for k1=1:r
                    for k2=1:c
                        idx = k2 + (k1-1) * c;
                        if K(k1,k2)
                            lc{idx} = '1.0';
                        else
                            lc{idx} = '0.0';
                        end
                    end
                end
            elseif strcmp(dt_lus, 'bool')
                for k1=1:r
                    for k2=1:c
                        idx = k2 + (k1-1) * c;
                        if K(k1,k2)
                            lc{idx} = 'true';
                        else
                            lc{idx} = 'false';
                        end
                    end
                end
            elseif strcmp(dt_lus, 'int')
                for k1=1:r
                    for k2=1:c
                        idx = k2 + (k1-1) * c;
                        if isreal(K(k1,k2))
                            lc{idx} = sprintf('%d', K(k1,k2));
                        else
                            lc{idx} = sprintf('%d + i*%d', int32(real(K(k1,k2))), int32(imag(K(k1,k2))));
                        end
                    end
                end
            else
                for k1=1:r
                    for k2=1:c
                        idx = k2 + (k1-1) * c;
                        if isreal(K(k1,k2))
                            lc{idx} = sprintf('%10.8f', K(k1,k2));
                        else
                            lc{idx} = sprintf('%10.8f + i*%10.10f', real(K(k1,k2)), imag(K(k1,k2)));
                        end
                    end
                end
            end
        end
        
        function [dim_r dim_c] = get_port_dims_simple(port_dims, port_number)
            [nb_dim dims] = Utils.get_port_dims(port_dims, port_number);
            dim_r = dims(1);
            if numel(dims) == 1
                dim_c = 1;
            else
                dim_c = dims(2);
            end
        end
        
        function [nb_dim dims] = get_port_dims(port_dims, port_number)
            idx_dim_port = 1;
            for idx_port=1:(port_number-1)
                idx_dim_port = idx_dim_port + port_dims(idx_dim_port) + 1;
            end
            nb_dim = port_dims(idx_dim_port);
            for idx_dim=1:nb_dim
                dims(idx_dim) = port_dims(idx_dim_port + idx_dim);
            end
        end
        
        function [res_str] = concat_delim(str, delim)
            if numel(str) == 0
                res_str = str;
            else
                res_str = '';
                for i=1:(numel(str)-1)
                    res_str = [res_str str{i} delim];
                end
                res_str = [res_str str{end}];
            end
        end
        
        function res = strtok_replace(str, to_be_replaced, replace_with)
            [res remain] = strtok(str);
            if strcmp(res, to_be_replaced)
                res = replace_with;
            end
            if numel(remain) ~= 0
                res = [res ' ' Utils.strtok_replace(remain, to_be_replaced, replace_with)];
            end
        end
        
        function res = strtok_contains(str, to_be_found)
            res = false;
            [first remain] = strtok(str);
            if numel(findstr(first, '(')) == 1 && findstr(first, '(') == 1 && strcmp(first(2:end), to_be_found)
                res = true;
            elseif numel(findstr(first, ')')) == 1 && findstr(first, ')') == numel(first) && strcmp(first(1:end-1), to_be_found)
                res = true;
            elseif strcmp(first, to_be_found)
                res = true;
            else
                if numel(remain) ~= 0
                    res = Utils.strtok_contains(remain, to_be_found);
                end
            end
        end
        
        function str_out = num2logic(num)
            if num ~= 0
                str_out = 'true';
            else
                str_out = 'false';
            end
        end
        
        function str_out = name_format(str)
            str_out = IRUtils.name_format(str);
        end

        function out = naming(nomsim)
            [a, b]=regexp (nomsim, '/', 'split');
            out = strcat(a{numel(a)-1},'_',a{end});
        end
        
        function out = naming_alone(nomsim)
            [a,~]=regexp (nomsim, '/', 'split');
            out = a{end};
        end
        
        function update_status(status)
            try
                h = evalin('base','cocosim_status_handle');
                h.String = status;
                drawnow limitrate
            catch
            end
        end
        
        function st = get_BlockDiagram_SampleTime(file_name)
            ts = Simulink.BlockDiagram.getSampleTimes(file_name);
            st = 0; % start by zero since gcd(0, v) = v;
            cst = 1000000; % Assuming Sample Time is never less than 10^-6, this constant helps gcd to be applied on integers
            for t=ts
                if ~isempty(t.Value) && isnumeric(t.Value)
                    tv = t.Value(1);
                    if ~(isnan(tv) || tv==Inf)
                        st = gcd(st * cst, tv * cst) / cst;
                    end
                end
            end
        end
    end
end

