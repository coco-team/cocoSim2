function [chartStruct] = chart_struct(chartPath)
    % add the CharParser jar file to the path
    [path, ~, ~] = fileparts(mfilename('fullpath'));
    path = fileparts(path);
    path = fullfile(path, 'utils', 'ChartParser.jar');    
    javaaddpath(path);
    
    chartStruct = {};
    chartStruct.SFCHART = {};
    
    chartPathParts = strsplit(chartPath, '/');    
    % get the name of the model
    modelName = char(chartPathParts(1));
    % get the name of the chart block
    chartStruct.SFCHART.name = chartPathParts(end);    
    
    % get a handle to the root object
    stateflowRoot = sfroot;
    % get the model object 
    model = stateflowRoot.find('-isa', 'Simulink.BlockDiagram', 'Name',modelName);
    % get the chart object
    chart = model.find('-isa','Stateflow.Chart', 'Path', chartPath);   
    
    %get the chart path
    chartStruct.SFCHART.origin_path = chart.Path;
    
    % get the data of the chart
    chartData = chart.find('-isa','Stateflow.Data');
    
    % get the states in the chart
    chartStates = chart.find('-isa','Stateflow.State');
    
    %get the transitions in the chart
    chartTransitions = chart.find('-isa','Stateflow.Transition');
    
    %get the junctions in the chart
    chartJunctions = chart.find('-isa','Stateflow.Junction');       
    
    % a map to store the pairs (transition.source, transition)
    sourceTransitionMap = containers.Map('KeyType','int32','ValueType','any');
        
    for i = 1 : length(chartTransitions)
        if ~ isempty(chartTransitions(i).Source) 
            id = chartTransitions(i).Source.id;
            if isKey(sourceTransitionMap, id)
                sourceTransitionMap(id) = [sourceTransitionMap(id) chartTransitions(i)];
            else
                sourceTransitionMap(id) = chartTransitions(i);
            end
        end
    end
    
    % build the json struct for data
    chartStruct.SFCHART.data = cell(length(chartData),1);
    for index = 1 : length(chartData)       
        chartStruct.SFCHART.data{index} = buildDataStruct(chartData(index));
    end
    
    % build the json struct for states
    chartStruct.SFCHART.states = cell(length(chartStates),1);
    for index = 1 : length(chartStates)
        % if the state is a source of some transitions
        stateTransitions = [];
        if isKey(sourceTransitionMap, chartStates(index).id)
            stateTransitions = sourceTransitionMap(chartStates(index).id);
        end
        chartStruct.SFCHART.states{index} = buildStateStruct(chartStates(index), stateTransitions);
    end
    
    % build the json struct for junctions
    chartStruct.SFCHART.junctions = cell(length(chartJunctions),1);
    for index = 1 : length(chartJunctions)
        % if the junction is a source of some transitions
        junctionTransitions = [];
        if isKey(sourceTransitionMap, chartJunctions(index).id)
            junctionTransitions = sourceTransitionMap(chartJunctions(index).id);
        end
        chartStruct.SFCHART.junctions{index} = buildJunctionStruct(chartJunctions(index), junctionTransitions);
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

function stateStruct =  buildStateStruct(state, stateTransitions)    
    % set the state path
    stateStruct.path = strcat (state.Path, '/',state.name);
    
    %set the id of the state
    stateStruct.id = state.id;
    
    % parse the label string of the state
    hashMap = edu.uiowa.chart.state.StateParser.parse(state.LabelString);     
    keys = hashMap.keySet.toArray;
     
    % set the state actions
    stateStruct.state_actions = {};  
    for i = 1 : length(keys)
        stateStruct.state_actions.(keys(i)) = char(hashMap.get(keys(i)));
    end    
    
    % set the state transitions    
    stateStruct.outer_trans = {};
    for i = 1 : length(stateTransitions)
       transitionStruct = buildDestinationStruct(stateTransitions(i));               
       stateStruct.outer_trans = [stateStruct.outer_trans transitionStruct];
    end    
end

function junctionStruct =  buildJunctionStruct(junction, junctionTransitions)    
    % set the junction path
    junctionStruct.path = strcat (junction.Path, '/Junction',int2str(junction.id));
    
    %set the junction type
    junctionStruct.type = junction.Type;
    
    % set the junction transitions    
    junctionStruct.outer_trans = {};
    for i = 1 : length(junctionTransitions)          
       transitionStruct.dest = buildDestinationStruct(junctionTransitions(i));
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