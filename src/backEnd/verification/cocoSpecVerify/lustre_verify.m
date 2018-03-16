function [ ] = lustre_verify( model_full_path, const_files, default_Ts, trace, dfexport )
if nargin==1
    [nom_lustre_file, ~, c_code, ir_struct]=lustre_compiler(model_full_path);
end

Utils.update_status('Verification');
smt_file = '';
Query_time = 0;


[output_dir, file_name, ~] = fileparts(nom_lustre_file);
[models, ~] = find_mdlrefs(file_name);

try
    SOLVER = evalin('base','SOLVER');
catch
    SOLVER = 'NONE';
end

mapping_file = strcat(output_dir,'/', file_name,'_mapping.json');

if (exist(mapping_file,'file') == 2) ...
        && not (strcmp(SOLVER, 'NONE'))
    if not (strcmp(SOLVER, 'Z') || strcmp(SOLVER,'K') || strcmp(SOLVER, 'J'))
        display_msg('Available solver is K for Kind2', Constants.WARNING, 'cocoSim', '');
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
    if strcmp(SOLVER, 'K')
        display_msg('Running Kind2', Constants.INFO, 'Verification', '');
        try
            kind2(nom_lustre_file, mapping_file);
        catch ME
            display_msg(ME.message, Constants.ERROR, 'Verification', '');
            display_msg(ME.getReport(), Constants.DEBUG, 'Verification', '');
        end    
    end
else
    display_msg('No property to prove', Constants.RESULT, 'Verification', '');
end

end
