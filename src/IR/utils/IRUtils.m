classdef IRUtils
    methods (Static = true)
        
    function str_out = name_format(str)
            newline = sprintf('\n');
            str_out = strrep(str, newline, '');
            str_out = strrep(str_out, ' ', '');
            str_out = strrep(str_out, '-', '_minus_');
            str_out = strrep(str_out, '+', '_plus_');
            str_out = strrep(str_out, '*', '_mult_');
            str_out = strrep(str_out, '.', '_dot_');
            str_out = strrep(str_out, '#', '_sharp_');
            str_out = strrep(str_out, '(', '_lpar_');
            str_out = strrep(str_out, ')', '_rpar_');
            str_out = strrep(str_out, '[', '_lsbrak_');
            str_out = strrep(str_out, ']', '_rsbrak_');
            str_out = strrep(str_out, '{', '_lbrak_');
            str_out = strrep(str_out, '}', '_rbrak_');
            %hamza modification
            str_out = strrep(str_out, ',', '_comma_');
            %             str_out = strrep(str_out, '/', '_slash_');
            str_out = strrep(str_out, '=', '_equal_');
            
            str_out = regexprep(str_out, '/(\d+)', '/_$1');
            str_out = regexprep(str_out, '[^a-zA-Z0-9_/]', '_');
        end

        function st = get_BlockDiagram_SampleTime(file_name)
            ts = Simulink.BlockDiagram.getSampleTimes(file_name);
            st = 1;
            for t=ts
                if ~isempty(t.Value) && isnumeric(t.Value)
                    tv = t.Value(1);
                    if ~(isnan(tv) || tv==Inf)
                        st = gcd(st*100,tv*100)/100;
                        
                    end
                end
            end
        end
    end 
end
