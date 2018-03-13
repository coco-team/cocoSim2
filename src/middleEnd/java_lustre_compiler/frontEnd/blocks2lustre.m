%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of CoCoSim.
% Copyright (C) 2014-2016  Carnegie Mellon University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Add summary of the function with parameters

function [node_header,let_tel_code_string, extern_s_functions_string, extern_functions, properties_nodes,...
    property_node_names, extern_matlab_functions, c_code, external_math_functions] = blocks2lustre(model_name, nom_lustre_file, ...
myblk, main_blks, mat_files, idx_subsys, trace, xml_trace)

% Returned values
let_tel_code_string = '';
extern_s_functions_string = '';
extern_functions = '';
extern_matlab_functions = {};
properties_nodes = '';
additional_variables = '';
property_node_names = '';

% Current subsystem
subsys = get_struct(myblk, main_blks{idx_subsys});
fields = fieldnames(subsys.Content);
fields(cellfun('isempty', regexprep(fields, '^Annotation.*', ''))) = [];
blks = {};
for i=1:numel(fields)
    blks = [blks, subsys.Content.(fields{i}).Path];
end

if idx_subsys == 1
    subsys = subsys.Content.(fields{1});
    blk = subsys.Path;
else
    blk = main_blks{idx_subsys};
end
nblk = numel(blks);
%%%%%%%%%%% Node header declaration

% Get the current SubSystem hierarchy
blk_path_elems = regexp(blk, '/', 'split');

% If we are at the last pass (main System)
if idx_subsys == 1    
	newinit= 1;
    blk_path_elems = regexp(blk, '/', 'split');
	node_name = Utils.concat_delim(blk_path_elems(1:(end-1)), '_');
	xml_trace.create_Node_Element(Utils.concat_delim(blk_path_elems(1:(end-1)), '/'), node_name);
else
	newinit= 2;
	node_name = Utils.concat_delim(blk_path_elems, '_');
	xml_trace.create_Node_Element(subsys.Origin_path, node_name);
end;

fid = fopen(nom_lustre_file, 'a');

node_header = sprintf('node %s (', node_name);

nbin=1;
for idx_block=1:nblk
    sub_blk = get_struct(myblk, blks{idx_block});
	if strcmp(sub_blk.BlockType, 'Inport')
		if nbin == 1
			% Create the "Inputs" traceability information element
			xml_trace.create_Inputs_Element();
        end
		list_out = list_var_input(sub_blk, xml_trace, 'Inport');
		for idx_output=1:numel(list_out)
			node_header = app_sprintf(node_header, '%s; ', list_out{idx_output});
		end
		nbin = nbin + 1;
	% Add the inputs for the trigger block if it is of 'either' type and it shows its output port
	elseif strcmp(sub_blk.BlockType, 'TriggerPort')
		if strcmp(sub_blk.TriggerType, 'either') && strcmp(sub_blk.ShowOutputPort, 'on')
			trigger_name_cell = regexp(sub_blk.Path, '/', 'split');
			trigger_name = Utils.concat_delim(trigger_name_cell, '_');
			str_in_trigg = '';
			str_in_trigg_pre = '';
			out_dt = LusUtils.get_lustre_dt(subsys.CompiledPortDataTypes.Trigger);
			[dim_r dim_c] = Utils.get_port_dims_simple(subsys.CompiledPortDimensions.Trigger, 1);
			for idx_dim=1:(dim_r*dim_c)
				str_in_trigg = app_sprintf(str_in_trigg, '%s_1_%d: %s; ', trigger_name, idx_dim, out_dt);
				str_in_trigg_pre = app_sprintf(str_in_trigg_pre, '%s_pre_1_%d: %s; ', trigger_name, idx_dim, out_dt);
			end
			node_header = app_sprintf(node_header, '%s%s', str_in_trigg, str_in_trigg_pre);
        end
	% Add the inputs for the enable block if it is of 'either' type
	elseif strcmp(sub_blk.BlockType, 'EnablePort')
		if strcmp(sub_blk.ShowOutputPort, 'on')
			enable_name_cell = regexp(sub_blk.Path, '/', 'split');
			enable_name = Utils.concat_delim(enable_name_cell, '_');
			str_in_enable = '';
			out_dt = LusUtils.get_lustre_dt(subsys.CompiledPortDataTypes.Enable);
			[dim_r dim_c] = Utils.get_port_dims_simple(subsys.CompiledPortDimensions.Enable, 1);
			for idx_dim=1:(dim_r*dim_c)
				str_in_enable = app_sprintf(str_in_enable, '%s_1_%d: %s; ', enable_name, idx_dim, out_dt);
			end
			node_header = app_sprintf(node_header, '%s', str_in_enable);
            
        end
	end
