function [startDir, libDir, sfuncFolderName, srtAddPath, defs]=xsrt_buildLibScriptInitLCT(buildScriptName)
% XSRT_BUILDLIBSCRIPTINIT initializes the Matlab enviroment for SRT Simulink library build scripts.

%   TU Berlin --- Fachgebiet Regelungssystem
%   Author: Markus Valtin
%   Copyright © 2017 Markus Valtin. All rights reserved.
%
%   This program is free software: you can redistribute it and/or modify it under the terms of the 
%   GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
%
%   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

    %% get the SRT configuration
    srtConfig = xsrt_getSetup();
    
    %% Save current dir and cd to script dir
    startDir = pwd ;
    libDir = fileparts(buildScriptName);
    cd(libDir);

    %% Create the sfunc folder, where all S-functions will be generated
    if (~isdir(['.', filesep, srtConfig.lctConfig.sfuncFolderName]))
        mkdir(srtConfig.lctConfig.sfuncFolderName);
    end
    delete([srtConfig.lctConfig.sfuncFolderName, filesep, '*']);
    sfuncFolderName = srtConfig.lctConfig.sfuncFolderName;

    %% Initialize SRT structure
    srtAddPath = { [libDir, filesep, sfuncFolderName] };
    
    %% Initialize LCT structures
    defs = {};
