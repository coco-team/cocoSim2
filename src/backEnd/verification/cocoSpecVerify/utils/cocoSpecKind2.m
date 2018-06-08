%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2018  The university of Iowa
% Author: Mudathir Mahgoub
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function cocoSpecKind2(lustre_file_name, mapping_file)
     
    cocosim_config;
    try
       kind2_option = evalin('base','kind2_option');
    catch
       kind2_option  = '';
    end    
       
    % Get start time
    t_start = now;

    % properties in the mapping file                        
    if exist(mapping_file, 'file') == 2

        kind2_out = Kind2Utils.verify(lustre_file_name, kind2_option);
        
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
        json = json_decode(str);
        %convert to cell if its json is struct 
        if isstruct(json)
            json = num2cell(json);
        end

        %build a map for properties        
        propertiesMap= containers.Map;
        jsonMap = containers.Map; 
        
        for i = 1 : length(json)        
            variableKey = '';
            if isfield(json{i}, 'NodeName')
                variableKey = json{i}.NodeName;
            else
                variableKey = json{i}.ContractName;
            end
            
            if isfield(json{i}, 'VariableName')
                variableKey = [variableKey '_' json{i}.VariableName];
            end
            jsonMap(variableKey) = json{i};
            if isfield(json{i}, 'PropertyName')                
                key = json{i}.PropertyName;    
                propertiesMap(key) = json{i};                        
            end
        end        
        
        [nodeNameToBlockNameMap] = getBlocksMapping();
        
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
                analysisStruct = handleAnalysis(propertiesMap, xmlAnalysis, ...
                    analysisStruct, nodeNameToBlockNameMap, jsonMap);
                verificationResults.analysisResults{i+1} = analysisStruct;
            end

            %store the verification results in the model workspace
            [verificationResults, compositionalMap] = saveVerificationResults(verificationResults, nodeNameToBlockNameMap);
            displayVerificationResults(verificationResults, compositionalMap);
            
            %save the model 
            if strcmp(get_param(gcs,'Dirty'),'on')
                save_system;
            end 
        end                        
    end    
    
    %% for modular execution
end

function [nodeNameToBlockNameMap] = getBlocksMapping()
    %get blocks names from nodes names
    %ToDo: refactor this process with the Java translator
    blockSet = find_system(gcs,'LookUnderMasks', 'on');
    nameSet = cell(length(blockSet), 1);
    for i = 1 : length(blockSet)
        nameSet{i} = Utils.name_format(blockSet{i});
        nameSet{i} = strrep(nameSet{i}, '/','_');
    end   
    nodeNameToBlockNameMap = containers.Map(nameSet, blockSet);    
end
function [verificationResults, compositionalMap] = saveVerificationResults(verificationResults, nodeNameToBlockNameMap)
    
    modelWorkspace = get_param(gcs,'ModelWorkspace');             
    
    
    %store the mapping in the model workspace
    assignin(modelWorkspace,'nodeNameToBlockNameMap',nodeNameToBlockNameMap);
    
    if ~ isfield(verificationResults, 'analysisResults')
       display_msg('No property found in kind2 XML output file', Constants.RESULT, '', '');   
       error('No property found in kind2 XML output file');
    end
    
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


function [analysisStruct] = handleAnalysis(propertiesMap, xml_analysis_start, ...
                               analysisStruct, nodeNameToBlockNameMap, jsonMap)
    xml_element = xml_analysis_start;
    analysisStruct.properties ={};       
    %ToDo: make sure the loop terminates when there are parsing errors
    while ~strcmp(xml_element.getNodeName,'AnalysisStop')
        
        xml_element = xml_element.getNextSibling;
        if strcmp(xml_element.getNodeName,'Property')            
            propertyStruct = {};            
            % get the property name
            propertyStruct.propertyName = char(xml_element.getAttribute('name'));
            %ToDo: fix the naming difference between kind2 xml file and
            %translator mapping file for compositional assume blocks
            if contains (propertyStruct.propertyName,'assume')
