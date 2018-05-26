function [ CoCoSimPreferences ] = loadCoCoSimPreferences()
    % check if the preferences mat file is there
    path = fileparts(mfilename('fullpath'));
    preferencesFile = fullfile(path, 'preferences.mat');
    if exist(preferencesFile, 'file') == 2        
        load(preferencesFile, 'CoCoSimPreferences');        
    end
    
    modified = false;
    
    % check if the variable CoCoSimPreferences is defined
    if exist('CoCoSimPreferences', 'var') ~= 1
        CoCoSimPreferences = {};
        modified = true;
    end  
    
    % check if the modelChecker is defined
    if ~ isfield(CoCoSimPreferences,'modelChecker')
        CoCoSimPreferences.modelChecker = 'Kind2';
        modified = true;
    end
    
    % check if javaToLustreCompiler is defined
    if ~ isfield(CoCoSimPreferences,'javaToLustreCompiler')
        CoCoSimPreferences.javaToLustreCompiler = true;
        modified = true;
    end
    % check if compositionalAnalysis is defined
    if ~ isfield(CoCoSimPreferences,'compositionalAnalysis')
        CoCoSimPreferences.compositionalAnalysis = true;
        modified = true;
    end 
    
    % check if kind2Binary is defined
    if ~ isfield(CoCoSimPreferences,'kind2Binary')
        % for windows the web service is the default
        if ispc
            CoCoSimPreferences.kind2Binary = 'Kind2 web service';
        else
            CoCoSimPreferences.kind2Binary = 'Local';
        end
        modified = true;
    end 
    % save if CoCoSimPreferences is modified
    if modified
        save(preferencesFile, 'CoCoSimPreferences');
    end
end

