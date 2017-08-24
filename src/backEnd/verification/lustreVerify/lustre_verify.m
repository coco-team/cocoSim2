function [ ] = lustre_verify( model_full_path, const_files, default_Ts, trace, dfexport )
%LUSTRE_VERIFY 
if nargin==5
[nom_lustre_file, ~, c_code, property_node_names, ir_struct, xml_trace, is_SF]=lustre_compiler(model_full_path, const_files, default_Ts, trace, dfexport);
elseif nargin==4
[nom_lustre_file, ~, c_code, property_node_names, ir_struct, xml_trace, is_SF]=lustre_compiler(model_full_path, const_files, default_Ts, trace);
elseif nargin==3
[nom_lustre_file, ~, c_code, property_node_names, ir_struct, xml_trace, is_SF]=lustre_compiler(model_full_path, const_files, default_Ts);
elseif nargin==2
[nom_lustre_file, ~, c_code, property_node_names, ir_struct, xml_trace, is_SF]=lustre_compiler(model_full_path, const_files);
elseif nargin==1
[nom_lustre_file, ~, c_code, property_node_names, ir_struct, xml_trace, is_SF]=lustre_compiler(model_full_path);
end

Utils.update_status('Verification');
smt_file = '';
Query_time = 0;

[model_path, file_name, ~] = fileparts(model_full_path);
[models, ~] = find_mdlrefs(file_name);
output_dir = fullfile(model_path, strcat('lustre_files/src_', file_name));
property_file_base_name = fullfile(output_dir, strcat(file_name, '.property'));

try
    SOLVER = evalin('base','SOLVER');
catch
    SOLVER = 'NONE';
end

if numel(property_node_names) > 0 && not (strcmp(SOLVER, 'NONE'))
    if not (strcmp(SOLVER, 'Z') || strcmp(SOLVER,'K') || strcmp(SOLVER, 'J'))
        display_msg('Available solvers are Z for Zustre and K for Kind2', Constants.WARNING, 'cocoSim', '');
        return
    end
    if exist(c_code, 'file')
        display_msg('Running SEAHORN', Constants.INFO, 'SEAHORN', '');
        try
            smt_file = seahorn(c_code);
            if strcmp(SOLVER, 'K')
                msg = 'Kind2 does not support S-Function. Switching to Zustre.';
                display_msg(msg, Constants.WARNING, 'SEAHORN', '');
                SOLVER = 'Z';
            end
        catch ME
            display_msg(ME.message, Constants.ERROR, 'SEAHORN', '');
            display_msg(ME.getReport(), Constants.DEBUG, 'SEAHORN', '');
        end
    end
    open(models{end});
    if strcmp(SOLVER, 'Z')
        display_msg('Running Zustre', Constants.INFO, 'Verification', '');
        try
            [Query_time, properties_summary] = zustre(nom_lustre_file, property_node_names, property_file_base_name, ir_struct, xml_trace, is_SF, smt_file);
            update_properties_gui(properties_summary, model_full_path, output_dir);
        catch ME
            display_msg(['Zustre has failed :' ME.message], Constants.ERROR, 'Verification', '');
            display_msg(ME.getReport(), Constants.DEBUG, 'Verification', '');
        end
    elseif strcmp(SOLVER, 'K')
        display_msg('Running Kind2', Constants.INFO, 'Verification', '');
        try
            kind2(nom_lustre_file, property_node_names, property_file_base_name, ir_struct, xml_trace);
        catch ME
            display_msg(ME.message, Constants.ERROR, 'Verification', '');
            display_msg(ME.getReport(), Constants.DEBUG, 'Verification', '');
        end
    elseif strcmp(SOLVER, 'J')
        display_msg('Running JKind', Constants.INFO, 'Verification', '');
        try
            jkind(nom_lustre_file, property_node_names, property_file_base_name, ir_struct, xml_trace);
        catch ME
            display_msg(ME.message, Constants.ERROR, 'Verification', '');
            display_msg(ME.getReport(), Constants.DEBUG, 'Verification', '');
        end
    end
else
    display_msg('No property to prove', Constants.RESULT, 'Verification', '');
end

end

