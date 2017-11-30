function [let_tel_code_string, var_list, assertions] = write_enable_subsystem(...
        current_block, ...
        let_tel_code_string_content, ...
        var_list_content, ...
        assertions_content)

% We assume that current_block provides the following fields
block_name = current_blk.name{1};
enable_signal = current_blk.enable_signal;
enable_reset = current_blk.enable_reset;

port_value_when_disabled = current_blk.port_value_when_disabled; % this is would 
% shall be replaced by an outport
         
% outports field shall be an array of output each output being defined as
% {name = string, type = string, init_val = string value, disabled = 'held' | 'reset'}

outports = current_blk.outports
% Each output with a 'held' needs an additional variable
outports = xxx get the outports of block
get the outport names, initial value and reset status

%list_var_outport(block_outport)

var_list = []
inactive_defs = []
header = ''
for i=1:length(outports)
    if strcmp(port_value_when_disabled(i),'held')
        outport = outports(i);
        pre_outport_name = ['pre_' outport.name];
        var_list = [var_list '\t' outport.name ':' outport.type '\n']
        inactive_defs = [inactive_defs '\t\t' outport.name ' = ' outport.init_val ' -> ' pre_outport_name ';\n'];
        header = [header '\t' pre_outport_name ' = pre ' outport.name '\n'];
    else % this is then a reset. No new var. Just defining the inactive def
        inactive_defs = [inactive_defs '\t\t' outport.namme ' = ' outport.init_val ';\n'];
    end
end

automaton_name = ['automaton_' block_name ]
if enable_reset 
    restart_resume = 'restart';
else
    restart_resume = 'reset';
end

let_tel_code_string = [...
   '\t' header '\n' '\tautomaton ' automaton_name '\n' ...
   '\tstate Active_' automaton_name ':\n' ...
   '\tunless not ' enable_signal ' restart Inactive_ ' automaton_name '\n' ...
   '\tvar ' var_list_content '\n' ...
   '\tlet\n' ...
   let_tel_code_string_content '\n' ... % one could add a \t at each line 
   assertions_content '\n' ...
   '\ttel\n' ...
   '\tstate Inactive_' automaton_name ':\n' ...
   '\tunless ' enable_signal ' ' restart_resume ' Inactive_ ' automaton_name '\n' ...
   '\tlet\n' inactive_defs '\n' ...
   '\ttel\n' ...
   ];
   

% For the moment, no automaton-specific assertations.
assertions = [];
end
