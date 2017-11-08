%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Goto/From blocks
%
% Same backend file for both Goto and From blocks. Goto/From blocks are
% identified by their unique goto_tag parameter.
% For the Goto block, generates a new variable for each element of the
% Input of the Goto block. For the From block, set eh output of the block
% to the values of the corresponding Goto block.
%
%% Generation scheme
% We take the example of a vector signal of 3 elements with goto_tag = 'A'
%
%%% Goto
%
%  Goto_A_1 = Input_1_1;
%  Goto_A_2 = Input_1_2;
%  Goto_A_3 = Input_1_3;
%
%%% From
%
%  Output_1_1 = Goto_A_1;
%  Output_1_2 = Goto_A_2;
%  Output_1_3 = Goto_A_3;
%
%% Code
%
function [output_string, var_out] = write_Goto(block, ir_struct, varargin)

goto_tag = block.GotoTag;

output_string = '';
add_vars = '';

[list_in] = list_var_entree(block, ir_struct);
add_vars = '\t';
in_dt = LusUtils.get_lustre_dt(block.CompiledPortDataTypes.Inport(1));
for idx_dim=1:block.CompiledPortWidths.Inport
    var_name = sprintf('Goto_%s_%s',  goto_tag, num2str(idx_dim));
    output_string = app_sprintf(output_string, '\t%s = %s;\n', var_name, list_in{idx_dim});
    add_vars = [add_vars var_name];
    if idx_dim == block.CompiledPortWidths.Inport
        add_vars = [add_vars ': ' in_dt ';\n'];
    else
        add_vars = [add_vars ', '];
    end
    
    % Add traceability for additional variables
    varargin{1}.add_Variable(var_name, block.Origin_path, 1, idx_dim, true);
end

var_out{1} = 'additional_variables';
var_out{2} = add_vars;
end
