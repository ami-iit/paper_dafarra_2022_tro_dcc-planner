if ~exist('plot_ci', 'var')
    plot_ci = true;
end

if plot_ci
    startFolder = '../CI/SpeedVariation/';
else
    startFolder = '../Review1/SpeedVariation/';
end

complementarityTypes = {'Classical', 'Dynamical', 'HyperbolicSecantInequality'};
speedValues = {'0.05', '0.06', '0.07'};
feet = {'left', 'right'};
for speed = speedValues
    for type = complementarityTypes
        disp("----------------------------------------")
        disp([type{:}, ' ', speed{:}])
        matFileName = dir([startFolder, '*', type{:}, '*_speed-', speed{:}, '*/*.mat']);
        if (isempty(matFileName))
            disp("DNF!!")
            continue
        end
        matFile = load([matFileName.folder, '/', matFileName.name]);
        meanTime = mean(matFile.computationalTime)
        stdTime = std(matFile.computationalTime)
        minTime = min(matFile.computationalTime)
        maxTime = max(matFile.computationalTime)
        for footCell = feet
            foot = footCell{:};
            disp(['-----' ,foot, ' complementarity'])
            accuracySum = zeros(length(matFile.stateTime),1);
            for index = 0 : 3
                pos = eval(['matFile.',foot, 'Point', int2str(index), 'Position'])';
                force = eval(['matFile.',foot, 'Point', int2str(index), 'Force'])';
                accuracySum = accuracySum + (pos(:,3) .* force(:,3));             
            end
            accuracySum(1) = 0.0; %The initial state
            accuracySum = accuracySum / 4;
            totMean = mean(accuracySum)
            totVar = std(accuracySum)
            minim = min(accuracySum)
            maxim = max(accuracySum)
        end
    end
end