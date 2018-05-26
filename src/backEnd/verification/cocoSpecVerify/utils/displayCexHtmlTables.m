%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2018  The university of Iowa
% Author: Mudathir Mahgoub
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function displayCexHtmlTables(resultIndex, propertyIndex)
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

    property = {};
    property.originPath = propertyStruct.originPath;
    
    property.tables = cell(length(flattenedNodes), 1);
    
    
    for nodeIndex = 1 : length(flattenedNodes)

        table = {};
        
        columns = flattenedNodes{nodeIndex}.timeSteps;
        % additional column for the row name
        columnNames = cell (1, columns + 1);

        timeStep = 0;
        columnNames{1} = 'Time';
        for j= 1 : columns
            columnNames{j+1} = num2str(timeStep);
            timeStep = timeStep + verificationResults.sampleTime;
        end
        
        table.columnNames = columnNames;        
        
        rows = length(flattenedNodes{nodeIndex}.streams);        
        
        data = cell (rows, 1);        
        for i = 1: rows            
            name = flattenedNodes{nodeIndex}.streams{i}.name;
            class = flattenedNodes{nodeIndex}.streams{i}.class;
            rowName = strcat(name, ' (', class, ')');
            % additional column for the row name
            dataRow = cell (1, columns + 1);
            dataRow{1} = rowName;
            
            for j=1 : propertyStruct.counterExample.node.timeSteps
                dataRow{j+1} = num2str(flattenedNodes{nodeIndex}.streams{i}.values(j));
            end            
            data{i} = dataRow;            
        end
        
        table.data = data;        
       
        table.name = flattenedNodes{nodeIndex}.name;
        if isKey(nodeNameToBlockNameMap, table.name)
            table.name = nodeNameToBlockNameMap(flattenedNodes{nodeIndex}.name);
        end       
        
        property.tables{nodeIndex} = table;
    end
    filePath = fileparts(mfilename('fullpath'));
    html = fileread(fullfile(filePath, 'html', 'cexTemplate.html'));
    json = json_encode(property);    
    html = strrep(html, '[(property)]', json);
    htmlFile = strcat(tempname, '.html');
    fid = fopen(htmlFile, 'w');
    fprintf(fid,'%s', html);
    fclose(fid);    
    
    % check css and js files
    
    tempFolder = fileparts(tempname);
    
    if ~ exist(fullfile(tempFolder, 'jquery.dataTables.min.css'), 'file')
        copyfile(fullfile(filePath, 'html', 'css', 'jquery.dataTables.min.css'), ...
        fullfile(tempFolder, 'jquery.dataTables.min.css')); 
    end
    
    if ~ exist(fullfile(tempFolder, 'jquery.min.js'), 'file')
        copyfile(fullfile(filePath, 'html', 'js', 'jquery.min.js'), ...
        fullfile(tempFolder, 'jquery.min.js')); 
    end
    
    if ~ exist(fullfile(tempFolder, 'jquery.dataTables.min.js'), 'file')
        copyfile(fullfile(filePath, 'html', 'js', 'jquery.dataTables.min.js'), ...
        fullfile(tempFolder, 'jquery.dataTables.min.js')); 
    end
    
    url = ['file:///',htmlFile];
    web(url);
end