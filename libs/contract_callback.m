function contract_callback(action,block)    
    if ~exist('ContractValidatorReady','var') == 1 || ...
            evalin( 'base', 'ContractValidatorReady' )  == 0
        feval(action,block)
    end
end

function inputs_callback(block)
% get the values of the mask
values = get_param(block,'MaskValues');

index = 0;
% get the size of assume ports
assumePorts = str2num(char(values(1)));
for i= 1 : assumePorts
    index = index + 1;
    portStr(index) = {['port_label(''input'',',num2str(index),',''assume'')']};       
end

% get the size of guarantee ports
guaranteePorts = str2num(char(values(2)));
for i= 1 : guaranteePorts
    index = index + 1;
    portStr(index) = {['port_label(''input'',',num2str(index),',''guarantee'')']};    
end

% get the size of mode ports
modeBlocksPorts = str2num(char(values(3)));
for i= 1 : modeBlocksPorts
    index = index + 1;
    portStr(index) = {['port_label(''input'',',num2str(index),',''mode'')']};    
end

% output ports
% validator output port
index = index + 1;
portStr(index) = {['port_label(''output'',',num2str(1),',''valid'')']};

set_param(block,'MaskDisplay',char(portStr));


    %% add or remove blocks
    blockModel = get_param(gcb, 'Parent');     
    validatorBlock = gcb;
    ports = get_param(validatorBlock,'PortHandles');
    portConnectivity = get_param(validatorBlock, 'PortConnectivity'); 
    
    gapWidth = 30;
    gapHeight = 20;
    
    for i = 1 : length(portConnectivity)
        
        requireBlock = -1;
        ensureBlock = -1;
        
        % if the port is not connected
        if portConnectivity(i).SrcBlock == -1
            % add a new block
            if i <= assumePorts                  
               blockHandle =  add_block('Kind/assume',strcat(blockModel,'/','assume'),'MakeNameUnique','on');
            else
                if i <= assumePorts + guaranteePorts
                    blockHandle =  add_block('Kind/guarantee',strcat(blockModel,'/','guarantee'),'MakeNameUnique','on');
                else 
                    blockHandle =  add_block('Kind/mode',strcat(blockModel,'/','mode'),'MakeNameUnique','on');
                    requireBlock = add_block('Kind/require',strcat(blockModel,'/','require'),'MakeNameUnique','on');
                    ensureBlock = add_block('Kind/ensure',strcat(blockModel,'/','ensure'),'MakeNameUnique','on');
                end
            end  
           % move the new block closer to its port
           position = get_param(blockHandle,'position');
           width = position(3) - position(1);
           height = position(4) - position(2);
           position(1) = portConnectivity(i).Position(1) - width - gapWidth;
           position(2) = portConnectivity(i).Position(2) - height/2;
           position(3) = portConnectivity(i).Position(1)  - gapWidth;
           position(4) = portConnectivity(i).Position(2) + height/2;                   
           set_param(blockHandle,'position',position);

           % connect the new block with its port
           blockPorts = get_param(blockHandle, 'PortConnectivity');
           [outputPortIndex , ~] = size(blockPorts);
           add_line(blockModel, [blockPorts(outputPortIndex).Position; portConnectivity(i).Position ]);            
           
           % add all assumptions to each mode port
           if i > assumePorts + guaranteePorts
               % get the mode ports
               modePorts = get_param(blockHandle, 'PortHandles');
               % connect require and ensure blocks to the mode block
               if requireBlock ~= -1
                   
                   % set the position of the require block
                   requirePosition = position;
                   requirePosition(1) = position(3) - position(1) - gapWidth;
                   requirePosition(3) = position(1) - gapWidth;                   
                   requirePosition(2) = position(2) - gapHeight;
                   requirePosition(4) = position(4) - (position(4) - position(2))/2 - gapHeight;
                   
                   set_param(requireBlock,'position',requirePosition);                  
                   
                   % get the require ports
                   requirePorts = get_param(requireBlock, 'PortHandles');
                   % connect the require port with the mode block port 1
                    add_line(blockModel, requirePorts.Outport(1) ,modePorts.Inport(1), 'autorouting','on');
               end
               
               if ensureBlock ~= -1
                   
                   % set the position of the ensure block
                    ensurePosition = position;
                    ensurePosition(1) = position(3) - position(1) - gapWidth;
                    ensurePosition(3) = position(1) - gapWidth;
                    ensurePosition(2) = position(2) + gapHeight;
                    ensurePosition(4) = position(4) - (position(4) - position(2))/2 + gapHeight;
                    set_param(ensureBlock,'position',ensurePosition);
                   
                   % get the ensure ports
                   ensurePorts = get_param(ensureBlock, 'PortHandles');
                   % connect the ensure port with the mode block port 2
                    add_line(blockModel, ensurePorts.Outport(1) ,modePorts.Inport(2), 'autorouting','on');
               end
               
                %check if the mode assume port is already connected
                %portLine = get_param(modePorts.Inport(1),'Line'); 
                %if portLine == -1   
                    % connect the assumption port with the mode block
                 %   add_line(blockModel, ports.Outport(1) ,modePorts.Inport(1), 'autorouting','on');
                %end
               %register a callback function when the mode inport
               %connectivity changes
               %set_param(ports.Inport(i), 'ConnectionCallback', 'checkModePort');               
           end
        end
    end
    
    %% connect input blocks with assume, guarantee, requires and ensure
    % blocks
    
    blockPaths = find_system(blockModel,'SearchDepth',1, 'LookUnderMasks', 'all','Type','Block');
    blockTypes = get_param(blockPaths,'BlockType');
    portConnectivity = get_param(validatorBlock, 'PortConnectivity');  
    for i = 1:length(blockTypes)
        if strcmp(blockTypes(i),'Inport') 
            
            %get the name of the inport block
            inportBlockName = get_param(blockPaths(i), 'Name');
            
            % get the inport outport
            input = get_param(blockPaths(i), 'PortHandles');
            inputLine = get_param(input{1,1}.Outport,'Line');
            
            destinationBlockHandles = [];
            if inputLine ~= -1
                destinationBlockHandles = get_param(inputLine, 'DstBlockHandle');
            end
            
            for j = 1 : (assumePorts + guaranteePorts)
                % if the line is not connected to the block
                if ~ismember(portConnectivity(j).SrcBlock, destinationBlockHandles) 
                    
                    % disable the library links for the target block
                    % for the first time, the SrcBlock is -1, invalid.
                    set_param(portConnectivity(j).SrcBlock, 'LinkStatus', 'inactive');
                    
                    % get the target block name
                    targetBlockName = get_param(portConnectivity(j).SrcBlock, 'Name');
                    % add new port inside that block
                    add_block('built-in/Inport', ...
                                    strcat(blockModel,'/',targetBlockName,'/','input'),'MakeNameUnique','on');
                    
                    targetBlockPorts = get_param(portConnectivity(j).SrcBlock, 'PortHandles');
                    %connect the inport with the block            
                    add_line(blockModel, input{1,1}.Outport ,targetBlockPorts.Inport(length(targetBlockPorts.Inport)), 'autorouting','on');
                end
            end
            
            for j = (assumePorts + guaranteePorts +1) : (assumePorts + guaranteePorts+ modeBlocksPorts)
                
                % get the mode ports
                modePorts = get_param(portConnectivity(j).SrcBlock, 'PortHandles');
                
                % get the block of the require port
                requireLine = get_param(modePorts.Inport(1), 'Line');
                requireBlockHandle = get_param(requireLine, 'SrcBlockHandle');
                 if ~ismember(requireBlockHandle, destinationBlockHandles) 
               
                    % disable the library links for the target block
                    % for the first time, the SrcBlock is -1, invalid.
                    set_param(portConnectivity(j).SrcBlock, 'LinkStatus', 'inactive');
                    modePorts =  get_param(portConnectivity(j).SrcBlock, 'PortHandles');
                     
                     
                    % disable the library links for the target block
                    % for the first time, the SrcBlock is -1, invalid.
                    set_param(requireBlockHandle, 'LinkStatus', 'inactive');
                    
                    % get the target block name
                    targetBlockName = get_param(requireBlockHandle, 'Name');
                    % add new port inside that block
                    add_block('built-in/Inport', ...
                                    strcat(blockModel,'/',targetBlockName,'/','input'),'MakeNameUnique','on');
                    
                    targetBlockPorts = get_param(requireBlockHandle, 'PortHandles');
                    %connect the inport with the block            
                    add_line(blockModel, input{1,1}.Outport ,targetBlockPorts.Inport(length(targetBlockPorts.Inport)), 'autorouting','on');
                 end            
                
                 % get the block of the ensure port
                ensureLine = get_param(modePorts.Inport(2), 'Line');
                ensureBlockHandle = get_param(ensureLine, 'SrcBlockHandle');
                 if ~ismember(ensureBlockHandle, destinationBlockHandles) 
                    
                    % disable the library links for the target block
                    % for the first time, the SrcBlock is -1, invalid.
                    set_param(ensureBlockHandle, 'LinkStatus', 'inactive');
                    
                    % get the target block name
                    targetBlockName = get_param(ensureBlockHandle, 'Name');
                    % add new port inside that block
                    add_block('built-in/Inport', ...
                                    strcat(blockModel,'/',targetBlockName,'/','input'),'MakeNameUnique','on');
                    
                    targetBlockPorts = get_param(ensureBlockHandle, 'PortHandles');
                    %connect the inport with the block            
                    add_line(blockModel, input{1,1}.Outport ,targetBlockPorts.Inport(length(targetBlockPorts.Inport)), 'autorouting','on');
                 end      
                 
            end
        end
    end
end

