%% Batch Evaluation for the simple PID Cexample

%   TU Berlin --- Fachgebiet Regelungssystem
%   Author: Markus Valtin
%   Copyright © 2017 Markus Valtin. All rights reserved.
%
%   This program is free software: you can redistribute it and/or modify it under the terms of the 
%   GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
%
%   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

% get the filenames of the last batch simulation
outputDirectory = './output/';
load([outputDirectory, 'bsOutputFilenames']); % dir works also ...

% prepare the figures
f1 = figure(1); hold on;
legend1 = {};
f2 = figure(2); hold on;
legend2 = {};

%% load every batch simulation result and process the result
for i = 1:length(outputFilenames)
    bsFilename = char(outputFilenames{i});
    
    % load the data
    load(bsFilename);
    
    %% process the data
    if (strcmp(bs_result.parameter.input, './step.mat'))
        figure(f1); hold on;
        plot(bs_result.output.simout);
        legend1{end +1} = ['ParameterSet ', num2str(i)]; 
    else
        figure(f2); hold on;
        plot(bs_result.output.simout);
        legend2{end +1} = ['ParameterSet ', num2str(i)];
    end
end

%% final touches
figure(f1); hold off;
grid on;
title('Input = Step');
legend(legend1, 'Location','southeast');

figure(f2); hold off;
grid on;
title('Input = Pulse');
legend(legend2);
