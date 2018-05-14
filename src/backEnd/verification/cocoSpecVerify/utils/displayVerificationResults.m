function displayVerificationResults(verificationResults, compositionalMap)    
    % display the verification result of each group
    initializeVerificationVisualization(verificationResults);
    for analysisIndex = 1 : length(compositionalMap.analysisNames)
        displayVerificationResult(verificationResults,compositionalMap, analysisIndex);
    end
end

function displayVerificationResult(verificationResults,compositionalMap, analysisIndex)
    
    analysisName = compositionalMap.analysisNames{analysisIndex};
    selectedOption = compositionalMap.selectedOptions(analysisIndex);
    selectedAbstract = compositionalMap.compositionalOptions{analysisIndex}{selectedOption};
    
    % find the analysis whose top = analysisName and 
    % abstrct = selectedAbstract
    resultIndex = find(cellfun(@(x) strcmp(x.abstract, selectedAbstract) && ...
        strcmp(x.top, analysisName),verificationResults.analysisResults));
    verificationResult = verificationResults.analysisResults{resultIndex};
    
    ancestorColor = 'green';
    for i = 1 : length(verificationResult.properties) 
        if isfield(verificationResult.properties{i},'propertyType')
            ancestorColor = displayAssumptionResult(verificationResult.properties{i},ancestorColor, resultIndex, i);
        else            
            ancestorColor = displayPropertyResult(verificationResult.properties{i},ancestorColor, resultIndex, i);
        end
        % color ancestor blocks
        ancestorBlock = fileparts(verificationResult.properties{i}.originPath);            
        while contains(ancestorBlock, '/')
            currentColor = get_param(ancestorBlock, 'BackgroundColor');
            if strcmp(currentColor, 'white') || ...
                    (strcmp(currentColor, 'green') && strcmp(ancestorColor, 'yellow')) || ...
                    strcmp(ancestorColor, 'red')
            set_param(ancestorBlock, 'BackgroundColor', ancestorColor);
            set_param(ancestorBlock,'HiliteAncestors',ancestorColor)
            end
            ancestorBlock = fileparts(ancestorBlock);
        end          
    end           
end


function initializeVerificationVisualization(verificationResults)
    for i = 1 : length(verificationResults.analysisResults)        
        
        % clear the colors of properties
        for j = 1 : length(verificationResults.analysisResults{i}.properties)
            propertyStruct = verificationResults.analysisResults{i}.properties{j};
            set_param(propertyStruct.originPath, 'BackgroundColor', 'white');
            set_param(propertyStruct.originPath, 'ForegroundColor', 'black');
            
            %clear mask controls for counter examples            
            modelWorkspace = get_param(bdroot(gcs),'ModelWorkspace');
            if modelWorkspace.hasVariable('maskControlsMap')
                maskControlsMap = modelWorkspace.getVariable('maskControlsMap');
                keySet = keys(maskControlsMap);
                for keyIndex = 1: length(keySet)
                    controls = maskControlsMap(keySet{keyIndex});
                    mask = Simulink.Mask.get(keySet{keyIndex}); 
                    for controlIndex = 1: length(controls)
                        mask.removeDialogControl(controls{controlIndex});
                    end
                    maskControlsMap(keySet{keyIndex}) = {};
                end
                assignin(modelWorkspace,'maskControlsMap',maskControlsMap); 
            end            
            
            % clear the colors of ancestor blocks 
            ancestorBlock = fileparts(verificationResults.analysisResults{i}.properties{j}.originPath);            
            while contains(ancestorBlock, '/')        
                set_param(ancestorBlock, 'BackgroundColor', 'white');
                set_param(propertyStruct.originPath, 'ForegroundColor', 'black');
                ancestorBlock = fileparts(ancestorBlock);
            end   

        end
    end  
end

