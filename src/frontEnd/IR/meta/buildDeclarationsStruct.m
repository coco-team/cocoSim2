%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2018  The university of Iowa
% Author: Mudathir Mahgoub
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [declarations] = buildDeclarationsStruct(ir_struct)
%getDeclarations returns an object that describes enumerations and
% bus objects defined in the model 

%https://www.mathworks.com/help/simulink/ug/migrate-enumerated-types-into-data-dictionary.html

% Find all variables and enumerated types used in model blocks

usedTypesVars = Simulink.findVars(gcs,'IncludeEnumTypes',true);
% Here, EnumsReporting is the name of the model and
% usedTypesVars is an array of Simulink.VariableUsage objects

% Find indices of enumerated types that are defined by MATLAB files or P-files
enumTypesFile = strcmp({usedTypesVars.SourceType},'MATLAB file');

% Find indices of enumerated types that are defined using the function 
% Simulink.defineIntEnumType
enumTypesDynamic = strcmp({usedTypesVars.SourceType},'dynamic class');

% In one array, represent indices of both kinds of enumerated types
enumTypesIndex = enumTypesFile | enumTypesDynamic;

% Use logical indexing to return the names of used enumerated types
enumTypeNames = {usedTypesVars(enumTypesIndex).Name}'; 

% initialize declarations
declarations.Enumerations = cell(length(enumTypeNames), 1);

    % build a struct for each enum
    for i = 1 : length(enumTypeNames)
        declarations.Enumerations {i} = buildEnumStruct(enumTypeNames{i});
    end
end

function enumStruct = buildEnumStruct(enumTypeName)
    
    % get the name of the enum
    enumStruct.Name = enumTypeName;        
    
    metadata = meta.class.fromName(enumTypeName);    
    
    % get the default value
    
    if ismethod(enumTypeName,'getDefaultValue')        
        cmd = [enumTypeName '.getDefaultValue()'];
        enumStruct.DefaultValue = char(eval(cmd));    
    else        
        enumStruct.DefaultValue = metadata.EnumerationMemberList(1).Name; 
    end
    
    enumStruct.Members = cell(length(metadata.EnumerationMemberList), 1);
    
     % get the members of the enum
    for i = 1 : length(metadata.EnumerationMemberList)
        enumStruct.Members{i}.Name = metadata.EnumerationMemberList(i).Name;
        cmd = ['int32(' enumTypeName '.' enumStruct.Members{i}.Name ')'];
        enumStruct.Members{i}.Value = eval(cmd);         
    end    
end

