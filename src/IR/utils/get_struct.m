function [Object_struct] = get_struct(ir_struct, Object)
    
Object_struct = [];
if isa(Object, 'char')
    path = strsplit(Object, filesep);
    Object_search = ir_struct;
    for i=1:numel(path)-1
        try
            Object_search = Object_search.(Utils.name_format(path{i})).Content;
        catch
            error(['error, reference to non-existent field : ', Utils.name_format(path{i})]);
        end
    end
    try
        Object_struct = Object_search.(Utils.name_format(path{numel(path)}));
    catch
        error(['error, reference to non-existent field : ', Utils.name_format(path{numel(path)})]);
    end
elseif isa(Object, 'double')
    if isfield(ir_struct, 'Handle') && ir_struct.Handle == Object
        Object_struct = ir_struct;
    else
        fields = fieldnames(ir_struct);
        i = 1;
        while i <= numel(fields) && isempty(Object_struct)
            if isa(ir_struct.(fields{i}), 'struct')
                Object_struct = get_struct(ir_struct.(fields{i}), Object);
            end
            i = i + 1;
        end
    end
else
    error('Error. \n Specified Object must be an id or a string of a path to a block not a %s.', class(Object));
end
end
