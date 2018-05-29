%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
% Copyright (C) 2018  The university of Iowa
% Authors: Temesghen Kahsai, Hamza Bourbouh, Mudathir Mahgoub
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef  CocosimMenu    
    methods(Static)
        %% Define the custom menu function.
        function schemaFcns = cocosimMenu
            schemaFcns = {@CocosimMenu.getcocoSim};
        end

        %% Define the custom menu function.
        function schema = getcocoSim(callbackInfo)
            schema = sl_container_schema;
            schema.label = 'CoCoSim';
            schema.statustip = 'Automated Analysis Framework';
            schema.autoDisableWhen = 'Busy';

%             modelWorkspace = get_param(callbackInfo.studio.App.blockDiagramHandle,'modelworkspace');
%             if modelWorkspace.hasVariable('isPreprocessedModel') && ...
%                     modelWorkspace.getVariable('isPreprocessedModel') == 1
%                 schema.state = 'Disabled';
%             end

            schema.childrenFcns = {...
                @VerificationMenu.verify, ...
                @VerificationMenu.verifyUsing,...
                @ValidationMenu.validate, ...
                @UnsupportedBlocksMenu.checkUnsupportedBlocks, ...
                %@ViewContractMenu.viewContract, ...
                @PropertyGenerationMenu.generateProperty, ...
                @PreprocessingMenu.preprocess,...
                @CocosimWindowMenu.getCompiler, ...
                @PreferencesMenu.getMenu ...
                };
        end
    end
end