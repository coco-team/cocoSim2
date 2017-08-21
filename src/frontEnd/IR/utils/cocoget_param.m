function [ ParamValue ] = cocoget_param( ir_struct, Object, Parameter )
%COCOGET_PARAM - Get parameter names and values of an internal representation
%
%   This function returns the name or value of the specified parameter for
%   the specified model or block object of the specified struct ir.
%
%   ParamValue = COCOGET_PARAM(ir, Object Parameter)

if ~isa(Parameter, 'char')
    error('The parameter name must be a string.');
end


if isa(Object, 'cell')
    ParamValue = {};
    for j=1:numel(Object)
        path = strsplit(Object{j}, filesep);
        Object_search = ir_struct;
        for i=1:numel(path)-1
            try
                Object_search = Object_search.(IRUtils.name_format(path{i})).Content;
            catch
                error(['error, reference to non-existent field : ', IRUtils.name_format(path{i})]);
            end
        end
        if ~isfield(Object_search, IRUtils.name_format(path{numel(path)}))
            error(['error, reference to non-existent field : ', IRUtils.name_format(path{numel(path)})]);
        elseif ~isfield(Object_search.(IRUtils.name_format(path{numel(path)})), Parameter)
            error(['error, reference to non-existent field : ', Parameter]);
        else
            ParamValue = [ ParamValue Object_search.(IRUtils.name_format(path{numel(path)})).(Parameter)];
        end
    end
elseif isa(Object, 'char')
    path = strsplit(Object, filesep);
    Object_search = ir_struct;
    for i=1:numel(path)-1
        try
            Object_search = Object_search.(IRUtils.name_format(path{i})).Content;
        catch
            error(['error, reference to non-existent field : ', IRUtils.name_format(path{i})]);
        end
    end
    if ~isfield(Object_search, IRUtils.name_format(path{numel(path)}))
        error(['error, reference to non-existent field : ', IRUtils.name_format(path{numel(path)})]);
    elseif ~isfield(Object_search.(IRUtils.name_format(path{numel(path)})), Parameter)
        error(['error, reference to non-existent field : ', Parameter]);
    else
        ParamValue = Object_search.(IRUtils.name_format(path{numel(path)})).(Parameter);
    end
elseif isa(Object, 'double')
    Object_struct = get_struct(ir_struct, Object);
    if isempty(Object_struct)
        error('Handle not valid.');
    end
    try
        ParamValue = Object_struct.(Parameter);
    catch
        error(['error, reference to non-existent field : ', Parameter]);
    end
else
    error('Error. \n Specified Object must be an id or a string of a path to a block not a %s.', class(Object));
end

end
