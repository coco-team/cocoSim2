function json_model = cocosim_IR( simulink_model_path )

% create the internal representation of a Simulink model for cocoSim

addpath('./blocks');
addpath('./utils');

ir = struct();
ir.meta.file_path = simulink_model_path;
load_system(simulink_model_path);
% lancement de la simulation pour les vrai types
Model1([],[],[],'compile');

[dir, file_name, ~] = fileparts(simulink_model_path);
ir.(file_name) = ports_and_subsystems_struct(file_name);

json_model = json_encode(ir); %faire en sorte qu'il y ait des sauts de ligne dans la réécriture de la fonction json_encode
% essayer d'enlever le escape des slash si possible pour l'esthétique

%To save the json in a file :
file_json = [file_name '.json'];
%Open or create the file
fid = fopen(file_json, 'w');
%Write in the file
fprintf(fid, '%s\n', json_model);
fclose(fid);
end