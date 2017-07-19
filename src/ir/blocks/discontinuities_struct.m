function [ S ] = discontinuities_struct( file_name, block_type )

%Non supporté : 'Backlash', 'DeadZone', 'HitCrossing', 'Quantizer',
%    'RateLimiter', 'Relay'

S = struct();

if strcmp(block_type, 'Saturate')
    S.LowerLimit = get_param(file_name, 'LowerLimit');
    S.UpperLimit = get_param(file_name, 'UpperLimit');
    S.RndMeth = get_param(file_name, 'RndMeth');
    %autre : LinearizeAsGain, ZeroCross, SampleTime, OutMin, OutMax,
    %OutDataTypeStr, LockScale, 
end

end

