%%  Description: Post-processing TEMPLATE for experiment data

%   TU Berlin --- Fachgebiet Regelungssystem
%   Author: Markus Valtin
%   Copyright © 2017 Markus Valtin. All rights reserved.
%
%   This program is free software: you can redistribute it and/or modify it under the terms of the 
%   GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
%
%   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

%% Load all nessesary files
cd(fileparts(mfilename('fullpath')));
if (exist('functions', 'dir')), addpath([pwd, '/functions']); end

%% Data Files
% first parts (filename + definition) are mandatory
files = {
'data_XYZ/XXX.mat'     'definition_XXX'  'optionA = 3' '1.4'
};

files_to_plot = 1;

%% Setup
% print / plot debug informations
do_debug = true;

% get the known data set definitions struct -> make sure all fie
dataSetDefinitions = my_knownDataSets();

%% 
%% automated data processing
close('all');
% selected files loop
for ftp = files_to_plot,
    %% Load the file and assign the variables
    [path, fname, ext] = fileparts(files{ftp,1});
    disp(['  Processing: ', fname, ext, ' ...']);
    tmt_getDataFromFile( files{ftp,1}, dataSetDefinitions.(files{ftp,2}), do_debug );

    %% post assignment cleanups
    % get options example
    eval(files{ftp,3});
    eval(['optionB = ', files{ftp,4}, ';'])
    disp(optionB);
    
    %% specific script parts

end
