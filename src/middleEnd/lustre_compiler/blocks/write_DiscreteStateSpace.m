%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% DiscreteStateSpace block
%
% Computes the calculation described in the block documentation in
% http://www.mathworks.com/help/simulink/slref/discretestatespace.html
%
% The block computes:
%
%  x(n+1) = A*x(n) + B*u(n)
%  y(n) = C*x(n) + D*u(n)
%
% Where u is the input and y is the output.
%
%% Generation scheme
% The value for x(n+1) is calculated in temporary variables and then the value
% for the output (y) is calculated based on these values.
%%%
%
%  BlockName_tmp_1 = calculation for x(n+1);
%  Output_1_1 = calculation for y(n);
%
%% Code
%
function [output_string, var_out] = write_DiscreteStateSpace(block, ir_struct, varargin)

dss_A = LusUtils.getParamValue(ir_struct, block, block.A);
dss_B = LusUtils.getParamValue(ir_struct, block, block.B);
dss_C = LusUtils.getParamValue(ir_struct, block, block.C);
dss_D = LusUtils.getParamValue(ir_struct, block, block.D);
X0 = LusUtils.getParamValue(ir_struct, block, block.X0);

output_string = '';
add_vars = '';

[list_out] = list_var_sortie(block);
[list_in] = list_var_entree(block, ir_struct);

block_full_name = regexp(block.Path, '/', 'split');
block_name = Utils.concat_delim(block_full_name(end - block.name_level : end), '_');
tmp_var_prefix = [block_name '_tmp_'];

nstate = length(dss_A);
[noutput ninput] = size(dss_D);

% Intermediate variables for the I/O calculus
for k1=1:nstate-1
    add_vars = app_sprintf(add_vars, '\t%s%s , ', tmp_var_prefix, num2str(k1));
    
    % Add traceability for additional variables
    varargin{1}.add_Variable(sprintf('%s%s', tmp_var_prefix, num2str(k1)), block.Origin_path, 1, k1, true);
end
if nstate > 0
    add_vars = app_sprintf(add_vars, '\t%s%s : real;\n', tmp_var_prefix, num2str(nstate));
    
    % Add traceability for additional variables
    varargin{1}.add_Variable(sprintf('%s%s', tmp_var_prefix, num2str(nstate)), block.Origin_path, 1, 1, true);
end

%%%%% states xi%%%%%%%%%%%
for k1=1:nstate
    xi_state{k1} = [tmp_var_prefix num2str(k1)];
    if numel(X0) == 1 % if all states have the same init
        xi_state0{k1} = num2str(X0, '%10.10f');
    elseif numel(X0) == 0 % Initial state not specified
        xi_state0{k1} = num2str(0, '%10.10f');
    else % or the vector is specified by the user
        xi_state0{k1} = num2str(X0(k1), '%10.10f');
    end
    %old code : misunderstanding of the system equation
    %     prestate{k1}= ['(pre ' tmp_var_prefix num2str(k1) ')'];
    prestate{k1}= ['(' xi_state0{k1} ' -> pre ' tmp_var_prefix num2str(k1) ')'];
    for k2=1:nstate
        Avalue{k1,k2} = num2str(dss_A(k1,k2), '%10.10f');
    end
end

%%%%%% inputs ui%%%%%%%%%%%
input=list_in;

for k1=1:ninput
    %old code : misunderstanding of the system equation
    % 	preinput{k1} = ['(pre ' list_in{k1} ')'];
    preinput{k1} = list_in{k1};
    for k2=1:nstate
        Bvalue{k2,k1} = num2str(dss_B(k2,k1), '%10.10f');
    end
    for k2=1:noutput
        Dvalue{k2,k1} = num2str(dss_D(k2,k1), '%10.10f');
    end
end

%%%% outputs yi%%%%%%%%%%%
output = list_out;

for k1=1:noutput
    for k2=1:nstate
        Cvalue{k1,k2} = num2str(dss_C(k1,k2), '%10.10f');
    end
end

if nstate == 0
    prestate = '';
    xi_state = '';
    Avalue = '';
    Bvalue = '';
    Cvalue = '';
end

buffer = get_dss_mat_contrib(nstate, nstate, prestate, dss_A, Avalue);

if nstate > 0
    cstate = buffer;
end

clear buffer;
buffer = get_dss_mat_contrib(nstate, ninput, preinput, dss_B, Bvalue);

if nstate > 0
    cinput = buffer;
end
%old code : misunderstanding of the system equation. The initial state
%should be applied to the state x(n) and not to whole wquation Ax(n) +
%Bu(n)
% for k1=1:nstate
% 	if strcmp(cinput{k1},'') ~= 0
% 		output_string = app_sprintf(output_string,'\t%s = %s -> (%s) ;\n', xi_state{k1}, xi_state0{k1}, cstate{k1});
% 	else
% 		output_string = app_sprintf(output_string,'\t%s = %s -> ((%s) + (%s));\n', xi_state{k1}, xi_state0{k1}, cstate{k1}, cinput{k1});
% 	end
% end
for k1=1:nstate
    if strcmp(cinput{k1},'') ~= 0
        output_string = app_sprintf(output_string,'\t%s = %s ;\n', xi_state{k1}, cstate{k1});
    else
        output_string = app_sprintf(output_string,'\t%s = (%s) + (%s);\n', xi_state{k1}, cstate{k1}, cinput{k1});
    end
end
clear buffer;
% Writing outputs

% States contributions
%old code : misunderstanding of the system equation. we use x(n) and not
%x(n+1)
% buffer = get_dss_mat_contrib(noutput, nstate, xi_state, dss_C, Cvalue);
buffer = get_dss_mat_contrib(noutput, nstate, prestate, dss_C, Cvalue);

cstate = buffer;

clear buffer
% Inputs contributions
buffer = get_dss_mat_contrib(noutput, ninput, input, dss_D, Dvalue);

cinput = buffer;


for k1=1:noutput
    if nstate > 0
        if strcmp(cinput{k1},'') == 0
            output_string = app_sprintf(output_string,'\t%s = ((%s) + (%s));\n', output{k1}, cstate{k1}, cinput{k1});
        else
            output_string = app_sprintf(output_string,'\t%s = %s;\n', output{k1}, cstate{k1});
        end
    else
        output_string = app_sprintf(output_string,'\t%s = %s;\n', output{k1}, cinput{k1});
    end
end
var_out{1} = 'additional_variables';
var_out{2} = add_vars;
end

function buffer = get_dss_mat_contrib(nstate, ninput, prestate, dss_mat, mat_value)
buffer = '';
for k1=1:nstate
    cpt = 0;
    k2 = 1;
    buffer{k1} = '';
    while (cpt == 0 && k2 <= ninput)
        if dss_mat(k1,k2) ~= 0
            if dss_mat(k1,k2) == 1
                buffer{k1} = [buffer{k1} prestate{k2}];
            else
                buffer{k1} = [buffer{k1} mat_value{k1,k2} '*' prestate{k2}];
            end
            cpt = 1;
        end
        k2 = k2 + 1;
    end
    while (k2 <= ninput)
        if dss_mat(k1,k2) ~= 0
            if dss_mat(k1,k2) == 1
                buffer{k1} = [buffer{k1} '+' prestate{k2}];
            elseif dss_mat(k1,k2) < 0
                buffer{k1} = [buffer{k1} mat_value{k1,k2} '*' prestate{k2}];
            else
                buffer{k1} = [buffer{k1} '+' mat_value{k1,k2} '*' prestate{k2}];
            end
        end
        k2 = k2 + 1;
    end
end

end
