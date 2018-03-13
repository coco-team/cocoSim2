%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sl_customization(cm)
%% Register custom menu function.
cm.addCustomMenuFcn('Simulink:ToolsMenu', @getMyMenuItems);
cm.addCustomMenuFcn('Simulink:PreContextMenu', @getPreContextMenu);
end

function schemaFcns = getPreContextMenu
schemaFcns = {@cocoSimActions};
end

%% Define the custom menu function.
function schema = cocoSimActions(callbackInfo)
schema = sl_container_schema;
schema.label = 'CoCoSim';
schema.statustip = 'CoCoSim';
schema.autoDisableWhen = 'Busy';

schema.childrenFcns = {@compositionalOptions, @signalBuilders};
end

function schema = compositionalOptions(callbackInfo)
    schema = sl_container_schema;
    schema.label = 'Compositional Abstract';
    schema.statustip = 'Compositional Abstract';
    schema.autoDisableWhen = 'Busy';
    % get the compositional options from the model workspace
    modelWorkspace = get_param(callbackInfo.studio.App.blockDiagramHandle,'modelworkspace');   
    compositionalMap = modelWorkspace.getVariable('compositionalMap');    
    
    % add a menu item for each option
    index = 1;
    for i = 1: length(compositionalMap.analysisNames)        
        schema.childrenFcns{index} = {@compositionalKey, compositionalMap.analysisNames{i}};
        index = index + 1;
        for j=1: length(compositionalMap.compositionalOptions{i})
            data.label = compositionalMap.compositionalOptions{i}{j};
            data.selectedOption = compositionalMap.selectedOptions(i);
            data.currentOption = j;
            data.currentAnalysis = i;
            schema.childrenFcns{index} = {@compositionalOption, data};
            index = index + 1;
        end
        schema.childrenFcns{index} = 'separator';
        index = index + 1;
    end    
end

function schema = compositionalKey(callbackInfo)
    schema = sl_action_schema;
    label = callbackInfo.userdata;    
    schema.label = label;      
    schema.state = 'Disabled';    
end

function schema = compositionalOption(callbackInfo)
    schema = sl_toggle_schema;
    data = callbackInfo.userdata;    
    if length(data.label) == 0
        schema.label = 'No abstract';
    else
        schema.label = data.label;
    end          
    if data.selectedOption == data.currentOption
        schema.checked = 'checked';    
    else
        schema.checked = 'unchecked';    
    end
    
    schema.callback = @compositionalOptionCallback;
    schema.userdata = data;
    
end

function compositionalOptionCallback(callbackInfo)    
    data = callbackInfo.userdata;    
    modelWorkspace = get_param(callbackInfo.studio.App.blockDiagramHandle,'modelworkspace');   
    verificationResults = modelWorkspace.getVariable('verificationResults');
    compositionalMap = modelWorkspace.getVariable('compositionalMap');    
    compositionalMap.selectedOptions(data.currentAnalysis) = data.currentOption; 
    assignin(modelWorkspace,'compositionalMap',compositionalMap);
    displayVerificationResults(verificationResults, compositionalMap);
end

function schema = signalBuilders(callbackInfo)
schema = sl_action_schema;
schema.label = 'Replace inports with signal builders';
schema.callback = @replaceInportsWithSignalBuilders;
end

