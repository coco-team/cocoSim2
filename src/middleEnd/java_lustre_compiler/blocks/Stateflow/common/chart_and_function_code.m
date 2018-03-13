%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [nodes_string, ...
    external_nodes, ...
    global_nodes_struct, ...
    nb_actions, ...
    nb_nodes] = chart_and_function_code( chart_or_fun, global_nodes_struct, isStateflowFunction, transitions_fcts,data_fcts, Debug ,xml_trace, file_name)

%CHART_AND_FUNCTION_CODE generates lustre code for a function or a chart
% inputs :
% chart_or_fun : chart or Stateflow function that will be translated to
%               lustre.
% global_nodes_struct : is a struct that saves all previous generated
%                lustre nodes.
% isStateflowFunction : indicates if it is a chart or Stateflow function
% transitions_fcts : contains all functions transitions, to be reducted
% from chart transitions. The chart has access to all transitions even
% Stateflow function, so we need to be sure we don't translate transitions
% twice.
%
% return :
% nodes_string : the lustre code of chart or function translation.
% external_nodes : containes informations about functions called as actions
%    but are not translated yet, like mathematical functions (min, max ..)
% global_node_struct : is the struct in input updated with the new
% generated lustre nodes.
% nb_actions and nb_nodes : are here for statistics.
if ~exist('Debug', 'var')
    Debug = 0;
end
nodes_string = '';
external_nodes = [];
nb_nodes = 0;
nb_actions = 0;


events = chart_or_fun.find('-isa', 'Stateflow.Event');

% we extract Data with depth 1 just to avoid Functions Data. a chart has
% access to all its objects data.
data = sort_by_order(chart_or_fun.find('-isa', 'Stateflow.Data'),'name');
data = setdiff(data, data_fcts);
% states = chart_or_fun.find('-isa', 'Stateflow.State');
% states = sort_by_order(chart_or_fun.find('-isa', 'Stateflow.State'),'states');
states = get_states(chart_or_fun);
% for i=1:numel(states)
%     states(i).Name
%     states(i).Position(1)
% end
% return

%we can't do the same as Data and define -depth 1. because it will give us
%just transitions of the first level. Here we take all transitions defined
%in the chart and delet functions transitions.
transitions = chart_or_fun.find('-isa','Stateflow.Transition');
transitions = setdiff(transitions, transitions_fcts);



%%% construction of node header for external nodes
[global_node_param, ...
    global_node_return, ...
    variables_struct]= extern_nodes_header(chart_or_fun, data, events, states, isStateflowFunction);
variables_to_be_initialized_in_global_node = variables_struct;

%this section if for functions : it adds more information to it's data.
% there are two types of funtcions :
% *functions without outputs : this type try to change global chart Data. So
%we add Chart information to functions inputs and outputs.
% *functions generate outputs : these functions normally calculate
% something and give us a generic result. We assume that the user don't
% change chart Data in this type of functions. So we don't add information
% to that type of function.
if isStateflowFunction
    
    if isempty(global_node_return)
        isfunction_without_output = true;
        global_chart = chart_or_fun.Chart;
        global_data = global_chart.find('-isa', 'Stateflow.Data','-depth',1);
        data = [data; global_data];
        global_states = global_chart.find('-isa', 'Stateflow.State');
        global_events = chart_or_fun.find('-isa', 'Stateflow.Event');       
        [ ~,~,global_variables_struct]= extern_nodes_header(global_chart, global_data, global_events, global_states, false);       
        variables_struct = [variables_struct, global_variables_struct];
    else
        isfunction_without_output = false;
    end
else
    isfunction_without_output = false;
end

%Matlab functions (not yet supported)
matlab_functions = chart_or_fun.find('-isa','Stateflow.EMFunction');
for i=1:numel(matlab_functions)
    if Debug
        fprintf('Start generating code for Matlab function : %s in chart : %s\n',matlab_functions(i).Name, chart_or_fun.Name);
    end
    [nodes_string_i,...
        external_nodes_i, ...
        global_nodes_struct] = write_sf_Matlab_function_node(chart_or_fun,data, matlab_functions(i), variables_struct, global_nodes_struct)
    nodes_string = [nodes_string nodes_string_i '\n'];
    external_nodes = [external_nodes, external_nodes_i];
end
%the order of the following generation is important. We start with
%transitions actions, then state action because state action can call
%sometimes transitions actions. After that the state node that calls state
%actions and transitions actions. Finally the global node that calls state
%node.


% add to extern_nodes_string transitions' actions (i.e A_To_B_Condition_Action, A_To_B_Transition_Action ...)
if Debug
    fprintf('Start generating code of transitions actions of chart or function : "%s"\n',chart_or_fun.Name);
end
send_transitions = [];
for i=1:size(transitions,1)
    try
        [transition_actions, nb_transition_actions, ext_nodes, global_nodes_struct] = write_Transition_actions(chart_or_fun, data, transitions(i), variables_struct, isStateflowFunction, global_nodes_struct);
    catch ME
        if strfind(transitions(i).LabelString,'send(')
            send_transitions = [send_transitions, transitions(i)];
            continue;
        else
            msg = sprintf('transitions actions level for chart : "%s" and tansition label : "%s"',chart_or_fun.Name, transitions(i).LabelString);
            causeException = MException('MATLAB:myCode:action',msg);
            ME = addCause(ME,causeException);
            rethrow(ME)
        end
    end
    nodes_string = [nodes_string transition_actions '\n'];
    external_nodes = [external_nodes, ext_nodes];
    nb_actions = nb_actions + nb_transition_actions;
