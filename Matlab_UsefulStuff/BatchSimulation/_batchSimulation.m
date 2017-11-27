%% Batch Simulation Script
% runs a Simulink simulation for various parameter sets, see
% https://de.mathworks.com/help/simulink/programmatic.html
% https://de.mathworks.com/help/simulink/run-multiple-parallel-simulations.html
% https://de.mathworks.com/help/rtw/examples/using-rsim-target-for-batch-simulations.html

%   TU Berlin --- Fachgebiet Regelungssystem
%   Author: Markus Valtin
%   Copyright © 2017 Markus Valtin. All rights reserved.
%
%   This program is free software: you can redistribute it and/or modify it under the terms of the 
%   GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
%
%   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.


%% Usage:
% 0. rename the script to a valid Matlab name (e.g. without the _)
% 1. edit the SETUP / PREPARATION / (MODEL CONFIGURATION) / PRE SIMULATION / POST SIMULATION parts
%    of the script to our likings
% 2. edit your Simulink model and replace the parameters you want to change
%    by 'param.XXX', where 'XXX' is the parameter name you used in the
%    setup struct, also set the diagram inputs and outputs accordingly
% 3. run this script
% 4. write a batchEvaluation script for your usecase

%% lets go ...
% clear the enviorement
clear; clc; close all;

%% SETUP
% TODO by YOU
simulinkFilename = './TODO'; % without the .slx part!

setup = struct( 'TODO', [TODO], ...
                'TODO1', [TODO] );

outputVariableNames = {'TODO'};
outputDirectory = './output/';
outputFilenameStart = 'BatchSim';

%% PREPARATION
% TODO by YOU, e.g. get the input data...

% add the tmt_bs... functions 
%addpath('../');
% delete all old results
delete([outputDirectory, outputFilenameStart, '*.mat']);



%% Internal PREPARATION
disp(['SIMULINK Batch Simulation', char(10), '  -> creating parameter sets ....']);
% create the parameter sets for the simulations
setup = tmt_bsCreateParameterSets(setup);
disp(['   .... ', num2str(setup.bs_state.numberOfParameterSets), ' parameter sets created', char(10), '  -> load Simulink model', char(10)]);
% prepare result struct and the output
bs_result = struct('input', [], 'parameter', [], 'output', []);
outputFilenames = {};
if (~isdir(outputDirectory)), mkdir(outputDirectory); end
[stat, fa] = fileattrib(outputDirectory);
if (~fa.UserWrite), error('This script must be run in a writable directory'); end

%% open the simulink diagramm
systemModel = load_system(simulinkFilename);
modelConfigSet = getActiveConfigSet(systemModel);
modelConfig = modelConfigSet.copy;
set_param(modelConfig, 'ReturnWorkspaceOutputs','on');
%% MODEL CONFIGURATION, if needed
% TODO by YOU, e.g. set the target -> configSet.switchTarget('ert_linux.tlc',[]);
%   or other parmeters -> set_param(modelConfig,'AbsTol','1e-5', 'SaveOutput','on','OutputSaveName','yout')



%% run the simulations
tic; estimatedDuration = -1;
for i=1:setup.bs_state.numberOfParameterSets
    % get the current parameter set
    [setup, param, status]=tmt_bsGetParameterSet(setup);
    bs_result.parameter = param;
    % USE param.OUR_PARAMETER_FROM_SETUP in your Simulink diagram
    
    %% PRE SIMULATION
    % TODO by YOU, if needed
    
    
    
    %% SIMULATION
    disp(['  Running batch simulation for parameter set ', num2str(status(1)), '/', num2str(status(2)), ' (done in ', sprintf('%.2f', estimatedDuration), ' min):']);
    disp(param);
    % run the simulation
    simResult = sim(simulinkFilename, modelConfig);
    % done
    disp(['  --> Simulation done', char(10), char(10)]);
    
    
    %% POST SIMULATION
    % TODO by YOU, if needed

    
    
    
    %% SAVE THE SIMULATION RESULTS
    % add the simulation result to the data struct
    bs_result.output = struct();
    for i = 1:length(outputVariableNames)
        bs_result.output.(char(outputVariableNames{i})) = simResult.get(char(outputVariableNames{i}));
    end
    % save the data struct
    outputFilenames{end +1} = cellstr([outputDirectory, outputFilenameStart, '__', num2str(status(1))]);
    save(char(outputFilenames{end}), 'bs_result'); 
    
    %% calculate the time still needed
    timeRunning = toc;
    timeOneRun = timeRunning / status(1);
    estimatedDuration = (timeOneRun *(status(2) -status(1))) /60;
end;

%% save the list of filenames for batch evaluation
save([outputDirectory, 'bsOutputFilenames'], 'outputFilenames');

% done
disp(['Batch simulation for ', num2str(status(2)), '  parameter sets done.', char(10), 'It took ', sprintf('%.2f', toc/60), ' minutes to run the batch simulations.']);
