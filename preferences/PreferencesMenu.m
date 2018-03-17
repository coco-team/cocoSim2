classdef PreferencesMenu

    methods(Static)
    
        function schema = getMenu(callbackInfo)
            schema = sl_container_schema;
            schema.label = 'Preferences';
            schema.statustip = 'Preferences';
            schema.autoDisableWhen = 'Busy';    

            CoCoSimPreferences = loadCoCoSimPreferences();

            schema.childrenFcns = {{@PreferencesMenu.getModelChecker,CoCoSimPreferences}, ...
                {@PreferencesMenu.getMiddleEnd,CoCoSimPreferences}, ...
                {@PreferencesMenu.getCompositionalAnalysis, CoCoSimPreferences}, ...
                {@PreferencesMenu.getKind2Binary, CoCoSimPreferences}};
        end

        function schema = getModelChecker(callbackInfo)
            schema = sl_container_schema;
            schema.label = 'Model checker';
            schema.statustip = 'Model checker';
            schema.autoDisableWhen = 'Busy';
            CoCoSimPreferences = callbackInfo.userdata;
            schema.childrenFcns = { ...
                {@PreferencesMenu.getKindOption, CoCoSimPreferences} , ... 
                 {@PreferencesMenu.getJKindOption, CoCoSimPreferences}};
        end

        function schema = getKindOption(callbackInfo)
            schema = sl_toggle_schema;
            schema.label = 'Kind2';    
            CoCoSimPreferences = callbackInfo.userdata;

            if strcmp(CoCoSimPreferences.modelChecker, 'Kind2')
                schema.checked = 'checked';
            else
                schema.checked = 'unchecked';
            end    
            schema.callback = @PreferencesMenu.setKindOption;
            schema.userdata = CoCoSimPreferences;
        end

        function setKindOption(callbackInfo)    
            CoCoSimPreferences = callbackInfo.userdata;
            CoCoSimPreferences.modelChecker = 'Kind2';
            PreferencesMenu.saveCoCoSimPreferences(CoCoSimPreferences);
        end

        function schema = getJKindOption(callbackInfo)
            schema = sl_toggle_schema;
            schema.label = 'JKind';    

            CoCoSimPreferences = callbackInfo.userdata;

            if strcmp(CoCoSimPreferences.modelChecker, 'JKind')
                schema.checked = 'checked';
            else
                schema.checked = 'unchecked';
            end

            schema.callback = @PreferencesMenu.setJKindOption;
            schema.userdata = CoCoSimPreferences;
        end

        function setJKindOption(callbackInfo)    
            CoCoSimPreferences = callbackInfo.userdata;
            CoCoSimPreferences.modelChecker = 'JKind';
            PreferencesMenu.saveCoCoSimPreferences(CoCoSimPreferences);
        end

        function schema = getMiddleEnd(callbackInfo)
            schema = sl_toggle_schema;
            schema.label = 'Use java to lustre Compiler';       

            CoCoSimPreferences = callbackInfo.userdata;

            if CoCoSimPreferences.javaToLustreCompiler
                schema.checked = 'checked';
            else
                schema.checked = 'unchecked';
            end    

            schema.callback = @PreferencesMenu.javaToLustreCompilerCallback;    
            schema.userdata = CoCoSimPreferences;

        end


        function javaToLustreCompilerCallback(callbackInfo)
            CoCoSimPreferences = callbackInfo.userdata;
            CoCoSimPreferences.javaToLustreCompiler = ~ CoCoSimPreferences.javaToLustreCompiler;
            PreferencesMenu.saveCoCoSimPreferences(CoCoSimPreferences);
        end

        function schema = getCompositionalAnalysis(callbackInfo)
            schema = sl_toggle_schema;
            schema.label = 'Compositional Analysis';    

            CoCoSimPreferences = callbackInfo.userdata;
            if CoCoSimPreferences.compositionalAnalysis
                schema.checked = 'checked';
            else
                schema.checked = 'unchecked';
            end

            schema.callback = @PreferencesMenu.compositionalAnalysis;    
            schema.userdata = CoCoSimPreferences;
        end

        function compositionalAnalysis(callbackInfo)
            CoCoSimPreferences = callbackInfo.userdata;
            CoCoSimPreferences.compositionalAnalysis = ~ CoCoSimPreferences.compositionalAnalysis;        
            PreferencesMenu.saveCoCoSimPreferences(CoCoSimPreferences);
        end



        function schema = getKind2Binary(callbackInfo)
            schema = sl_container_schema;
            schema.label = 'Kind2 binary';        
            schema.statustip = 'Kind2 binary';
            schema.autoDisableWhen = 'Busy';    

            CoCoSimPreferences = callbackInfo.userdata;

            schema.childrenFcns = {{@PreferencesMenu.kind2BinaryLocal,CoCoSimPreferences}, ...       
                {@PreferencesMenu.kind2BinaryDocker, CoCoSimPreferences}, ...
                {@PreferencesMenu.kind2BinaryWebService, CoCoSimPreferences}};
        end

        function schema = kind2BinaryLocal(callbackInfo)
            schema = sl_toggle_schema;
            schema.label = 'Local';    

            CoCoSimPreferences = callbackInfo.userdata;
            if strcmp(CoCoSimPreferences.kind2Binary, 'Local')
                schema.checked = 'checked';
            else
                schema.checked = 'unchecked';
            end

            schema.callback = @PreferencesMenu.kind2BinaryLocalCallback;    
            schema.userdata = CoCoSimPreferences;
        end

        function kind2BinaryLocalCallback(callbackInfo)
            CoCoSimPreferences = callbackInfo.userdata;
            CoCoSimPreferences.kind2Binary = 'Local';        
            PreferencesMenu.saveCoCoSimPreferences(CoCoSimPreferences);
        end

        function schema = kind2BinaryDocker(callbackInfo)
            schema = sl_toggle_schema;
            schema.label = 'Docker';    

            CoCoSimPreferences = callbackInfo.userdata;
            if strcmp(CoCoSimPreferences.kind2Binary, 'Docker')
                schema.checked = 'checked';
            else
                schema.checked = 'unchecked';
            end

            schema.callback = @PreferencesMenu.kind2BinaryDockerCallback;    
            schema.userdata = CoCoSimPreferences;
        end

        function kind2BinaryDockerCallback(callbackInfo)
            CoCoSimPreferences = callbackInfo.userdata;
            CoCoSimPreferences.kind2Binary = 'Docker';        
            PreferencesMenu.saveCoCoSimPreferences(CoCoSimPreferences);
        end

        function schema = kind2BinaryWebService(callbackInfo)
            schema = sl_toggle_schema;
            schema.label = 'Kind2 web service';    

            CoCoSimPreferences = callbackInfo.userdata;
            if strcmp(CoCoSimPreferences.kind2Binary, 'Kind2 web service')
                schema.checked = 'checked';
            else
                schema.checked = 'unchecked';
            end

            schema.callback = @PreferencesMenu.kind2BinaryWebServiceCallback;    
            schema.userdata = CoCoSimPreferences;
        end

        function kind2BinaryWebServiceCallback(callbackInfo)
            CoCoSimPreferences = callbackInfo.userdata;
            CoCoSimPreferences.kind2Binary = 'Kind2 web service';        
            PreferencesMenu.saveCoCoSimPreferences(CoCoSimPreferences);
        end

        function saveCoCoSimPreferences(CoCoSimPreferences)
            [cocosim_path, ~, ~] = fileparts(mfilename('fullpath'));
            preferencesFile = fullfile(cocosim_path, 'preferences.mat');
            save(preferencesFile, 'CoCoSimPreferences');
        end
    end
