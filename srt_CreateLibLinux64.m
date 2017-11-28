function [] = srt_CreateLibLinux64(LibList)
% TEMP solution to build the SRT modules ...
%
% srt_CreateLib(LibList) creates the simulink modules for the Soft-Realtime Toolbox (SRT)
%
% Parameters: 
%   LibList = Cell array with the Libary names you want to use ...
%   e.g. srt_CreateLib({'LIB_RehaMovePro', 'LIB_XXX'})

%   TU Berlin --- Fachgebiet Regelungssystem
%   Author: Markus Valtin
%   Copyright © 2017 Markus Valtin. All rights reserved.
%
%   This program is free software: you can redistribute it and/or modify it under the terms of the 
%   GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
%
%   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.


%% Use standard definition if parameters not specified
BuildAllSfunctions = 1;
BuildARMSfunctions = 0;

if nargin < 1
    LibList = {};
else
    if ~iscell(LibList)
        error('srt_CreateLibLinux64: LibList Argument has to be a cell array! E.g. LibList = {''Lib1'',''Lib2''}');
    end
end

%% Save current dir and cd to script dir
startcreatelibdir = pwd ;
cd(fileparts(mfilename('fullpath')));

%% Create log file and delete old contents
fclose(fopen('BuildLogs/build.log','w'));

% Besides the Error Log file, also a diary is created which logs all output
log_name = ['createLib_' datestr(now,'yyyymmddHHMMSS') '__All.log'];
diary(['BuildLogs/',log_name]);
diary on;
fprintf('Building the Simulink Soft-Realtime toolbox ....\n\n');

% Add functions directory to the path
addpath(fullfile(pwd, 'Matlab_LibFunctions'));

%% Create a list with all the library folders (all folders starting with 'Lib_')
cd('SimulinkLib_linux64');

if (isempty(LibList))
    dirList = dir(['.', filesep, 'LIB_*']);
    LibList = { dirList.name };
end



%% Create List of all Libraries by cycling through sub-directories
LibraryList = {};
for iDir = 1:length(LibList)
    % check if directory exists and starts with LIB_
    if (isdir(LibList{iDir}) && (length(LibList{iDir}) > 4) && strcmp(LibList{iDir}(1:4), 'LIB_'))
       simFiles = dir([LibList{iDir}, '/*.slx']);
       simFiles = {simFiles.name};
       for iSubLib = 1:length(simFiles)
           LibName = strrep(simFiles{iSubLib}, '.slx', '');
           LibraryList{end +1}.name = LibName;
           LibraryList{end}.path = LibList{iDir};
       end
   else
       warning('Error: Directory "%s" is not valid!', LibList{iDir});
   end
end

%% Close Main Control Lib
delete('srt_control_lib.slx');
close_system('srt_control_lib',0);

%% Build all S-Functions
if (BuildAllSfunctions)
    for iLib = 1:length(LibraryList)
       cd(LibraryList{iLib}.path);
       
       mFiles = dir('*.m');
       mFiles = {mFiles.name};
       for iMfile = 1:length(mFiles)
           % check if the filname contains build -> must be build script
           if contains(mFiles{iMfile},'build','IgnoreCase',true)
               % check if the filname contains arm or ARM for the arm platform
               if contains(mFiles{iMfile},'arm','IgnoreCase',true)
                   if (BuildARMSfunctions)
                       fprintf('\n** %s ARM ******************************************\n\n', LibraryList{iLib}.name);
                       run(mFiles{iMfile}); %run ARM build script
                   end
               else
                   fprintf('\n** %s **********************************************\n\n', LibraryList{iLib}.name);
                   run(mFiles{iMfile}); %run build script
               end
           end
       end
       
       cd('..');
    end
end
fprintf('\n************************************************\n\n');

%% Create Main Control Lib
% get the SRT configuration
srtConfig = xsrt_getSetup();
new_system('srt_control_lib', 'Library');

%% Load Libraries into control Library
for iLib = 1:length(LibraryList)
    %Load Library
    load_system([LibraryList{iLib}.path, filesep , srtConfig.lctConfig.sfuncFolderName, filesep, LibraryList{iLib}.name,'.slx']);
    
    %Find Blocks in Library
    src_blocks = find_system(LibraryList{iLib}.name,'SearchDepth',1,'type','block');
    
    %Add empty Subsystem for Sublibrary
    add_block('built-in/SubSystem', ['srt_control_lib/',LibraryList{iLib}.name], 'Position', [100*iLib 50 (100*iLib+50) 100]); 
    for j = 1:length(src_blocks)
        dest_blocks = ['srt_control_lib/', src_blocks{j}];
        add_block(src_blocks{j}, dest_blocks);
    end
    close_system([LibraryList{iLib}.path, filesep , srtConfig.lctConfig.sfuncFolderName, filesep, LibraryList{iLib}.name,'.slx']);
end

%% Save and Close New Library
set_param('srt_control_lib','EnableLBRepository','on'); % TODO verify
save_system('srt_control_lib');
close_system('srt_control_lib');

%% Add Matlab path of the new library srt_control.slx
addpath(pwd); %Add This Path



%% Create documentation
%cd('..'); % back to simulink_libraries-folder
% create all necessary documentation files
%createDocumentation(LibraryList.name, LibraryList.path);
% remove path
%rmpath(genpath([pwd, '/Documentation']));
% addpath with subfolders to generate the help 
%addpath(genpath([pwd, '/Documentation']));

%% Save all added pathes
savepath();
fprintf('\n\n');
fprintf('Building the Simulink Soft-Realtime toolbox is done!\n\n');
cd('..');

%% Rename log file to add date and time
newlogname = ['createLib_' datestr(now,'yyyymmddHHMMSS') '__Errors.log'];
movefile('BuildLogs/build.log',['BuildLogs/' newlogname]);
errorText = fileread(['BuildLogs/' newlogname]);
if (~isempty(errorText))
    fprintf('srt_CreateLibLinux64: The following errors occurred (also see: BuildLogs/%s):\n\n',newlogname);
    disp(errorText);
end
diary off;


%% Go back to the start directory
cd(startcreatelibdir);

end