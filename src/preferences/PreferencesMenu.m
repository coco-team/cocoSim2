classdef PreferencesMenu

    methods(Static)
    
        function schema = getMenu(callbackInfo)
            schema = sl_container_schema;
            schema.label = 'Preferences';
            schema.statustip = 'Preferences';
            schema.autoDisableWhen = 'Busy';    

            CoCoSimPreferences = loadCoCoSimPreferences();

            schema.childrenFcns = {...
                % not supported now
                %{@PreferencesMenu.getModelChecker,CoCoSimPreferences}, ...
                {@PreferencesMenu.getMiddleEnd,CoCoSimPreferences}, ...
                {@PreferencesMenu.getCompositionalAnalysis, CoCoSimPreferences}, ...
                {@PreferencesMenu.getKind2Binary, CoCoSimPreferences}, ...
                {@PreferencesMenu.getVerificationTimeout, CoCoSimPreferences}, ...
                };
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
            
            % Kind2 binary is not locally supported in windows
            if ispc 
                    schema.childrenFcns = { ...      
                    {@PreferencesMenu.kind2BinaryDocker, CoCoSimPreferences}, ...
                    {@PreferencesMenu.kind2BinaryWebService, CoCoSimPreferences}};
            else
                schema.childrenFcns = {{@PreferencesMenu.kind2BinaryLocal,CoCoSimPreferences}, ...       
                    {@PreferencesMenu.kind2BinaryDocker, CoCoSimPreferences}, ...
                    {@PreferencesMenu.kind2BinaryWebService, CoCoSimPreferences}};
            end
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

        
        function schema = getVerificationTimeout(callbackInfo)
            schema = sl_container_schema;
            schema.label = 'Verification timeout';        
            schema.statustip = 'Verification timeout';
            schema.autoDisableWhen = 'Busy';    

            CoCoSimPreferences = callbackInfo.userdata;            
            
            % ToDo: remove the hardcoded options
            timeoutOptions = [1 3 5 10 20];
            data = {};
            data.selectedOption = CoCoSimPreferences.verificationTimeout / 60; % seconds
            data.CoCoSimPreferences = CoCoSimPreferences;
            
            for index = 1 : length(timeoutOptions)                
                data.currentOption = timeoutOptions(index);                                    
                schema.childrenFcns{index} = {@PreferencesMenu.timeoutOption, data};
            end
        end
        
        function schema = timeoutOption(callbackInfo)
            schema = sl_toggle_schema;
            data = callbackInfo.userdata;    
            if data.currentOption == 1
                schema.label = '1 minute';
            else
                schema.label = strcat(num2str(data.currentOption), ' minutes');
            end          
            
            if data.selectedOption == data.currentOption
                schema.checked = 'checked';    
            else
                schema.checked = 'unchecked';    
            end

            schema.callback = @PreferencesMenu.timeoutOptionCallback;
            schema.userdata = data;
        end

        function timeoutOptionCallback(callbackInfo)    
            data = callbackInfo.userdata;    
            CoCoSimPreferences = data.CoCoSimPreferences;
            CoCoSimPreferences.verificationTimeout = data.currentOption * 60;        
            PreferencesMenu.saveCoCoSimPreferences(CoCoSimPreferences);
        end        
        
        function saveCoCoSimPreferences(CoCoSimPreferences)
            [cocosim_path, ~, ~] = fileparts(mfilename('fullpath'));
            preferencesFile = fullfile(cocosim_path, 'preferences.mat');
            save(preferencesFile, 'CoCoSimPreferences');
        end
        
    end
end