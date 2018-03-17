classdef PreContextMenu
    methods(Static)
        function schemaFcns = preContextMenu
            schemaFcns = {@PreContextMenu.cocoSimActions};
        end

        function schema = cocoSimActions(callbackInfo)
            schema = sl_container_schema;
            schema.label = 'CoCoSim';
            schema.statustip = 'CoCoSim';
            schema.autoDisableWhen = 'Busy';

            modelWorkspace = get_param(callbackInfo.studio.App.blockDiagramHandle,'modelworkspace');   
            if modelWorkspace.hasVariable('compositionalMap')
                schema.childrenFcns = {@PreContextMenu.compositionalOptions,...
                    @PreContextMenu.signalBuilders};
            else
                schema.childrenFcns = {@PreContextMenu.signalBuilders};
            end
        end

        function schema = compositionalOptions(callbackInfo)
            schema = sl_container_schema;
            schema.label = 'Compositional Abstract';
            schema.statustip = 'Compositional Abstract';
            schema.autoDisableWhen = 'Busy';
            % get the compositional options from the model workspace
            modelWorkspace = get_param(callbackInfo.studio.App.blockDiagramHandle,'modelworkspace');   
            compositionalMap = modelWorkspace.getVariable('compositionalMap');    

            % add a menu item for each option
            index = 1;
            for i = 1: length(compositionalMap.analysisNames)        
                schema.childrenFcns{index} = {@compositionalKey, compositionalMap.analysisNames{i}};
                index = index + 1;
                for j=1: length(compositionalMap.compositionalOptions{i})
                    data.label = compositionalMap.compositionalOptions{i}{j};
                    data.selectedOption = compositionalMap.selectedOptions(i);
                    data.currentOption = j;
                    data.currentAnalysis = i;
                    schema.childrenFcns{index} = {@PreContextMenu.compositionalOption, data};
                    index = index + 1;
                end
                schema.childrenFcns{index} = 'separator';
                index = index + 1;
            end    
        end

        function schema = compositionalKey(callbackInfo)
            schema = sl_action_schema;
            label = callbackInfo.userdata;    
            schema.label = label;      
            schema.state = 'Disabled';    
        end

        function schema = compositionalOption(callbackInfo)
            schema = sl_toggle_schema;
            data = callbackInfo.userdata;    
            if length(data.label) == 0
                schema.label = 'No abstract';
            else
                schema.label = data.label;
            end          
            if data.selectedOption == data.currentOption
                schema.checked = 'checked';    
            else
                schema.checked = 'unchecked';    
            end

            schema.callback = @PreContextMenu.compositionalOptionCallback;
            schema.userdata = data;

        end

        function compositionalOptionCallback(callbackInfo)    
            data = callbackInfo.userdata;    
            modelWorkspace = get_param(callbackInfo.studio.App.blockDiagramHandle,'modelworkspace');   
            verificationResults = modelWorkspace.getVariable('verificationResults');
            compositionalMap = modelWorkspace.getVariable('compositionalMap');    
            compositionalMap.selectedOptions(data.currentAnalysis) = data.currentOption; 
            assignin(modelWorkspace,'compositionalMap',compositionalMap);
            displayVerificationResults(verificationResults, compositionalMap);
        end

        function schema = signalBuilders(callbackInfo)
        schema = sl_action_schema;
        schema.label = 'Replace inports with signal builders';
        schema.callback = @PreContextMenu.replaceInportsWithSignalBuilders;
        end

        function replaceInportsWithSignalBuilders(callbackInfo)
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
