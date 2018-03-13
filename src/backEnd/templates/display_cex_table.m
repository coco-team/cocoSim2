clear;
load('[(matFile)]');
values = {Inputs_[(propertyName)] , Outputs_[(propertyName)]};
f = figure('Name','[(originPath)]','NumberTitle','off');
t = uitable(f);
for j= 1 : length(values{1}.time)
    columnNames{j} = values{1}.time(j);
end
t.ColumnName = columnNames;
t.ColumnEditable = true;

rowNames = {};
%input variables
inputVariables = length(values{1}.signals);
for i = 1: inputVariables
    name = strcat(values{1}.signals(i).var_name, ' (input)');
    rowNames{i}  = name;
    for j=1 : length(values{1}.time)
        data{i, j} = values{1}.signals(i).values(j);
    end
end
%output variables

if [(displayOutput)]
    outputVariables = length(values{2}.signals);
    for i = 1: outputVariables
        name = strcat(values{2}.signals(i).var_name, ' (output)');
        rowNames{i + inputVariables}  = name;
        for j=1 : length(values{2}.time)
            data{i +inputVariables, j} = values{2}.signals(i).values(j);
        end
    end
end
t.Data = data;
t.RowName = rowNames;
set(t,'ColumnWidth',{50});
set(t,'Position',[10 200 500 200]);

