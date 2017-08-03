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

if isa(Object, 'char')
    path = strsplit(Object, filesep);
    Object_search = ir_struct;
    for i=1:numel(path)-1
        Object_search = Object_search.(path{i}).Content;
    end
    ParamValue = Object_search.(path{numel(path)}).(Parameter);
elseif isa(Object, 'double')
    Object_struct = get_struct(ir_struct, Object);
    if isempty(Object_struct)
        error('Handle not valid.');
    end
    ParamValue = Object_struct.(Parameter);
else
    error('Error. \n Specified Object must be an id or a string of a path to a block not a %s.', class(Object));
end

end

%function [ParamValue] = cocoget_param_aux(ir_struct, Handle, Parameter)
%    ParamValue = [];
%    if isfield(ir_struct, 'Handle') && ir_struct.Handle == Handle
%        ParamValue = ir_struct.(Parameter);
%    else
%        fields = fieldnames(ir_struct);
%        i = 1;
%        while i <= numel(fields) && isempty(ParamValue)
%            if isa(ir_struct.(fields{i}), 'struct')
%                ParamValue = cocoget_param_aux(ir_struct.(fields{i}), Handle, Parameter);
%            end
%            i = i+1;
%        end
%    end
%end

