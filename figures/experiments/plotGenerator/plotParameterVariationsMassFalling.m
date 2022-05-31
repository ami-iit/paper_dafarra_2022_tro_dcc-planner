close all 

addpath('./labelpoints')
addpath('./export_fig')

%% Constants
iterations = 100;

inputStruct = struct();
inputStruct.m = 1.0;
inputStruct.g = -9.81;

inputStruct.dT = 0.1;
inputStruct.T = 2.0;

inputStruct.x0 = 0.1;
inputStruct.v0 = 0;
inputStruct.f0 = 0;

inputStruct.cost_multiplier = 1;

inputStruct.M_fdot = 100;
inputStruct.epsilon_relaxed = 0.004;
inputStruct.K_dynamic = 20;
inputStruct.epsilon_dynamical = 0.05;
inputStruct.K_hyperbolic = 250;
inputStruct.scaling_hyperbolic = 500;
complementarities = {'Relaxed', 'Dynamical', 'Hyperbolic'};

if ~exist('displayFigures', 'var')
    displayFigures = true;
end

if ~exist('use_dataset', 'var')
    use_dataset = true;
end

if ~exist('plot_ci', 'var')
    plot_ci = true;
end

if plot_ci
    datasetFolder = '../CI/ToyProblem';
    outputRootFolder = '../../generated/CI/';
else
    datasetFolder = '../Review2/ToyProblem';
    outputRootFolder = '../../generated/Review2/';
end

if use_dataset
    disp(['Loading ', datasetFolder, '/first_run.mat'])
    load([datasetFolder, '/first_run.mat']);
    disp(['Loading ', datasetFolder, '/parameter_variation_height.mat'])
    load([datasetFolder, '/parameter_variation_height.mat']);
    disp(['Loading ', datasetFolder, '/parameter_variation_mass.mat'])
    load([datasetFolder, '/parameter_variation_mass.mat']);
end

labels = {};
for comp_cell = complementarities
    labels = [labels, comp_cell];
end

%% First run
if ~use_dataset
    first_run_results = struct();
    for comp_cell = complementarities
        inputStruct.complementairity = comp_cell{:};

        [first_run_results.(comp_cell{:}).position, ~, first_run_results.(comp_cell{:}).force, ...
            first_run_results.(comp_cell{:}).propeller, ~, first_run_results.(comp_cell{:}).t ...
            , ~, ~, first_run_results.(comp_cell{:}).freeFalling, first_run_results.(comp_cell{:}).expectedForce] ...
            = solve_propelled_mass(inputStruct);
    end
    save('first_run.mat', 'first_run_results');
end

