function cocoSpecIRPP( file_name, output_dir, json_model)
    % Fix the dimensionality issue "CompiledPortDimensions": 
    % {..."Outport": [2,1,1]...} -> {..."Outport": [1,1]...}
    %json_model = strrep(json_model,'"Outport":[2,1,1]','"Outport":[1,1]');
    %ToDo: this is a dirty quick fix which may not work for all cases. A
    %revision and a better approach is needed. 
    
    matches = regexp(json_model, '("Inport":|"Outport":)\[.*?2,1,1.*?\]', 'match');
    for i = 1 : length(matches)
        newStr = strrep(matches(i), '2,1,1', '1,1');
        json_model = strrep(json_model,matches(i),newStr);
    end
    
    %ToDo: this code is redundant in 3 places cocosim_IR.m, this file and
    %ir_pp.m. Needs refactoring. 
    
    file_json = [file_name '_IR.json'];
    % Open or create the file
    file_path = fullfile(output_dir, file_json);
    fid = fopen(file_path, 'w');
    % Write in the file
    fprintf(fid, '%s\n', char(json_model));
    fclose(fid);
    
end