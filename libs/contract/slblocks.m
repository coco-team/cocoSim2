%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2018  The university of Iowa
% Author: Mudathir Mahgoub
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function blkStruct = slblocks
    % This function specifies that the library should appear
    % in the Library Browser
    % and be cached in the browser repository

    Browser.Library = 'CoCoSimSpecification';
    % 'CoCoSimSpecification' is the name of the library

    Browser.Name = 'CoCoSim Specification';
    % 'CoCoSim Specification' is the library name that appears 
    % in the Library Browser
    blkStruct.Browser = Browser; 
end