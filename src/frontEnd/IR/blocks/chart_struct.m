%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2018  The university of Iowa
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Author: Mudathir

function [StateflowContentStruct] = chart_struct(chartPath)
    % add the CharParser jar file to the path
    [path, ~, ~] = fileparts(mfilename('fullpath'));
    path = fileparts(path);
    path = fullfile(path, 'utils', 'ChartParser.jar');    
    javaaddpath(path);
    
    StateflowContentStruct = {};
    
    chartPathParts = strsplit(chartPath, '/');    
    % get the name of the model
    modelName = char(chartPathParts(1));
    % get the name of the chart block
    StateflowContentStruct.Name = chartPathParts(end);    
    
    % get a handle to the root object
    stateflowRoot = sfroot;
    % get the model object 
    model = stateflowRoot.find('-isa', 'Simulink.BlockDiagram', 'Name',modelName);
    % get the chart object
    chart = model.find('-isa','Stateflow.Chart', 'Path', chartPath);   
    
    %get the chart path
    StateflowContentStruct.Path = chart.Path;
       
    % get the data of the chart
    chartData = chart.find('-isa','Stateflow.Data', '-depth', 1);
    % build the json struct for data
    StateflowContentStruct.Data = cell(length(chartData),1);
    for index = 1 : length(chartData)       
        StateflowContentStruct.Data{index} = buildDataStruct(chartData(index));
    end
    
    
    % get the events of the chart
    chartEvents = chart.find('-isa','Stateflow.Event');
    % build the json struct for events
    StateflowContentStruct.Events = cell(length(chartEvents),1);
    for index = 1 : length(chartEvents)       
        StateflowContentStruct.Events{index} = buildEventStruct(chartEvents(index));
    end
    
    % add a virtual state that represents the chart itself 
    % set the state path
    virtualState.Path = chart.path;    
    %set the id of the state
    virtualState.Id = chart.id;       
    virtualState.InnerTransitions = [];
    virtualState.OuterTransitions = [];
    %ToDo: find a better name for composition
    virtualState.Composition = getContent(chart, false);     
    
    % get the states in the chart
    chartStates = chart.find('-isa','Stateflow.State');   
    % build the json struct for states
    StateflowContentStruct.States = cell(length(chartStates) + 1,1);
     StateflowContentStruct.States{1} = virtualState;
    for index = 1 : length(chartStates)       
        StateflowContentStruct.States{index+1} = buildStateStruct(chartStates(index));
    end
    
     %get the junctions in the chart
    chartJunctions = chart.find('-isa','Stateflow.Junction');           
    % build the json struct for junctions
    StateflowContentStruct.Junctions = cell(length(chartJunctions),1);
    for index = 1 : length(chartJunctions)        
        StateflowContentStruct.Junctions{index} = buildJunctionStruct(chartJunctions(index));
    end 
    
    %get the functions in the chart
    chartFunctions = chart.find('-isa','Stateflow.Function'); 
    % build the json struct for functions              
    StateflowContentStruct.GraphicalFunctions = cell(length(chartFunctions),1);
    for index = 1 : length(chartFunctions)        
        StateflowContentStruct.GraphicalFunctions{index} = buildFunctionStruct(chartFunctions(index));
    end 
    
    %get the truth tables in the chart
    chartTruthTables = chart.find('-isa','Stateflow.TruthTable'); 
    % build the json struct for truth tables              
    StateflowContentStruct.TruthTables = cell(length(chartTruthTables),1);
    for index = 1 : length(chartTruthTables)        
        StateflowContentStruct.TruthTables{index} = buildTruthTableStruct(chartTruthTables(index));
    end 
end

function dataStruct = buildDataStruct(data)
    dataStruct.Id = data.id;
    dataStruct.Name = data.name;
    dataStruct.Datatype = data.DataType;
    dataStruct.CompiledType = data.CompiledType;
    dataStruct.Port = data.Port;
    dataStruct.InitialValue = data.Props.InitialValue;    
    dataStruct.Scope = data.scope;
    dataStruct.ArraySize = data.Props.Array.Size;
end

function eventStruct = buildEventStruct(event)
    eventStruct.Id = event.id;
    eventStruct.Name = event.name;    
    eventStruct.Port = event.Port;
    eventStruct.Scope = event.scope;
end

function stateStruct =  buildStateStruct(state)    
    % set the state path
    stateStruct.Path = strcat (state.Path, '/',state.name);
    
    %set the id of the state
    stateStruct.Id = state.id;
    
    % parse the label string of the state
    stateAction = edu.uiowa.chart.state.StateParser.parse(state.LabelString);     
    
    % set the state actions    
    stateStruct.Actions.Entry = cell(stateAction.entry);
    stateStruct.Actions.During = cell(stateAction.during);
    stateStruct.Actions.Exit = cell(stateAction.exit);
    stateStruct.Actions.Bind = cell(stateAction.bind);
    stateStruct.Actions.On = getOnAction(stateAction.on);
    stateStruct.Actions.OnAfter = getOnAction(stateAction.onAfter);
    stateStruct.Actions.OnBefore = getOnAction(stateAction.onBefore);
    stateStruct.Actions.OnAt = getOnAction(stateAction.onAt);
    stateStruct.Actions.OnEvery = getOnAction(stateAction.onEvery);
    
    % set the state transitions    
    stateStruct.InnerTransitions = {};
    transitions = state.innerTransitions;
    for i = 1 : length(transitions)       
       transitionStruct = buildDestinationStruct(transitions(i));                       
       stateStruct.InnerTransitions = [stateStruct.InnerTransitions transitionStruct];
    end  
    
    stateStruct.OuterTransitions = {};
    transitions = state.outerTransitions;
    for i = 1 : length(transitions)
       transitionStruct = buildDestinationStruct(transitions(i));                       
       stateStruct.OuterTransitions = [stateStruct.OuterTransitions transitionStruct];
    end  
    
    %ToDo: find a better name for composition
    stateStruct.Composition = getContent(state, true);    
