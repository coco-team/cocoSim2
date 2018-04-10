function [chartStruct] = chart_struct(chartPath)
    % add the CharParser jar file to the path
    [path, ~, ~] = fileparts(mfilename('fullpath'));
    path = fileparts(path);
    path = fullfile(path, 'utils', 'ChartParser.jar');    
    javaaddpath(path);
    
    chartStruct = {};
    chartStruct.Chart = {};
    
    chartPathParts = strsplit(chartPath, '/');    
    % get the name of the model
    modelName = char(chartPathParts(1));
    % get the name of the chart block
    chartStruct.Chart.name = chartPathParts(end);    
    
    % get a handle to the root object
    stateflowRoot = sfroot;
    % get the model object 
    model = stateflowRoot.find('-isa', 'Simulink.BlockDiagram', 'Name',modelName);
    % get the chart object
    chart = model.find('-isa','Stateflow.Chart', 'Path', chartPath);   
    
    %get the chart path
    chartStruct.Chart.origin_path = chart.Path;
    
    % get the data of the chart
    chartData = chart.find('-isa','Stateflow.Data');
    
    % get the states in the chart
    chartStates = chart.find('-isa','Stateflow.State');   
        
    %get the junctions in the chart
    chartJunctions = chart.find('-isa','Stateflow.Junction');       
    
    % build the json struct for data
    chartStruct.Chart.data = cell(length(chartData),1);
    for index = 1 : length(chartData)       
        chartStruct.Chart.data{index} = buildDataStruct(chartData(index));
    end
    
    % add a virtual state that represents the chart itself 
    % set the state path
    virtualState.path = chart.path;    
    %set the id of the state
    virtualState.id = chart.id;       
    virtualState.inner_trans = [];
    virtualState.outer_trans = [];
    %ToDo: find a better name for internal_composition
    virtualState.internal_composition = getContent(chart, false);     
    
    
    % build the json struct for states
    chartStruct.Chart.states = cell(length(chartStates) + 1,1);
     chartStruct.Chart.states{1} = virtualState;
    for index = 1 : length(chartStates)       
        chartStruct.Chart.states{index+1} = buildStateStruct(chartStates(index));
    end
    
    % build the json struct for junctions
    chartStruct.Chart.junctions = cell(length(chartJunctions),1);
    for index = 1 : length(chartJunctions)        
        chartStruct.Chart.junctions{index} = buildJunctionStruct(chartJunctions(index));
    end 
    
    %get the functions in the chart
    chartFunctions = chart.find('-isa','Stateflow.Function'); 
    % build the json struct for functions              
    chartStruct.Chart.graphicalFunctions = cell(length(chartFunctions),1);
    for index = 1 : length(chartFunctions)        
        chartStruct.Chart.graphicalFunctions{index} = buildFunctionStruct(chartFunctions(index));
    end 
end

function dataStruct = buildDataStruct(data)
    dataStruct.id = data.id;
    dataStruct.name = data.name;
    dataStruct.datatype = data.DataType;
    dataStruct.port = data.Port;
    dataStruct.initial_value = data.Props.InitialValue;    
    dataStruct.scope = data.scope;
    dataStruct.array_size = data.Props.Array.Size;
end

function stateStruct =  buildStateStruct(state)    
    % set the state path
    stateStruct.path = strcat (state.Path, '/',state.name);
    
    %set the id of the state
    stateStruct.id = state.id;
    
    % parse the label string of the state
    stateAction = edu.uiowa.chart.state.StateParser.parse(state.LabelString);     
    
    % set the state actions    
    stateStruct.actions.entry = cell(stateAction.entry);
    stateStruct.actions.during = cell(stateAction.during);
    stateStruct.actions.exit = cell(stateAction.exit);
    stateStruct.actions.bind = cell(stateAction.bind);
    stateStruct.actions.on = getOnAction(stateAction.on);
    stateStruct.actions.onAfter = getOnAction(stateAction.onAfter);
    stateStruct.actions.onBefore = getOnAction(stateAction.onBefore);
    stateStruct.actions.onAt = getOnAction(stateAction.onAt);
    stateStruct.actions.onEvery = getOnAction(stateAction.onEvery);
    
    % set the state transitions    
    stateStruct.inner_trans = {};
    transitions = state.innerTransitions;
    for i = 1 : length(transitions)       
       transitionStruct = buildDestinationStruct(transitions(i));                       
       stateStruct.inner_trans = [stateStruct.inner_trans transitionStruct];
    end  
    
    stateStruct.outer_trans = {};
    transitions = state.outerTransitions;
    for i = 1 : length(transitions)
       transitionStruct = buildDestinationStruct(transitions(i));                       
       stateStruct.outer_trans = [stateStruct.outer_trans transitionStruct];
    end  
    
    %ToDo: find a better name for internal_composition
    stateStruct.internal_composition = getContent(state, true);    