end


% add to extern_nodes_string states' actions (i.e A_en, A_ex, A_du ...)
n=numel(states);
for i=1:n %n:-1:1
    if Debug
        fprintf('Start generating code of state actions of state : "%s" with unique name :"%s"\n',states(i).Name, get_full_name(states(i)));
    end
    try
        [state_actions, nb_state_actions, ext_nodes, global_nodes_struct] = write_state_actions(chart_or_fun, data, states(i), variables_struct, global_nodes_struct);
    catch ME
        msg = sprintf('write_state_actions level for chart : "%s" and state name : "%s"',chart_or_fun.Name, get_full_name(states(i)));
        causeException = MException('MATLAB:myCode:action',msg);
        ME = addCause(ME,causeException);
        rethrow(ME)
    end
    nb_actions = nb_actions + nb_state_actions;
    nodes_string = [nodes_string state_actions '\n'];
    external_nodes = [external_nodes, ext_nodes];
end




nb_nodes =nb_nodes+ nb_actions;
% add to extern_nodes_string states' automaton nodes (i.e Anode, Bnode ...)
N = numel(states);
for i=1:N %N:-1:1
    if ~isempty(states(i).findShallow('State')) || ~isempty(states(i).findShallow('Transition'))
        if ~isempty(send_transitions)
            [send_transitions_i, send_transitions] = get_transition(states(i),send_transitions);
            for j=1:numel(send_transitions_i)
                transition = send_transitions_i(j);
                try
                    [transition_actions, nb_transition_actions, ext_nodes, global_nodes_struct] = write_Transition_actions(chart_or_fun, data, transition, variables_struct, isStateflowFunction, global_nodes_struct);
                catch ME

                    msg = sprintf('transitions actions level for chart : "%s" and tansition label : "%s"',chart_or_fun.Name, transition.LabelString);
                    causeException = MException('MATLAB:myCode:action',msg);
                    ME = addCause(ME,causeException);
                    rethrow(ME)

                end
                nodes_string = [nodes_string transition_actions '\n'];
                external_nodes = [external_nodes, ext_nodes];
                nb_actions = nb_actions + nb_transition_actions;
            end
        end
        if Debug
            fprintf('Start generating automaton code of state: "%s" with unique name :"%s"\n',states(i).Name, get_full_name(states(i)));
        end
        try
            state_node_obj = write_state_node(chart_or_fun, data, states(i), isStateflowFunction, variables_struct, global_nodes_struct);
            state_node = state_node_obj.state_node;
            global_nodes_struct = state_node_obj.global_nodes_struct;
            ext_nodes = state_node_obj.external_nodes;
        catch ME
            msg = sprintf('write_state_node level for chart : "%s" and state name : "%s"',chart_or_fun.Name, get_full_name(states(i)));
            causeException = MException('MATLAB:myCode:action',msg);
            ME = addCause(ME,causeException);
            rethrow(ME)
        end
        nodes_string = [nodes_string state_node '\n'];
        nb_nodes = nb_nodes + 1;
        external_nodes = [external_nodes, ext_nodes];
    end
end
if Debug
    fprintf('Start generating automaton code of chart: "%s"\n',chart_or_fun.Name);
end
try
    state_node_obj= write_state_node(chart_or_fun, data, chart_or_fun, isStateflowFunction, variables_struct, global_nodes_struct);
    state_node = state_node_obj.state_node;
    global_nodes_struct = state_node_obj.global_nodes_struct;
    ext_nodes = state_node_obj.external_nodes;
catch ME
    msg = sprintf('write_state_node level for chart : "%s" ',chart_or_fun.Name);
    causeException = MException('MATLAB:myCode:stateNode',msg);
    ME = addCause(ME,causeException);
    rethrow(ME)
end
nodes_string = [nodes_string state_node '\n'];
nb_nodes = nb_nodes + 1;
external_nodes = [external_nodes, ext_nodes];

if Debug
    fprintf('Start generating global node code of chart: "%s"\n',chart_or_fun.Name);
end
try
[global_node, global_nodes_struct] =  write_global_node(chart_or_fun, data, global_node_param,global_node_return,variables_to_be_initialized_in_global_node,isStateflowFunction, isfunction_without_output,variables_struct, global_nodes_struct ,xml_trace, file_name);
catch ME
    msg = sprintf('write_global_node level for chart : "%s" ',chart_or_fun.Name);
    causeException = MException('MATLAB:myCode:chartNode',msg);
    ME = addCause(ME,causeException);
    rethrow(ME)
end
nodes_string = [nodes_string global_node '\n'];
nb_nodes = nb_nodes + 1;


end

function [send_transitions_i, send_transitions] = get_transition(s,send_transitions)
send_transitions_i  = [];
state_name = s.Name;
for i=1:numel(send_transitions)
    s_tr_name = Utils.naming_alone(send_transitions(i).Path);
    if strcmp(state_name,s_tr_name)
        send_transitions_i = [send_transitions_i, send_transitions(i)];
    end
end
send_transitions = setdiff(send_transitions,send_transitions_i);
end

function states = get_states(chart)
states = [];
states_1 = sort_by_order(chart.findShallow('State'),'states');
for i=1:numel(states_1)
    states = [ get_states(states_1(i)); states_1(i); states ];
end
end