<<<<<<< HEAD:preferences/preferencesMenu.m
end
=======
    
    schema.callback = @compositionalAnalysis;    
    schema.userdata = CoCoSimPreferences;
end

function compositionalAnalysis(callbackInfo)
    CoCoSimPreferences = callbackInfo.userdata;
    CoCoSimPreferences.compositionalAnalysis = ~ CoCoSimPreferences.compositionalAnalysis;        
    saveCoCoSimPreferences(CoCoSimPreferences);
end



function schema = getKind2Binary(callbackInfo)
    schema = sl_container_schema;
    schema.label = 'Kind2 binary';        
    schema.statustip = 'Kind2 binary';
    schema.autoDisableWhen = 'Busy';    
    
    CoCoSimPreferences = callbackInfo.userdata;
    
    schema.childrenFcns = {{@kind2BinaryLocal,CoCoSimPreferences}, ...       
        {@kind2BinaryDocker, CoCoSimPreferences}, ...
        {@kind2BinaryWebService, CoCoSimPreferences}};
end

function schema = kind2BinaryLocal(callbackInfo)
    schema = sl_toggle_schema;
    schema.label = 'Local';    
    
    CoCoSimPreferences = callbackInfo.userdata;
    if strcmp(CoCoSimPreferences.kind2Binary, 'Local')
        schema.checked = 'checked';
    else
        schema.checked = 'unchecked';
    end
    
    schema.callback = @kind2BinaryLocalCallback;    
    schema.userdata = CoCoSimPreferences;
end

function kind2BinaryLocalCallback(callbackInfo)
    CoCoSimPreferences = callbackInfo.userdata;
    CoCoSimPreferences.kind2Binary = 'Local';        
    saveCoCoSimPreferences(CoCoSimPreferences);
end

function schema = kind2BinaryDocker(callbackInfo)
    schema = sl_toggle_schema;
    schema.label = 'Docker';    
    
    CoCoSimPreferences = callbackInfo.userdata;
    if strcmp(CoCoSimPreferences.kind2Binary, 'Docker')
        schema.checked = 'checked';
    else
        schema.checked = 'unchecked';
    end
    
    schema.callback = @kind2BinaryDockerCallback;    
    schema.userdata = CoCoSimPreferences;
end

function kind2BinaryDockerCallback(callbackInfo)
    CoCoSimPreferences = callbackInfo.userdata;
    CoCoSimPreferences.kind2Binary = 'Docker';        
    saveCoCoSimPreferences(CoCoSimPreferences);
end

function schema = kind2BinaryWebService(callbackInfo)
    schema = sl_toggle_schema;
    schema.label = 'Kind2 web service';    
    
    CoCoSimPreferences = callbackInfo.userdata;
    if strcmp(CoCoSimPreferences.kind2Binary, 'Kind2 web service')
        schema.checked = 'checked';
    else
        schema.checked = 'unchecked';
    end
    
    schema.callback = @kind2BinaryWebServiceCallback;    
    schema.userdata = CoCoSimPreferences;
end

function kind2BinaryWebServiceCallback(callbackInfo)
    CoCoSimPreferences = callbackInfo.userdata;
    CoCoSimPreferences.kind2Binary = 'Kind2 web service';        
    saveCoCoSimPreferences(CoCoSimPreferences);
end

function saveCoCoSimPreferences(CoCoSimPreferences)
    [cocosim_path, ~, ~] = fileparts(mfilename('fullpath'));
    preferencesFile = fullfile(cocosim_path, 'preferences.mat');
    save(preferencesFile, 'CoCoSimPreferences');
end
>>>>>>> 26a3bdda336f6008226609daa048ed6606412619:preferences/PreferencesMenu.m
