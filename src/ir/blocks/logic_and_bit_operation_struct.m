function [ S ] = logic_and_bit_operation_struct( file_name, block_type )

%Non supporté : 'CombinatorialLogic', 'ArithShift'

S = struct();

if strcmp(block_type, 'Logic')
    S.Inputs = get_param(file_name, 'Inputs');
    S.CollapseMode = get_param(file_name, 'CollapseMode'); %n'existe pas dans la doc
    S.CollapseDim = get_param(file_name, 'CollapseDim'); %n'existe pas dans la doc
    S.Multiplication = get_param(file_name, 'Multiplication'); %n'existe pas dans la doc
elseif strcmp(block_type, 'RelationalOperator')
    S.Operator = get_param(file_name, 'Operator');
end

end

