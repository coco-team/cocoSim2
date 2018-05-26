%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
% Copyright (C) 2018  The university of Iowa
% Author: Mudathir Mahgoub
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef ValidationMenu

    methods(Static)
        function schema = validate(callbackInfo)
            schema = sl_action_schema;
            schema.label = 'Compiler Validation (Experimental)';
            schema.callback = @ValidationMenu.validateCallBack;
        end % validate
        
        function validateCallBack(callbackInfo)
            try
                [cocoSim_path, ~, ~] = fileparts(mfilename('fullpath'));
                model_full_path = ValidationMenu.get_file_name(gcs) ;
                L = log4m.getLogger(fullfile(fileparts(model_full_path),'logfile.txt'));
                validate_window(model_full_path,cocoSim_path,1,L);
            catch ME
                display_msg(ME.getReport(), Constants.DEBUG,'Validate_model','');
                display_msg(ME.message, Constants.ERROR,'Validate_model','');
            end
        end % validateCallBack
        
        function fname = get_file_name(gcs)
            names = regexp(gcs,'/','split');
            fname = get_param(names{1},'FileName');
        end % get_file_name
        
    end
 end