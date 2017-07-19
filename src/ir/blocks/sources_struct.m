function [ S ] = sources_struct( file_name, block_type )

% Non supporté : 'Clock',
%    'DigitalClock', 'EnumeratedConstant', 'FromFile',
%    'Ground', 'DiscretePulseGenerator',
%    'RandomNumber',
%    'SignalGenerator', 'Sin',
%    'UniformRandomNumber', 'WaveformGenerator'

% Inport : rien d'intéressant ?

S = struct();

if strcmp(block_type, 'Step')
    S.Time = get_param(file_name, 'Time');
    S.Before = get_param(file_name, 'Before');
    S.After = get_param(file_name, 'After');
elseif strcmp(block_type, 'Constant')
    S.Value = get_param(file_name, 'Value');
elseif strcmp(block_type, 'FromWorkspace')
    S.VariableName = get_param(file_name, 'VariableName');
end

end

