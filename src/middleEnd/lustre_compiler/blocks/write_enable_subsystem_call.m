function [code, var_list] = write_enable_subsystem_call(...
        node_call_name, ...
        reset_mem, ... 
        enable_signal, ...
        list_in_str, ...
        list_out_def)
    %, ...
    %    list_out_dt, ...
    %    list_out_disabled, ...
    %    list_out_init)
        
% One fresh var for each 'held' output

%lassert(length(list_out)==length(list_out_dt));

list_out = [];
for i = 1:numel(list_out_def)
   list_out = [list_out list_out_def(i).vars]; 
end
list_out_str = Utils.concat_delim(list_out, ', ');
if numel(list_out) > 1
    list_out_str = ['(' list_out_str ')'];
end

nb_out = length(list_out);
var_list = cell(1,nb_out);
copy_out_list = cell(1,nb_out);
code_fresh_vars = [];
cpt=1;
for i=1:length(list_out_def) %nb_out
    output = list_out_def(i);
    for j=1:length(output.vars)
        output
        new_var = ['pre_' output.vars{j}];
        dt = output.dt{j};
        if strcmp(output.initial_value,'[]')
            init_val = 0; % unspecified init value
        else
            init_val = str2num(output.initial_value);
            %init_val = init_val(j);
        end
        disabled=output.value_when_disabled;
        var_list(cpt) = {[new_var ': ' dt ';\n']};
        if strcmp(dt,'real')
            init_val = sprintf('%.15f',init_val);
        elseif strcmp(output.dt,'int')
            init_val = sprintf('%i',init_val);
        elseif strcmp(dt,'bool')
            if init_val 
                init_val = 'true';
            else
                init_val = 'false';
            end
        else
            assert 0;
            init_val = '0'; % TODO: THIS IS FALSE, DEAL with the other types cases
        end
        copy_out_list(cpt) = {new_var};
        if strcmp(disabled,'held')
            code_fresh_vars = [code_fresh_vars '\t' new_var ' = ' init_val ' -> pre ' output.vars{j} ';\n'];
        else
            code_fresh_vars = [code_fresh_vars '\t' new_var ' = ' init_val ';\n'];
        end
        cpt=cpt+1;
    end
end
if numel(copy_out_list) > 1
   copy_out_list_str= ['(' Utils.concat_delim(copy_out_list, ', ') ')'];
else
   copy_out_list_str = copy_out_list{1};
end


automaton_name = ['automaton_' node_call_name '_' list_out{1} ];
if reset_mem
    restart_resume = 'restart';
else
    restart_resume = 'resume';
end

code = [...
   '\n' code_fresh_vars '\n' '\tautomaton ' automaton_name '\n' ...
   '\tstate Active_' automaton_name ':\n' ...
    '\tunless not ' enable_signal ' restart Inactive_' automaton_name '\n' ...
    '\tlet\n' ...
    '\t\t' list_out_str ' = ' node_call_name '('  list_in_str ');\n' ...
    '\ttel\n' ...
    '\tstate Inactive_' automaton_name ':\n' ...
    '\tunless ' enable_signal ' ' restart_resume ' Active_' automaton_name '\n' ...
    '\tlet\n\t\t' list_out_str ' = ' copy_out_list_str  ';\n' ...
    '\ttel\n' ...
   ];
   

end