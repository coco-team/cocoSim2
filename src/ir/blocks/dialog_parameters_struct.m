function [ S ] = dialog_parameters_struct( file_name, block_type )

IR_config;

S = struct();

dialog_param = get_param(file_name, 'DialogParameters');
if ~isempty(dialog_param)
    if isKey(block_param_map, block_type) && ~isempty(block_param_map(block_type).DialogParameters) && ~strcmp(block_param_map(block_type).DialogParameters{1}, 'all')
        value = block_param_map(block_type);
        for i=1:numel(value.DialogParameters)
            S.(value.DialogParameters{i}) = get_param(file_name, value.DialogParameters{i});
        end
    else
        fields = fieldnames(dialog_param);
        for i=1:numel(fields)
            S.(fields{i}) = get_param(file_name, fields{i});
        end
    end
end

end

