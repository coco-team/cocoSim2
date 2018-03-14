%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function start_cocosim() 
warning ('off','all');
[cocoSim_path, function_name, ext] = fileparts(mfilename('fullpath'));
disp('--------------------------')
disp('    WELCOME TO COCOSIM    ')
disp('--------------------------')
disp('... adding cocoSim path')
addpath(genpath(fullfile(cocoSim_path, 'src')));
%TODO: clean 'addpath' mess-up
addpath(fullfile(cocoSim_path, 'libs'));
addpath(fullfile(cocoSim_path, 'src','gui'));
addpath(fullfile(cocoSim_path, 'src','utils'));
cocosim_config;
rmpath(genpath(fullfile(cocoSim_path, 'src', 'middleEnd')));
addpath(genpath(LUSTRE_COMPILER_DIR));
PWD = pwd;
cd(fullfile(cocoSim_path, 'src', 'frontEnd', 'IR', 'utils'));
make;
cd(PWD);

if strcmp(ZUSTRE, 'PATH')
    disp('Warning: Path to Zustre is NOT configured in src/config.m')
end
if strcmp(LUSTREC, 'PATH')
    disp('Warning: Path to LUSTREC is NOT configured in src/config.m')
end
if strcmp(Z3, 'PATH')
    disp('Warning: Path to Z3 is NOT configured in src/config.m')
end
if strcmp(KIND2, 'PATH')
    disp('Warning: Path to KIND2 is NOT configured in src/config.m')
end
if strcmp(JKIND, 'PATH')
    disp('Warning: Path to JKIND is Not configured in src/config/m')
end

disp('... refreshing customizations')
addpath(fullfile(cocoSim_path, '.'));
sl_refresh_customizations;
disp('... CoCoSim is Ready');
example_model = fullfile(cocoSim_path, 'test', 'properties', 'safe_1.mdl');
e_message = sprintf('\n\t Click <a href="matlab: open %s">here</a> to start with a simple verification example.', example_model);
disp('--------------------------')
disp(e_message);
clear;
end
