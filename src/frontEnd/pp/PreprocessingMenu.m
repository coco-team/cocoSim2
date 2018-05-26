%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
% Copyright (C) 2018  The university of Iowa
% Author: Mudathir Mahgoub
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef PreprocessingMenu
    methods(Static)
       
        % Function to pre-process and simplify the Simulink model
        function schema = preprocess(callbackInfo)
            schema = sl_action_schema;
            schema.label = 'Simplifier';
            schema.callback = @PreprocessingMenu.preprocessCallBack;
        end % preprocess

        function preprocessCallBack(callbackInfo)
            try
                [prog_path, fname, ext] = fileparts(mfilename('fullpath'));
                addpath(fullfile(prog_path, 'pp'));
                simulink_name = PreprocessingMenu.get_file_name(gcs);%gcs;
                pp_model = cocosim_pp(simulink_name);
                load_system(char(pp_model));
            catch ME
                display_msg(ME.getReport(),Constants.DEBUG,'getPP','');
                display_msg(ME.message,Constants.ERROR,'getPP','');
            end
        end

        
        function fname = get_file_name(gcs)
            names = regexp(gcs,'/','split');
            fname = get_param(names{1},'FileName');
        end % get_file_name
        
    end

end

