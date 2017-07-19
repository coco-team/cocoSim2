function [ S ] = discrete_struct( file_name, block_type )

%Non supporté : 'DiscreteFilter', 'DiscreteFIR',
%    'DiscreteTransferFcn', 'DiscreteZeroPole',
%    'Enabled Delay',
%    'ZeroOrderHold'

S = struct();

if strcmp(block_type, 'DiscreteIntegrator')
    S.gainval = get_param(file_name, 'gainval');
    S.ExternalReset = get_param(file_name, 'ExternalReset');
    S.IntegratorMethod = get_param(file_name, 'IntegratorMethod');
    S.CompiledSampleTime = get_param(file_name, 'CompiledSampleTime'); %common à tous les blocks
    S.InitialConditionSource = get_param(file_name, 'InitialConditionSource');
    S.InitialCondition = get_param(file_name, 'InitialCondition');
    S.LimitOutput = get_param(file_name, 'LimitOutput');
    S.LowerSaturationLimit = get_param(file_name, 'LowerSaturationLimit');
    S.UpperSaturationLimit = get_param(file_name, 'UpperSaturationLimit');
elseif strcmp(block_type, 'DiscreteStateSpace')
    S.A = get_param(file_name, 'A');
    S.B = get_param(file_name, 'B');
    S.C = get_param(file_name, 'C');
    S.D = get_param(file_name, 'D');
    S.X0 = get_param(file_name, 'X0');
elseif strcmp(block_type, 'UnitDelay')
    S.X0 = get_param(file_name, 'X0') %n'existe pas dans la doc.
    S.SampleTime = get_param(file_name, 'SampleTime'); %common à tous
elseif strcmp(block_type, 'Delay')
    S.X0 = get_param(file_name, 'X0'); %n'existe pas dans la doc
    S.DelayLength = get_param(file_name, 'DelayLength');
elseif strcmp(block_type, 'Memory')
    S.X0 = get_param(file_name, 'X0');
end

end

