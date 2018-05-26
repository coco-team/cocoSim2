%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
% Copyright (C) 2018  The university of Iowa
% Author: Mudathir Mahgoub
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef UnsupportedBlocksMenu
    methods(Static)
        function schema = checkUnsupportedBlocks(callbackInfo)
            schema = sl_action_schema;
            schema.label = 'Check unsupported blocks';
            schema.callback = @UnsupportedBlocksMenu.checkBlocksCallBack;
        end % checkUnsupportedBlocks

        function checkBlocksCallBack(callbackInfo)
            try
                model_full_path = UnsupportedBlocksMenu.get_file_name(gcs);
                unsupported_blocks_gui( model_full_path );
            catch ME
                display_msg(ME.message,Constants.ERROR,'getCheckBlocks','');
                display_msg(ME.getReport(),Constants.DEBUG,'getCheckBlocks','');
            end
        end % checkBlocksCallBack
        
        function fname = get_file_name(gcs)
            names = regexp(gcs,'/','split');
            fname = get_param(names{1},'FileName');
        end % get_file_name
        
    end
end