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
    if ~iscell(LibList)
        error('srt_CreateLibLinux64: LibList Argument has to be a cell array! E.g. LibList = {''Lib1'',''Lib2''}');
    end
end

% Save current dir and cd to script dir
startcreatelibdir = pwd ;
cd(fileparts(mfilename('fullpath')));

%% Create log file and delete old contents
fclose(fopen('SRT_ErrorLogs/build.log','w'));

% Besides the Error Log file, also a diary is created which logs all output
log_name = ['srt_CreateLib_All_Output_' datestr(now,'yyyymmddHHMMSS') '.log'];
diary(['SRT_ErrorLogs/',log_name]);
diary on;

% add functions directory to the path
addpath(fullfile(pwd, 'Matlab_LibFunctions'));

cd 'SimulinkLib_linux64';

%% Create a list with all the library folders (all folders starting with 'Lib_')
libDirs = {};
noLibs = 0;

for i = 1:length(LibList)
    if length(LibList{i}) > 4
        if strcmp(LibList{i}(1:4), 'LIB_')
            noLibs = noLibs + 1;
            libDirs{noLibs} = LibList{i};
        end
    end
end

%% Create Main Control Lib

% simulink;
delete('srt_control.slx');
close_system('srt_control',0);
new_system('srt_control', 'Library');


%% Create List of all Libraries by cycling through sub-directories
LibraryList = cell(0);
LibraryPathList = cell(0);
counter = 0;
for DirNo = 1:length(libDirs)
   if exist(libDirs{DirNo}, 'dir') > 0 %check if directory exists
       subLibs = dir([libDirs{DirNo}, '/*.slx']);
       subLibs = {subLibs.name};
       for LibNo = 1:length(subLibs)
           counter = counter + 1;
           LibName = strrep(subLibs{LibNo}, '.slx', '');
           LibraryList{counter} = LibName;
           LibraryPathList{counter} = libDirs{DirNo};
       end
       
       if length(subLibs) > 0
           % Add to Matlab path
           addpath([pwd, '/', libDirs{DirNo}]);
       end
       
   else
       disp(['Error: Directory ', libDirs{DirNo},' does not exist']);
   end
end


%% Load Libraries into control Library

for i = 1:length(LibraryList)
    %Load Library
    load_system([LibraryPathList{i},'/',LibraryList{i},'.slx']);
    
    %Find Blocks in Library
    src_blocks = find_system(LibraryList{i},'SearchDepth',1,'type','block');
    
    %Add empty Subsystem for Sublibrary
    add_block('built-in/SubSystem', ['srt_control/',LibraryList{i}], 'Position', [100*i 50 (100*i+50) 100]); 
    for j = 1:length(src_blocks)
        dest_blocks = ['srt_control/', src_blocks{j}];
        add_block(src_blocks{j}, dest_blocks);
    end
    close_system([LibraryPathList{i},'/',LibraryList{i},'.slx']);
end


%% Save and Close New Library
set_param('srt_control','EnableLBRepository','on'); % TODO verify
save_system('srt_control');
close_system('srt_control');

%% Add Matlab path of the new library srt_control.slx
addpath(pwd); %Add This Path



%% Build all S-Functions
if BuildAllSfunctions == 1
    for DirNo = 1:length(libDirs)
       cd(libDirs{DirNo});
       subLibs = dir('*.m');
       subLibs = {subLibs.name};
       for i = 1:length(subLibs)
           if length(strfind(subLibs{i},'build')) > 0 % filname contains build -> must be build script
               if (length(strfind(subLibs{i},'ARM')) > 0) || (length(strfind(subLibs{i},'arm')) > 0)
                   if BuildARMSfunctions == 1
                       run(subLibs{i}); %run ARM build script
                   end
               else
                   run(subLibs{i}); %run build script
               end
           end
       end
       cd('..');
    end
end


%% Create documentation
%cd('..'); % back to simulink_libraries-folder
% create all necessary documentation files
%createDocumentation(LibraryList,LibraryPathList);

% remove path
%rmpath(genpath([pwd, '/Documentation']));

% addpath with subfolders to generate the help 
%addpath(genpath([pwd, '/Documentation']));

%% Save all added pathes
savepath;

%% Rename log file to add date and time
cd ..
newlogname = ['build_' datestr(now,'yyyymmddHHMMSS') '.log'];
movefile('SRT_ErrorLogs/build.log',['SRT_ErrorLogs/' newlogname]);
fprintf('\n\n\n');
fprintf('*********************************************\n');
fprintf('srt_CreateLibLinux64: The following errors occurred (also see: Error_Logs/%s):\n\n',newlogname);
type(['SRT_ErrorLogs/' newlogname]);
diary off;


%% Go back to the start directory
cd(startcreatelibdir);

end
