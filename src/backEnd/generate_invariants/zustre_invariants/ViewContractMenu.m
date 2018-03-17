classdef ViewContractMenu
    methods(Static)
       
        function schema = viewContract(callbackInfo)
            schema = sl_action_schema;
            schema.label = 'View generated CoCoSpec (Experimental)';
            schema.callback = @ViewContractMenu.viewContractCallback;
        end

        function viewContractCallback(callbackInfo)
            model_full_path = ViewContractMenu.get_file_name(gcs);
            simulink_name = gcs;
            contract_name = [simulink_name '_COCOSPEC'];
            emf_name = [simulink_name '_EMF'];
            try
                CONTRACT = evalin('base', contract_name);
                EMF = evalin('base', emf_name);
                disp(['CONTRACT LOCATION ' char(CONTRACT)]);

            catch ME
                display_msg(ME.getReport(),Constants.DEBUG,'viewContract','');
                msg = sprintf('No CoCoSpec Contract for %s \n Verify the model with Zustre', simulink_name);
                warndlg(msg,'CoCoSim: Warning');
            end
            try
                Output_url = view_cocospec(model_full_path, char(EMF));
                open(Output_url);
            catch ME
                display_msg(ME.getReport(),Constants.DEBUG,'viewContract','');
            end
        end

        
        function fname = get_file_name(gcs)
            names = regexp(gcs,'/','split');
            fname = get_param(names{1},'FileName');
        end % get_file_name
        
    end
end