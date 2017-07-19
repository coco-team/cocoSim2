function [ S ] = ports_and_subsystems_struct( file_name, block_type )

% Non supporté : 'EnablePort', 'ForEach',
%    'ModelReference',
%    'Subsystem Examples',
%    'WhileIterator'

% ActionPort : rien d'intéressant ?

if nargin < 2
    init;
    block_type = '';
end

S = struct();

if strcmp(block_type, 'SubSystem') | strcmp(block_type, '')
    content = find_system(file_name);
    content(1) = []; %the first one is file_name

    for i=1:numel(content)
        [parent, sub_name, ~] = fileparts(content{i});
        sub_type = get_param(content{i}, 'BlockType');
        common_part = common_struct(content{i});
        if (ismember(sub_type, Continuous))
            specif_part = continuous_struct(content{i}, sub_type);
        elseif (ismember(sub_type, Discontinuities))
            specif_part = discontinuities_struct(content{i}, sub_type);
        elseif (ismember(sub_type, Discrete))
            specif_part = discrete_struct(content{i}, sub_type);
        elseif (ismember(sub_type, Logic_and_Bit_Operations))
            specif_part = logic_and_bit_operation_struct(content{i}, sub_type);
        elseif (ismember(sub_type, Lookup_Tables))
            specif_part = lookup_tables_struct(content{i}, sub_type);
        elseif (ismember(sub_type, Math_Operation))
            specif_part = math_operation_struct(content{i}, sub_type);
        elseif (ismember(sub_type, Model_Verification))
            specif_part = model_verification_struct(content{i}, sub_type);
        elseif (ismember(sub_type, Model_Wide_Utilities))
            specif_part = model_wide_utilities_struct(content{i}, sub_type);
        elseif (ismember(sub_type, Ports_and_Subsystems))
            if ~strcmp(block_type, '') && strcmp(get_param(file_name, 'Mask'), on)
                mask_type = get_param(file_name, 'MaskType');
                if ~strcmp(mask_type, '')
                    specif_part = masked_subsystems_struct(content{i}, mask_type);
                end
            else
                specif_part = ports_and_subsystems_struct(content{i}, sub_type);
            end
        elseif (ismember(sub_type, Signal_Attributes))
            specif_part = signal_attributes_struct(content{i}, sub_type);
        elseif (ismember(sub_type, Signal_Routing))
            specif_part = signal_routing_struct(content{i}, sub_type);
        elseif (ismember(sub_type, Sinks))
            specif_part = sinks_struct(content{i}, sub_type);
        elseif (ismemeber(sub_type, Sources))
            specif_part = sources_struct(content{i}, sub_type);
        elseif (ismember(sub_type, User_Defined_Function))
            specif_part = user_defined_function_struct(content{i}, sub_type);
        else
            %ajout d'autres librairies
        end
        S.(sub_name) = catstruct(common_part, specif_part);
    end
elseif strcmp(block_type, 'ForIterator')
    S.IterationSource = get_param(file_name, 'IterationSource');
    S.ExternalIncrement = get_param(file_name, 'ExternalIncrement');
    S.ShowIterationPort = get_param(file_name, 'ShowIterationPort');
    S.IndexMode = get_param(file_name, 'IndexMode');
    S.IterationVariableDataType = get_param(file_name, 'IterationVariableDataType');
elseif strcmp(block_type, 'SwitchCase')
    S.CaseConditions = get_param(file_name, 'CaseConditions');
    S.ShowDefaultCase = get_param(file_name, 'ShowDefaultCase');
elseif strcmp(block_type, 'TriggerPort')
    S.ShowOutputPort = get_param(file_name, 'ShowOutputPort');
elseif strcmp(block_type, 'If')
    S.IfExpression = get_param(file_name, 'IfExpression');
    S.ElseIfExpressions = get_param(file_name, 'ElseIfExpressions');
    S.NumInputs = get_param(file_name, 'NumInputs');
    S.ShowElse = get_param(file_name, 'ShowElse');
elseif strcmp(block_type, 'Inport')
    % on garde les inherited et -1 ou on simule pour avoir le vrai type à
    % la compilation ?
    S.Port = get_param(file_name, 'Port');
    portDimensions = get_param(file_name, 'CompiledPortDimensions');
    S.PortDimensions = portDimensions.Outport(1); % à revoir, je ne comprends pas la signification du vecteur
    compiledPortDataType = get_param(file_name, 'CompiledPortDataTypes');
    S.OutDataTypeStr = compiledPortDataType.Outport;
elseif strcmp(block_type, 'Outport')
    S.Port = get_param(file_name, 'Port');
    portDimensions = get_param(file_name, 'CompiledPortDimensions');
    S.PortDimensions = portDimensions.Inport(1); % idem
    compiledPortDataType = get_param(file_name, 'CompiledPortDataTypes');
    S.OutDataTypeStr = compiledPortDataType.Inport;
end
end

