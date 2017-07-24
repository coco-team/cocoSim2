function json_model = cocosim_IR( simulink_model_path )

% COCOSIM_IR - create the internal representation of a Simulink model for cocoSim
%
%   This function create a json file of the internal representation of the
%   model, and return the json representation
%   
%   json_model = COCOSIM_IR(model_path)

%% Initialisation
addpath('./blocks');
addpath('./utils');
addpath('../utils');

load_system(simulink_model_path);

%% Construction of the internal representation
ir = struct();
ir.meta.file_path = simulink_model_path;

% launch of the simulation of the model to get the compiled values.
try
    Cmd = [simulink_model_path, '([], [], [], ''compile'');'];
    eval(Cmd);
    ir.meta.sampleTime = Utils.get_BlockDiagram_SampleTime(simulink_model_path);
catch
    warning('Simulation of the model failed. The model doesn''t compile.');
end

[dir, file_name, ~] = fileparts(simulink_model_path);

file_name = strrep(file_name, ' ', '_');
ir.(file_name) = subsystems_struct(file_name);

%% Saving the json ir
json_model = json_encode(ir); %faire en sorte qu'il y ait des sauts de ligne dans la réécriture de la fonction json_encode
% essayer d'enlever le escape des slash si possible pour l'esthétique

% To save the json in a file :
file_json = [file_name '.json'];
% Open or create the file
fid = fopen(file_json, 'w');
% Write in the file
fprintf(fid, '%s\n', json_model);
fclose(fid);
end