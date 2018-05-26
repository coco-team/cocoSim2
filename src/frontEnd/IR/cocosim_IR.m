%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
% Copyright (C) 2018  The university of Iowa
% Authors: Hamza Bourbouh, Mudathir Mahgoub
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ir_struct, all_blocks, subsyst_blocks, ir_handle_struct_map] = cocosim_IR( simulink_model_path, df_export, output_dir )

% COCOSIM_IR - create the internal representation of a Simulink model for cocoSim
%
%   This function create a json file of the internal representation of the
%   model, and return the json representation
%   
%   json_model = COCOSIM_IR(model_path)
%   json_model = COCOSIM_IR(model_path, df_export) if you want to export
%   the json in a file

%% Initialisation
[ir_path, ~, ~] = fileparts(mfilename('fullpath'));
addpath(fullfile(ir_path, 'blocks'));
addpath(fullfile(ir_path, 'utils'));

if nargin < 2
    df_export = false;
end

load_system(simulink_model_path);

%% Construction of the internal representation
ir_struct = struct();
ir_struct.meta.file_path = simulink_model_path;

% launch of the simulation of the model to get the compiled values.
[parent, file_name, ~] = fileparts(simulink_model_path);
try
    Cmd = [file_name, '([], [], [], ''compile'');'];
    eval(Cmd);
    ir_struct.meta.sampleTime = IRUtils.get_BlockDiagram_SampleTime(file_name);
catch
    warning('Simulation of the model failed. The model doesn''t compile.');
end

ir_struct.meta.date = datestr(datetime('today'));


file_name_modif = IRUtils.name_format(file_name);
[ir_struct.(file_name_modif).Content, all_blocks, subsyst_blocks, ir_handle_struct_map] = subsystems_struct(file_name);

%% Stop the simulation
try
    Cmd = [file_name, '([], [], [], ''term'');'];
    eval(Cmd);
catch
    %do nothing
end


%% Saving the json ir
json_model = json_encode(ir_struct); %faire en sorte qu'il y ait des sauts de ligne dans la réécriture de la fonction json_encode
json_model = strrep(json_model,'\/','/');
json_model = strrep(json_model,'"X0"','"InitialCondition"');
% essayer d'enlever le escape des slash si possible pour l'esthétique

% To save the json in a file :
if nargin < 3
    output_dir = parent;
end
if df_export
    file_json = [file_name '_IR.json'];
    % Open or create the file
    file_path = fullfile(output_dir, file_json);
    fid = fopen(file_path, 'w');
    % Write in the file
    fprintf(fid, '%s\n', json_model);
    fclose(fid);
% The code below doesn't work in windows
%     new_path = fullfile(output_dir, [file_name '_IR.json']);
%     cmd = ['cat ' file_path ' | python -mjson.tool > ' new_path];
%     try
% 
%         [status, output] = system(cmd);
%         if status==0
%             system(['rm ' file_path]);
%         end
%     catch
%     end
end
end
