function contract_callback(action,block)
if evalin( 'base', '~exist(''ContractValidatorReady'',''var'')' ) == 1 || ...
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

%prepare for adding new blocks and lines
blockModel = get_param(gcb, 'Parent');
validatorBlock = gcb;
ports = get_param(validatorBlock,'PortHandles');
portConnectivity = get_param(validatorBlock, 'PortConnectivity');
ContractValidatorBlock = evalin( 'base', 'ContractValidatorBlock');
if ContractValidatorBlock.assumePorts + ...
        ContractValidatorBlock.guaranteePorts + ...
        ContractValidatorBlock.modeBlocksPorts ~= ...
        assumePorts + guaranteePorts + modeBlocksPorts
    
        % remove all lines
        for i = 1: length(ports.Inport)
            if portConnectivity(i).SrcBlock ~= -1
                sourcePort = get_param(portConnectivity(i).SrcBlock,'PortHandles');
                delete_line(blockModel, sourcePort.Outport(1) ,ports.Inport(i));
            end
        end
end

set_param(block,'MaskDisplay',char(portStr));

ports = get_param(validatorBlock,'PortHandles');
portConnectivity = get_param(validatorBlock, 'PortConnectivity');


%% restore old connections
% check if the number of ports has changed
% ContractValidatorBlock is set in callback LoadFcn of the validator block


if ContractValidatorBlock.assumePorts + ...
        ContractValidatorBlock.guaranteePorts + ...
        ContractValidatorBlock.modeBlocksPorts ~= ...
        assumePorts + guaranteePorts + modeBlocksPorts
    
        % remove all lines
        %for i = 1: length(ports.Inport)
        %    if portConnectivity(i).SrcBlock ~= -1
        %        sourcePort = get_param(portConnectivity(i).SrcBlock,'PortHandles');
        %        delete_line(blockModel, sourcePort.Outport(1) ,ports.Inport(i));
         %   end
        %end
    
    % connect assume lines
    for i = 1: min(ContractValidatorBlock.assumePorts, assumePorts)
        if ContractValidatorBlock.portConnectivity(i).SrcBlock ~= -1
            try
                sourcePort = get_param(ContractValidatorBlock.portConnectivity(i).SrcBlock,'PortHandles');
                add_line(blockModel, sourcePort.Outport(1) ,ports.Inport(i));
            catch
            end
        end
    end
    
    % connect guarantee lines
    for i = 1: min(ContractValidatorBlock.guaranteePorts, guaranteePorts)
        if ContractValidatorBlock.portConnectivity(i + ContractValidatorBlock.assumePorts).SrcBlock ~= -1
            try
                sourcePort = get_param(ContractValidatorBlock.portConnectivity(i + ContractValidatorBlock.assumePorts).SrcBlock,'PortHandles');
                add_line(blockModel, sourcePort.Outport(1) ,ports.Inport(i+assumePorts));
            catch
            end
        end
    end
    
    % connect mode lines
    for i = 1: min(ContractValidatorBlock.modeBlocksPorts, modeBlocksPorts)
        if ContractValidatorBlock.portConnectivity(i + ...
                ContractValidatorBlock.assumePorts + ContractValidatorBlock.guaranteePorts).SrcBlock ~= -1
            try
                sourcePort = get_param(ContractValidatorBlock.portConnectivity(i + ...
                    ContractValidatorBlock.assumePorts + ContractValidatorBlock.guaranteePorts).SrcBlock,'PortHandles');
                add_line(blockModel, sourcePort.Outport(1) ,ports.Inport(i+assumePorts + guaranteePorts));
            catch
            end
        end
    end   
     
end


validatorBlock = gcb;
ports = get_param(validatorBlock,'PortHandles');
portConnectivity = get_param(validatorBlock, 'PortConnectivity');

%% add blocks
gapWidth = 30;
gapHeight = 20;

createRequireEnsureCheckbox = char(values(6));
requireEnsureCheckbox = strcmp(createRequireEnsureCheckbox, 'on');

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
                if requireEnsureCheckbox == 1
                    requireBlock = add_block('Kind/require',strcat(blockModel,'/','require'),'MakeNameUnique','on');
                    ensureBlock = add_block('Kind/ensure',strcat(blockModel,'/','ensure'),'MakeNameUnique','on');
                end
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
        
        % mode ports
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

%update ContractValidatorBlock

portConnectivity = get_param(validatorBlock, 'PortConnectivity');
evalin('base',strcat('ContractValidatorBlock.assumePorts = ', char(values(1))));    
evalin('base',strcat('ContractValidatorBlock.guaranteePorts = ', char(values(2))));
evalin('base',strcat('ContractValidatorBlock.modeBlocksPorts = ', char(values(3))));
expression = {'ContractValidatorBlock.portConnectivity'};
assignin('base','temp', portConnectivity');
cellfun(@(lhs) evalin('base', [lhs '=temp']), expression);   

% get the value of createInportsCheckbox
createInportsValue = char(values(5));
if strcmp(createInportsValue, 'on')
    createInports(blockModel, validatorBlock, assumePorts, ...
        guaranteePorts, modeBlocksPorts, requireEnsureCheckbox);
end
end

function createInports(blockModel, validatorBlock, assumePorts,...
    guaranteePorts, modeBlocksPorts, requireEnsureCheckbox)
    %% connect input blocks with assume, guarantee, requires and ensure blocks

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

                    destinationPath = strcat(blockModel,'/',targetBlockName,'/',inportBlockName);
                    % add new port inside that block
                    add_block('built-in/Inport', char(destinationPath),'MakeNameUnique','on');

                    targetBlockPorts = get_param(portConnectivity(j).SrcBlock, 'PortHandles');
                    %connect the inport with the block
                    add_line(blockModel, input{1,1}.Outport ,targetBlockPorts.Inport(length(targetBlockPorts.Inport)), 'autorouting','on');
                end
            end

            if requireEnsureCheckbox == 1
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

                        destinationPath = strcat(blockModel,'/',targetBlockName,'/',inportBlockName);
                        % add new port inside that block
                        add_block('built-in/Inport', char(destinationPath),'MakeNameUnique','on');

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
                        destinationPath = strcat(blockModel,'/',targetBlockName,'/',inportBlockName);
                        % add new port inside that block
                        add_block('built-in/Inport', char(destinationPath),'MakeNameUnique','on');

                        targetBlockPorts = get_param(ensureBlockHandle, 'PortHandles');
                        %connect the inport with the block
                        add_line(blockModel, input{1,1}.Outport ,targetBlockPorts.Inport(length(targetBlockPorts.Inport)), 'autorouting','on');
                    end

                end
            end
        end
    end
end

