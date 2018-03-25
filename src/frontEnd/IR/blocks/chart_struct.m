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
    % get the states of the chart
    chartStates = chart.find('-isa','Stateflow.State');
    
    transitions = chart.find('-isa','Stateflow.Transition');
    
    % build the json struct for states
    chartStruct.states = cell(length(chartStates),1);
    for index = 1 : length(chartStates)
        chartStruct.states{index} = buildStateStruct(chartStates(index));
    end
end

function stateStruct =  buildStateStruct(state)    
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
end