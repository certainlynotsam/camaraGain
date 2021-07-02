%% gainCalculator.m
%
% by Sam Daly
% This code takes a given number of .tif stacks corresponding to calculates
% the mean and variance is then calculated and plotted in order to find the
% gain of an EMCCD detector. 

clear all; close all; clc;

%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Specify the root folder containing .tif stacks and the root name (i.e.
% Int*.tif for Int1.tif, Int2.tif, Int3.tif... IntN.tif.

myFolder = 'E:\Agave\A&S_BIG_PUSH\Calibration\DH_calib\cropped';
power_ids = 'Int*.tif';
dark_ids = 'dark*.tif';

%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Check folder exists

if ~isfolder(myFolder)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s\nPlease specify a new folder.', myFolder);
    uiwait(warndlg(errorMessage));
    myFolder = uigetdir();
    if myFolder == 0
        return;
    end
end

%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Calculations

gain = calculateGain(power_ids, myFolder);

%offset = calculateOffset(dark_ids, myFolder);

%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Functions

function gain = calculateGain(filePrefix, myFolder);
filePattern = fullfile(myFolder, filePrefix);
theFiles = dir(filePattern);

for k = 1:length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(theFiles(k).folder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    
    info = imfinfo(fullFileName);
    imageStack = [];
    numberOfImages = length(info);
    
    for a = 1:numberOfImages
        currentImage = imread(fullFileName, a, 'Info', info);
        d = double(currentImage);
        mean1 = mean(d);
        mean2 = mean(mean1); %find average intensity
        diff = d - mean2; %difference image
        sqr = diff .^2;
        sum1 = sum(sqr);
        sum2 = sum(sum1);
        var = sum2/262144; %find the variance of the difference image 
        std = sqrt(var); 
            all_var(a) = var;
            all_std(a) = std;
            all_mean(a) = mean2;
    imageStack(:,:,a) = currentImage;
    end  
   
    variance(k) = mean(all_var);
    stand_deviation(k) = mean(all_std);
    tot_mean(k) = mean(all_mean);
end

figure
scatter(tot_mean,variance, 'k', 'LineWidth', 1.5);
c = polyfit(tot_mean,variance,1);
fprintf(['Equation is y = ' num2str(c(1)) 'x' num2str(c(2)) '\n'])
gain = c(1)/2;
fprintf('Camera gain is %4f\n', gain);
y_est = polyval(c,tot_mean);
hold on
plot(tot_mean,y_est,'r-.', 'LineWidth', 1.5)
hold off
ax = gca;
ax.FontSize = 14;
xlabel('Mean Intensity');
ylabel('Variance');
title('Conversion Gain Calibration')

end