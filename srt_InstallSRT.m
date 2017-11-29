%% Install script for the Soft-Realtime Simulink Toolbox

%   TU Berlin --- Fachgebiet Regelungssystem
%   Author: Markus Valtin
%   Copyright © 2017 Markus Valtin. All rights reserved.
%
%   This program is free software: you can redistribute it and/or modify it under the terms of the 
%   GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
%
%   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

fprintf('\nInstallation of the Soft-Realtime Simulink Toolbox\n===================================================\n\n');
startDirInstall = pwd();

%% Install the ERT_Linux scripts
cd(['ert_linux', filesep, 'ert_linux']);
fprintf('### Running ERT_Linux installation:\n   -> ');
ert_linux_setup();
fprintf('\n');

%% Add the LibFunctions to the path
cd(startDirInstall);
addpath('Matlab_LibFunctions');


%% Create List of all Libraries by cycling through sub-directories
dirList = dir(['SimulinkLib_linux64', filesep, 'LIB_*']);
LibraryList = {};

for iDir = 1:length(dirList)
    % check if directory exists and starts with LIB_
    if (isdir([dirList(iDir).folder, filesep, dirList(iDir).name]))
        LibraryList{end +1}.name = dirList(iDir).name;
        LibraryList{end}.path = dirList(iDir).folder;
        
        LibraryList{end}.buildScript = '';
        LibraryList{end}.installScript = '';
        mFiles = dir([LibraryList{end}.path, filesep, dirList(iDir).name, filesep, '*.m']);
        mFiles = {mFiles.name};
        for iMfile = 1:length(mFiles)
            % check if the filname contains build -> must be build script
            if contains(mFiles{iMfile},'build_','IgnoreCase',true)
                LibraryList{end}.buildScript = mFiles{iMfile};
                continue;
            end
            % check if the filname contains install -> must be install script
            if contains(mFiles{iMfile},'install_','IgnoreCase',true)
                LibraryList{end}.installScript = mFiles{iMfile};
                continue;
            end
        end
        % was this Lib already installed?
        if (exist([dirList(iDir).folder, filesep, dirList(iDir).name, filesep, '.installDone'], 'file'))
            LibraryList{end}.installed = true;
        else
            LibraryList{end}.installed = false;
        end
   end
end
if (isempty(LibraryList))
    fprintf('\n### NO Block libraries found! -> done\n\n');
    return;
end

%% Run the individual install scripts
% update the list what to install
[LibraryList, doAbort] = xsrt_getInstallUI(LibraryList);
if (doAbort), return; end
for iLib = 1:length(LibraryList)
    if (LibraryList{iLib}.runInstallScript)
        cd([LibraryList{iLib}.path, filesep, LibraryList{iLib}.name]);
        fprintf('\n### Running install script for "%s": %s\n', LibraryList{iLib}.name, LibraryList{iLib}.installScript);
        run(LibraryList{iLib}.installScript);
        fprintf('   -> done.\n');
        LibraryList{iLib}.installed = true;
    end
end
cd(startDirInstall);

%% Run the individual build scripts?
% update the list what to install
[LibraryList, doAbort] = xsrt_getBuildUI(LibraryList);
if (doAbort)
    fprintf('\n\n====================================================================\nThe installation of the Soft-Realtime Simulink Toolbox is done.\n\nYou must run the build script with the "srt_CreateLib" command!\n\n');
    return;
end
fprintf('\n\n====================================================================\nRunning the build scripts now. You can run the build script also with the "srt_CreateLib" command.\n\n');

LibNames = {};
for iLib = 1:length(LibraryList)
    if (LibraryList{iLib}.runBuildScript)
        LibNames{end+1} = LibraryList{iLib}.name;
    end
end
srt_CreateLib(LibNames);
cd(startDirInstall);

fprintf('\n\n====================================================================\nThe installation of the Soft-Realtime Simulink Toolbox is done.\n\nYou can run the build script again with the "srt_CreateLib" command (necessary after upgrades)!\n\n');
