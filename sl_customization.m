%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sl_customization(cm)    
    cm.addCustomMenuFcn('Simulink:ToolsMenu', @CocosimMenu.cocosimMenu);
    cm.addCustomMenuFcn('Simulink:PreContextMenu', @PreContextMenu.preContextMenu);
end
