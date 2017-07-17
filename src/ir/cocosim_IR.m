function json_model = cocosim_IR( simulink_model_path )

% create the internal representation of a Simulink model for cocoSim
addpath('./blocks');
addpath('./utils');

ir = struct();
ir.meta.file_path = simulink_model_path;
load_system(simulink_model_path);

[dir, file_name, ext] = fileparts(simulink_model_path);
ir.file_name = ports_and_subsystems_struct(file_name);

json_model = json_encode(ir);

end