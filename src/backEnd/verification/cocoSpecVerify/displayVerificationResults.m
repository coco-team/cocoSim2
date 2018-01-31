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
        ancestorColor = displayPropertyResult(verificationResult.properties{i},ancestorColor);
        
        % color ancestor blocks
        ancestorBlock = fileparts(verificationResult.properties{i}.originPath);            
        while contains(ancestorBlock, '/')
            currentColor = get_param(ancestorBlock, 'BackgroundColor');
            if strcmp(currentColor, 'white') || ...
                    (strcmp(currentColor, 'green') && strcmp(ancestorColor, 'yellow')) || ...
                    strcmp(ancestorColor, 'red')
            set_param(ancestorBlock, 'BackgroundColor', ancestorColor);
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

function [ancestorColor] = displayPropertyResult(propertyStruct, ancestorColor)
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
     end                        
end