end

function content = getContent(chartObject, self)
    content = {};
    
    % specify the decomposition
    if isprop(chartObject, 'Decomposition')
        content.Type = chartObject.Decomposition;
    else
        content.Type = 'EXCLUSIVE_OR';
    end
    
    %handle initial transitions    
    defaultTransitions = chartObject.defaultTransitions;
    content.DefaultTransitions = {};
    for i = 1 : length(defaultTransitions)
        transitionStruct = buildDestinationStruct(defaultTransitions(i));                       
       content.DefaultTransitions = ...
           [content.DefaultTransitions transitionStruct];
    end
    
    %handle initial states
    childStates = chartObject.find('-isa', 'Stateflow.State', '-depth', 1);
    
    index = 0;
    % for states: child states start from childstates(2)
    % for chart: child states  start from childStates(1)
    if self 
        index = 1; 
    end
    
    content.Substates = cell(length(childStates) - index,1);
    content.States = cell(length(childStates) - index,1);
    for i = 1 + index : length(childStates)
        content.Substates{i-index} = childStates(i).name;
        content.States{i-index} = childStates(i).id;
    end
end

function junctionStruct =  buildJunctionStruct(junction)    
    % set the junction path
    junctionStruct.Path = strcat (junction.Path, '/Junction',int2str(junction.id));
    
    % set the junction name
    junctionStruct.name = strcat ('Junction',int2str(junction.id));
    
    %set the id of the junction
    junctionStruct.Id = junction.id;
    
    %set the junction type
    junctionStruct.Type = junction.Type;
    
    % set the junction transitions    
    junctionStruct.OuterTransitions = {};
    transitions = junction.sourcedTransitions;
    for i = 1 : length(transitions)          
       transitionStruct.Destination = buildDestinationStruct(transitions(i));
       junctionStruct.OuterTransitions = [junctionStruct.OuterTransitions transitionStruct];
    end    
end

function transitionStruct = buildDestinationStruct(transition)
    transitionStruct = {};
    transitionStruct.Id = transition.id;       
    destination =  transition.Destination;
    transitionStruct.Destination.Id = destination.id;    
    
    % parse the label string of the transition
    transitionObject = edu.uiowa.chart.transition.TransitionParser.parse(transition.LabelString);   
    transitionStruct.Event = char(transitionObject.eventOrMessage);
    transitionStruct.Condition = char(transitionObject.condition);
    transitionStruct.ConditionAction = cell(transitionObject.conditionAction);  
    transitionStruct.TransitionAction = cell(transitionObject.transitionAction);  
    
    % check if the destination is a state or a junction
    if strcmp(destination.Type, 'CONNECTIVE') || ...
       strcmp(destination.Type, 'HISTORY')
       transitionStruct.Destination.Type = 'Junction';
       transitionStruct.Destination.Name = strcat(destination.Path, '/', ...
           'Junction', int2str(destination.id));
    else
       transitionStruct.Destination.Type = 'State';
       transitionStruct.Destination.Name = strcat(destination.Path, '/', ...
           destination.name);
    end                       
end

function functionStruct =  buildFunctionStruct(functionObject)    
    % set the function path
    functionStruct.Path = strcat (functionObject.Path, '/',functionObject.name);
    
    %set the id of the function
    functionStruct.Id = functionObject.id;       
     
    %set the name of the function
    functionStruct.Name = functionObject.name;      
    
    %set the signature of the function
    functionStruct.LabelString = functionObject.LabelString;    
    % set the content of the function
    functionStruct.Composition = getContent(functionObject, false); 
    
     % get the data of the function
    functionData = functionObject.find('-isa','Stateflow.Data');
    % build the json struct for data
    functionStruct.Data = cell(length(functionData),1);
    for index = 1 : length(functionData)       
        functionStruct.Data{index} = buildDataStruct(functionData(index));
    end
    
end

function truthTableStruct =  buildTruthTableStruct(truthTable)       
    % set the truthTable path
    truthTableStruct.Path = strcat (truthTable.Path, '/',truthTable.name);
    
    %set the id of the truthTable
    truthTableStruct.Id = truthTable.id;       
     
    %set the name of the truthTable
    truthTableStruct.Name = truthTable.name;      
    
    %set the signature of the truthTable
    truthTableStruct.LabelString = truthTable.LabelString;    
    
    % set the tables of the truthTable
    truthTableStruct.ConditionTable = truthTable.ConditionTable;
    truthTableStruct.ActionTable = truthTable.ActionTable;
    
     % get the data of the truthTable
    truthTableData = truthTable.find('-isa','Stateflow.Data');
    % build the json struct for data
    truthTableStruct.Data = cell(length(truthTableData),1);
    for index = 1 : length(truthTableData)       
        truthTableStruct.Data{index} = buildDataStruct(truthTableData(index));
    end
    
end

function [onActionStruct] = getOnAction(onActionObject)
    onActionArray = cell(onActionObject);
    onActionStruct = cell(length(onActionArray), 1);
    for i = 1 : length(onActionStruct)
        onActionStruct{i}.N = onActionArray{i}.n;
        onActionStruct{i}.EventName = cell(onActionArray{i}.eventName);
        onActionStruct{i}.Actions = cell(onActionArray{i}.actions);
    end
end