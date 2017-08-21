function [] = selector_process(model)
% SELECTOR_PROCESS Searches for selector blocks and replaces them by a
% GAL-friendly equivalent.
%   model is a string containing the name of the model to search in

% Processing selector blocks
selector_list = find_system(model,'BlockType','Selector');
if not(isempty(selector_list))
    display_msg('Processing Selector blocks...', Constants.INFO,...
        'selector_process', '');
    for i=1:length(selector_list)
        display_msg(selector_list{i}, Constants.INFO,...
            'selector_process', '');
        [new_block_name, err] = selector_block_process(selector_list{i});
        if ~err
            replace_one_block(selector_list{i},new_block_name);
            delete_block(new_block_name)
        end
        
    end
    display_msg('Done\n\n', Constants.INFO, 'selector_process', ''); 
end
end

function [new_block, err] = selector_block_process(init_block)
% SELECTOR_BLOCK_PROCESS Changes the init_block block into a 
% GAL-friendly block.
%   init_block is a string containing the name of the block to process 

new_block = strcat(init_block,'_p');
err= 0;
% Check that the input is only a verctor
nb_dimensions = str2num(get_param(init_block,'NumberOfDimensions'));
if (nb_dimensions ~= 1)
    msg = sprintf('%s%s%s\n%s\n','The block "',init_block,...
        '" is not supported because the ',...
        'number of input dimensions is not 1\n');
    display_msg(msg, Constants.WARNING, 'selector_process', ''); 
    err = 1;
else
    add_block('gal_lib/multi_in_out',new_block);
    delete_block(strcat(new_block,'/multi_block'));
    % Get the reference for indexes
    index_mode = get_param(init_block,'IndexMode');
    if strcmp(index_mode,'Zero-based')
        idx = 1;
    else
        idx = 0;
    end
    
    input_size = get_param(init_block,'InputPortWidth');
    set_param(strcat(new_block,'/Demux'),'Outputs',num2str(input_size));
    
    index_option = get_param(init_block,'IndexOptionArray');
    
    switch index_option{1} % index_option is a cell array
        case 'Index vector (dialog)'
            out = get_param(init_block,'IndexParamArray');
            out = str2num(out{1}); % out is a cell array containing a string
            if length(out) == 1
                % Avoid vector output when the ouput is a scalar
                delete_block(strcat(new_block,'/Mux'));
                line_handle = get_param(strcat(new_block,'/Out'),'LineHandles');
                delete_line(line_handle.Inport);
                add_line(new_block,...
                    strcat('Demux/',num2str(out+idx)),'Out/1');
            else
                set_param(strcat(new_block,'/Mux'),...
                    'Inputs',num2str(length(out)));
                for i=1:length(out)
                    add_line(new_block,strcat('Demux/',num2str(out(i)+idx)),...
                        strcat('Mux/',num2str(i)));
                end
            end
        otherwise
            msg = sprintf('The option "%s" in block "%s" is not handled\n',...
                index_option{1},init_block);
            display_msg(msg, Constants.WARNING, 'selector_process', ''); 
            err = 1;
            delete_block(new_block)
    end
end
end

