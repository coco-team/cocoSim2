%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ sorted_objects] = sort_by_order( objects, port_or_order, chart, isFunction )
%this function can be called also for states to sort them by their
%execution order

if ~exist('port_or_order','var')
    port_or_order = 'order';
end

if ~exist('chart','var') 
    chart = [];
end


if ~exist('isFunction','var')
    isFunction = false;
end
n = numel(objects);
execution_order = zeros(n,1);
sorted_objects = objects;
if n>1
    if isFunction
        label = chart.LabelString;
        for i=1:n
            ind = strfind(label,objects(i).Name);
            if ~isempty(ind)
                execution_order(i) = ind(1);
            else
                execution_order(i) = Inf;
            end
        end
        [~, sorted_ind] = sort(execution_order);
        sorted_objects = objects(sorted_ind);
    else
        if strcmp(port_or_order,'port')

                for i=1:n
                    execution_order(i) = objects(i).Port;
                end
                [~, sorted_ind] = sort(execution_order);
                sorted_objects = objects(sorted_ind);

        elseif strcmp(port_or_order,'name')
        %         sorted_objects = sort(objects);
                names = cell(1,n);
                for i=1:n
                    names{i} = objects(i).Name;
                end
                [~, sorted_ind] = sort(names);
                sorted_objects = objects(sorted_ind);

        elseif strcmp(port_or_order,'order')
            for i=1:n
                execution_order(i) = objects(i).ExecutionOrder;
            end
            [~, sorted_ind] = sort(execution_order);
            sorted_objects = objects(sorted_ind);
            
        elseif strcmp(port_or_order,'states')
            execution_order = zeros(n,2);
            for i=1:n
                execution_order(i,:) = objects(i).Position(1:2);
            end
            [~, sorted_ind] = sortrows(execution_order);
            sorted_objects = objects(sorted_ind);
        end
    end
end


end

