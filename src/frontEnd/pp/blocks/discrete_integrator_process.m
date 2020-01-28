function [] = discrete_integrator_process(model)
% DISCRETE_INTEGRATOR_PROCESS Searches for discrete_integrator blocks 
% and replaces them by a GAL-friendly equivalent.
%   model is a string containing the name of the model to search in

% Processing Discrete Integrator blocks
discrete_intr_list = find_system(model,'BlockType',...
    'DiscreteIntegrator');
model_smtp = Utils.get_BlockDiagram_SampleTime(model);
if not(isempty(discrete_intr_list))
    display_msg('Processing Discrete Integrator blocks...', Constants.INFO, 'discrete_integrator_process', ''); 
    for i=1:length(discrete_intr_list)
        display_msg(discrete_intr_list{i}, Constants.INFO, 'discrete_integrator_process', ''); 
        IntegratorMethod = get_param(discrete_intr_list{i}, 'IntegratorMethod');
        if ~strcmp(IntegratorMethod, 'Integration: Backward Euler')
            % TODO Support other integration methods
            display_msg(sprintf('The block "%s" use method of integration different from Backward Euler. We will use Backward Euler instead. This can cause different behavior of the block.', discrete_intr_list{i}), ...
                Constants.WARNING, 'discrete_integrator_process', ''); 
        end
        sample_tmp = get_param(discrete_intr_list{i}, 'SampleTime'); 
        if strcmp(sample_tmp,'-1')
            sample_tmp = num2str(model_smtp);
        end
        gainval = get_param(discrete_intr_list{i}, 'gainval'); 
        % add sample time * gain
        gainval = sprintf('(%s)*(%s)', sample_tmp, gainval);
        ICS = get_param(discrete_intr_list{i},'InitialConditionSource');
        ER = get_param(discrete_intr_list{i},'ExternalReset');
        SaturateOnIntegerOverflow = get_param(discrete_intr_list{i},'SaturateOnIntegerOverflow');
        OutMin = get_param(discrete_intr_list{i}, 'OutMin');
        OutMax = get_param(discrete_intr_list{i}, 'OutMax');
        % Handle internal/external initial value
        if strcmp(ICS,'internal')
            x0 = get_param(discrete_intr_list{i},'InitialCondition');
            switch ER
                case 'none'
                    replace_one_block(discrete_intr_list{i},'gal_lib/atomic_integrator');
                    set_param(strcat(discrete_intr_list{i},'/UnitDelay'),...
                        'InitialCondition',x0);
                case {'level', 'rising', 'falling', 'either', 'sampled level'}
                    reset = strrep(ER, ' ', '_');
                    name = strcat('gal_lib/atomic_integrator_reset_', reset);
                    replace_one_block(discrete_intr_list{i},name);
                    set_param(strcat(discrete_intr_list{i},'/Init'),'Value',x0);
                    % Set the sample time of the Discrete integrator
                    set_param(strcat(discrete_intr_list{i},'/UnitDelay1'),...
                        'SampleTime',sample_tmp);
                    if ~strcmp(ER,'sampled level')
                        set_param(strcat(discrete_intr_list{i},'/UnitDelay2'),...
                        'SampleTime',sample_tmp);
                    end
                    set_param(strcat(discrete_intr_list{i},'/Sum6'),...
                        'SampleTime',sample_tmp);
                otherwise
                        continue;
            end
        else
            switch ER
                case 'none'
                    replace_one_block(discrete_intr_list{i},'gal_lib/atomic_integrator_ic');
                case {'level', 'rising', 'falling', 'either', 'sampled level'}
                    reset = strrep(ER, ' ', '_');
                    name = strcat('gal_lib/atomic_integrator_reset_', reset,'_ic');
                    replace_one_block(discrete_intr_list{i},name);
                    % Set the sample time of the Discrete integrator
                    if ~strcmp(ER,'sampled level')
                    set_param(strcat(discrete_intr_list{i},'/UnitDelay2'),...
                        'SampleTime',sample_tmp);
                    end
                    set_param(strcat(discrete_intr_list{i},'/Sum6'),...
                        'SampleTime',sample_tmp);
                otherwise
                    continue;
            end
            % Set the sample time of the Discrete integrator
            set_param(strcat(discrete_intr_list{i},'/UnitDelay1'),...
                'SampleTime',sample_tmp);
        end
        % Set the sample time of the Discrete integrator
        set_param(strcat(discrete_intr_list{i},'/Sample'),...
            'Gain',gainval);
        set_param(strcat(discrete_intr_list{i},'/UnitDelay'),...
            'SampleTime',sample_tmp);
        set_param(strcat(discrete_intr_list{i},'/Sum6'),...
            'SaturateOnIntegerOverflow',SaturateOnIntegerOverflow);
        try
            % we assume output port called 
            set_param(strcat(discrete_intr_list{i},'/F(x)'), 'OutMin', OutMin);
            set_param(strcat(discrete_intr_list{i},'/F(x)'), 'OutMax', OutMax);
        catch
        end
    end
    display_msg('Done\n\n', Constants.INFO, 'discrete_integrator_process', ''); 
end
end