end

% Add iteration input if necessary
[is_foriter iter_var_name dt] = LusUtils.needs_for_iter_var(myblk, subsys);
if is_foriter
	node_header = app_sprintf(node_header, '%s: %s;', iter_var_name, dt);
	nbin = nbin + 1;
end

% Add reset input if necessary
[is_reset var_name] = LusUtils.is_reset(subsys);
if is_reset
	if is_foriter
		node_header = [node_header '  '];
	end
	node_header = app_sprintf(node_header, '%s: bool; ', var_name);
	nbin = nbin + 1;
end

if nbin == 1
	node_header = app_sprintf(node_header, 'i_virtual : real');
else
    node_header = node_header(1:end-2); % remove the last ; for JKIND
end


node_header = app_sprintf(node_header, ')\nreturns (');
list_output = '';
list_outputs = '';
list_output_names = '';
cpt_outports = 0;
nb_out = 1;
for idx_block=1:nblk
    sub_blk = get_struct(myblk, blks{idx_block});
	if strcmp(sub_blk.BlockType, 'Outport')
		if nb_out == 1
			% Create the "Outputs" traceability information element
			xml_trace.create_Outputs_Element();
		end
		cpt_outports = cpt_outports + 1;
		block_name = regexp(sub_blk.Path, '/', 'split');
		outport_dt = LusUtils.get_lustre_dt(sub_blk.CompiledPortDataTypes.Inport(1));
		if sub_blk.CompiledPortComplexSignals.Inport(1)
			outport_dt = ['complex_' outport_dt];
        end
		for k2=1:sub_blk.CompiledPortWidths.Inport
			%list_output{k2} = ['out' sub_blk.Port '_' num2str(k2) '_' model_name];
			list_output_names{k2} = [block_name{end} '_' sub_blk.Port '_' num2str(k2)];
			list_output{k2} = [list_output_names{k2} ' : ' outport_dt];
			% Add trace information
			xml_trace.add_Output(list_output_names{k2}, sub_blk.Origin_path, 1, k2);
		end
		list_outputs{cpt_outports} = Utils.concat_delim(list_output, '; ');
		nb_out = nb_out + 1;
		clear list_output
	end
end

list_output = Utils.concat_delim(list_outputs, ';\n\t');
node_header = app_sprintf(node_header, list_output);

% Close the returns statement
node_header = app_sprintf(node_header, '); \n');

%%%%%%%%%%%%%%%% Var section declaration

cpt_var=1;
cptn=1;

for idx_block=newinit:nblk
    sub_blk = get_struct(myblk, blks{idx_block});
	list_output = '';
	noutput = sub_blk.Ports(2);
	% Only for the blocks that are not fby
	if noutput ~= 0 && ~strcmp(sub_blk.BlockType, 'Inport')
		if ~(strcmp(sub_blk.BlockType, 'SubSystem') && BlockUtils.is_property(sub_blk.MaskType))
			if cpt_var == 1
				% Create the "Variables" traceability information element
				xml_trace.create_Variables_Element();
			end
			list_output = list_var_input(sub_blk, xml_trace, 'Variable');
			list_output_final = Utils.concat_delim(list_output, '; ');
			if cpt_var == 1
				node_header = app_sprintf(node_header, 'var\n\t%s;\n', char(list_output_final));
			else
				node_header = app_sprintf(node_header, '\t%s;\n', char(list_output_final));
			end
			cpt_var = cpt_var+1;
		end
	end
end
if idx_subsys==1 
    if cpt_var == 1
        node_header = app_sprintf(node_header, 'var\n\t%s;\n', 'i_virtual_local : real');
    else
        node_header = app_sprintf(node_header, '\t%s;\n', 'i_virtual_local : real');
    end
end
%%%%%%%%%%%%%%%% Retrieve nodes code
[let_tel_code_string, extern_s_functions_string, extern_functions, properties_nodes, additional_variables, property_node_names, extern_matlab_functions, c_code, external_math_functions] = ...
    write_code(nblk, subsys, blks, myblk, nom_lustre_file, false, trace, xml_trace);

if idx_subsys==1
   let_tel_code_string = app_sprintf(let_tel_code_string, '\t%s;\n', 'i_virtual_local= 0.0 -> 1.0');
end
% Add additional variables (ex in the MinMax block backend)
if ~strcmp(additional_variables, '')
	node_header = app_sprintf(node_header, '%s', additional_variables);
end

node_header = app_sprintf(node_header, 'let \n');
end
