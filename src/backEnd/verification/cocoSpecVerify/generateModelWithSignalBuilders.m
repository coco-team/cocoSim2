function generateModelWithSignalBuilders(resultIndex, propertyIndex)
    %get the verification results
    modelWorkspace = get_param(bdroot(gcs),'ModelWorkspace');
    verificationResults = modelWorkspace.getVariable('verificationResults');    

    propertyStruct = verificationResults.analysisResults{resultIndex}.properties{propertyIndex};
    node = propertyStruct.counterExample.node;
    modelName = Utils.name_format(propertyStruct.originPath);
    modelName = strrep(modelName, '/','_');
    
    %maximum length for a model name is 63
    MaxLength = 63;
    if length(modelName) > MaxLength
        modelName = modelName(1:MaxLength);
    end
    
    time = zeros (1, node.timeSteps);

    for i= 1 : length(time)
        time(i) = i - 1;
    end    
    
    close_system(modelName, 0);
    generatedModel = new_system(modelName);
    
    configSet = getActiveConfigSet(generatedModel);
    set_param(configSet, 'Solver', 'FixedStepDiscrete');
    set_param(configSet, 'FixedStep', '1');
    
    
    %copy at the level of the parent of the contract    
    pathParts = strsplit(propertyStruct.originPath,'/');    
    % the parent of the contract is 2 levels above the property 
    contractParentPath = strjoin(pathParts(1 :end - 2), '/');    
    
    %ToDo: fix for the observer
    if isempty(contractParentPath)
        contractParentPath = pathParts{1};
    end
    
    open_system(generatedModel);
    if contains(contractParentPath, '/')
        % subsystem
        Simulink.SubSystem.copyContentsToBlockDiagram(contractParentPath, generatedModel);
    else
        % it would be better if there is a way to copy contents direclty
        % from block diagram to block diagram
        tempModelName  = strcat(modelName(1:end - 4), 'temp');
        close_system(tempModelName, 0);
        tempModel = new_system(tempModelName);
        open_system(tempModel);
        subsystemName = strcat(tempModelName, '/tempSubsystem');        
        add_block('built-in/Subsystem', subsystemName);
        Simulink.BlockDiagram.copyContentsToSubsystem(contractParentPath, subsystemName);
        Simulink.SubSystem.copyContentsToBlockDiagram(subsystemName, generatedModel);
        close_system(tempModelName, 0);
    end
    
    
    % signal builder requires time to be a vector
    if length(time) == 1
        time = [0 1];
        % increase the dimensionality of the values by repeating the last
        % value
        for i = 1: length(node.streams)
            node.streams{i}.values = cat(2,node.streams{i}.values,node.streams{i}.values);
        end
    end

    for i = 1 : length(node.streams)
        if strcmp('input', node.streams{i}.class)
            %ToDo review the cases where stream name has special symbols            
            blockName = strcat(modelName, '/', node.streams{i}.name);
            
            portHandle = get_param(blockName,'PortHandles');
            portHandle = portHandle.Outport;
            line = get_param(portHandle,'Line');
            destinationPorts = get_param(line, 'Dstporthandle');

            % delete old lines
            for j=1: length(destinationPorts)
                delete_line(generatedModel, portHandle, destinationPorts(j));        
            end

            position = get_param(blockName,'Position');
            
            name = node.streams{i}.name;

            signalType = 'double';
            if strcmp('bool', node.streams{i}.type)
                signalType = 'boolean';
            else
                if strcmp('int', node.streams{i}.type)
                    signalType = 'int32';
                end
            end

            % remove the inport block
            delete_block(blockName); 

            % add Data type conversion block if the signal type is not double
            if ~strcmp(signalType, 'double')
                convertBlockName = strcat(modelName,'/', name, '_convert_to_', signalType);
                convertBlock = add_block('Simulink/Signal Attributes/Data Type Conversion',convertBlockName);        
                set_param(convertBlock, 'Position', position);
                set_param(convertBlock, 'OutDataTypeStr', signalType);
                portHandle = get_param(convertBlock,'PortHandles');
                x_shift = 100;
                position = [position(1)-x_shift position(2) position(3)-x_shift position(4)];        
                signalBuilderBlock = signalbuilder(char(blockName), 'create', time, {node.streams{i}.values'},name, name,1,position,{0 0});
                signalBuilderPorts = get_param(signalBuilderBlock,'PortHandles');
                add_line(generatedModel, signalBuilderPorts.Outport, portHandle.Inport,'autorouting','on');               
            else
                signalBuilderBlock = signalbuilder(char(blockName), 'create', time, {node.streams{i}.values'},name, name,1,position,{0 0});
                portHandle = get_param(signalBuilderBlock,'PortHandles');
            end

            portHandle = portHandle.Outport;

            % add new lines
            for j=1: length(destinationPorts)
                add_line(generatedModel, portHandle, destinationPorts(j),'autorouting','on');
            end    
        end
    end
end