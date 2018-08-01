function [LibraryList, doAbort] = xsrt_getInstallUI(LibraryList)
%XSRT_GETINSTALLUI get a list of blocks to install

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
x = (gfig.ScreenSize(3)-540)/2;
y = (gfig.ScreenSize(4)-h)/2;
CD = dialog('Position',[x y 740 h],'Name','Select which block libraries to install.');

yOffset = h -40;
xOffset = 20;
nText = uicontrol('Parent', CD,'Style', 'text', 'String', 'Select which Block Libraries to Install:', 'HorizontalAlignment', 'left',...
    'Position', [xOffset, yOffset, 700, 20], 'FontWeight', 'bold');

yOffset = h -70;
cbLibs = {};
for iLib = 1:nLibs
    textTemp = ['run the install script for ', LibraryList{iLib}.name];
    if (LibraryList{iLib}.installed)
        defaultSel = false; 
        textTemp = [textTemp, ' (already installed)'];
    else
        defaultSel = true;
    end
    cbLibs{end+1} = uicontrol('Parent', CD,'Style', 'radiobutton', 'String', textTemp, 'Value', defaultSel, 'Max', 1, 'FontName', 'FixedWidth', ...
        'Position', [xOffset, yOffset, 720, 25]);
         yOffset = yOffset -30;
end

xOffset = 0;
btnAbort = uicontrol('Parent',CD, 'Position',[120+xOffset,  10, 230, 25], 'String','Abort', 'HorizontalAlignment', 'center', 'Callback','delete(gcf)');
btnClose = uicontrol('Parent',CD, 'Position',[390+xOffset, 10, 230, 25], 'String','Install the Block Libraries', 'HorizontalAlignment', 'center', 'Callback',@cb_SetInstallState);

% Wait for d to close before running to completion
doAbort = true;
uiwait(CD);

    function cb_SetInstallState(popup,event)
        for i=1:length(cbLibs)
            LibraryList{i}.runInstallScript = cbLibs{i}.Value;
        end
        delete(CD);
        doAbort = false;
    end
end
