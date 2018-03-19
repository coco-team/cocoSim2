%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function cocoSpecKind2(lustre_file_name, mapping_file)
     
    cocosim_config;
    try
       kind2_option = evalin('base','kind2_option');
    catch
       kind2_option  = '';
    end
    try
       timeout = evalin('base','timeout');
    catch
       timeout = '60.0';
    end
       
    % Get start time
    t_start = now;

    % properties in the mapping file                        
    if exist(mapping_file, 'file') == 2

        date_value = datestr(now, 'ddmmyyyyHHMMSS');
        [file_path,file_name,extension] = fileparts(lustre_file_name);      

        kind2_out = Kind2Utils.verify(lustre_file_name, kind2_option, timeout);
        
        results_file_name = strrep(lustre_file_name,'.lus','.xml');
        fid = fopen(results_file_name, 'w');
        fprintf(fid, kind2_out);
        fclose(fid);            
        s = dir(results_file_name);


        t_end = now;
        t_compute = t_end - t_start;
        display_msg(['Total Kind2 verification time: ' datestr(t_compute, 'HH:MM:SS.FFF')], Constants.RESULT, 'Time', '');  

        % read the mapping file
        fid = fopen(mapping_file);
        raw = fread(fid, inf);                
        str = char(raw');  
        fclose(fid); 
        json = jsondecode(str);
        %convert to cell if its json is struct 
        if isstruct(json)
            json = num2cell(json);
        end

        verificationResults = {};

        if s.bytes ~= 0                
            xml_doc = xmlread(results_file_name);
            xml_analysis_elements = xml_doc.getElementsByTagName('AnalysisStart');     
            for i = 0:(xml_analysis_elements.getLength-1)
                xmlAnalysis = xml_analysis_elements.item(i);
                analysisStruct.top = char(xmlAnalysis.getAttribute('top'));
                analysisStruct.abstract = char(xmlAnalysis.getAttribute('abstract'));
                analysisStruct.concrete= char(xmlAnalysis.getAttribute('concrete'));
                analysisStruct.assumptions = char(xmlAnalysis.getAttribute('assumptions'));                    
                analysisStruct = handleAnalysis(json, xmlAnalysis, date_value, ...
                           analysisStruct);
                verificationResults.analysisResults{i+1} = analysisStruct;
            end

            %store the verification results in the model workspace
            [verificationResults, compositionalMap] = saveVerificationResults(verificationResults);
            displayVerificationResults(verificationResults, compositionalMap);
        end                        
    end    
    
    %% for modular execution
end

function [verificationResults, compositionalMap] = saveVerificationResults(verificationResults)
    
    modelWorkspace = get_param(gcs,'ModelWorkspace');    
    
    %get blocks names from nodes names
    %ToDo: refactor this process with the Java translator
    blockSet = find_system(gcs,'LookUnderMasks', 'on');
    nameSet = cell(length(blockSet), 1);
    for i = 1 : length(blockSet)
        nameSet{i} = Utils.name_format(blockSet{i});
        nameSet{i} = strrep(nameSet{i}, '/','_');
    end   
    nodeNameToBlockNameMap = containers.Map(nameSet, blockSet);
    %store the mapping in the model workspace
    assignin(modelWorkspace,'nodeNameToBlockNameMap',nodeNameToBlockNameMap);    
    
    %replace the nodes names with blocks names
    for i = 1: length(verificationResults.analysisResults)        
        % replace the analysis name (top) with the corresponding block path
        if isKey(nodeNameToBlockNameMap, verificationResults.analysisResults{i}.top)
            verificationResults.analysisResults{i}.top = ...
                nodeNameToBlockNameMap(verificationResults.analysisResults{i}.top);
        else
            % handle the case of one mode active
            if contains(verificationResults.analysisResults{i}.top, '_one_mode_active')
               verificationResults.analysisResults{i}.top = ...
               strrep( verificationResults.analysisResults{i}.top, '_one_mode_active', '');
               verificationResults.analysisResults{i}.top = ...
                nodeNameToBlockNameMap(verificationResults.analysisResults{i}.top);
               verificationResults.analysisResults{i}.top = ...
                strcat(verificationResults.analysisResults{i}.top, ' (one mode active)' );
            end            
        end
        if ~ isempty(verificationResults.analysisResults{i}.abstract)
            % replace the abstract name with the corresponding block name        
            abstract = strsplit(verificationResults.analysisResults{i}.abstract,',');
            abstract = cellfun(@(x) nodeNameToBlockNameMap(x), abstract,'UniformOutput', 0);
            for j = 1: length(abstract)
                [~, nodeName] = fileparts(abstract{j});
                abstract{j} = ['Abstract ' nodeName];
            end
            verificationResults.analysisResults{i}.abstract = strjoin(abstract,', ');
        end
    end
    
     % extract the top field from each analysis result      
    analysisNames = cellfun(@(x) x.top, verificationResults.analysisResults,'UniformOutput', 0);
    % group the analysis results by top field
    groups = findgroups(analysisNames);    
    % get the name of each group
    distinctAnalysisNames = splitapply(@(x) x(1),analysisNames,groups); 

    % get the options for compositional analysis    
    compositionalOptions = cell(1, length(distinctAnalysisNames));    
    for i = 1: length(verificationResults.analysisResults)        
        index = find(strcmp(distinctAnalysisNames,verificationResults.analysisResults{i}.top));
        optionIndex = length(compositionalOptions{index}) + 1;
        compositionalOptions{index}{optionIndex} = verificationResults.analysisResults{i}.abstract;        
    end    

    % by default, display the last analysis for each group
    selectedOptions = cellfun(@(x) length(x), compositionalOptions);

    %map options and selected options with each distinct name
    compositionalMap.analysisNames = distinctAnalysisNames;
    compositionalMap.compositionalOptions = compositionalOptions;
    compositionalMap.selectedOptions = selectedOptions;
       
    %store the options in the model workspace
    modelWorkspace = get_param(bdroot(gcs),'ModelWorkspace');
    assignin(modelWorkspace,'compositionalMap',compositionalMap);      
    
    %aggregate valid properties in compositional analysis
    %ToDo: remove this if kind2 verifier returns all properties in each 
    %analysis
    for i = 1 : length(compositionalMap.analysisNames)
        % only nodes with multiple analysis results
        if length(compositionalMap.compositionalOptions) > 1
            aggregatedProperties = {};
            for j = 1: length(verificationResults.analysisResults)
                analysisResult = verificationResults.analysisResults{j};
                aggregatedLength = length(aggregatedProperties);
                
                if strcmp(analysisResult.top, ...
                        compositionalMap.analysisNames{i})
                    %add valid properties to aggregatedProperties
                    for propertyIndex = 1 : length(analysisResult.properties)
                        if strcmp('SAFE', analysisResult.properties{propertyIndex}.answer)
                            % In kind2  new valid properties are always
                            % missing from aggregated properties
                            aggregatedProperties = cat(2, aggregatedProperties, ...
                                analysisResult.properties{propertyIndex});
                        end
                    end   
                    %add valid properties so far to the analysis results
                    verificationResults.analysisResults{j}.properties = ...
                        cat (2, verificationResults.analysisResults{j}.properties, ...
                        aggregatedProperties(1:aggregatedLength));
                    
                end                
            end
        end
    end
    
    %get the sample time
    verificationResults.sampleTime = Utils.get_BlockDiagram_SampleTime(bdroot(gcs));
    
    %store the verification results in the model workspace
    assignin(modelWorkspace,'verificationResults',verificationResults);    
    
end


function [analysisStruct] = handleAnalysis(json, xml_analysis_start, date_value, ...
                               analysisStruct)
    xml_element = xml_analysis_start;
    analysisStruct.properties ={};
    contractColor = 'green';
    index = 0;
    %ToDo: make sure the loop terminates when there are parsing errors
    while ~strcmp(xml_element.getNodeName,'AnalysisStop')
        
        xml_element = xml_element.getNextSibling;
        if strcmp(xml_element.getNodeName,'Property')            
            propertyStruct = {};
            index = index + 1;
            % get the property name
            propertyStruct.propertyName = char(xml_element.getAttribute('name'));
            %ToDo: fix the naming difference between kind2 xml file and
            %translator mapping file for compositional assume blocks
            if contains (propertyStruct.propertyName,'.assume')
                propertyStruct.propertyName 
                %ToDo delete this line
                index = index - 1;
                continue
            end
            propertyStruct.answer = xml_element.getElementsByTagName('Answer').item(0).getTextContent;
            if strcmp(propertyStruct.answer, 'valid')  
                propertyStruct.answer = 'SAFE';
            elseif strcmp(propertyStruct.answer, 'falsifiable')
                propertyStruct.answer = 'CEX';
            else
                propertyStruct.answer = 'UNKNOWN';
            end

            msg = [' result for property node [' propertyStruct.propertyName ']: ' propertyStruct.answer];
            display_msg(msg, Constants.RESULT, 'Property checking', '');

            % get the json mapping
            jsonName = regexprep(propertyStruct.propertyName,'\[l\S*?\]',''); 
            originPath = '';
            if contains(jsonName,  '._one_mode_active')
                % get the validator block
                for i = 1 : length(json)
                    if isfield(json{i,1},'ContractName')
                        path = json{i,1}.OriginPath;
                        contractPath = fileparts(path);
                        originPath = strcat(contractPath, '/validator');
                        propertyStruct.originPath = originPath;

                        if strcmp(propertyStruct.answer, 'CEX')
                            set_param(originPath, 'BackgroundColor', 'red');
                            contractColor = 'red';
                            oneModeActiveAnnotation = strcat(contractPath, '/contract has non-exhaustive modes');                                    
                            note = Simulink.Annotation(oneModeActiveAnnotation);
                            validatorPosition = get_param(originPath, 'Position');
                            validatorPosition(2) = validatorPosition(2) + 20;                                    
                            note.position = [validatorPosition(1) validatorPosition(4) + 20]; 
                            note.ForegroundColor = 'red';
                            % set the color of the contract
                            set_param(contractPath, 'BackgroundColor', 'red');     

                            % display the counter example box                                              
                            counterExampleElement = xml_element.getElementsByTagName('CounterExample');                        
                            if counterExampleElement.getLength > 0                                
                                propertyStruct.counterExample = parseCounterExample(counterExampleElement.item(0));
                                
                                analysisStruct.properties{index} = propertyStruct;
                            else
                                msg = [solver ': FAILURE to get counter example: '];
                                msg = [msg property_name '\n'];
                                display_msg(msg, Constants.WARNING, 'Property Checking', '');
                            end                                                            
                        end
                        % one mode active analysis uses the same node name
                        % (top value) as compositional analyses. To
                        % distinguish between the 2 cases, rename the top
                        analysisStruct.top = strcat(analysisStruct.top, '_one_mode_active');
                        analysisStruct.properties{index} = propertyStruct;                        
                        break;
                    end
                end
                % check other properties
                continue;
            end
            for i = 1 : length(json)        
                if isfield(json{i}, 'PropertyName')
                    if isfield(json{i,1},'ContractName')
                        propertyJsonName = json{i,1}.ContractName;
                        if  strcmp(json{i,1}.PropertyName, 'guarantee')
                            propertyJsonName = strcat(propertyJsonName, '.guarantee');
                        end
                        if strcmp(json{i,1}.PropertyName, 'ensure')
                            propertyJsonName = strcat(propertyJsonName,'.', json{i,1}.ModeName ,'.ensure');
                        end
                        if strcmp(json{i,1}.PropertyName, 'assume')
                            propertyJsonName = strcat(propertyJsonName, '.assume');
                        end
                        if isfield(json{i,1},'Index')
                            propertyJsonName = strcat(propertyJsonName,'[', json{i,1}.Index ,']');
                        end
                    else
                        propertyJsonName = json{i,1}.PropertyName;
                    end
                    %ToDo: check the condition and removing colors
                    %if strcmp(propertyJsonName, jsonName)                           
                    if contains(jsonName, propertyJsonName)   

                        propertyStruct.originPath = json{i,1}.OriginPath;                            

                        if strcmp(propertyStruct.answer, 'SAFE')
                            set_param(propertyStruct.originPath, 'BackgroundColor', 'green');
                            set_param(propertyStruct.originPath, 'ForegroundColor', 'green');                                
                        elseif strcmp(propertyStruct.answer, 'TIMEOUT')
                            set_param(propertyStruct.originPath, 'BackgroundColor', 'gray');
                            set_param(propertyStruct.originPath, 'ForegroundColor', 'gray');
                            % set the color of the contract
                            if isfield(json{i,1},'ContractName') && strcmp(contractColor, 'green')
                                contractColor = 'yellow';
                            end
                        elseif strcmp(propertyStruct.answer, 'UNKNOWN')
                            set_param(propertyStruct.originPath, 'BackgroundColor', 'yellow');
                            set_param(propertyStruct.originPath, 'ForegroundColor', 'yellow');
                             % set the color of the contract
                            if isfield(json{i,1},'ContractName') && strcmp(contractColor, 'green')
                                contractColor = 'yellow';
                            end
                        elseif strcmp(propertyStruct.answer, 'CEX')
                            set_param(propertyStruct.originPath, 'BackgroundColor', 'red');
                            set_param(propertyStruct.originPath, 'ForegroundColor', 'red');   

                             % set the color of the contract
                            if isfield(json{i,1},'ContractName')
                                contractColor = 'red';                                                            
                            end

                            % get the counter example                                        
                            counterExampleElement = xml_element.getElementsByTagName('CounterExample');                        
                            if counterExampleElement.getLength > 0                            
                                propertyStruct.counterExample = parseCounterExample(counterExampleElement.item(0));                    
                            else
                                msg = [solver ': FAILURE to get counter example: '];
                                msg = [msg property_name '\n'];
                                display_msg(msg, Constants.WARNING, 'Property Checking', '');
                            end

                        end
                        analysisStruct.properties{index} = propertyStruct;
                        if isfield(json{i,1},'ContractName')                            
                                contractBlock = fileparts(json{i,1}.OriginPath);
                                set_param(contractBlock, 'BackgroundColor', contractColor);
                                ancestorBlock = fileparts(contractBlock);
                                while contains(ancestorBlock, '/')
                                    ancestorBlockColor = get_param(ancestorBlock, 'BackgroundColor');
                                    if strcmp(ancestorBlockColor, 'white') || ...
                                            (strcmp(ancestorBlockColor, 'green') && strcmp(ancestorBlockColor, 'yellow')) || ...
                                            strcmp(contractColor, 'red')
                                    set_param(ancestorBlock, 'BackgroundColor', contractColor);
                                    end
                                    ancestorBlock = fileparts(ancestorBlock);
                                end
                        end                    
                    end
                end
            end
        end
    end
end

function [counterExampleStruct] = parseCounterExample(counterExampleElement)
    counterExampleStruct = {};    
    nodeElement = counterExampleElement.getElementsByTagName('Node').item(0); 
    counterExampleStruct.node = parseCounterExampleNode(nodeElement);        
end

function [nodeStruct] = parseCounterExampleNode(nodeElement)
    nodeStruct = {};
    nodeStruct.name = char(nodeElement.getAttribute('name'));  
    children = nodeElement.getChildNodes;        
    streamIndex = 0;
    nodeIndex = 0;
    
    for childIndex = 0 : (children.getLength - 1)
    
        xmlElement = children.item(childIndex);
        
        if strcmp(xmlElement.getNodeName,'Stream')                                              
            streamStruct = {};                     
            streamStruct.name = char(xmlElement.getAttribute('name'));
            streamStruct.type = char(xmlElement.getAttribute('type'));
            streamStruct.class = char(xmlElement.getAttribute('class'));             
            valueElements = xmlElement.getElementsByTagName('Value');
            streamStruct.values = [];
            nodeStruct.timeSteps = valueElements.getLength;
            for valueIndex=0:(valueElements.getLength-1)
                value = char(valueElements.item(valueIndex).getTextContent);
                if strcmp(value, 'false')
                    streamStruct.values(valueIndex + 1) = false;
                elseif strcmp(value, 'true')
                    streamStruct.values(valueIndex + 1) = true;
                else
                    streamStruct.values(valueIndex + 1) = str2num(value);
                end
            end
            streamIndex = streamIndex + 1;
            nodeStruct.streams{streamIndex} = streamStruct;    
        elseif strcmp(xmlElement.getNodeName,'Node')   
            % for parsing nested nodes and their streams inside
            % the counter example            
            nestedNodeStruct = parseCounterExampleNode(xmlElement);
            nodeIndex = nodeIndex + 1;
            nodeStruct.nodes{nodeIndex} = nestedNodeStruct;   
        end            
    end        
end 