if displayFigures
    for comp_cell = complementarities

        figure('Renderer', 'painters', 'Position', [10 10 900 500])

        t = first_run_results.(comp_cell{:}).t;

        yyaxis left

        plot(t, first_run_results.(comp_cell{:}).position, 'linewidth', 1.2)
        hold on
        plot(t, first_run_results.(comp_cell{:}).freeFalling, '--', 'linewidth', 1.2)
        ylabel('Position (m)', 'Interpreter', 'latex', 'FontSize', 16')
        xlabel('Time (s)', 'Interpreter', 'latex', 'FontSize', 16')
        limPos = [-0.01, 1.1 *inputStruct.x0];
        ylim(limPos)
        grid on

        yyaxis right

        plot(t, first_run_results.(comp_cell{:}).force, 'linewidth', 1.2)
        hold on
        plot(t, first_run_results.(comp_cell{:}).expectedForce, '--', 'linewidth', 1.2)
        ylabel('Force (N)', 'Interpreter', 'latex', 'FontSize', 16')
        xlabel('Time (s)', 'Interpreter', 'latex', 'FontSize', 16')
        limForce = [-0.01, 1.2 *max(first_run_results.(comp_cell{:}).expectedForce)];
        ylim([limForce(2) * limPos(1)/limPos(2) limForce(2)])
        grid on
        h = legend({'Position', 'Position Guess',...
            'Force', 'Force Guess'}, 'Location', 'northoutside', 'Orientation','horizontal');
        set(h,'Interpreter','latex')
        set(h,'FontSize', 16);

        outputPath = [outputRootFolder, comp_cell{:}, '/'];
        outputFileName = 'massFallingPosForce.pdf';

        if ~exist(outputPath, 'dir')
            mkdir(outputPath)
        end
        export_fig('-transparent', [outputPath, outputFileName])

        figure('Renderer', 'painters', 'Position', [10 10 900 500])

        yyaxis left
        plot(t, first_run_results.(comp_cell{:}).propeller, 'linewidth', 1.2)
        ylabel('Propeller (N)', 'Interpreter', 'latex', 'FontSize', 16')
        xlabel('Time (s)', 'Interpreter', 'latex', 'FontSize', 16')
        limProp = [-20 20];
        ylim(limProp)
        grid on


        yyaxis right
        complementarity = first_run_results.(comp_cell{:}).position .* first_run_results.(comp_cell{:}).force;
        plot(t, complementarity, 'linewidth', 1.2)
        hold on
        line([0 inputStruct.T], [mean(complementarity) mean(complementarity)], 'LineStyle', '--')
        ylabel('$x_m \cdot f_m$', 'Interpreter', 'latex', 'FontSize', 16')
        xlabel('Time (s)', 'Interpreter', 'latex', 'FontSize', 16')
        limAccuracy = [0, 6e-3];
        ylim([limAccuracy(2) * limProp(1)/limProp(2) limAccuracy(2)])
        grid on

        h = legend({'Propeller', 'Accuracy',...
            'Average Accuracy'}, 'Location', 'northoutside', 'Orientation','horizontal');
        set(h,'Interpreter','latex')
        set(h,'FontSize', 16);

        %sgtitle([inputStruct.complementairity, ' Complementarity, ( ', num2str(elapsedTime), 's, mass ', num2str(inputStruct.m), 'kg)'], 'Interpreter', 'none')


        outputPath = [outputRootFolder, comp_cell{:}, '/'];
        outputFileName = 'massFallingAccuracy.pdf';

        if ~exist(outputPath, 'dir')
            mkdir(outputPath)
        end
        export_fig('-transparent', [outputPath, outputFileName])
    end
end

%% Parameters variation

if ~use_dataset
    initialRelaxed = inputStruct;
    initialRelaxed.complementairity = 'Relaxed';
    experiments(1:4) = {initialRelaxed};

    experiments{1}.epsilon_relaxed = 0.004;
    experiments{2}.epsilon_relaxed = 0.008;
    experiments{3}.epsilon_relaxed = 0.012;
    experiments{4}.epsilon_relaxed = 0.016;


    initialDynamical = inputStruct;
    initialDynamical.complementairity = 'Dynamical';
    experiments(5:8) = {initialDynamical};

    experiments{5}.K_dynamic              = 20;
    experiments{5}.epsilon_dynamical = 0.05;

    experiments{6}.K_dynamic               = 20;
    experiments{6}.epsilon_dynamical = 0.1;

    experiments{7}.K_dynamic               = 10;
    experiments{7}.epsilon_dynamical = 0.05;

    experiments{8}.K_dynamic               = 10;
    experiments{8}.epsilon_dynamical = 0.1;

    initialHyperbolic = inputStruct;
    initialHyperbolic.complementairity = 'Hyperbolic';
    experiments(9:12) = {initialHyperbolic};

    experiments{9}.K_hyperbolic           = 250;
    experiments{9}.scaling_hyperbolic = 500;

    experiments{10}.K_hyperbolic           = 125;
    experiments{10}.scaling_hyperbolic = 500;

    experiments{11}.K_hyperbolic           = 250;
    experiments{11}.scaling_hyperbolic = 400;

    experiments{12}.K_hyperbolic           = 125;
    experiments{12}.scaling_hyperbolic = 400;

    experimentsResults = struct();

    for comp_cell = complementarities
        experimentsResults.(comp_cell{:})  = struct();
        experimentsResults.(comp_cell{:}).elapsedTimes = zeros(1, 4);
        experimentsResults.(comp_cell{:}).accuracy = zeros(1, 4);
    end

    experimentsResults.Relaxed.legendName = 'Relaxed';
    experimentsResults.Relaxed.parameters = {'epsilon_relaxed'};
    experimentsResults.Relaxed.parametersLabel = {'$\epsilon$'};
    experimentsResults.Relaxed.labels = {};
    experimentsResults.Relaxed.marker = '^';

    experimentsResults.Dynamical.legendName = 'Dynamically Enforced';
    experimentsResults.Dynamical.parameters = {'epsilon_dynamical', 'K_dynamic'};
    experimentsResults.Dynamical.parametersLabel = {'$\varepsilon$', '$K_{bs}$'};
    experimentsResults.Dynamical.labels = {};
    experimentsResults.Dynamical.marker = 'o';

    experimentsResults.Hyperbolic.legendName = 'Hyperbolic Secant';
    experimentsResults.Hyperbolic.parameters = {'scaling_hyperbolic', 'K_hyperbolic'};
    experimentsResults.Hyperbolic.parametersLabel = {'$k_h$', '$K_{f,z}$'};
    experimentsResults.Hyperbolic.labels = {};
    experimentsResults.Hyperbolic.marker = 'h';

    currentCompl = '';
    expIndex = 0;
    for iter = 1 : iterations
        iter
        for exp = experiments
            if (strcmp(exp{:}.complementairity, currentCompl))
                expIndex = expIndex + 1;
            else
                expIndex = 1;
                currentCompl = exp{:}.complementairity;
            end

            [position, velocity, force, propeller, forceDerivative, t, costValue, elapsedTime, freeFalling, expectedForce] = solve_propelled_mass(exp{:});
            experimentsResults.(exp{:}.complementairity).elapsedTimes(expIndex) = (experimentsResults.(exp{:}.complementairity).elapsedTimes(expIndex) * (iter - 1) + elapsedTime)/iter;
            experimentsResults.(exp{:}.complementairity).accuracy(expIndex) = (experimentsResults.(exp{:}.complementairity).accuracy(expIndex) * (iter - 1) + mean(position .* force))/iter;
        end
    end

    for exp = experiments
        label = '(';
        for param = 1 : length(experimentsResults.(exp{:}.complementairity).parameters)
            paramName = experimentsResults.(exp{:}.complementairity).parameters{param};
            paramLabel = experimentsResults.(exp{:}.complementairity).parametersLabel{param};
            paramValue = exp{:}.(paramName);
            label = [label, paramLabel,' ', num2str(paramValue)];
            if (param < length(experimentsResults.(exp{:}.complementairity).parameters))
                label = [label, ', ']; %[label, ',', newline];
            end
        end
        label = [label,')'];
        experimentsResults.(exp{:}.complementairity).labels = ...
            [experimentsResults.(exp{:}.complementairity).labels ...
            label];
    end
end

if displayFigures

    figure('Renderer', 'painters', 'Position', [10 10 900 500])

    lowerCut = round(max([experimentsResults.Dynamical.elapsedTimes experimentsResults.Relaxed.elapsedTimes]) , 3) + 0.001;
    upperCut = round(max([experimentsResults.Hyperbolic.elapsedTimes]), 3) - 0.002;

    for comp_cell = complementarities
        hold on
        grid on

        if plot_ci
            x_limits = [0.04, 0.12];
        else
            x_limits = [0.03, 0.13];
        end

        scatterPlotWithXAxisBreak(experimentsResults.(comp_cell{:}).elapsedTimes, ... x
            experimentsResults.(comp_cell{:}).accuracy, ... y
            0.2,  ...
            0.2, ...
            0.00, ...
            experimentsResults.(comp_cell{:}).marker, ... marker
            48, ... markerSize
            x_limits, ... xLim
            [0.001, 10.0e-3], ... yLim
            experimentsResults.(comp_cell{:}).legendName, ... DisplayName
            experimentsResults.(comp_cell{:}).labels, ... labels
            'N', ... labelPosition
            0.35, ... labelBuffer
            30, ... labelRotation
            9); % labelFontSize
    end

    h = legend();
    set(h,'Location', 'northoutside')
    set(h,'Orientation','horizontal')
    set(h,'Interpreter','latex')
    set(h,'FontSize', 16);
    x_label = xlabel('Average Computational Time (s)');
    set(x_label, 'Interpreter', 'latex');
    set(x_label, 'FontSize', 16);
    y_label = ylabel('Accuracy $x_m \cdot f_m$');
    set(y_label,'Interpreter','latex');
    set(y_label,'FontSize', 16);

    outputPath = outputRootFolder;
    outputFileName = 'ParametersVariationMass.pdf';

    if ~exist(outputPath, 'dir')
        mkdir(outputPath)
    end
    export_fig('-transparent', [outputPath, outputFileName])

end

if ~use_dataset
    save('parameter_variation_mass.mat', 'experimentsResults');
end


%% initial position take 2
initial_positions = 0.05 : 0.02 : 0.15;

if ~use_dataset
    positions_result = struct();

    for comp_cell = complementarities
        positions_result.(comp_cell{:}) = struct();
        positions_result.(comp_cell{:}).elapsed_times = zeros(1,length(initial_positions));
        positions_result.(comp_cell{:}).complementarity_average = zeros(1,length(initial_positions));
        positions_result.(comp_cell{:}).costValue = zeros(1,length(initial_positions));
    end

    for iter = 1 : iterations
        iter
        for i = 1 : length(initial_positions)
            i
            inputStruct.x0 = initial_positions(i);
            for comp_cell = complementarities
                inputStruct.complementairity = comp_cell{:};

                [position, velocity, force, propeller, forceDerivative, t, costValue, elapsedTime, freeFalling, expectedForce] = solve_propelled_mass(inputStruct);
                positions_result.(comp_cell{:}).elapsed_times(i) = (positions_result.(comp_cell{:}).elapsed_times(i) * (iter -1) + elapsedTime)/iter;
                positions_result.(comp_cell{:}).complementarity_average(i) = (positions_result.(comp_cell{:}).complementarity_average(i) * (iter -1) + mean(position .* force))/iter;
                positions_result.(comp_cell{:}).costValue(i) = (positions_result.(comp_cell{:}).costValue(i) * (iter -1) + costValue)/iter;
            end
        end
    end
    inputStruct.x0 = 0.1;
end

if displayFigures
    figure
    time_elapsed_matrix = [];
    for comp_cell = complementarities
        hold on
        plot(initial_positions, positions_result.(comp_cell{:}).elapsed_times)
        time_elapsed_matrix = [time_elapsed_matrix; positions_result.(comp_cell{:}).elapsed_times];
    end
    hold on
    plot(initial_positions, min(time_elapsed_matrix, [], 1), '*');
    legend([labels, 'Best Time'])

    figure
    for comp_cell = complementarities
        hold on
        plot(initial_positions, positions_result.(comp_cell{:}).complementarity_average)
    end
    legend(labels)

    figure
    for comp_cell = complementarities
        hold on
        plot(initial_positions, positions_result.(comp_cell{:}).costValue)
    end
    legend(labels)
end

disp('----- Initial height Variation -----')
for comp_cell = complementarities
    disp(['The ', comp_cell{:}, ' elapsed times is (', strjoin(cellstr(num2str(positions_result.(comp_cell{:}).elapsed_times(:))), ', '), ')'])
    disp(['The ', comp_cell{:}, ' complementarity average is (', strjoin(cellstr(num2str(positions_result.(comp_cell{:}).complementarity_average(:))), ', '), ')'])
    disp(['The ', comp_cell{:}, ' cost is (', strjoin(cellstr(num2str(positions_result.(comp_cell{:}).costValue(:))), ', '), ')'])
end

if ~use_dataset
    save('parameter_variation_height.mat', 'positions_result');
end


