%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ object_full_name ] = get_full_name( object,isChart )
%GET_FULL_NAME Summary of this function goes here
%   Detailed explanation goes here
if ~exist('isChart', 'var')
    isChart = false;
end
% object_full_name = regexprep(strcat(object.path,'_',object.Name),expression,replace);
object_parent_name= regexp(object.Path, '/','split');
if isChart
    str = object_parent_name(1:end-1);
    object_parent_name = Utils.concat_delim(str, '_');%object_parent_name{1};
else
    object_parent_name = object_parent_name{end};
end
expression = '(\s*|\-|/)';
replace = '';
try
object_name = regexprep(object.Name,expression,replace);
catch
    object_name = strcat('Junction',num2str(object.Id));
end
object_parent_name = regexprep(object_parent_name,expression,replace);
if isChart
    object_full_name = Utils.name_format(strcat(object_parent_name,'_',object_name));
else
    object_full_name = Utils.name_format(strcat(object_parent_name,'_',object_name,num2str(object.Id)));
end
end

