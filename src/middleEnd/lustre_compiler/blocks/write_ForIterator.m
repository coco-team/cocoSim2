%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ForIterator block
%
% ForIterator block provides the value for the iterator at the Iteration
% step. This value is used only if the show_iter_port parameter is set to
% 'on', nothing is generated in the other case.
% The next iteration value can either be provided by an internal rule or provided from an
% external source.
%
%% Generation scheme
%
%%% Iteration value provided by iteration rule.
% In this case, the iteration value is provided as an input of the enclosing subsystem.
%
%  Output_1_1 = iter_variable;
%
%%% Iteration value provided from an external source.
% The init value depends on the index_mode parameter (one-based or zero-based).
%
%  Output_1_1 = init -> pre(Input_1_1);
%
%% Code
%
function [output_string, var_out] = write_ForIterator(block, ir_struct, varargin)

var_out = {};

iter_source = block.IterationSource;
if strcmp(iter_source, 'external')
    error_msg = 'ForIterator block implementation does not support external iteration limit\n';
    error_msg = [error_msg block.Origin_path];
    display_msg(error_msg, Constants.ERROR, 'write_code', '');
end
ext_incr = block.ExternalIncrement;
show_iter_port = block.ShowIterationPort;
index_mode = block.IndexMode;
iter_dt = block.IterationVariableDataType;

output_string = '';

% Only retrieve the variables names if necessary
if strcmp(show_iter_port, 'on')
    [list_out] = list_var_sortie(block);
    iter_dt = LusUtils.get_lustre_dt(iter_dt);
    if strcmp(index_mode, 'One-based')
        if strcmp(iter_dt, 'int')
            state = '1';
        else
            state = '1.0';
        end
    else
        if strcmp(iter_dt, 'int')
            state = '0';
        else
            state = '0.0';
        end
    end
    
    if strcmp(ext_incr, 'on')
        [list_in] = list_var_entree(block, ir_struct);
        for idx=1:numel(list_out)
            output_string = app_sprintf(output_string, '\t%s = %s -> pre(%s);\n', list_out{idx}, state, list_in{idx});
        end
    else
        [res var_iter] = LusUtils.needs_for_iter_var(ir_struct, get_subsystem_struct(ir_struct, block));
        for idx=1:numel(list_out)
            output_string = app_sprintf(output_string, '\t%s = %s;\n', list_out{idx}, var_iter);
        end
    end
end

end

