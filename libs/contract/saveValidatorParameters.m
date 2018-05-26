%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2018  The university of Iowa
% Author: Mudathir Mahgoub
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function saveValidatorParameters(blockPath)
values = get_param(blockPath,'MaskValues');

ContractValidatorBlock.block = blockPath;

ContractValidatorBlock.assumePorts = str2num(char(values(1)));
ContractValidatorBlock.guaranteePorts = str2num(char(values(2)));
ContractValidatorBlock.modeBlocksPorts = str2num(char(values(3)));

ContractValidatorBlock.portHandles = get_param(ContractValidatorBlock.block, 'PortHandles');
ContractValidatorBlock.portConnectivity =get_param(ContractValidatorBlock.block, 'PortConnectivity');

% store ContractValidatorBlock in ContractValidatorBlocksMap
modelWorkspace = get_param(bdroot,'ModelWorkspace');
if modelWorkspace.hasVariable('ContractValidatorBlocksMap')
    ContractValidatorBlocksMap = modelWorkspace.getVariable('ContractValidatorBlocksMap');
else
    ContractValidatorBlocksMap = containers.Map;
end

ContractValidatorBlocksMap(ContractValidatorBlock.block) = ContractValidatorBlock;
assignin(modelWorkspace,'ContractValidatorBlocksMap',ContractValidatorBlocksMap); 

end

