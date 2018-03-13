%% The map contains BlockTypes or MaskTypes associate with the function's name you want to call
% If you don't want the basic write of a certain blocks, you can whether
% change its code, or add your new function into lustre_ME/blocks/. If you
% add a new function don't forget to specify it in this map.

%% You must respect the Inputs and Outputs
% Here is the signature your function must always have :
% [string_output, varargout] = write_X(block, ir_struct, varargin);
% here is how the function is called :
% [string_output, varargout] = write_X(block, ir_struct, xml_trace).
% So be aware that varargin{1} is xml_trace. You can add more inputs if you
% want but don't delete them.
% varargout is organized as follow :
% varargout{i} = 'Name'
% varargout{i+1} = Value
% Here is the actual Name in varargout that are treated :
% 'extern_functions', 'additional_variables', 'extern_s_functions',
% 'extern_math_functions', 'c_code'. If you add others, you must add as
% well their treatments in the code.

%% Example : if you want to add the function my_function_name for the Sum
% BlockType :
% write_func_map('Sum') = 'my_function_name';

global write_func_map;

write_func_map = containers.Map();

%% Add new functions here
% write_func_map('BlockType or MaskType or SFBlockType') = 'your_function_path/name'
