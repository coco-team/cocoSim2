%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ Lustre_type, initial_value ] = sT2fT( stateflow_Type, data_name )

    
    if strcmp(stateflow_Type, 'real') || strcmp(stateflow_Type, 'int') || strcmp(stateflow_Type, 'bool')
        Lustre_type = simulink_dt;
    else
        if strcmp(stateflow_Type, 'logical') || strcmp(stateflow_Type, 'boolean')
            Lustre_type = 'bool';
            initial_value = 'false';
        elseif strncmp(stateflow_Type, 'int', 3) || strncmp(stateflow_Type, 'uint', 4) || strncmp(stateflow_Type, 'fixdt(1,16,', 11) || strncmp(stateflow_Type, 'sfix64', 6)
            Lustre_type = 'int';
            initial_value = '0';
        else
            Lustre_type = 'real';
            initial_value = '0.0';
        end
    end
end

