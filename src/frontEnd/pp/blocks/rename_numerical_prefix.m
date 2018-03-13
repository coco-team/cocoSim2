function [] = rename_numerical_prefix(model)
% RENAME_NUMERICAL_PREFIX Replaces all blocks which name starts with a
% number by a prefix xx

% Processing all blocks
block_list = find_system(model,'Regexp','on','Name','^[0-9]');
if not(isempty(block_list))
    disp('Processing numerical-prefix blocks...')
    display_msg('Processing numerical-prefix blocks...', Constants.INFO, ...
        'rename_numerical_prefix', '');
    for i=1:length(block_list)
        display_msg(block_list{i}, Constants.INFO, 'rename_numerical_prefix', '');
        name = get_param(block_list{i},'Name');
        set_param(block_list{i},'Name',['xx' name]);
    end
    display_msg('Done\n\n', Constants.INFO, 'rename_numerical_prefix', ''); 
end
end

