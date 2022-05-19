%% TO AVOID ERRORS GENERATE THESE PLOTS USING A SINGLE SCREEN AT 1920X1080 RESOLUTION WITH NO SCALING (s  = settings;s.matlab.desktop.DisplayScaleFactor)

close all;
clear all;

addpath('./export_fig')

complementarityTypes = {'Classical', 'Dynamical', 'HyperbolicSecantConstraint'};
paths = struct();

paths.Classical.data = '../Review1/SpeedVariation/2021-8-23_10_55_38_Classical_incr-0.100_speed-0.050/log-2021-8-23_10_55_382021-8-23_11_11_31.mat';
paths.Classical.figures = '../../generated/Review2/Classical';
paths.Dynamical.data = '../Review1/SpeedVariation/2021-8-23_10_27_12_Dynamical_incr-0.100_speed-0.050/log-2021-8-23_10_27_122021-8-23_10_40_24.mat';
paths.Dynamical.figures = '../../generated/Review2/Dynamical';
paths.HyperbolicSecantConstraint.data = '../Review1/SpeedVariation/2021-8-23_10_42_13_HyperbolicSecantInequality_incr-0.100_speed-0.050/log-2021-8-23_10_42_132021-8-23_10_54_48.mat';
paths.HyperbolicSecantConstraint.figures = '../../generated/Review2/HyperbolicSecantConstraint';

feet = {'left', 'right'};
yAxisLabel = struct();
yAxisLabel.Force = 'Force (N)';
yAxisLabel.Position = 'Position (m)';
yAxisLabel.LinearMomentum = 'Linear Momentum (kg m/s)';
yAxisLabel.comPosition = 'Position (m)';
yAxisLabel.AngularMomentum = 'Angular Momentum (kg m$^2$/s)';

yLimits = struct();
% yLimits.Position = [-0.4, 1.2];
% yLimits.Force = [-20, 100];
% yLimits.LinearMomentum = [-10, 10];
% yLimits.AngularMomentum = [-11, 11];
% yLimits.comPosition = [-0.3, 1.0];
% yLimits.computationalTime = [0, 50];
% yLimits.accuracy = [-0.001, 0.035];

yLimits.Position = [-0.4, 0.8];
yLimits.Force = [-20, 100];
yLimits.LinearMomentum = [-5, 5];
yLimits.AngularMomentum = [-2, 2];
yLimits.comPosition = [-0.3, 0.8];
yLimits.computationalTime = [0, 45];
yLimits.accuracy = [-0.001, 0.02];

momentumIndeces = struct();
momentumIndeces.LinearMomentum = 1:3;
momentumIndeces.AngularMomentum = 4:6;

signalTypes = {'Position', 'LinearMomentum', 'AngularMomentum', 'comPosition'};


domain = [0 20];

for typeCell = complementarityTypes
    type = typeCell{:};
    load(paths.(type).data);
    if ~exist(paths.(type).figures, 'dir')
        mkdir(paths.(type).figures)
    end

    disp(['Complementarity: ', settings.complementarity])
    disp(['Mean time: ', num2str(mean(computationalTime))])
    disp(['STD time: ', num2str(std(computationalTime))])
    disp(['Max time: ', num2str(max(computationalTime))])
    disp(['Min time: ', num2str(min(computationalTime))])
    figure('Renderer', 'painters', 'Position', [10 10 900 500])
    plot(computationalTime);
    xlim([0 100])
    ylim(yLimits.computationalTime)
    plot_aesthetic_nolegend('', 'Run',  'Time (s)', '', 16)
    fileName = [paths.(type).figures,'/ComputationalTime'];
    export_fig('-transparent', [fileName, '.pdf'])

    for signalTypeCell = signalTypes
        signalType = signalTypeCell{:};
        if((~strcmp(signalType, 'LinearMomentum')) && (~strcmp(signalType, 'AngularMomentum')) && (~strcmp(signalType, 'comPosition')) )
            for footCell = feet
                foot = footCell{:};
                for index = 0
                    figure('Renderer', 'painters', 'Position', [10 10 900 500])
                    plot3DSignal(stateTime, eval([foot, 'Point', int2str(index), signalType])',  ...
                        domain, yLimits.(signalType), yAxisLabel.(signalType));
                    fileName = [paths.(type).figures,'/',foot, 'Point', int2str(index), signalType];
                    export_fig('-transparent', [fileName, '.pdf'])
                end
            end
        elseif (strcmp(signalType, 'LinearMomentum') || strcmp(signalType, 'AngularMomentum'))
            figure('Renderer', 'painters', 'Position', [10 10 900 500])
            plot3DSignal(stateTime, momentumInCoM(momentumIndeces.(signalType), :)',  ...
                domain, yLimits.(signalType), yAxisLabel.(signalType));
            fileName = [paths.(type).figures,'/',signalType];
            export_fig('-transparent', [fileName, '.pdf'])


        elseif (strcmp(signalType, 'comPosition'))
            figure('Renderer', 'painters', 'Position', [10 10 900 500])
            plot3DSignal(stateTime, comPosition',  ...
                domain, yLimits.(signalType), yAxisLabel.(signalType));
            fileName = [paths.(type).figures,'/',signalType];
            export_fig('-transparent', [fileName, '.pdf'])

        end
    end

    fileName = [paths.(type).figures,'/PointVsForce'];
    figure('Renderer', 'painters', 'Position', [10 10 1800 1000])
    for index = 0 : 3
        for footCell = feet
            foot = footCell{:};
            pos = eval([foot, 'Point', int2str(index), 'Position'])';
            force = eval([foot, 'Point', int2str(index), 'Force'])';
            subplot(2,2,index+1)
            hold on
            plotSignalComparison(stateTime, pos(:,3),  force(:,3),...
                domain, [-0.005 0.08], yAxisLabel.Position, ...
                [-20, 100], yAxisLabel.Force, 24);
        end
        h = legend({'Position (L)', 'Position (R)',...
            'Force (L)', 'Force (R)'}, 'Location', 'northoutside', 'Orientation','horizontal');
        set(h,'Interpreter','latex')
        set(h,'FontSize', 16);
    end
    export_fig('-transparent', [fileName, '.pdf'])

    figure('Renderer', 'painters', 'Position', [10 10 1800 500])
    fileName = [paths.(type).figures,'/','Complementarity'];

    i = 1;
    for footCell = feet
        foot = footCell{:};
        footCapitalized = foot;
        idx=regexp([' ' footCapitalized],'(?<=\s+)\S','start')-1;
        footCapitalized(idx)=upper(footCapitalized(idx));
        subplot(1,2,i);
        accuracySum = zeros(length(stateTime),1);
        for index = 0 : 3
            pos = eval([foot, 'Point', int2str(index), 'Position'])';
            force = eval([foot, 'Point', int2str(index), 'Force'])';
            hold on
            accuracy = pos(:,3) .* force(:,3);
            accuracy(1) = 0.0;
            plotSignal(stateTime, accuracy, domain, yLimits.accuracy,...
                '$p_z \cdot f_z$', footCapitalized, 22);
            accuracySum = accuracySum + (pos(:,3) .* force(:,3));
        end
        accuracySum(1) = 0.0; %The initial state
        accuracySum = accuracySum / 4;
        totMean = mean(accuracySum)
        totVar = std(accuracySum)
        %minim = min(accuracySum)
        maxim = max(accuracySum)
        hold on
        line(domain, [totMean, totMean],'Color','k', 'LineStyle', '--')
        i = i+1;
    end
    export_fig('-transparent', [fileName, '.pdf'])

end
