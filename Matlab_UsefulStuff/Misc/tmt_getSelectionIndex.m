function selIndex = tmt_getSelectionIndex(time, startTime, endTime)
% TMT_GETSELECTIONINDEX return the index entries of time which are between startTime and endTime.
% Useful for time based plots were you easy want to plot from t=x to t=y.

%   TU Berlin --- Fachgebiet Regelungssystem
%   Author: Markus Valtin
%   Copyright © 2017 Markus Valtin. All rights reserved.
%
%   This program is free software: you can redistribute it and/or modify it under the terms of the 
%   GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
%
%   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

    [temp, iStart] = min(abs(time -startTime));
    [temp, iEnd] = min(abs(time -endTime));
    selIndex = [iStart : iEnd];
end
