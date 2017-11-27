function base_path = xsrt_getBaseToolboxPath(varargin)
%XSRT_GETBASETOOLBOXPATH returns the local path tho the TUB Control Matlab Toolbox
%   path = XSRT_GETBASETOOLBOXPATH(type, library_name) returns the local
%   path to the TUB Control Matlab Toolbox or to a specific library within
%   the toolbox.
%
%   Both parameter are optional with the following defaults: 
%   - type = toolbox
%   - library_name = SimulinkLib_linux64

%   TU Berlin --- Fachgebiet Regelungssystem
%   Author: Markus Valtin
%   Copyright © 2017 Markus Valtin. All rights reserved.
%
%   This program is free software: you can redistribute it and/or modify it under the terms of the 
%   GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
%
%   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

    %% check the arguments
    p = inputParser;
    defaultType = 'toolbox';
    defaultLib  = 'SimulinkLib_linux64';
    expectedTypes = {'toolbox', 'lib', 'library'};

    addOptional(p,'type', defaultType, @(x) any(validatestring(x,expectedTypes)));
    addOptional(p,'lib_name', defaultLib, @ischar);
    parse(p,varargin{:});
    type = p.Results.type;
    lib_name = p.Results.lib_name;
    % use only library
    if ( strcmp(type, 'lib') )
        type = 'library';
    end
    
    %% get the path to this function
    searchForFunctionName = 'xsrt_getBaseToolboxPath.m';
    fullpath = which(searchForFunctionName);

    %% check path and return the requested result
    if ( ~isempty(fullpath) )
        [pathstr,name,ext] = fileparts(fullpath);
        % strip the last directory ("./Matlab_LibFunctions") from the path
        pathstr = fileparts(pathstr);
        % what is expectedd ?
        switch (type)
            case 'toolbox'
                base_path = [pathstr, filesep];
            case 'library'
                if ( nargin < 2 || strcmp(lib_name, '') )
                    warning('A valid name of a library is expected as argument 2, if "type" is "library"! Using the default "SimulinkLib_linux64"!')
                    lib_name  = 'SimulinkLib_linux64';
                end
                base_path = fullfile(pathstr, lib_name, filesep);
            otherwise
               error('Unexpected type "%s" as argument 1!', type);
        end
        
        %% chek if base_path exist if it is not empty
        if ( ~isempty(base_path) )
           if ( ~isdir(base_path) )
               % the base_path string is not valid -> throw an error
               error('The %s path "%s" is not a valid path!', type, base_path);
           end
        end
    else
        error('The function %s was not found by Matlab!', searchForFunctionName);
    end
end
