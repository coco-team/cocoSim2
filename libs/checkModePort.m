function checkModePort(modePortHandle)
 %get the signal line associated with the port
 line = get_param(modePortHandle,'Line'); 

 if line ~= -1
     %get the source block handle of the line
     sourceBlock= get_param(line,'SrcBlockHandle');

     %get the destination block handle of the line
     destinationBlock= get_param(line,'DstBlockHandle');

     % get source ports
     sourcePorts = get_param(sourceBlock, 'PortHandles');

     % get destination ports
     destinationPorts = get_param(destinationBlock, 'PortHandles');



     %check if the mode assume port is already connected
     portLine = get_param(sourcePorts.Inport(1),'Line'); 

     if portLine == -1    
         % connect the assumption port of the validator
         % with the assume port of the mode
         blockModel = get_param(gcb, 'Parent'); 
         %add_line(blockModel, destinationPorts.Outport(1) ,sourcePorts.Inport(1), 'autorouting','on');
         %hilite_system(sourcePort)
     end
 end
end 