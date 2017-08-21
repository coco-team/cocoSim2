function [] = math_process(model)
% MATH_PROCESS Searches for Math blocks with unsupported functions 
% and replaces them by a GAL-friendly equivalent.
%   model is a string containing the name of the model to search in

% Processing Math unsupported blocks
math_list = find_system(model,'BlockType','Math');
if not(isempty(math_list))
    display_msg('Processing Math blocks...', Constants.INFO, ...
        'math_process', '');
    for i=1:length(math_list)
        func = get_param(math_list{i},'Operator');
        switch func
            case 'magnitude^2'
                disp(math_list{i})
                display_msg(math_list{i}, Constants.INFO,...
                    'math_process', '');
                new_block = strcat(math_list{i},'_p');
                expression_process('u^2',new_block,1);
                replace_one_block(math_list{i},new_block);
                delete_block(new_block);
            %otherwise
                % The function is natively supported by GAL : nothing to
                % do.
        end
    end
    display_msg('Done\n\n', Constants.INFO, 'math_process', ''); 
end
end

