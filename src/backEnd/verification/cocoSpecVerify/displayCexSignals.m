function displayCexSignals(resultIndex, propertyIndex)
    %get the verification results
    modelWorkspace = get_param(bdroot(gcs),'ModelWorkspace');
    verificationResults = modelWorkspace.getVariable('verificationResults');

    propertyStruct = verificationResults.analysisResults{resultIndex}.properties{propertyIndex};

    % faltten all nested nodes
    node = propertyStruct.counterExample.node;

    % draw a figure that holds all subplots
    f = figure('Name',propertyStruct.originPath,'NumberTitle','off');

    % for now only consider input and output signals and ignore local ones
    classes = cellfun(@(x) x.class, node.streams,'UniformOutput', 0);
    inputOutputSignals = find(~strcmp(classes, 'local'));
    numberOfSignals = length(inputOutputSignals);

    time = zeros (1, node.timeSteps);
    
    timeStep = 0;
    for i= 1 : length(time)
        time(i) = timeStep;
        timeStep = timeStep + verificationResults.sampleTime;
    end

    colorSize = 500;
    colormap = jet(colorSize);

    for index = 1 : numberOfSignals
        signalIndex = inputOutputSignals(index);
        subplot(numberOfSignals, 1, signalIndex);

        % choose a color
        colorIndex = index/ (numberOfSignals +1) * colorSize + 1;
        color = colormap(randi(500), :);
        stairs(time, node.streams{signalIndex}.values, 'LineStyle', '-', ...
            'LineWidth', 2, 'Color', color, ...
            'DisplayName', strcat(node.streams{signalIndex}.name, ...
            ' (', node.streams{signalIndex}.class, ')'));
        legend('off');
        l = legend('show');
        set(l, 'Interpreter', 'none');

        xLimits = xlim();
        ylabel(node.streams{signalIndex}.name, 'FontSize', 8);

        set(gca, 'xtick', xLimits(1):verificationResults.sampleTime:xLimits(2));
        hold on;
    end

    xlabel('time', 'FontSize', 8); 
end