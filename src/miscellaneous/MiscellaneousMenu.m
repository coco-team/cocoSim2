%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2018  The university of Iowa
% Author: Mudathir Mahgoub
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef MiscellaneousMenu
    methods(Static)
        
        function schema = replaceInportsWithSignalBuilders(callbackInfo)
        schema = sl_action_schema;
        schema.label = 'Replace inports with signal builders';
        schema.callback = @MiscellaneousMenu.replaceInportsWithSignalBuildersCallback;
        end

        function replaceInportsWithSignalBuildersCallback(callbackInfo)
            modelName = get_param(gcs, 'Name');

            blocks = find_system(gcs, 'SearchDepth',1,'BlockType','Inport');
            time = [0:10];
            values  = zeros(1, 11);

            % get the signal types of inports
            compileCommand = strcat(modelName, '([],[],[],''compile'')');
            eval (compileCommand);     
            for i = 1 : length(blocks)
                compiledPortDataTypes = get_param(blocks(i),'CompiledPortDataTypes');
                signalTypes(i) = compiledPortDataTypes{1}.Outport;  
            end        
            terminateCommand = strcat(modelName, '([],[],[],''term'')');
            eval (terminateCommand);   

            for i = 1 : length(blocks)
                portHandle = get_param(blocks(i),'PortHandles');
                portHandle = portHandle{1,1}.Outport;       
                line = get_param(portHandle,'Line');
                destinationPorts = get_param(line, 'Dstporthandle');

                % delete old lines
                for j=1: length(destinationPorts)
                    delete_line(gcs, portHandle, destinationPorts(j));        
                end

                position = get_param(blocks(i),'Position');
                position = position{1,1};

                [path name] = fileparts(char(blocks(i)));

                % remove the inport block
                delete_block(blocks(i));

                % add Data type conversion block if the signal type is not double
                if ~strcmp(signalTypes(i), 'double')
                    convertBlockName = strcat(modelName, '/', name, '_convert_to_', signalTypes(i));
                    convertBlock = add_block('Simulink/Signal Attributes/Data Type Conversion',char(convertBlockName));        
                    set_param(convertBlock, 'Position', position);
                    set_param(convertBlock, 'OutDataTypeStr', char(signalTypes(i)));
                    portHandle = get_param(convertBlock,'PortHandles');
                    x_shift = 100;
                    position = [position(1)-x_shift position(2) position(3)-x_shift position(4)];        
                    signalBuilderBlock = signalbuilder(char(blocks(i)), 'create', time, {values},name, name,1,position,{0 0});
                    signalBuilderPorts = get_param(signalBuilderBlock,'PortHandles');
                    add_line(modelName, signalBuilderPorts.Outport, portHandle.Inport,'autorouting','on');               
                else
                    signalBuilderBlock = signalbuilder(char(blocks(i)), 'create', time, {inputs(1,i).values'},name, name,1,position,{0 0});
                    portHandle = get_param(signalBuilderBlock,'PortHandles');
                end

                portHandle = portHandle.Outport;

                % add new lines
                for j=1: length(destinationPorts)
                    add_line(modelName, portHandle, destinationPorts(j),'autorouting','on');
                end    
            end
        end
    end
end
