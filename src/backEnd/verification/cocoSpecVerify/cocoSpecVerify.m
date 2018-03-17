function [ ] = cocoSpecVerify(model_full_path)
    if nargin==1
        [nom_lustre_file, ~, ir_struct]=cocoSpecCompiler(model_full_path);
    end

    Utils.update_status('Verification');

    [output_dir, file_name, ~] = fileparts(nom_lustre_file);
    [models, ~] = find_mdlrefs(file_name);

    try
        SOLVER = evalin('base','SOLVER');
    catch
        SOLVER = 'NONE';
    end

    % Get start time
    t_start = now;

    mapping_file = strcat(output_dir,'/', file_name,'_mapping.json');

    if (exist(mapping_file,'file') == 2)
        if not (strcmp(SOLVER, 'Z') || strcmp(SOLVER,'K') || strcmp(SOLVER, 'J'))
            display_msg('Available solver is K for Kind2', Constants.WARNING, 'cocoSim', '');
            return
        end    
        open(models{end});
        if strcmp(SOLVER, 'K')
            display_msg('Running Kind2', Constants.INFO, 'Verification', '');
            try
                cocoSpecKind2(nom_lustre_file, mapping_file);
            catch ME
                display_msg(ME.message, Constants.ERROR, 'Verification', '');
                display_msg(ME.getReport(), Constants.DEBUG, 'Verification', '');
            end    
        end
    else
        display_msg('No property to prove', Constants.RESULT, 'Verification', '');
    end
    
    t_end = now;
    t_compute = t_end - t_start;
    display_msg(['Total verification time: ' datestr(t_compute, 'HH:MM:SS.FFF')], Constants.RESULT, 'Time', '');    
end
