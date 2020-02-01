%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2018  The university of Iowa
% Author: Mudathir Mahgoub
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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
    
    %get the chart ActionLanguage, StateMachineType, ChartUpdate, 
    % ExecuteAtInitialization, InitializeOutput, EnableNonTerminalStates
    StateflowContentStruct.ActionLanguage = chart.ActionLanguage;
    StateflowContentStruct.StateMachineType = chart.StateMachineType;
    StateflowContentStruct.ChartUpdate = chart.ChartUpdate;
    StateflowContentStruct.ExecuteAtInitialization = chart.ExecuteAtInitialization;
    StateflowContentStruct.InitializeOutput = chart.InitializeOutput;
    StateflowContentStruct.EnableNonTerminalStates = chart.EnableNonTerminalStates;
    
    %get the chart path
    StateflowContentStruct.Path = chart.Path;
       
    % get the data of the chart
    chartData = chart.find('-isa','Stateflow.Data', '-depth', 1);
    % build the json struct for data
    StateflowContentStruct.Data = cell(length(chartData),1);
    for index = 1 : length(chartData)       
        StateflowContentStruct.Data{index} = SFStruct.buildDataStruct(chartData(index));
    end
    
    
    % get the events of the chart
    chartEvents = chart.find('-isa','Stateflow.Event');
    % build the json struct for events
    StateflowContentStruct.Events = cell(length(chartEvents),1);
    for index = 1 : length(chartEvents)       
        StateflowContentStruct.Events{index} = SFStruct.buildEventStruct(chartEvents(index));
    end
    
    % add a virtual state that represents the chart itself 
    % set the state path
    virtualState.Path = chart.path;   
    virtualState.Name = chart.Name; 
    %set the id of the state
    virtualState.Id = chart.id;       
    virtualState.InnerTransitions = [];
    virtualState.OuterTransitions = [];
    states_fields = {'Entry', 'During', 'Exit', 'Bind', 'On', 'OnAfter', ...
        'OnBefore', 'OnAt', 'OnEvery'};
    for f=states_fields
        virtualState.Actions.(f{1}) = '';
    end
    %ToDo: find a better name for composition
    virtualState.Composition = SFStruct.getContent(chart, false);     
    
    % get the states in the chart
    chartStates = chart.find('-isa','Stateflow.State');   
    % build the json struct for states
    StateflowContentStruct.States = cell(length(chartStates) + 1,1);
     StateflowContentStruct.States{1} = virtualState;
    for index = 1 : length(chartStates)       
        StateflowContentStruct.States{index+1} = SFStruct.buildStateStruct(chartStates(index));
    end
    
     %get the junctions in the chart
    chartJunctions = chart.find('-isa','Stateflow.Junction');           
    % build the json struct for junctions
    StateflowContentStruct.Junctions = cell(length(chartJunctions),1);
    for index = 1 : length(chartJunctions)        
        StateflowContentStruct.Junctions{index} = SFStruct.buildJunctionStruct(chartJunctions(index));
    end 
    
    %get the functions in the chart
    chartFunctions = chart.find('-isa','Stateflow.Function'); 
    % build the json struct for functions              
    StateflowContentStruct.GraphicalFunctions = cell(length(chartFunctions),1);
    for index = 1 : length(chartFunctions)        
        StateflowContentStruct.GraphicalFunctions{index} = SFStruct.buildGraphicalFunctionStruct(chartFunctions(index));
    end 
    
    %get simulink functions in the chart
    chartSimulinkFunctions = chart.find('-isa','Stateflow.SLFunction'); 
    % build the json struct for simulink functions              
    StateflowContentStruct.SimulinkFunctions = cell(length(chartSimulinkFunctions),1);
    for index = 1 : length(chartSimulinkFunctions)        
        StateflowContentStruct.SimulinkFunctions{index} = SFStruct.buildSimulinkFunctionStruct(chartSimulinkFunctions(index));
    end 
    
    %get the truth tables in the chart
    chartTruthTables = chart.find('-isa','Stateflow.TruthTable'); 
    % build the json struct for truth tables              
    StateflowContentStruct.TruthTables = cell(length(chartTruthTables),1);
    for index = 1 : length(chartTruthTables)        
        StateflowContentStruct.TruthTables{index} = SFStruct.buildTruthTableStruct(chartTruthTables(index));
    end 
end
