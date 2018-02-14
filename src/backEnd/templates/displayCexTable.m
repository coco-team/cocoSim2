%get the verification results
modelWorkspace = get_param(bdroot(gcs),'ModelWorkspace');
verificationResults = modelWorkspace.getVariable('verificationResults');
nodeNameToBlockNameMap = modelWorkspace.getVariable('nodeNameToBlockNameMap');

propertyStruct = verificationResults.analysisResults{[(resultIndex)]}.properties{[(propertyIndex)]};

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
panel = uipanel('Parent',f);
panel.Position = [0 0 f.Position(3) f.Position(4)];

% draw a table for each node
tables = cell(1, length(flattenedNodes));
for nodeIndex =1 : length(flattenedNodes)    
    
    t = uitable(panel);

    columns = flattenedNodes{nodeIndex}.timeSteps;
    columnNames = cell (1, columns);

    for j= 1 : columns
        columnNames{j} = j - 1;
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
    if nodeIndex > 1       
        t.Position(2) = tables{nodeIndex - 1}.Position(2) + tables{nodeIndex - 1}.Position(4) + 30;
    end
    tableName = flattenedNodes{nodeIndex}.name;
    if isKey(nodeNameToBlockNameMap, tableName)
        tableName = nodeNameToBlockNameMap(flattenedNodes{nodeIndex}.name);
    end
    text = uicontrol('Style','text','String',tableName,'parent',panel);
    text.Position = [0 t.Position(2)+t.Position(4)  500 20];
    tables{nodeIndex} = t;
end
