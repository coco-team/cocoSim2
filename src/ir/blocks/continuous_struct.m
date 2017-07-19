function [ S ] = continuous_struct( file_name, block_type )

%TransferFcn : rien d'intéressant ? : Numerator, Denominator
%AbsoluteTolerance, ContinuousStateAttributes

%Non supporté par cocoSim : 'Derivative', 'Integrator', 'SecondOrderIntegrator',
%    'StateSpace', 'TransportDelay', 'VariableTimeDelay',
%    'VariableTransportDelay'

S = struct();

if strcmp(block_type, 'ZeroPole')
    S.Zeros = get_param(file_name, 'Zeros');
    S.Poles = get_param(file_name, 'Poles');
    S.Gain = get_param(file_name, 'Gain');
    % autre : AbsoluteTolerance ContinuousStateAttributes
end

end

