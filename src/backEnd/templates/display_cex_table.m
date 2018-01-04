load('[(matFile)]');
values = {Inputs_[(propertyName)] , Outputs_[(propertyName)]};
f = figure;
t = uitable(f);
columnNames{1} = '';
for j= 1 : length(values{1}.time)
    columnNames{j+1} = values{1}.time(j);
end
t.ColumnName = columnNames;
t.ColumnEditable = true;

%input variables
inputVariables = length(values{1}.signals);
for i = 1: inputVariables
    name = strcat(values{1}.signals(i).var_name, ' (input)');
    data{i,1}  = name;
    for j=1 : length(values{1}.time)
        data{i, j+1} = values{1}.signals(i).values(j);
    end
end
%output variables

if [(displayOutput)]
    outputVariables = length(values{2}.signals);
    for i = 1: outputVariables
        name = strcat(values{2}.signals(i).var_name, ' (output)');
        data{i + inputVariables,1}  = name;
        for j=1 : length(values{2}.time)
            data{i +inputVariables, j+1} = values{2}.signals(i).values(j);
        end
    end
end
t.Data = data;


