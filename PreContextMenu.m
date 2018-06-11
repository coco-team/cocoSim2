%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2018  The university of Iowa
% Author: Mudathir Mahgoub
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef PreContextMenu
    methods(Static)
        function schemaFcns = preContextMenu
            schemaFcns = {@PreContextMenu.cocoSimActions};
        end

        function schema = cocoSimActions(callbackInfo)
            schema = sl_container_schema;
            schema.label = 'CoCoSim';
            schema.statustip = 'CoCoSim';
            schema.autoDisableWhen = 'Busy';

            modelWorkspace = get_param(callbackInfo.studio.App.blockDiagramHandle,'modelworkspace');   
            if ~isempty(modelWorkspace) && modelWorkspace.hasVariable('compositionalMap')
                schema.childrenFcns = {...
                    @VerificationMenu.displayHtmlVerificationResults,...
                    @VerificationMenu.compositionalOptions,...
                    @MiscellaneousMenu.replaceInportsWithSignalBuilders...
                    };
            else
                schema.childrenFcns = {@MiscellaneousMenu.replaceInportsWithSignalBuilders};
            end
        end
    end
end
