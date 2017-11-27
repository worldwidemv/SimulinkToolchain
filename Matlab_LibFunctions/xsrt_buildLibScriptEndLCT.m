function [ successful ]=xsrt_buildLibScriptEndLCT(startDir, libDir, libName, sfuncFolderName, srtAddPath, defs)
% XSRT_BUILDLIBSCRIPTENDLCT finishes the Matlab Legacy Code Tool and compiles each block and adds the block to the local SRT setup.

%   TU Berlin --- Fachgebiet Regelungssystem
%   Author: Markus Valtin
%   Copyright © 2017 Markus Valtin. All rights reserved.
%
%   This program is free software: you can redistribute it and/or modify it under the terms of the 
%   GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
%
%   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

    successful = false;
    
    %% get the SRT configuration
    srtConfig = xsrt_getSetup();
    
    %% go to the directory where the sfunctions should be build
    cd(sfuncFolderName);
    
    try
        %% compile all blocks
        for j = 1:length(defs)
            legacy_code('sfcn_tlc_generate', defs{j});
            legacy_code('generate_for_sim', defs{j});
        end
        % generate rtwmakecfg script
        legacy_code('rtwmakecfg_generate', cell2mat(defs));
        xsrt_addPath(srtAddPath);
        cd(startDir);
        successful = true;
    catch exception
        %% handle errors
        msgString = getReport(exception);
        disp(msgString);
        warnString = ['ERROR DURING COMPILATION OF LIB_', libName, ' PALLET'];
        warning(warnString);
        fid = fopen('../../../SRT_ErrorLogs/build.log','a');
        fprintf(fid, '\n%s\n%s\n', warnString, msgString);
        fclose(fid);
        cd(startDir);
        return;
    end
