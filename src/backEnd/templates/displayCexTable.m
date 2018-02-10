modelWorkspace = get_param(bdroot(gcs),'ModelWorkspace');
verificationResults = modelWorkspace.getVariable('verificationResults');
propertyStruct = verificationResults.analysisResults{[(resultIndex)]}.properties{[(propertyIndex)]};
f = figure('Name',propertyStruct.originPath,'NumberTitle','off');
t = uitable(f);

columns = propertyStruct.counterExample.node.timeSteps;
columnNames = cell (1, columns);

for j= 1 : columns
    columnNames{j} = j - 1;
end

t.ColumnName = columnNames;
t.ColumnEditable = true;

rows = length(propertyStruct.counterExample.node.streams);
rowNames = cell(1, rows);

data = cell (rows, columns);
for i = 1: rows
    name = propertyStruct.counterExample.node.streams{i}.name;
    class = propertyStruct.counterExample.node.streams{i}.class;
    rowName = strcat(name, ' (', class, ')');
    rowNames{i}  = rowName;
    for j=1 : propertyStruct.counterExample.node.timeSteps
        data{i, j} = propertyStruct.counterExample.node.streams{i}.values(j);
    end
end

t.Data = data;
t.RowName = rowNames;
t.ColumnWidth = {50};
t.Position(3:4) = t.Extent(3:4);
f.Position(3) = t.Position(3) + 20;




