function [] = lookuptable_nD_process(model)
% LOOKUPTABLE_ND_PROCESS Searches for lookuptable blocks and replaces them
% by a GAL-friendly equivalent.
%   model is a string containing the name of the model to search in

% Processing Lookup table n_D blocks
lookup_nD_list = find_system(model,'BlockType','Lookup_n-D');
if not(isempty(lookup_nD_list))
    display_msg('Processing Lookup table n-D blocks...', Constants.INFO,...
        'lookuptable_nD_process', '');
    for i=1:length(lookup_nD_list)
        display_msg(lookup_nD_list{i}, Constants.INFO, ...
            'lookuptable_nD_process', '');
        new_block_name = lookuptable_nD_block_process(lookup_nD_list{i});
        replace_one_block(lookup_nD_list{i},new_block_name);
        delete_block(new_block_name)
    end
    display_msg('Done\n\n', Constants.INFO, 'lookuptable_nD_process', '');
end
end

function [new_block] = lookuptable_nD_block_process(init_block)
% LOOKUPTABLE_ND_BLOCK_PROCESS Changes the lookup table into a
% GAL-friendly block.
%   init_block is a sting containing the name of
%   the block to process.
%   ONLY HANDLE 1D LOOKUP TABLES FOR NOW

% Obtaining tables
if eval(get_param(init_block, 'NumberOfTableDimensions')) > 1
    display_msg('Only 1D lookup table', Constants.ERROR, ...
        'lookuptable_nD_process', '');
    error('Only 1D lookup table');
end

indexes = eval(get_param(init_block, 'BreakpointsForDimension1'));
datatable = eval(get_param(init_block, 'Table'));

if size(indexes) ~= size(datatable)
    if size(indexes) ~= size(datatable')
        display_msg('Incompatible dimension for indexes and data',...
            Constants.ERROR, 'lookuptable_nD_process', '');
        error('Incompatible dimension for indexes and data');
    else
        % We have to transpose one of them
        if size(indexes,1) > 1
            indexes= indexes';
        else
            datatable=datatable';
        end
    end
end

new_block = strcat(init_block,'_p');
datatable_process(indexes,datatable,new_block);

end


