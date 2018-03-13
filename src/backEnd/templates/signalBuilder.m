open_system('[(model_name)]');
blocks = find_system('[(model_name)]', 'SearchDepth',1,'BlockType','Inport');

inputs = [(inputs_matfile_name)].signals;
time = [(inputs_matfile_name)].time;

% signal builder requires time to be a vector
if length(time) == 1
    time = [0 1];
    % increase the dimensionality of the values by repeating the values
    for i = 1: length(blocks)
        inputs(1,i).values = [inputs(1,i).values inputs(1,i).values];
    end
end

for i = 1 : length(blocks)
    portHandle = get_param(blocks(i),'PortHandles');
    portHandle = portHandle{1,1}.Outport;
    line = get_param(portHandle,'Line');
    destinationPorts = get_param(line, 'Dstporthandle');

    % delete old lines
    for j=1: length(destinationPorts)
        delete_line('[(model_name)]', portHandle, destinationPorts(j));        
    end

    position = get_param(blocks(i),'Position');
    position = position{1,1};

    [path name] = fileparts(char(blocks(i)));

    signalType = 'double';
    if islogical(inputs(1,i).values)
        signalType = 'boolean';
    else
        if isinteger(inputs(1,i).values)
            signalType = 'int32';
        end
    end
    
    % remove the inport block
    delete_block(blocks(i)); 
    
    % add Data type conversion block if the signal type is not double
    if ~strcmp(signalType, 'double')
        convertBlockName = strcat('[(model_name)]/', name, '_convert_to_', signalType);
        convertBlock = add_block('Simulink/Signal Attributes/Data Type Conversion',convertBlockName);        
        set_param(convertBlock, 'Position', position);
        set_param(convertBlock, 'OutDataTypeStr', signalType);
        portHandle = get_param(convertBlock,'PortHandles');
        x_shift = 100;
        position = [position(1)-x_shift position(2) position(3)-x_shift position(4)];        
        signalBuilderBlock = signalbuilder(char(blocks(i)), 'create', time, {inputs(1,i).values'},name, name,1,position,{0 0});
        signalBuilderPorts = get_param(signalBuilderBlock,'PortHandles');
        add_line('[(model_name)]', signalBuilderPorts.Outport, portHandle.Inport,'autorouting','on');               
    else
        signalBuilderBlock = signalbuilder(char(blocks(i)), 'create', time, {inputs(1,i).values'},name, name,1,position,{0 0});
        portHandle = get_param(signalBuilderBlock,'PortHandles');
    end
    
    portHandle = portHandle.Outport;
    
    % add new lines
    for j=1: length(destinationPorts)
        add_line('[(model_name)]', portHandle, destinationPorts(j),'autorouting','on');
    end    
end
