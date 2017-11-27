function [srtConfig] = xsrt_getSetup()
% XSRT_GETSETUP returns a struct with the SRT configuration values.

%   TU Berlin --- Fachgebiet Regelungssystem
%   Author: Markus Valtin
%   Copyright © 2017 Markus Valtin. All rights reserved.
%
%   This program is free software: you can redistribute it and/or modify it under the terms of the 
%   GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
%
%   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

    %% load the SRT default setup
    try
        load([fileparts(mfilename('fullpath')), filesep, 'srtConfig.mat']);
    catch
        srtConfig = struct();
        srtConfig.lctConfig = struct();
        srtConfig.lctConfig.sfuncFolderName = 'auto_generated';
    end

    %% load the user specific setup
    try
        userConfig = load([fileparts(mfilename('fullpath')), filesep, '.srtUserConfig.mat']);
        if (isfield(userConfig, 'srtUserConfig'))
            srtConfig.userConfig = userConfig.srtUserConfig;
        else
            srtConfig.userConfig = struct();
        end
    catch
        srtConfig.userConfig = struct();
    end
