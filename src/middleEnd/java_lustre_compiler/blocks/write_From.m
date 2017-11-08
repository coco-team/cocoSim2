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
function [output_string, var_out] = write_From(unbloc, ir_struct, varargin)

var_out = {};

goto_tag = unbloc.GotoTag;

output_string = '';

[list_out] = list_var_sortie(unbloc);
for idx_dim=1:unbloc.CompiledPortWidths.Outport
    var_name = sprintf('Goto_%s_%s',  goto_tag, num2str(idx_dim));
    output_string = app_sprintf(output_string, '\t%s = %s;\n', list_out{idx_dim}, var_name);
end

end
