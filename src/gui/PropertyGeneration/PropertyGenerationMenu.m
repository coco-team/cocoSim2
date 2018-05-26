%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
% Copyright (C) 2018  The university of Iowa
% Authors: Temesghen Kahsai, Hamza Bourbouh, Mudathir Mahgoub
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef PropertyGenerationMenu
    methods(Static)
       
        function schema = generateProperty(callbackInfo)
            schema = sl_action_schema;
            schema.label = 'Create Property';
            schema.callback = @PropertyGenerationMenu.displayPropertyGenerationGui;
        end

        function displayPropertyGenerationGui(callbackInfo)
            try
                [prog_path, fname, ext] = fileparts(mfilename('fullpath'));
                simulink_name = PropertyGenerationMenu.get_file_name(gcs);
                add_property(simulink_name);
            catch ME
                display_msg(ME.getReport(),Constants.DEBUG,'generateProperty','');
            end
        end

        
        function fname = get_file_name(gcs)
            names = regexp(gcs,'/','split');
            fname = get_param(names{1},'FileName');
        end % get_file_name
        
    end
end

