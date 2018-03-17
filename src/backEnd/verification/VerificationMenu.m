 classdef VerificationMenu

    methods(Static)
        function schema = verify(callbackInfo)
            schema = sl_action_schema;
            schema.label = 'Verify';
            if evalin( 'base', '~exist(''MODEL_CHECKER'',''var'')' ) == 1 || ...
                        strcmp(evalin( 'base', 'MODEL_CHECKER' ) ,'Kind2')
                schema.callback = @VerificationMenu.kindCallback;
            else
                if strcmp(evalin( 'base', 'MODEL_CHECKER' ) ,'JKind')
                    schema.callback = @jkindCallback;
                end
            end
        end % verify
        
        function schema = verifyUsing(callbackInfo)
            schema = sl_container_schema;
            schema.label = 'Verify using ...';
            schema.statustip = 'Verify the current model with CoCoSim';
            schema.autoDisableWhen = 'Busy';
            schema.childrenFcns = {@VerificationMenu.getZustre, ...
                @VerificationMenu.getKind, @VerificationMenu.getJKind};
        end % verifyUsing
        
        function kindCallback(callbackInfo)
            clear;
            [prog_path, fname, ext] = fileparts(mfilename('fullpath'));
            assignin('base', 'SOLVER', 'K');
            assignin('base', 'RUST_GEN', 0);
            assignin('base', 'C_GEN', 0);
            VerificationMenu.runCoCoSim;
        end % kindCallback
        
        function jkindCallback(callbackInfo)
            clear;
            [prog_path, fname, ext] = fileparts(mfilename('fullpath'));
            assignin('base', 'SOLVER', 'J');
            assignin('base', 'RUST_GEN', 0);
            assignin('base', 'C_GEN', 0);
            VerificationMenu.runCoCoSim;
        end % jkindCallback

        function zustreCallback(callbackInfo)
            clear;
            assignin('base', 'SOLVER', 'Z');
            assignin('base', 'RUST_GEN', 0);
            assignin('base', 'C_GEN', 0);
            VerificationMenu.runCoCoSim;
        end % zustreCallback
        
        function runCoCoSim
            [path, name, ext] = fileparts(mfilename('fullpath'));
            addpath(fullfile(path, 'utils'));
            try
                simulink_name = VerificationMenu.get_file_name(gcs);
                cocosim_window(simulink_name);
                %       cocoSim(simulink_name); % run cocosim
            catch ME
                if strcmp(ME.identifier, 'MATLAB:badsubscript')
                    msg = ['Activate debug message by running cocosim_debug=true', ...
                        ' to get more information where the model in failing'];
                    e_msg = sprintf('Error Msg: %s \n Action:\n\t %s', ME.message, msg);
                    display_msg(e_msg, Constants.ERROR, 'cocoSim', '');
                    display_msg(ME.getReport(),Constants.DEBUG,'cocoSim','');
                elseif strcmp(ME.identifier,'MATLAB:MException:MultipleErrors')
                    msg = 'Make sure that the model can be run (i.e. most probably missing constants)';
                    d_msg = sprintf('Error Msg: %s', ME.getReport());
                    display_msg(d_msg, Constants.DEBUG, 'cocoSim', '');
                    display_msg(msg, Constants.ERROR, 'cocoSim', '');
                elseif strcmp(ME.identifier, 'Simulink:Commands:ParamUnknown')
                    msg = 'Run CoCoSim on the most top block of the model';
                    e_msg = sprintf('Error Msg: %s \n Action:\n\t %s', ME.message, msg);
                    display_msg(e_msg, Constants.ERROR, 'cocoSim', '');
                    display_msg(ME.getReport(),Constants.DEBUG,'cocoSim','');
                else
                    display_msg(ME.message,Constants.ERROR,'cocoSim','');
                    display_msg(ME.getReport(),Constants.DEBUG,'cocoSim','');
                end

            end
        end % runCoCoSim
        
        
        function schema = getKind(callbackInfo)
            schema = sl_action_schema;
            schema.label = 'Kind2';
            schema.callback = @VerificationMenu.kindCallback;
        end % getKind

        function schema = getJKind(callbackInfo)
            schema = sl_action_schema;
            schema.label = 'JKind';
            schema.callback = @VerificationMenu.jkindCallback;
        end % getJKind

        function schema = getZustre(callbackInfo)
            schema = sl_action_schema;
            schema.label = 'Zustre';
            schema.callback = @VerificationMenu.zustreCallback;
        end % getZustre
        
        function fname = get_file_name(gcs)
            names = regexp(gcs,'/','split');
            fname = get_param(names{1},'FileName');
        end % get_file_name
        
    end
 end