function [ancestorColor] = displayAssumptionResult(propertyStruct, ancestorColor, resultIndex, propertyIndex)
    
    ports = get_param(propertyStruct.originPath,'PortHandles');    
    color = '';
    
    if strcmp(propertyStruct.answer, 'SAFE')
        color = 'green';        
    elseif strcmp(propertyStruct.answer, 'TIMEOUT')
        color = 'gray';        
        if strcmp(ancestorColor, 'green')
            ancestorColor = 'yellow';
        end
    elseif strcmp(propertyStruct.answer, 'UNKNOWN')
        color = 'yellow';        
        if strcmp(ancestorColor, 'green')
            ancestorColor = 'yellow';
        end
    elseif strcmp(propertyStruct.answer, 'CEX')
        color = 'red';        
        ancestorColor = 'red';
        %To: display the assumption counter example
        %addCounterExampleOptions(propertyStruct, resultIndex, propertyIndex);
     end                        
           
    for i = 1 : length(ports.Inport)
        line = get_param(ports.Inport(i),'Line');
        set_param(line,'HiliteAncestors',color);
    end    
end


function [ancestorColor] = displayPropertyResult(propertyStruct, ancestorColor, resultIndex, propertyIndex)
     if strcmp(propertyStruct.answer, 'SAFE')
        set_param(propertyStruct.originPath, 'BackgroundColor', 'green');
        set_param(propertyStruct.originPath, 'ForegroundColor', 'green');                                
    elseif strcmp(propertyStruct.answer, 'TIMEOUT')
        set_param(propertyStruct.originPath, 'BackgroundColor', 'gray');
        set_param(propertyStruct.originPath, 'ForegroundColor', 'gray');        
        if strcmp(ancestorColor, 'green')
            ancestorColor = 'yellow';
        end
    elseif strcmp(propertyStruct.answer, 'UNKNOWN')
        set_param(propertyStruct.originPath, 'BackgroundColor', 'yellow');
        set_param(propertyStruct.originPath, 'ForegroundColor', 'yellow');         
        if strcmp(ancestorColor, 'green')
            ancestorColor = 'yellow';
        end
    elseif strcmp(propertyStruct.answer, 'CEX')
        set_param(propertyStruct.originPath, 'BackgroundColor', 'red');
        set_param(propertyStruct.originPath, 'ForegroundColor', 'red');   
        ancestorColor = 'red';
        addCounterExampleOptions(propertyStruct, resultIndex, propertyIndex);
     end                        
end

function addCounterExampleOptions(propertyStruct,resultIndex, propertyIndex)

    pathParts = strsplit(mfilename('fullpath'),'/');
    path = strjoin(pathParts(1 :end - 3), '/');
    
    % display the counter example as signals    
    cexSignals = sprintf('displayCexSignals(%d, %d);', resultIndex, propertyIndex);        
    createMaskAction('Display counter example as signals', cexSignals, propertyStruct.originPath);
    
    % display the counter example as a table
    cexTable = sprintf('displayCexTables(%d, %d);', resultIndex, propertyIndex);             
    createMaskAction('Display counter example as tables', cexTable, propertyStruct.originPath);
    
    %generate an outer model with signal builders (level = 2)
    cexOuterModel = sprintf('generateModelWithSignalBuilders(%d, %d, 2);', resultIndex, propertyIndex);             
    createMaskAction('Generate an outer model for the counter example', cexOuterModel, propertyStruct.originPath);
    
    %generate an inner model with signal builders (level = 1)
    cexInnerModel = sprintf('generateModelWithSignalBuilders(%d, %d, 1);', resultIndex, propertyIndex);             
    createMaskAction('Generate an inner model for the counter example', cexInnerModel, propertyStruct.originPath);
end

function createMaskAction(title, content, originPath)
    mask = Simulink.Mask.get(originPath);    
    name = regexprep(title,'[/\s'']','_');    
    button = mask.addDialogControl('pushbutton', name);
    button.Prompt = title;
    button.Callback = content;    
    
    % store the control 
    modelWorkspace = get_param(bdroot(gcs),'ModelWorkspace');
    if modelWorkspace.hasVariable('maskControlsMap')
        maskControlsMap = modelWorkspace.getVariable('maskControlsMap');
        if isKey(maskControlsMap, originPath)
            maskControlsMap(originPath) = cat(2, maskControlsMap(originPath), {name}); 
        else
            maskControlsMap(originPath) = {name};
        end
    else
        maskControlsMap = containers.Map;
        maskControlsMap(originPath) = {name};          
    end
    assignin(modelWorkspace,'maskControlsMap',maskControlsMap);  
end