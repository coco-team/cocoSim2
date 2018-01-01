open_system('[(model_name)]');
blocks = find_system('[(model_name)]', 'SearchDepth',1,'BlockType','Inport');

inputs = [(inputs_matfile_name)].signals;
time = [(inputs_matfile_name)].time;

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


    delete_block(blocks(i));
    builderBlock = signalbuilder(char(blocks(i)), 'create', time, {inputs(1,i).values'},name, name,1,position,{0 0});

    portHandle = get_param(builderBlock,'PortHandles');
    portHandle = portHandle.Outport;
    
    % add new lines
    for j=1: length(destinationPorts)
        add_line('[(model_name)]', portHandle, destinationPorts(j),'autorouting','on');
    end    
end
