function [Object_struct] = get_struct(ir_struct, Object, handle_struct_map)
global ir_handle_struct_map;
if isempty(ir_handle_struct_map) && nargin >= 3
    ir_handle_struct_map = handle_struct_map;
elseif isempty(ir_handle_struct_map)
    ir_handle_struct_map = containers.Map('KeyType','double', 'ValueType','any');
end
Object_struct = [];
if isa(Object, 'char')
    path = strsplit(Object, filesep);
    Object_search = ir_struct;
    for i=1:numel(path)-1
        try
            Object_search = Object_search.(IRUtils.name_format(path{i})).Content;
        catch
            error(['error, reference to non-existent field : ', IRUtils.name_format(path{i})]);
        end
    end
    try
        Object_struct = Object_search.(IRUtils.name_format(path{numel(path)}));
    catch
        error(['error, reference to non-existent field : ', IRUtils.name_format(path{numel(path)})]);
    end
elseif isa(Object, 'double')
    if isKey(ir_handle_struct_map, Object)
        Object_struct = ir_handle_struct_map(Object);
    else
        if isfield(ir_struct, 'Handle') && (ir_struct.Handle == Object)
            Object_struct = ir_struct;
        elseif ~isempty(ir_struct)
            fields = fieldnames(ir_struct);
            i = 1;
            while i <= numel(fields) && isempty(Object_struct)
                field = ir_struct.(fields{i});
                if isa(field, 'struct')
                    Object_struct = get_struct(ir_struct.(fields{i}), Object);
                end
                i = i + 1;
            end
        end
    end
else
    error('Error. \n Specified Object must be an id or a string of a path to a block not a %s.', class(Object));
end
end
