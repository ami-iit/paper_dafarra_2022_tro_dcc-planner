close all;

addpath('./labelpoints')
addpath('./export_fig')

if ~exist('plot_ci', 'var')
    plot_ci = true;
end

if plot_ci
    startFolder = '../CI/';
    outputPath = '../../generated/CI/';
else
    startFolder = '../Review1/';
    outputPath = '../../generated/Review1/';
end


speedVariationFolder = 'SpeedVariation/';
speedValue = '0.05';
parametersVariationFolder = 'ParameterVariations/';
outputFileName = 'ParametersVariation.pdf';

classical = struct();
classical.name = 'Classical';
classical.legendName = 'Relaxed';
classical.parameters = {'classicalComplementarityTolerance'};
classical.parametersLabel = {'$\epsilon$'};
classical.meanTimes = [];
classical.accuracy = [];
classical.labels = {};
classical.marker = '^';

dynamical = struct();
dynamical.name = 'Dynamical';
dynamical.legendName = 'Dynamically Enforced';
dynamical.parameters = {'dynamicComplementarityUpperBound', 'complementarityDissipation'};
dynamical.parametersLabel = {'$\varepsilon$', '$K_{bs}$'};
dynamical.meanTimes = [];
dynamical.accuracy = [];
dynamical.labels = {};
dynamical.marker = 'o';

hyperbolicSecant = struct();
hyperbolicSecant.name = 'HyperbolicSecantInequality';
hyperbolicSecant.legendName = 'Hyperbolic Secant';
hyperbolicSecant.parameters = {'normalForceHyperbolicSecantScaling', 'normalForceDissipationRatio'};
hyperbolicSecant.parametersLabel = {'$k_h$', '$K_{f,z}$'};
hyperbolicSecant.meanTimes = [];
hyperbolicSecant.accuracy = [];
hyperbolicSecant.labels = {};
hyperbolicSecant.marker = 'h';

complementarityTypes = {classical, dynamical, hyperbolicSecant};
feet = {'left', 'right'};

figure('Renderer', 'painters', 'Position', [10 10 900 500])

for complementarityIndex = 1 : length(complementarityTypes)
    
    complementarityName = complementarityTypes{complementarityIndex}.name;
    
    matFileNames = dir([startFolder, parametersVariationFolder, '*', complementarityName, '*_speed-', speedValue, '*/*.mat']);
    matFileNames = [matFileNames', dir([startFolder, speedVariationFolder, '*', complementarityName, '*_speed-', speedValue, '*/*.mat'])];
    
    for matFileName = matFileNames
        
        matFile = load([matFileName.folder, '/', matFileName.name]);
        
        complementarityTypes{complementarityIndex}.meanTimes = ...
            [complementarityTypes{complementarityIndex}.meanTimes ...
            mean(matFile.computationalTime)];
        
        accuracySum = zeros(length(matFile.stateTime),1);
        
        for footCell = feet
            foot = footCell{:};
            for index = 0 : 3
                pos = eval(['matFile.',foot, 'Point', int2str(index), 'Position'])';
                force = eval(['matFile.',foot, 'Point', int2str(index), 'Force'])';
                accuracySum = accuracySum + (pos(:,3) .* force(:,3));
            end
        end
        accuracySum(1) = 0.0;
                
        complementarityTypes{complementarityIndex}.accuracy = ...
            [complementarityTypes{complementarityIndex}.accuracy ...
            mean(accuracySum / 8)];
                    
        label = '(';
        for param = 1 : length(complementarityTypes{complementarityIndex}.parameters)
            paramName = complementarityTypes{complementarityIndex}.parameters{param};
            paramLabel = complementarityTypes{complementarityIndex}.parametersLabel{param};
            paramValue = eval(['matFile.settings.', paramName]);
            label = [label, paramLabel,' ', num2str(paramValue)];
            if (param < length(complementarityTypes{complementarityIndex}.parameters))
                label = [label, ', ']; %[label, ',', newline];
            end
        end
        label = [label,')'];
        complementarityTypes{complementarityIndex}.labels = ...
            [complementarityTypes{complementarityIndex}.labels ...
            label];
    end
    hold on
    scatter(complementarityTypes{complementarityIndex}.meanTimes, ...
        complementarityTypes{complementarityIndex}.accuracy, 48, ...
        complementarityTypes{complementarityIndex}.marker,...
        'filled','s', 'DisplayName', complementarityTypes{complementarityIndex}.legendName);
    legend('-DynamicLegend');

    labelpoints(complementarityTypes{complementarityIndex}.meanTimes, ...
        complementarityTypes{complementarityIndex}.accuracy, ...
        complementarityTypes{complementarityIndex}.labels,...
        'position', 'N', 'buffer', 0.5, 'adjust_axes', 1,...
        'rotation', 45, ...
        'interpreter', 'latex', 'FontSize', 11);
end
ylim([0, 15.1e-3])

if ~plot_ci
    xlim([4.9, 7.5])
end


h = legend();
set(h,'Location', 'northoutside')
set(h,'Orientation','horizontal')
set(h,'Interpreter','latex')
set(h,'FontSize', 16);
x_label = xlabel('Average Computational Time (s)');
set(x_label, 'Interpreter', 'latex');
set(x_label, 'FontSize', 16);
y_label = ylabel('Accuracy $p_z \cdot f_z$');
set(y_label,'Interpreter','latex');
set(y_label,'FontSize', 16);

if ~exist(outputPath, 'dir')
      mkdir(outputPath)
end
export_fig('-transparent', [outputPath, outputFileName])


