function xsrt_addpath(pathToAdd)
%% XSRT_ADDPATH adds the paths given to the Matlab path

%   TU Berlin --- Fachgebiet Regelungssystem
%   Author: Markus Valtin
%   Copyright © 2017 Markus Valtin. All rights reserved.
%
%   This program is free software: you can redistribute it and/or modify it under the terms of the 
%   GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
%
%   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

    if (iscell(pathToAdd))
        for j = 1:length(pathToAdd)
            addpath(pathToAdd{j});
        end
    elseif (ischar(pathToAdd))
        addpath(pathToAdd);
    end
