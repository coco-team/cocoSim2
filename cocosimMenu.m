
%% Define the custom menu function.
function schemaFcns = cocosimMenu
    schemaFcns = {@getcocoSim};
end

%% Define the custom menu function.
function schema = getcocoSim(callbackInfo)
schema = sl_container_schema;
schema.label = 'CoCoSim';
schema.statustip = 'Automated Analysis Framework';
schema.autoDisableWhen = 'Busy';

modelWorkspace = get_param(callbackInfo.studio.App.blockDiagramHandle,'modelworkspace');
if modelWorkspace.hasVariable('cocomSimMenuDisabled') && ...
        modelWorkspace.getVariable('cocomSimMenuDisabled') == 1
    schema.state = 'Disabled';
end

schema.childrenFcns = {@VerificationMenu.verify, @VerificationMenu.verifyUsing,...
    @ValidationMenu.validate, @UnsupportedBlocksMenu.checkUnsupportedBlocks, ...
    @ViewContractMenu.viewContract, @PropertyGenerationMenu.generateProperty, ...
    @getPP,  @getCompiler, @preferencesMenu};
end




% Function to pre-process and simplify the Simulink model
function schema = getPP(callbackInfo)
schema = sl_action_schema;
schema.label = 'Simplifier';
schema.callback = @ppCallBack;
end

function ppCallBack(callbackInfo)
try
    [prog_path, fname, ext] = fileparts(mfilename('fullpath'));
    addpath(fullfile(prog_path, 'pp'));
    simulink_name = get_file_name(gcs);%gcs;
    pp_model = cocosim_pp(simulink_name);
    load_system(char(pp_model));
catch ME
    display_msg(ME.getReport(),Constants.DEBUG,'getPP','');
    display_msg(ME.message,Constants.ERROR,'getPP','');
end
end

function cocoSimDialog(message)
msg= sprintf('CoCoSpec in: %s', message);
d = dialog('Position',[300 300 250 150],'Name','CoCoSim');

txt = uicontrol('Parent',d,...
    'Style','text',...
    'Position',[20 80 210 40],...
    'String',msg);

btn = uicontrol('Parent',d,...
    'Position',[85 20 70 25],...
    'String','Close',...
    'Callback','delete(gcf)');
end






function schema = getCompiler(callbackInfo)
schema = sl_container_schema;
schema.label = 'Compile (Experimental)';
%schema.userdata = 'two';
schema.childrenFcns = {@getRust, @getC};
end

function schema = getRust(callbackInfo)
schema = sl_action_schema;
schema.label = 'to Rust';
schema.callback = @rustCallback;
end

function rustCallback(callbackInfo)
try
    [prog_path, fname, ext] = fileparts(mfilename('fullpath'));
    assignin('base', 'SOLVER', 'NONE');
    assignin('base', 'RUST_GEN', 1);
    assignin('base', 'C_GEN', 0);
    simulink_name = get_file_name(gcs);%gcs;
    cocoSim(simulink_name);
catch ME
    display_msg(ME.getReport(),Constants.DEBUG,'getRust','');
    disp('run the command in the top level of the model')
end
end

function schema = getC(callbackInfo)
schema = sl_action_schema;
schema.label = 'to C';
schema.callback = @cCallback;
end

function cCallback(callbackInfo)
clear;
assignin('base', 'SOLVER', 'NONE');
assignin('base', 'RUST_GEN', 0);
assignin('base', 'C_GEN', 1);
runCoCoSim;
end

%  function schema = getSeaHorn(callbackInfo)
%   schema = sl_action_schema;
%   schema.label = 'SeaHorn';
%  end

%  function schema = getEldarica(callbackInfo)
%   schema = sl_action_schema;
%   schema.label = 'Eldarica';
%     schema.callback = @eldaricaCallback;
%  end

%   function eldaricaCallback(callbackInfo)
%   try
%       [prog_path, fname, ext] = fileparts(mfilename('fullpath'));
%       fileID = fopen([prog_path filesep 'src' filesep 'config.m'],'a');
%       fprintf(fileID, '\nSOLVER=''E'';\nRUST_GEN=0;\nC_GEN=0;');
%       fclose(fileID);
%       simulink_name = gcs;
%       cocoSim(simulink_name);
%   catch ME
%       disp(ME.getReport())
%   end
%  end


function fname = get_file_name(gcs)
names = regexp(gcs,'/','split');
fname = get_param(names{1},'FileName');
end
