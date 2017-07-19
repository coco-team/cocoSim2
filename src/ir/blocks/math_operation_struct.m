function [ S ] = math_operation_struct( file_name, block_type )
%Non supporté : 'ComplexToMagnitudeAngle', 'ComplexToRealImag',
%    'Product', 'Find',
%    'MagnitudeAngleToComplex',
%    'PermuteDimensions', 'Product',
%    'RealImagToComplex',
%    'Sin',
%    'UnaryMinus', 'SampleTimeMath'

%Abs, Reshape, DotProduct, Signum : rien d'interessant ?

S = struct();

if strcmp(block_type, 'Gain')
    S.Gain = get_param(file_name, 'Gain');
    S.Multiplication = get_param(file_name, 'Multiplication');
elseif strcmp(block_type, 'Polyval')
    S.coefs = get_param(file_name, 'coefs');
elseif strcmp(block_type, 'MinMax')
    S.Function = get_param(file_name, 'Function');
elseif strcmp(block_type, 'Sum')
    S.Inputs = get_param(file_name, 'Inputs');
    S.CollapseMode = get_param(file_name, 'CollapseMode');
    S.CollapseDim = get_param(file_name, 'CollapseDim');
elseif strcmp(block_type, 'Bias')
    S.Bias = get_param(file_name, 'Bias');
elseif strcmp(block_type, 'Concatenate')
    S.Mode = get_param(file_name, 'Mode');
    S.ConcatenateDimension = get_param(file_name, 'ConcatenateDimension');
elseif strcmp(block_type, 'Rounding')
    S.Operator = get_param(file_name, 'Operator');
    S.TruthTable = get_param(file_name, 'TruthTable'); %n'existe pas dans la doc
elseif strcmp(block_type, 'Math') | strcmp(block_type, 'Sqrt') | strcmp(block_type, 'Trigonometry')
    S.Operator = get_param(file_name, 'Operator');
elseif strcmp(block_type, 'Assignment')
    S.NumberOfDimensions = get_param(file_name, 'NumberOfDimensions');
    S.IndexOptions = get_param(file_name, 'IndexOptions');
    S.Indices = get_param(file_name, 'Indices');
    S.IndexMode = get_param(file_name, 'IndexMode');
end

end

