function blkStruct = slblocks
    % This function specifies that the library should appear
    % in the Library Browser
    % and be cached in the browser repository

    Browser.Library = 'Kind';
    % 'Kind' is the name of the library

    Browser.Name = 'Kind';
    % 'Kind' is the library name that appears 
    % in the Library Browser
    blkStruct.Browser = Browser; 
end