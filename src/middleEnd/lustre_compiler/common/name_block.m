%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Make it more efficient (transform for loop as while loop)
function [nom]=name_block(blks, block_path)
nom='';
block_path_split = regexp(block_path, '/', 'split');
nom = block_path_split{end};
end
