function [ S ] = signal_routing_struct( file_name, block_type )
% Non supporté : 'DataStoreMemory', 'DataStoreRead', 'DataStoreWrite',
%    'GotoTagVisibility', 'VariantSink', 'tVariantSource'

% Concatenate traité dans Math avec Mode et ConcatenateDimension. Pas de
% ConcatenateDimension dans le cas d'un Vector Concatenate dans signal
% routing

% Demux, merge, mux : rien d'intéressant ?

S = struct();

if strcmp(block_type, 'Switch')
    S.Criteria = get_param(file_name, 'Criteria');
    S.Threshold = get_param(file_name, 'Threshold');
elseif strcmp(block_type, 'MultiPortSwitch')
    S.DataPortOrder = get_param(file_name, 'DataPortOrder');
    S.DataPortIndices = get_param(file_name, 'DataPortIndices');
    S.Inputs = get_param(file_name, 'Inputs');
    S.DataPortForDefault = get_param(file_name, 'DataPortForDefault');
    S.AllowDiffInputSizes = get_param(file_name, 'AllowDiffInputSizes');
elseif strcmp(block_type, 'From') | srtcmp(block_type, 'Goto')
    S.GotoTag = get_param(file_name, 'GotoTag');
elseif strcmp(block_type, 'BusSelector')
    S.OutputSignals = get_param(file_name, 'OutputSignals');
    S.OutputAsBus = get_param(file_name, 'OutputAsBus');
elseif strcmp(block_type, 'BusCreator')
    S.NonVirtualBus = get_param(file_name, 'NonVirtualBus');
elseif strcmp(block_type, 'BusAssignment')
    S.AssignedSignals = get_param(file_name, 'AssignedSignals');
elseif strcmp(block_type, 'Selector')
    S.NumberOfDimensions = get_param(file_name, 'NumberOfDimensions');
    S.IndexOptions = get_param(file_name, 'IndexOptions');
    S.Indices = get_param(file_name, 'Indices');
    S.IndexMode = get_param(file_name, 'IndexMode');
    S.OutputSizes = get_param(file_name, 'OutputSizes');
end

end

