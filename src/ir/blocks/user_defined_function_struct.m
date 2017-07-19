function [ S ] = user_defined_function_struct( file_name, block_type )
% Non supporté : 'MATLABFcn', 'M-S-Function',
%    'MATLABSystem'

S = struct();

if strcmp(block_type, 'S-Function')
    S.FunctionName = get_param(file_name, 'FunctionName');
    S.PortConnectivity = get_param(file_name, 'PortConnectivity'); % common à tous et contient plusieurs info
elseif strcmp(block_type, 'Fcn')
    S.Expr = get_param(file_name, 'Expr');
end

end

