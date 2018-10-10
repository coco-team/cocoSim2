%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2018  The university of Iowa
% Author: Mudathir Mahgoub
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function generateModelWithSignalBuilders(resultIndex, propertyIndex, level)
try
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
    
    timeStep = 0;
    for i= 1 : length(time)
        time(i) = timeStep;
        timeStep = timeStep + verificationResults.sampleTime;
    end
    
    close_system(modelName, 0);
    generatedModel = new_system(modelName);
    
    configSet = getActiveConfigSet(generatedModel);
    set_param(configSet, 'Solver', 'FixedStepDiscrete');
    set_param(configSet, 'FixedStep', '1');
    
    
    %copy at the level of the parent of the contract
    pathParts = strsplit(propertyStruct.originPath,'/');
    % the parent of the contract is 2 levels above the property (level = 2)
    % whereas the contract is 1 level above the property (level = 1)
    copyPath = strjoin(pathParts(1 :end - level), '/');
    
    %ToDo: fix for the observer
    if isempty(copyPath)
        copyPath = pathParts{1};
    end
    
    open_system(generatedModel);
    if contains(copyPath, '/')
        % subsystem
        Simulink.SubSystem.copyContentsToBlockDiagram(copyPath, generatedModel);
    else
        % it would be better if there is a way to copy contents direclty
        % from block diagram to block diagram
        tempModelName  = strcat(modelName(1:end - 4), 'temp');
        close_system(tempModelName, 0);
        tempModel = new_system(tempModelName);
        open_system(tempModel);
        subsystemName = strcat(tempModelName, '/tempSubsystem');
        add_block('built-in/Subsystem', subsystemName);
        %copyContentsToSubsystem is not supported in 2015b
        %Simulink.BlockDiagram.copyContentsToSubsystem(copyPath, subsystemName);
        bdObj = get_param(copyPath,'object');
        ssH = get_param(subsystemName, 'handle');
        bdObj.copyContentsToSS(ssH);
        Simulink.SubSystem.copyContentsToBlockDiagram(subsystemName, generatedModel);
        close_system(tempModelName, 0);
    end
    
    
    % signal builder requires time to be a vector
    if length(time) == 1
        time = [0 verificationResults.sampleTime];
        % increase the dimensionality of the values by repeating the last
        % value
        for i = 1: length(node.streams)
            node.streams{i}.values = cat(2,node.streams{i}.values,node.streams{i}.values);
        end
    end
    
    % get available inport blocks
    inportBlocks = find_system(modelName, 'SearchDepth', '1', 'BlockType','Inport');
    
    newInportPosition = [];
    
    for i = 1 : length(node.streams)
        
        if strcmp('input', node.streams{i}.class) || ... % outside the contract
                (strcmp('output', node.streams{i}.class) && level == 1) % inside the contract
            %ToDo review the cases where stream name has special symbols
            blockName = strcat(modelName, '/', node.streams{i}.name);
            % check there is an inport block for the blockName
            isPresent = any(ismember(inportBlocks, blockName));
            
            if ~ isPresent
                %handle this case by creating an inport and connecting it
                %to the target subsystem and its contract
                [~, subsystemName] = fileparts(verificationResults.analysisResults{resultIndex}.top);
                targetSubsystem = strcat(modelName, '/', subsystemName );
                portHandles = get_param(targetSubsystem, 'PortHandles');
                subsystemInports = portHandles.Inport;
                subsystemInport = strcat(modelName, '/', subsystemName, '/', node.streams{i}.name);
                portIndex = str2num(get_param(subsystemInport, 'Port'));
                subsystemLine = get_param(subsystemInports(portIndex), 'Line');
                subsystemLineSource = get_param(subsystemLine, 'SrcPortHandle');
                
                subsystemLine = get_param(subsystemLineSource, 'Line');
                destinationPorts = get_param(subsystemLine, 'DstPortHandle');
                delete_line(subsystemLine);
                
                newInportBlock = add_block('built-in/Inport', blockName,'MakeNameUnique','on');
                if ~ isempty(newInportPosition)
                    newInportPosition(2) = newInportPosition(2) - 75;
                    newInportPosition(4) = newInportPosition(4) - 75;
                    set_param(newInportBlock, 'Position',newInportPosition);
                end
                newInportPosition = get_param(newInportBlock, 'Position');
                newPortHandles = get_param(newInportBlock, 'PortHandles');
                
                for j = 1 : length(destinationPorts)
                    add_line(modelName, newPortHandles.Outport,destinationPorts(j), 'autorouting','on');
                end
            end
            
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
                signalBuilderBlock = signalbuilder(char(blockName), 'create', time, {node.streams{i}.values'},name, name,1,position);
                signalBuilderPorts = get_param(signalBuilderBlock,'PortHandles');
                add_line(generatedModel, signalBuilderPorts.Outport, portHandle.Inport,'autorouting','on');
            else
                signalBuilderBlock = signalbuilder(char(blockName), 'create', time, {node.streams{i}.values'},name, name,1,position);
                portHandle = get_param(signalBuilderBlock,'PortHandles');
            end
            
            portHandle = portHandle.Outport;
            
            % add new lines
            for j=1: length(destinationPorts)
                add_line(generatedModel, portHandle, destinationPorts(j),'autorouting','on');
            end
        end
    end
catch me
    errordlg('This option is not supported for this CounterExample.');
    display_msg(me.getReport(), Constants.DEBUG, 'generateModelWithSignalBuilders', '');
end
end
