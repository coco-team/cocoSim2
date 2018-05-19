%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2018  The university of Iowa
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Author: Mudathir

function displayCexTables(resultIndex, propertyIndex)
    %get the verification results
    modelWorkspace = get_param(bdroot(gcs),'ModelWorkspace');
    verificationResults = modelWorkspace.getVariable('verificationResults');
    nodeNameToBlockNameMap = modelWorkspace.getVariable('nodeNameToBlockNameMap');

    propertyStruct = verificationResults.analysisResults{resultIndex}.properties{propertyIndex};

    % faltten all nested nodes
    node = propertyStruct.counterExample.node;
    flattenedNodes = {node};

    if isfield(node,'nodes')
        queue = node.nodes;
        while length(queue) > 0
            % add the first element to the flattenedNodes
            flattenedNodes = cat(2, flattenedNodes, queue(1));
            % add the nested nodes of the first element
            if isfield(queue{1},'nodes')
                queue = cat(2, queue, queue{1}.nodes);            
            end        
            % remove the first element
            queue = queue (2: end);
        end
    end

    % draw a figure that holds all tables
    f = figure('Name',propertyStruct.originPath,'NumberTitle','off');
    
    % draw a table for each node
    tables = cell(1, length(flattenedNodes));
    labels = cell(1, length(flattenedNodes));
    
    for nodeIndex = length(flattenedNodes): -1 : 1     

        t = uitable(f);

        columns = flattenedNodes{nodeIndex}.timeSteps;
        columnNames = cell (1, columns);

        timeStep = 0;
        
        for j= 1 : columns
            columnNames{j} = timeStep;
            timeStep = timeStep + verificationResults.sampleTime;
        end

        t.ColumnName = columnNames;
        t.ColumnEditable = true;

        rows = length(flattenedNodes{nodeIndex}.streams);
        rowNames = cell(1, rows);

        data = cell (rows, columns);
        for i = 1: rows
            name = flattenedNodes{nodeIndex}.streams{i}.name;
            class = flattenedNodes{nodeIndex}.streams{i}.class;
            rowName = strcat(name, ' (', class, ')');
            rowNames{i}  = rowName;
            for j=1 : propertyStruct.counterExample.node.timeSteps
                data{i, j} = flattenedNodes{nodeIndex}.streams{i}.values(j);
            end
        end

        t.Data = data;
        t.RowName = rowNames;
        t.ColumnWidth = {50};    
        t.Position(3:4) = t.Extent(3:4);
        if nodeIndex < length(tables)       
            t.Position(2) = tables{nodeIndex + 1}.Position(2) + tables{nodeIndex + 1}.Position(4) + 30;
        end
        tableName = flattenedNodes{nodeIndex}.name;
        if isKey(nodeNameToBlockNameMap, tableName)
            tableName = nodeNameToBlockNameMap(flattenedNodes{nodeIndex}.name);
        end
        text = uicontrol('Style','text','String',tableName,'parent',f);
        text.Position = [0 t.Position(2)+t.Position(4)  500 20];
        labels{nodeIndex} = text;
        tables{nodeIndex} = t;
    end

    totalHeight = labels{1}.Position(2)+20;
    % difference = tables height - window height
    difference = totalHeight - f.Position(4);    
    labelPositions = cell(1, length(labels));
    tablePositions = cell(1, length(labels));
    for nodeIndex = 1 : length(labels)
        labels{nodeIndex}.Position(2) = labels{nodeIndex}.Position(2) - difference;
        tables{nodeIndex}.Position(2) = tables{nodeIndex}.Position(2) - difference;
        labelPositions{nodeIndex} = labels{nodeIndex}.Position(2);
        tablePositions{nodeIndex} = tables{nodeIndex}.Position(2);
    end
    
    slider = uicontrol('Parent', f, 'Style', 'slider', ...
        'Min',0,'Max',100,'Value',100,...
        'Units', 'Normalized', 'Position',[0.97,0,.03,1], ...
        'Callback', @sliderCallback) ; 
    
    function sliderCallback(source,event)
            y = (100 - source.Value)/100 * difference;               
            for index = 1 : length(labels)
                labels{index}.Position(2) = labelPositions{index} + y;
                tables{index}.Position(2) = tablePositions{index} + y;
            end
    end
end