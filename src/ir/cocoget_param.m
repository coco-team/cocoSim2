function [ ParamValue ] = cocoget_param( ir, Object, Parameter )
%COCOGET_PARAM - Get parameter names and values of an internal representation
%
%   This function returns the name or value of the specified parameter for
%   the specified model or block object of the specified json ir.
%
%   ParamValue = COCOGET_PARAM(ir, Object Parameter)

% Open the file
fid = fopen(ir, 'r');
% Read the file
json_model = fread(fid);
fclose(fid);
ir_struct = json_decode(char(json_model));

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
    [~, file_name, ~] = fileparts(ir);
    ParamValue = cocoget_param_aux(ir_struct.(file_name).Content, Object, Parameter);
    if isempty(ParamValue)
        error('Handle not valid.');
    end
else
    error('Error. \n Specified Object must be an id or a string of a path to a block not a %s.', class(Object));
end

end

function [ParamValue] = cocoget_param_aux(ir_struct, Object, Parameter)
    ParamValue = [];
    if isfield(ir_struct, 'Handle') && ir_struct.Handle == Object
        ParamValue = ir_struct.(Parameter);
    else
        fields = fieldnames(ir_struct);
        i = 1;
        while i <= numel(fields) && isempty(ParamValue)
            if isa(ir_struct.(fields{i}), 'struct')
                ParamValue = cocoget_param_aux(ir_struct.(fields{i}), Object, Parameter);
            end
            i = i+1;
        end
    end
end