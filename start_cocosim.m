%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
% Copyright (C) 2018  The university of Iowa
% Authors: Temesghen Kahsai, Christelle Dambreville, Hamza Bourbouh, Daniel Larraz ,  Mudathir Mahgoub
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function start_cocosim() 
warning ('off','all');
[cocoSim_path, function_name, ext] = fileparts(mfilename('fullpath'));
disp('--------------------------')
disp('    WELCOME TO COCOSIM    ')
disp('--------------------------')
disp('... adding cocoSim path')
addpath(genpath(fullfile(cocoSim_path, 'src')));
addpath(genpath(fullfile(cocoSim_path, 'examples')));
%TODO: clean 'addpath' mess-up
addpath(genpath(fullfile(cocoSim_path, 'libs')));

cocosim_config;


ir_utils_path = fullfile(cocoSim_path, 'src', 'frontEnd', 'IR', 'utils');

json_encode_file = 'json_encode';
json_decode_file = 'json_decode';

if ismac
    json_encode_file = fullfile(ir_utils_path, 'json_encode.mexmaci64');
    json_decode_file = fullfile(ir_utils_path, 'json_decode.mexmaci64');
elseif isunix
    json_encode_file = fullfile(ir_utils_path, 'json_encode.mexa64');
    json_decode_file = fullfile(ir_utils_path, 'json_decode.mexa64');
elseif ispc
    json_encode_file = fullfile(ir_utils_path, 'json_encode.mexw64');
    json_decode_file = fullfile(ir_utils_path, 'json_decode.mexw64');
end

if ~ exist(json_encode_file, 'file') || ~ exist(json_decode_file, 'file')
    PWD = pwd;
    cd(fullfile(cocoSim_path, 'src', 'frontEnd', 'IR', 'utils'));
    make;
    cd(PWD);
end
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
example_model = fullfile(cocoSim_path, 'examples', 'contract', 'absolute.slx');
e_message = sprintf('\n\t Click <a href="matlab: open %s">here</a> to start with a simple verification example.', example_model);
disp('--------------------------')
disp(e_message);
clear;
end