function replaceInportsWithSignalBuilders(callbackInfo)
    modelName = get_param(gcs, 'Name');
       
    blocks = find_system(gcs, 'SearchDepth',1,'BlockType','Inport');
    time = [0:10];
    values  = zeros(1, 11);
    
    % get the signal types of inports
    compileCommand = strcat(modelName, '([],[],[],''compile'')');
    eval (compileCommand);     
    for i = 1 : length(blocks)
        compiledPortDataTypes = get_param(blocks(i),'CompiledPortDataTypes');
        signalTypes(i) = compiledPortDataTypes{1}.Outport;  
    end        
    terminateCommand = strcat(modelName, '([],[],[],''term'')');
    eval (terminateCommand);   
    
    for i = 1 : length(blocks)
        portHandle = get_param(blocks(i),'PortHandles');
        portHandle = portHandle{1,1}.Outport;       
        line = get_param(portHandle,'Line');
        destinationPorts = get_param(line, 'Dstporthandle');

        % delete old lines
        for j=1: length(destinationPorts)
            delete_line(gcs, portHandle, destinationPorts(j));        
        end

        position = get_param(blocks(i),'Position');
        position = position{1,1};

        [path name] = fileparts(char(blocks(i)));

        % remove the inport block
        delete_block(blocks(i));

        % add Data type conversion block if the signal type is not double
        if ~strcmp(signalTypes(i), 'double')
            convertBlockName = strcat(modelName, '/', name, '_convert_to_', signalTypes(i));
            convertBlock = add_block('Simulink/Signal Attributes/Data Type Conversion',char(convertBlockName));        
            set_param(convertBlock, 'Position', position);
            set_param(convertBlock, 'OutDataTypeStr', char(signalTypes(i)));
            portHandle = get_param(convertBlock,'PortHandles');
            x_shift = 100;
            position = [position(1)-x_shift position(2) position(3)-x_shift position(4)];        
            signalBuilderBlock = signalbuilder(char(blocks(i)), 'create', time, {values},name, name,1,position,{0 0});
            signalBuilderPorts = get_param(signalBuilderBlock,'PortHandles');
            add_line(modelName, signalBuilderPorts.Outport, portHandle.Inport,'autorouting','on');               
        else
            signalBuilderBlock = signalbuilder(char(blocks(i)), 'create', time, {inputs(1,i).values'},name, name,1,position,{0 0});
            portHandle = get_param(signalBuilderBlock,'PortHandles');
        end

        portHandle = portHandle.Outport;

        % add new lines
        for j=1: length(destinationPorts)
            add_line(modelName, portHandle, destinationPorts(j),'autorouting','on');
        end    
    end
end

%% Define the custom menu function.
function schemaFcns = getMyMenuItems
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

schema.childrenFcns = {@verify, @getVerify,@getValidate,...
    @getCheckBlocks, @viewContract, @getProps, ...
    @getPP,  @getCompiler, @getPreferences};
end

function schema = verify(callbackInfo)
    schema = sl_action_schema;
    schema.label = 'Verify';
    if evalin( 'base', '~exist(''MODEL_CHECKER'',''var'')' ) == 1 || ...
                strcmp(evalin( 'base', 'MODEL_CHECKER' ) ,'Kind2')
        schema.callback = @kindCallback;
    else
        if strcmp(evalin( 'base', 'MODEL_CHECKER' ) ,'JKind')
            schema.callback = @jkindCallback;
        end
    end
end

function schema = getCheckBlocks(callbackInfo)
schema = sl_action_schema;
schema.label = 'Check unsupported blocks';
schema.callback = @checkBlocksCallBack;
end

function checkBlocksCallBack(callbackInfo)
try
    model_full_path = get_file_name(gcs);
    unsupported_blocks_gui( model_full_path );
catch ME
    display_msg(ME.message,Constants.ERROR,'getCheckBlocks','');
    display_msg(ME.getReport(),Constants.DEBUG,'getCheckBlocks','');
end
end

function schema = getValidate(callbackInfo)
schema = sl_action_schema;
schema.label = 'Compiler Validation (Experimental)';
schema.callback = @validateCallBack;
end

function validateCallBack(callbackInfo)
try
    [cocoSim_path, ~, ~] = fileparts(mfilename('fullpath'));
    model_full_path = get_file_name(gcs) ;
    L = log4m.getLogger(fullfile(fileparts(model_full_path),'logfile.txt'));
    validate_window(model_full_path,cocoSim_path,1,L);
catch ME
    display_msg(ME.getReport(), Constants.DEBUG,'Validate_model','');
    display_msg(ME.message, Constants.ERROR,'Validate_model','');
end
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

function schema = viewContract(callbackInfo)
schema = sl_action_schema;
schema.label = 'View generated CoCoSpec (Experimental)';
schema.callback = @viewContractCallback;
end

function viewContractCallback(callbackInfo)
model_full_path = get_file_name(gcs);
simulink_name = gcs;
contract_name = [simulink_name '_COCOSPEC'];
emf_name = [simulink_name '_EMF'];
try
    CONTRACT = evalin('base', contract_name);
    EMF = evalin('base', emf_name);
    disp(['CONTRACT LOCATION ' char(CONTRACT)])
    
    
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

function schema = getProps(callbackInfo)
schema = sl_action_schema;
schema.label = 'Create Property';
schema.callback = @synchObsCallback;
end

function synchObsCallback(callbackInfo)
try
    [prog_path, fname, ext] = fileparts(mfilename('fullpath'));
    simulink_name = get_file_name(gcs);
    add_property(simulink_name);
catch ME
    display_msg(ME.getReport(),Constants.DEBUG,'getProps','');
end
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

%% Run cocoSim

function schema = getVerify(callbackInfo)
schema = sl_container_schema;
schema.label = 'Verify using ...';
schema.statustip = 'Verify the current model with CoCoSim';
schema.autoDisableWhen = 'Busy';

schema.childrenFcns = {@getZustre, @getKind, @getJKind};
end


function schema = getZustre(callbackInfo)
schema = sl_action_schema;
schema.label = 'Zustre';
schema.callback = @zustreCallback;
end

function zustreCallback(callbackInfo)
clear;
assignin('base', 'SOLVER', 'Z');
assignin('base', 'RUST_GEN', 0);
assignin('base', 'C_GEN', 0);
runCoCoSim;
end


function schema = getKind(callbackInfo)
schema = sl_action_schema;
schema.label = 'Kind2';
schema.callback = @kindCallback;
end

function kindCallback(callbackInfo)
clear;
[prog_path, fname, ext] = fileparts(mfilename('fullpath'));
assignin('base', 'SOLVER', 'K');
assignin('base', 'RUST_GEN', 0);
assignin('base', 'C_GEN', 0);
runCoCoSim;
end

function schema = getJKind(callbackInfo)
schema = sl_action_schema;
schema.label = 'JKind';
schema.callback = @jkindCallback;
end

function jkindCallback(callbackInfo)
clear;
[prog_path, fname, ext] = fileparts(mfilename('fullpath'));
assignin('base', 'SOLVER', 'J');
assignin('base', 'RUST_GEN', 0);
assignin('base', 'C_GEN', 0);
runCoCoSim;
end

function runCoCoSim
[path, name, ext] = fileparts(mfilename('fullpath'));
addpath(fullfile(path, 'utils'));
try
    simulink_name = get_file_name(gcs);
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


function schema = getPreferences(callbackInfo)
    schema = sl_container_schema;
    schema.label = 'Preferences';
    schema.statustip = 'Preferences';
    schema.autoDisableWhen = 'Busy';    
    
    CoCoSimPreferences = loadCoCoSimPreferences();
    
    schema.childrenFcns = {{@getModelChecker,CoCoSimPreferences}, ...
        {@getMiddleEnd,CoCoSimPreferences}, ...
        {@getCompositionalAnalysis, CoCoSimPreferences}, ...
        {@getKind2Binary, CoCoSimPreferences}};
end

function schema = getModelChecker(callbackInfo)
    schema = sl_container_schema;
    schema.label = 'Model checker';
    schema.statustip = 'Model checker';
    schema.autoDisableWhen = 'Busy';
    CoCoSimPreferences = callbackInfo.userdata;
    schema.childrenFcns = { ...
        {@getKindOption, CoCoSimPreferences} , ... 
         {@getJKindOption, CoCoSimPreferences}};
end

function schema = getKindOption(callbackInfo)
    schema = sl_toggle_schema;
    schema.label = 'Kind2';    
    CoCoSimPreferences = callbackInfo.userdata;
    
    if strcmp(CoCoSimPreferences.modelChecker, 'Kind2')
        schema.checked = 'checked';
    else
        schema.checked = 'unchecked';
    end    
    schema.callback = @setKindOption;
    schema.userdata = CoCoSimPreferences;
end

function setKindOption(callbackInfo)    
    CoCoSimPreferences = callbackInfo.userdata;
    CoCoSimPreferences.modelChecker = 'Kind2';
    saveCoCoSimPreferences(CoCoSimPreferences);
end

function schema = getJKindOption(callbackInfo)
    schema = sl_toggle_schema;
    schema.label = 'JKind';    
    
    CoCoSimPreferences = callbackInfo.userdata;
    
    if strcmp(CoCoSimPreferences.modelChecker, 'JKind')
        schema.checked = 'checked';
    else
        schema.checked = 'unchecked';
    end
    
    schema.callback = @setJKindOption;
    schema.userdata = CoCoSimPreferences;
end

function setJKindOption(callbackInfo)    
    CoCoSimPreferences = callbackInfo.userdata;
    CoCoSimPreferences.modelChecker = 'JKind';
    saveCoCoSimPreferences(CoCoSimPreferences);
end


function schema = getMiddleEnd(callbackInfo)
    schema = sl_toggle_schema;
    schema.label = 'Use java to lustre Compiler';       
    
    CoCoSimPreferences = callbackInfo.userdata;
    
    if CoCoSimPreferences.javaToLustreCompiler
        schema.checked = 'checked';
    else
        schema.checked = 'unchecked';
    end    
    
    schema.callback = @javaToLustreCompilerCallback;    
    schema.userdata = CoCoSimPreferences;
    
end


function javaToLustreCompilerCallback(callbackInfo)
    CoCoSimPreferences = callbackInfo.userdata;
    CoCoSimPreferences.javaToLustreCompiler = ~ CoCoSimPreferences.javaToLustreCompiler;
    
    [cocosim_path, ~, ~] = fileparts(mfilename('fullpath'));        
    if CoCoSimPreferences.javaToLustreCompiler
        % select the middle end lustre compiler        
        javaaddpath(fullfile(cocosim_path,'tools','CocoSim_IR_Compiler-0.1-jar-with-dependencies.jar'));    
        addpath(genpath(fullfile(cocosim_path, 'src', 'middleEnd', 'java_lustre_compiler')));    
        rmpath(genpath(fullfile(cocosim_path, 'src', 'middleEnd', 'lustre_compiler')));    
        
        addpath(genpath(fullfile(cocosim_path, 'src', 'backEnd', 'verification', 'cocoSpecVerify')));    
        rmpath(genpath(fullfile(cocosim_path, 'src', 'backEnd', 'verification', 'lustreVerify')));    
    else        
        addpath(genpath(fullfile(cocosim_path, 'src', 'middleEnd', 'lustre_compiler')));
        rmpath(genpath(fullfile(cocosim_path, 'src', 'middleEnd', 'java_lustre_compiler')));    
        
        addpath(genpath(fullfile(cocosim_path, 'src', 'backEnd', 'verification', 'lustreVerify')));    
        rmpath(genpath(fullfile(cocosim_path, 'src', 'backEnd', 'verification', 'cocoSpecVerify')));           
    end
    saveCoCoSimPreferences(CoCoSimPreferences);
end

function schema = getCompositionalAnalysis(callbackInfo)
    schema = sl_toggle_schema;
    schema.label = 'Compositional Analysis';    
    
    CoCoSimPreferences = callbackInfo.userdata;
    if CoCoSimPreferences.compositionalAnalysis
        schema.checked = 'checked';
    else
        schema.checked = 'unchecked';
    end
    
    schema.callback = @compositionalAnalysis;    
    schema.userdata = CoCoSimPreferences;
end

function compositionalAnalysis(callbackInfo)
    CoCoSimPreferences = callbackInfo.userdata;
    CoCoSimPreferences.compositionalAnalysis = ~ CoCoSimPreferences.compositionalAnalysis;        
    saveCoCoSimPreferences(CoCoSimPreferences);
end

function schema = getKind2Binary(callbackInfo)
    schema = sl_container_schema;
    schema.label = 'Kind2 binary';        
    schema.statustip = 'Kind2 binary';
    schema.autoDisableWhen = 'Busy';    
    
    CoCoSimPreferences = callbackInfo.userdata;
    
    schema.childrenFcns = {{@kind2BinaryLocal,CoCoSimPreferences}, ...       
        {@kind2BinaryDocker, CoCoSimPreferences}, ...
        {@kind2BinaryWebService, CoCoSimPreferences}};
end

function schema = kind2BinaryLocal(callbackInfo)
    schema = sl_toggle_schema;
    schema.label = 'Local';    
    
    CoCoSimPreferences = callbackInfo.userdata;
    if strcmp(CoCoSimPreferences.kind2Binary, 'Local')
        schema.checked = 'checked';
    else
        schema.checked = 'unchecked';
    end
    
    schema.callback = @kind2BinaryLocalCallback;    
    schema.userdata = CoCoSimPreferences;
end

function kind2BinaryLocalCallback(callbackInfo)
    CoCoSimPreferences = callbackInfo.userdata;
    CoCoSimPreferences.kind2Binary = 'Local';        
    saveCoCoSimPreferences(CoCoSimPreferences);
end

function schema = kind2BinaryDocker(callbackInfo)
    schema = sl_toggle_schema;
    schema.label = 'Docker';    
    
    CoCoSimPreferences = callbackInfo.userdata;
    if strcmp(CoCoSimPreferences.kind2Binary, 'Docker')
        schema.checked = 'checked';
    else
        schema.checked = 'unchecked';
    end
    
    schema.callback = @kind2BinaryDockerCallback;    
    schema.userdata = CoCoSimPreferences;
end

function kind2BinaryDockerCallback(callbackInfo)
    CoCoSimPreferences = callbackInfo.userdata;
    CoCoSimPreferences.kind2Binary = 'Docker';        
    saveCoCoSimPreferences(CoCoSimPreferences);
end

function schema = kind2BinaryWebService(callbackInfo)
    schema = sl_toggle_schema;
    schema.label = 'Kind2 web service';    
    
    CoCoSimPreferences = callbackInfo.userdata;
    if strcmp(CoCoSimPreferences.kind2Binary, 'Kind2 web service')
        schema.checked = 'checked';
    else
        schema.checked = 'unchecked';
    end
    
    schema.callback = @kind2BinaryWebServiceCallback;    
    schema.userdata = CoCoSimPreferences;
end

function kind2BinaryWebServiceCallback(callbackInfo)
    CoCoSimPreferences = callbackInfo.userdata;
    CoCoSimPreferences.kind2Binary = 'Kind2 web service';        
    saveCoCoSimPreferences(CoCoSimPreferences);
end

function saveCoCoSimPreferences(CoCoSimPreferences)
    [cocosim_path, ~, ~] = fileparts(mfilename('fullpath'));
    preferencesFile = fullfile(cocosim_path, 'libs', 'preferences.mat');
    save(preferencesFile, 'CoCoSimPreferences');
end