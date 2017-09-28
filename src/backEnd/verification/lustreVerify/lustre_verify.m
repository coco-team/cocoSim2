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


[output_dir, file_name, ~] = fileparts(nom_lustre_file);
[models, ~] = find_mdlrefs(file_name);
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
            update_properties_gui(properties_summary, nom_lustre_file, output_dir);
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

function update_properties_gui(properties_summary, model_full_path, lus_dir)
[~, file_name, ~] = fileparts(model_full_path);
try
    tgroup = evalin('base','cocosim_tgroup_handle');
    if (tgroup.isvalid)
        tgroup_found  = true;
    else
        tgroup_found  = false;
    end
catch
    tgroup_found  = false;
end
if tgroup_found && isa(tgroup,'matlab.ui.container.TabGroup')
    nb_pp = numel(properties_summary);
    fields_nb = nb_pp + 4;% properties +  titles +buttons
    space = 1 / (fields_nb + 1);
    panel = tgroup.Children(6).Children(1);
    if panel.isvalid && isa(panel,'matlab.ui.container.Panel')
        panel.Children = [];
        uicontrol(panel,'Style','text',...
            'String','Safe properties :','HorizontalAlignment','left',...
            'FontUnits', 'Normalized', 'FontSize',space, 'FontWeight', 'bold', ...
            'Units', 'Normalized','Position',[0.05 space*fields_nb 0.8 space]);
        j = 1;
        cex_indexes = [];
        timeout_indexes = [];
        unknown_indexes = [];
        for i=1:nb_pp
            answer = properties_summary(i).Answer;
            if strcmp(answer, 'SAFE')
                name = properties_summary(i).Name;
                uicontrol(panel,'Style','text',...
                    'String',name,'HorizontalAlignment','left',...
                    'FontUnits', 'Normalized', 'FontSize',space, 'FontWeight', 'bold', ...
                    'ForegroundColor', 'blue', ...
                    'Units', 'Normalized','Position',[0.15 space*(fields_nb - j) 0.8 space]);
                j = j + 1;
            elseif strcmp(answer, 'CEX')
                cex_indexes = [cex_indexes, i];
            elseif strcmp(answer, 'TIMEOUT')
                timeout_indexes = [timeout_indexes, i];
            else
                unknown_indexes = [unknown_indexes, i];
            end
        end
        if j > 1
            uicontrol(panel,'Style','pushbutton',...
                'String','View generated CoCoSpec (Experimental)','HorizontalAlignment','left',...
                'FontUnits', 'Normalized', 'FontSize',space, 'FontWeight', 'bold', ...
                'Units', 'Normalized','Position',[0.15 space*(fields_nb - j) 0.3 space],...
                'Callback', @viewContractCallback)
            j = j + 1;
        else
            uicontrol(panel,'Style','text',...
                'String','No safe properties','HorizontalAlignment','left',...
                'FontUnits', 'Normalized', 'FontSize',space, 'FontWeight', 'bold', ...
                'ForegroundColor', 'blue', ...
                'Units', 'Normalized','Position',[0.15 space*(fields_nb - j) 0.8 space]);
            j = j + 1;
        end
        %CEX
        if numel(cex_indexes) > 0
            uicontrol(panel,'Style','text',...
                'String','Unsafe properties :','HorizontalAlignment','left',...
                'FontUnits', 'Normalized', 'FontSize',space, 'FontWeight', 'bold', ...
                'Units', 'Normalized','Position',[0.05 space*(fields_nb - j) 0.8 space]);
            j = j + 1;
            for i=cex_indexes
                name = properties_summary(i).Name;
                uicontrol(panel,'Style','text',...
                    'String',name,'HorizontalAlignment','left',...
                    'FontUnits', 'Normalized', 'FontSize',space, 'FontWeight', 'bold', ...
                    'ForegroundColor', 'red', ...
                    'Units', 'Normalized','Position',[0.15 space*(fields_nb - j) 0.3 space]);
                
                uicontrol(panel,'Style','pushbutton',...
                    'String','View Counter example','HorizontalAlignment','left',...
                    'FontUnits', 'Normalized', 'FontSize',space, 'FontWeight', 'bold', ...
                    'Units', 'Normalized','Position',[0.5 space*(fields_nb - j+ 0.25) 0.25 space],...
                    'Callback', {@viewCEX,name})
                
                j = j + 1;
            end
        end
        
        if numel(timeout_indexes) > 0
            uicontrol(panel,'Style','text',...
                'String','TIMEOUT properties :','HorizontalAlignment','left',...
                'FontUnits', 'Normalized', 'FontSize',space, 'FontWeight', 'bold', ...
                'Units', 'Normalized','Position',[0.05 space*(fields_nb - j) 0.8 space]);
            j = j + 1;
            for i=timeout_indexes
                name = properties_summary(i).Name;
                uicontrol(panel,'Style','text',...
                    'String',name,'HorizontalAlignment','left',...
                    'FontUnits', 'Normalized', 'FontSize',space, 'FontWeight', 'bold', ...
                    'ForegroundColor', 'red', ...
                    'Units', 'Normalized','Position',[0.15 space*(fields_nb - j) 0.8 space]);
                j = j + 1;
            end
        end
        
        if numel(unknown_indexes) > 0
            uicontrol(panel,'Style','text',...
                'String','UNKNOWN properties :','HorizontalAlignment','left',...
                'FontUnits', 'Normalized', 'FontSize',space, 'FontWeight', 'bold', ...
                'Units', 'Normalized','Position',[0.05 space*(fields_nb - j) 0.8 space]);
            j = j + 1;
            for i=unknown_indexes
                name = properties_summary(i).Name;
                uicontrol(panel,'Style','text',...
                    'String',name,'HorizontalAlignment','left',...
                    'FontUnits', 'Normalized', 'FontSize',space, 'FontWeight', 'bold', ...
                    'ForegroundColor', 'red', ...
                    'Units', 'Normalized','Position',[0.15 space*(fields_nb - j) 0.8 space]);
                j = j + 1;
            end
        end
    end
end
    function viewCEX(src, callbackInfo, prop_name)
        html_output = fullfile(lus_dir, strcat(prop_name,'.html'));
        if exist(html_output, 'file')
            open(html_output);
        else
            errordlg('FAILURE to parse the counter example');
        end
    end
    function viewContractCallback(src, callbackInfo)
        emf_name = [file_name '_EMF'];
        try
            EMF = evalin('base', emf_name);
        catch ME
            display_msg(ME.getReport(),Constants.DEBUG,'viewContract','');
            msg = sprintf('No CoCoSpec Contract for %s \n Verify the model with Zustre', file_name);
            warndlg(msg,'CoCoSim: Warning');
            return;
        end
        try
            Output_url = view_cocospec(model_full_path, char(EMF));
        catch ME
            display_msg(ME.getReport(),Constants.DEBUG,'viewContract','');
        end
    end
end
