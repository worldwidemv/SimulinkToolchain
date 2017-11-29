function [LibraryList, doAbort] = xsrt_getBuildUI(LibraryList)
%XSRT_GETBUILDUI gets a list of blocks to build

%   TU Berlin --- Fachgebiet Regelungssystem
%   Author: Markus Valtin
%   Copyright © 2017 Markus Valtin. All rights reserved.
%
%   This program is free software: you can redistribute it and/or modify it under the terms of the 
%   GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
%
%   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

nLibs = length(LibraryList);
hLib = 30;
h = (90 +nLibs*hLib);
gfig = groot();
x = (gfig.ScreenSize(3)-500)/2;
y = (gfig.ScreenSize(4)-h)/2;
CD = dialog('Position',[x y 500 h],'Name','Select which block libraries to setup.');

yOffset = h -40;
xOffset = 20;
nText = uicontrol('Parent', CD,'Style', 'text', 'String', 'Select which Block Libraries to Setup:', 'HorizontalAlignment', 'left',...
    'Position', [xOffset, yOffset, 400, 20], 'FontWeight', 'bold');

yOffset = h -70;
cbLibs = {};
for iLib = 1:nLibs
    if (LibraryList{iLib}.installed)
        textTemp = ['run the build script for ', LibraryList{iLib}.name,];
        defaultSel = true;
        cbLibs{iLib} = uicontrol('Parent', CD,'Style', 'radiobutton', 'String', textTemp, 'Value', defaultSel, 'Max', 1, 'FontName', 'FixedWidth', ...
            'Position', [xOffset, yOffset, 450, 25]);
        yOffset = yOffset -30;
    end
end

xOffset = 0;
btnAbort = uicontrol('Parent',CD, 'Position',[20+xOffset,  10, 210, 25], 'String','Skip the Setup', 'HorizontalAlignment', 'center', 'Callback','delete(gcf)');
btnClose = uicontrol('Parent',CD, 'Position',[250+xOffset, 10, 210, 25], 'String','Run the Build Scripts now', 'HorizontalAlignment', 'center', 'Callback',@cb_SetBuildState);

% Wait for d to close before running to completion
doAbort = true;
uiwait(CD);

    function cb_SetBuildState(popup,event)
        for i=1:length(cbLibs)
            if (isempty(cbLibs{i}))
                LibraryList{i}.runBuildScript = false;
            else
                LibraryList{i}.runBuildScript = cbLibs{i}.Value;
            end
        end
        delete(CD);
        doAbort = false;
    end
end