end

function content = getContent(chartObject, self)
    content = {};
    
    % specify the decomposition
    if isprop(chartObject, 'Decomposition')
        content.type = chartObject.Decomposition;
    else
        content.type = 'EXCLUSIVE_OR';
    end
    
    %handle initial transitions    
    defaultTransitions = chartObject.defaultTransitions;
    content.initial_transitions = {};
    for i = 1 : length(defaultTransitions)
        transitionStruct = buildDestinationStruct(defaultTransitions(i));                       
       content.initial_transitions = ...
           [content.initial_transitions transitionStruct];
    end
    
    %handle initial states
    childStates = chartObject.find('-isa', 'Stateflow.State', '-depth', 1);
    
    index = 0;
    % for states: child states start from childstates(2)
    % for chart: child states  start from childStates(1)
    if self 
        index = 1; 
    end
    
    content.substates = cell(length(childStates) - index,1);
    content.states = cell(length(childStates) - index,1);
    for i = 1 + index : length(childStates)
        content.substates{i-index} = childStates(i).name;
        content.states{i-index} = childStates(i).id;
    end
end

function junctionStruct =  buildJunctionStruct(junction)    
    % set the junction path
    junctionStruct.path = strcat (junction.Path, '/Junction',int2str(junction.id));
    
    %set the id of the junction
    junctionStruct.id = junction.id;
    
    %set the junction type
    junctionStruct.type = junction.Type;
    
    % set the junction transitions    
    junctionStruct.outer_trans = {};
    transitions = junction.sourcedTransitions;
    for i = 1 : length(transitions)          
       transitionStruct.dest = buildDestinationStruct(transitions(i));
       junctionStruct.outer_trans = [junctionStruct.outer_trans transitionStruct];
    end    
end

function transitionStruct = buildDestinationStruct(transition)
    transitionStruct = {};
    transitionStruct.id = transition.id;       
    destination =  transition.Destination;
    transitionStruct.dest.id = destination.id;    
    
    % parse the label string of the transition
    transitionObject = edu.uiowa.chart.transition.TransitionParser.parse(transition.LabelString);   
    transitionStruct.event = char(transitionObject.eventOrMessage);
    transitionStruct.condition = char(transitionObject.condition);
    transitionStruct.condition_act = cell(transitionObject.conditionActions);  
    transitionStruct.transition_act = cell(transitionObject.transitionActions);  
    
    % check if the destination is a state or a junction
    if strcmp(destination.Type, 'CONNECTIVE') || ...
       strcmp(destination.Type, 'HISTORY')
       transitionStruct.dest.type = 'Junction';
       transitionStruct.dest.name = strcat(destination.Path, '/', ...
           'Junction', int2str(destination.id));
    else
       transitionStruct.dest.type = 'State';
       transitionStruct.dest.name = strcat(destination.Path, '/', ...
           destination.name);
    end                       
end

function functionStruct =  buildFunctionStruct(functionObject)    
    % set the function path
    functionStruct.path = strcat (functionObject.Path, '/',functionObject.name);
    
    %set the id of the function
    functionStruct.id = functionObject.id;       
     
    %set the name of the function
    functionStruct.name = functionObject.name;      
end

function [onActionStruct] = getOnAction(onActionObject)
    onActionArray = cell(onActionObject);
    onActionStruct = cell(length(onActionArray), 1);
    for i = 1 : length(onActionStruct)
        onActionStruct{i}.n = onActionArray{i}.n;
        onActionStruct{i}.eventName = cell(onActionArray{i}.eventName);
        onActionStruct{i}.actions = cell(onActionArray{i}.actions);
    end
end