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
    
    % create a map that holds all needed chart objects
    chartObjectsMap = containers.Map('KeyType','int32','ValueType','any');
    
    % a convenient function to add chart objects to chartObjectsMap
    function addObjectToMap(chartObject)
        chartObjectsMap(chartObject.id) = chartObject;
    end
    
    % get the states in the chart
    chartStates = chart.find('-isa','Stateflow.State');
    % add chart states to the map
    arrayfun(@addObjectToMap, chartStates);
    %get the transitions in the chart
    chartTransitions = chart.find('-isa','Stateflow.Transition');
    % add chart transitions to the map
    arrayfun(@addObjectToMap, chartTransitions);
       
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
end

function stateStruct =  buildStateStruct(state, stateTransitions)    
    % set the state path
    stateStruct.path = state.Path;
    
    % parse the label string of the state
    hashMap = edu.uiowa.chart.state.StateActionParser.parse(state.LabelString);     
    keys = hashMap.keySet.toArray;
     
    % set the state actions
    stateStruct.state_actions = {};  
    for i = 1 : length(keys)
        stateStruct.state_actions.(keys(i)) = char(hashMap.get(keys(i)));
    end    
    
    % set the state transitions    
    stateStruct.outer_trans = {};
    for i = 1 : length(stateTransitions)
       transitionStruct.id = stateTransitions(i).id;
       
       transitionStruct.dest.id = stateTransitions(i).Destination.id;
       
       % check if the destination is a junction or a state
       if strcmp(stateTransitions(i).Destination.Type, 'CONNECTIVE')
           transitionStruct.dest.type = 'Junction';
           transitionStruct.dest.name = '';
       else
           transitionStruct.dest.type = 'State';
           transitionStruct.dest.name = stateTransitions(i).Destination.name;
       end                
       stateStruct.outer_trans = [stateStruct.outer_trans transitionStruct];
    end    
end