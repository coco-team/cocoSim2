%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of cocoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Main file for CoCoSim

function [nom_lustre_file, sf2lus_Time, ir_struct]= ... 
    cocoSpecCompiler(model_full_path)
bdclose('all');
open(model_full_path);

if nargin < 1
    display_help_message();
    return
end

Utils.update_status('Configuration');
% Get start time
t_start = now;
sf2lus_start = tic;
% Retrieving of the path containing the cocoSim file
[cocoSim_path, ~, ~] = fileparts(mfilename('fullpath'));
% Retrieving of the path containing the model for which we generate the code
[model_path, file_name, ~] = fileparts(model_full_path);

%ToDo: folder doesn't exist addpath(genpath(fullfile(cocoSim_path, 'backEnd')));
addpath(genpath(fullfile(cocoSim_path, 'frontEnd')));
%ToDo: folder doesn't exist addpath(fullfile(cocoSim_path, 'utils'));
addpath(fullfile(cocoSim_path, '.'));

addpath(cocoSim_path);
cocosim_config;
try
    SOLVER = evalin('base','SOLVER');   
catch
    SOLVER = 'NONE';    
end

config_msg = 'CoCoSim Configuration, Change this configuration in src/config.m\n';
config_msg = [config_msg '--------------------------------------------------\n'];
config_msg = [config_msg '|  SOLVER: ' SOLVER '\n'];
config_msg = [config_msg '|  KIND2:  ' KIND2 '\n'];
config_msg = [config_msg '|  Z3: ' Z3 '\n'];
config_msg = [config_msg '--------------------------------------------------\n'];
display_msg(config_msg, Constants.INFO, 'cocoSim', '');

Utils.update_status('Loading model');
msg = ['Loading model: ' model_full_path];
display_msg(msg, Constants.INFO, 'cocoSim', '');

% add path the model directory
addpath(model_path);

load_system(char(model_full_path));

% Pre-process model
Utils.update_status('Pre-processing');
display_msg('Pre-processing', Constants.INFO, 'cocoSim', '');
new_file_name = cocosim_pp(model_full_path);

if ~strcmp(new_file_name, '')
    model_full_path = new_file_name;
    [model_path, file_name, ~] = fileparts(model_full_path);
    open(model_full_path);
end

% Definition of the output files names
output_dir = fullfile(model_path, strcat('lustre_files/src_', file_name));
nom_lustre_file = fullfile(output_dir, strcat(file_name, '.lus'));
mkdir(output_dir);

Utils.update_status('Building internal format');

display_msg('Building internal format', Constants.INFO, 'cocoSim', '');

%%%%%% Internal representation building %%%%%%
[ir_struct, all_blks, subs_blks_list] = cocosim_IR(file_name, 1, output_dir);

%%%%%%%%%%%%%%% Retrieving nodes code %%%%%%%%%%%%%%%
Utils.update_status('Lustre generation');
display_msg('Lustre generation', Constants.INFO, 'cocoSim', '');

%%%%%%%%%%%%%%%%%%
javaaddpath(fullfile('src','backEnd','verification','cocoSpecVerify','utils','CocoSim_IR_Compiler-0.1-jar-with-dependencies.jar'));    
json_file=fullfile(output_dir, strcat(file_name, '_IR.json'));
j2l_trans=edu.uiowa.json2lus.J2LTranslator(json_file);
ppv=edu.uiowa.json2lus.lustreAst.LustrePrettyPrinter();
ppv.printLustreProgramToFile(j2l_trans.execute(), nom_lustre_file);

%output the mapping
mapping_file = strrep(nom_lustre_file,'.lus','_mapping.json');
j2l_trans.dumpMappingInfoToJsonFile(mapping_file);

%%%%%%%%%%%%%%%%%%

display_msg('End of code generation', Constants.INFO, 'cocoSim', '');

sf2lus_Time = toc(sf2lus_start);
msg = sprintf(' %s', nom_lustre_file);
display_msg(msg, Constants.RESULT, 'Lustre Code', '');

%%%%%%%%%%%% Cleaning and end of operations %%%%%%%%%%


t_end = now;
t_compute = t_end - t_start;
display_msg(['Total compile time: ' datestr(t_compute, 'HH:MM:SS.FFF')], Constants.RESULT, 'Time', '');
Utils.update_status('Done');
end

function display_help_message()
msg =  ' -----------------------------------------------------  \n';
msg = [msg '  CoCoSim: Automated Analysis Framework for Simulink/Stateflow\n'];
msg = [msg '   \n Usage:\n'];
msg = [msg '    >> cocoSim(MODEL_PATH\n'];
msg = [msg '\n'];
msg = [msg '      MODEL_PATH: a string containing the path to the model\n'];
msg = [msg '        e.g. ''cocoSim test/properties/property_2_test.mdl\''\n'];
msg = [msg  '  -----------------------------------------------------  \n'];
cprintf('blue', msg);
end
