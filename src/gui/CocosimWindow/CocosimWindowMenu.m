classdef CocosimWindowMenu
    
    methods(Static)

        function schema = getCompiler(callbackInfo)
            schema = sl_container_schema;
            schema.label = 'Compile (Experimental)';            
            schema.childrenFcns = {@CocosimWindowMenu.getRust, @CocosimWindowMenu.getC};
        end

        function schema = getRust(callbackInfo)
            schema = sl_action_schema;
            schema.label = 'to Rust';
            schema.callback = @CocosimWindowMenu.rustCallback;
        end

        function rustCallback(callbackInfo)
            try
                [prog_path, fname, ext] = fileparts(mfilename('fullpath'));
                assignin('base', 'SOLVER', 'NONE');
                assignin('base', 'RUST_GEN', 1);
                assignin('base', 'C_GEN', 0);
                simulink_name = CocosimWindowMenu.get_file_name(gcs);%gcs;    
                cocosim_window(simulink_name);
            catch ME
                display_msg(ME.getReport(),Constants.DEBUG,'getRust','');
                disp('run the command in the top level of the model')
            end
        end

        function schema = getC(callbackInfo)
            schema = sl_action_schema;
            schema.label = 'to C';
            schema.callback = @CocosimWindowMenu.cCallback;
        end

        function cCallback(callbackInfo)
            clear;
            assignin('base', 'SOLVER', 'NONE');
            assignin('base', 'RUST_GEN', 0);
            assignin('base', 'C_GEN', 1);
            simulink_name = CocosimWindowMenu.get_file_name(gcs);%gcs;    
            cocosim_window(simulink_name);
        end

        function fname = get_file_name(gcs)
            names = regexp(gcs,'/','split');
            fname = get_param(names{1},'FileName');
        end
    end
end

