%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Make it more efficient (transform for loop as while loop)
function [nom]=nom_block(blks, block_name)
nom='';
fields = fieldnames(blks.Content);
for k1= 1:numel(fields)
 
   % tmp=regexp(blks.Content.(fields{k1}).Path,filesep,'split');
   % name=tmp{1}{2};
    if strcmp(blks.Content.(fields{k1}).Path, block_name)
        nom=fields{k1};
   end
end

end