%                 propertyStruct.propertyName 
%                 %ToDo delete this line
%                 index = index - 1;
%                 continue;
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
            jsonName = regexprep(propertyStruct.propertyName,'.*\[l\S*?\]\.',''); 
            jsonName = regexprep(jsonName,'[.*\]',''); 
            originPath = '';
            if contains(jsonName,  '._one_mode_active')
                %ToDo: find the contract block direclty when the json
                %mapping file is fixed                
                contractName = strrep(jsonName, '._one_mode_active', '');                
                propertiesValues = values(propertiesMap);  
                
                for i = 1 : length(propertiesValues)
                    if isfield(propertiesValues{i},'ContractName') && ...
                            strcmp(propertiesValues{i}.ContractName, contractName)                        
                        
                        blockPath = propertiesValues{i}.OriginPath;
                        blocks = find_system(blockPath,'LookUnderMasks','on','MaskType','KindContractValidator');
                        %ToDo: remove this while when the json mapping file
                        %is fixed
                        while isempty(blocks) 
                            blockPath = fileparts(blockPath);
                            blocks = find_system(blockPath,'LookUnderMasks','on','MaskType','KindContractValidator');
                        end
                        validatorBlock = blocks{1};
                        propertyStruct.originPath = getfullname(validatorBlock);

                        contractPath = fileparts(propertyStruct.originPath);
                        
                        if strcmp(propertyStruct.answer, 'CEX')
                            set_param(validatorBlock, 'BackgroundColor', 'red');
                            contractColor = 'red';
                            oneModeActiveAnnotation = strcat(contractPath, '/contract has non-exhaustive modes');                                    
                            note = Simulink.Annotation(oneModeActiveAnnotation);
                            validatorPosition = get_param(validatorBlock, 'Position');
                            validatorPosition(2) = validatorPosition(2) + 20;                                    
                            note.position = [validatorPosition(1) validatorPosition(4) + 20]; 
                            note.ForegroundColor = 'red';
                            % set the color of the contract
                            set_param(contractPath, 'BackgroundColor', 'red');     

                            % display the counter example box                                              
                            counterExampleElement = xml_element.getElementsByTagName('CounterExample');                        
                            if counterExampleElement.getLength > 0                                
                                propertyStruct.counterExample = parseCounterExample(counterExampleElement.item(0), jsonMap);
                                
                             %   analysisStruct.properties{end + 1} = propertyStruct;
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
                        propertyStruct.propertyType = 'oneModeActive';
                        analysisStruct.properties{end + 1} = propertyStruct;                        
                        break;
                    end
                end
                % check other analyses
                continue;
            end
            
            if isKey(propertiesMap, jsonName)                
                property = propertiesMap(jsonName);
                propertyStruct.originPath = property.OriginPath;      
                
                if isfield(property, 'propertyType')
                    propertyStruct.propertyType = property.propertyType;      
                else
                    maskValues = get_param(propertyStruct.originPath,'MaskValues');
                
                    if strcmp(maskValues{1}, 'ContractAssumeBlock')
                        propertyStruct.propertyType = 'assume';
                    elseif strcmp(maskValues{1}, 'ContractGuaranteeBlock')
                        propertyStruct.propertyType = 'guarantee';
                    elseif strcmp(maskValues{1}, 'ContractEnsureBlock')
                        propertyStruct.propertyType = 'ensure';
                    else
                        propertyStruct.propertyType = 'observer';
                    end
                end
                if strcmp(propertyStruct.answer, 'CEX') 
                    % get the counter example                                        
                    counterExampleElement = xml_element.getElementsByTagName('CounterExample');                        
                    if counterExampleElement.getLength > 0                            
                        propertyStruct.counterExample = parseCounterExample(counterExampleElement.item(0), jsonMap);                    
                    else
                        msg = [solver ': FAILURE to get counter example: '];
                        msg = [msg property_name '\n'];
                        display_msg(msg, Constants.WARNING, 'Property Checking', '');
                    end
                end
                analysisStruct.properties{end + 1} = propertyStruct;
            end %end if isKey(propertiesMap, jsonName)                        
        end % end if strcmp(xml_element.getNodeName, 'Property')
    end
end

function [counterExampleStruct] = parseCounterExample(counterExampleElement, jsonMap)
    counterExampleStruct = {};    
    nodeElement = counterExampleElement.getElementsByTagName('Node').item(0); 
    counterExampleStruct.node = parseCounterExampleNode(nodeElement, jsonMap);        
end

function [nodeStruct] = parseCounterExampleNode(nodeElement, jsonMap)
    nodeStruct = {};
    nodeStruct.name = char(nodeElement.getAttribute('name'));  
    children = nodeElement.getChildNodes;        
    streamIndex = 0;
    nodeIndex = 0;
    
    for childIndex = 0 : (children.getLength - 1)
    
        xmlElement = children.item(childIndex);
        
        if strcmp(xmlElement.getNodeName,'Stream')                                              
            streamStruct = {};                     
            name = char(xmlElement.getAttribute('name'));
            name = [nodeStruct.name '_' name];
            if isKey(jsonMap, name)
                name = jsonMap(name).OriginPath;
            else
                % some variables are added by the translator which are not
                % blocks in Simulink
                continue;
            end
            [path streamStruct.name] = fileparts(name);
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
            
            nodeName = char(xmlElement.getAttribute('name'));
            
             if ~isKey(jsonMap, nodeName)                
                % some  nodes like bool_to_int are added by the
                % translator which are not blocks in Simulink
                continue;
            end
            
            nestedNodeStruct = parseCounterExampleNode(xmlElement, jsonMap);
            nodeIndex = nodeIndex + 1;
            nodeStruct.nodes{nodeIndex} = nestedNodeStruct;   
        end            
    end        
end 
