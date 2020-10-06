function [] = saturation_dynamic_process(model)
% SATURATION_DYNAMIC_PROCESS Searches for saturation_dynamic blocks and
% replaces them by a GAL-friendly equivalent.
%   model is a string containing the name of the model to search in

% Processing Saturation Dynamic blocks
sat_dyn_list = find_system(model,'MaskType','Saturation Dynamic');
if not(isempty(sat_dyn_list))
    display_msg('Processing Saturation Dynamic blocks...', Constants.INFO, ...
        'saturation_dynamic_process', '');
    for i=1:length(sat_dyn_list)
        display_msg(sat_dyn_list{i}, Constants.INFO, ...
            'saturation_dynamic_process', '');
        outputDataType = get_param(sat_dyn_list{i}, 'OutDataTypeStr');
        OutMin = get_param(sat_dyn_list{i}, 'OutMin');
        OutMax = get_param(sat_dyn_list{i}, 'OutMax');
            
        replace_one_block(sat_dyn_list{i},'gal_lib/saturation_dyn');
        if ~strcmp(outputDataType, 'Inherit: Same as second input')
            set_param(strcat(sat_dyn_list{i},'/upper'),...
                'OutDataTypeStr',outputDataType);
            set_param(strcat(sat_dyn_list{i},'/lower'),...
                'OutDataTypeStr',outputDataType);
        end
        
        set_param(strcat(sat_dyn_list{i},'/Out'), 'OutMin', OutMin);
        set_param(strcat(sat_dyn_list{i},'/Out'), 'OutMax', OutMax);
    end
    display_msg('Done\n\n', Constants.INFO, ...
        'saturation_dynamic_process', '');
end
end

