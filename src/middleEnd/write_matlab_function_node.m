%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Matlab Function block
%
% Outputs a node containing the link to the .m file containing the MAtlab
% Function code.
%
%% Generation scheme
%
%%% The function has 2 inputs, the first is a 3 elements vector of doubles, the second
% is a 3 elements row matrix of integers. The output is a 2 elements
% vector of reals.
%
%  node BlockName_MatlabFunctionName (in1: real^1^3; in2: int^3)
%  returns (out: real^1^2)
%  let
%     --!MATLAB_Code: 'BlockName_MatlabFunctionName.m'
%  tel
%
%% Code
%
function [header] = write_matlab_function_node(block, main_blk, inter_blk, fun_name, chart, xml_trace)

header = '';

% Prepare node header
blk_path_elems = regexp(block.Path, filesep, 'split');
node_call_name = Utils.concat_delim(blk_path_elems, '_');

header = sprintf('node %s_%s (', node_call_name, fun_name);

xml_trace_node = xml_trace.create_Node_Element(xml_trace, block.Origin_path, node_call_name);

inputs = {};
% Get inputs
for idx_in=1:numel(block.Pre)
   in_name = char(chart.Inputs(idx_in).Name);
	in_dt = Utils.get_lustre_dt(block.CompiledPortDataTypes.Inport{idx_in});
	[dim_r dim_c] = Utils.get_port_dims_simple(block.CompiledPortDimensions.Iport, idx_in);
	if block.CompiledPortComplexSignals{1}.Inport(idx_in)
		in_dt = ['complex_' in_dt];
	end
	if dim_r == 1 && dim_c == 1
		dt_str = in_dt;
	elseif dim_r == 1
		dt_str = sprintf('%s^%d', in_dt, dim_c);
	elseif dim_c == 1
		dt_str = sprintf('%s^1^%d', in_dt, dim_r);
	else
		dt_str = sprintf('%s^%d^%d', in_dt, dim_c, dim_r);
	end
	inputs{idx_in} = [in_name ' : ' dt_str];
end

inputs_string = Utils.concat_delim(inputs, '; ');
header = app_sprintf(header, '%s;)\nreturns (', inputs_string);

outputs = {};
% Get outputs
for idx_out=1:numel(block.Post)
	out_name = char(chart.Outputs(idx_out).Name);
	out_dt = Utils.get_lustre_dt(block.CompiledPortDataTypes.Outport{idx_out});
	[dim_r dim_c] = Utils.get_port_dims_simple(block.CompiledPortDimensions.Outport, idx_out);
	if block.CompiledPortComplexSignals{1}.Outport(idx_in)
		out_dt = ['complex_' out_dt];
	end
	if dim_r == 1 && dim_c == 1
		dt_str = out_dt;
	elseif dim_r == 1
		dt_str = sprintf('%s^%d', out_dt, dim_c);
	elseif dim_c == 1
		dt_str = sprintf('%s^1^%d', out_dt, dim_r);
	else
		dt_str = sprintf('%s^%d^%d', out_dt, dim_c, dim_r);
	end
	outputs{idx_out} = [out_name ' : ' dt_str];
end

outputs_string = Utils.concat_delim(outputs, '; ');
header = app_sprintf(header, '%s)\n', outputs_string);

header = app_sprintf(header, 'let\n');

comment_string = sprintf('\t--!MATLAB_Code ''%s_%s.m''', node_call_name, fun_name);

header = app_sprintf(header, '%s\ntel\n\n', comment_string);


end

