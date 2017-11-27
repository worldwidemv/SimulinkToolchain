function [ assignedVariables, variableNames ] = tmt_getDataFromFile( inputFileName, definitionToUse, debugOutput )
%TMT_GETDATAFROMFILE loads the input file and assigns the variables specified
%   The function speeds up the assignment of Simulink experimental data,
%   available as time series array (see ToFile block).
%   The input file is loaded and the rows are assigned to variables
%   acording to the configuration supplied in "definitionToUse".
%
%   Inputs:
%       - inputFileName: full path to the input *.mat file containing the
%         time series array.
%       - definitionToUse: struct were each field describes a variable to
%         assign. The field name is the variable name to be used. The value
%         of the field are the rows from the input file used by this
%         variable. The structs can be nested to define structured
%         variables.

%   TU Berlin --- Fachgebiet Regelungssystem
%   Author: Markus Valtin
%   Copyright © 2017 Markus Valtin. All rights reserved.
%
%   This program is free software: you can redistribute it and/or modify it under the terms of the 
%   GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
%
%   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

assignedVariables = [0, 0];
variableNames = {};

%% load input file
DATA = load(inputFileName);
% get the fildname of the DATA struct
dataNames = fieldnames(DATA);
% which data to assing?
if (length(dataNames) == 1)
    % only one name -> use this dataset
    DATA = DATA.(dataNames{1});
else
    if (length(dataNames) > 1)
        % more than one name -> select dataset
        %data_name = questdlg({'The selected file contains more than one data set.'; ''; 'Which data set do you want to use?'}, ...
        %    'HSS - Select DataSet', ...
        %    dataNames{:}, dataNames{1});
        %DATA = DATA.(data_name);
        error('The selected file contains more than one data field, which is not supported (yet)!');
    else
        error('The selected file does not contain any data!');
    end
end
% check the data fiels
if (isstruct(DATA))
    %if (isfield(DATA ,'setup') && isstruct(DATA.setup))
    %else
    %    h = msgbox({'The selected DataSet does not have a field "setup"!'; ''; 'Only structs with a know type are allowed!'}, 'HSS - Select DataSet', 'error');
    %    uiwait(h);
    %    error('The selected DataSet does not have a field "setup"!');
    %end
    error('The selected file contains a "struct" which is not supported (yet)!');
else
    if (~isnumeric(DATA))
        error('The selected file contains neither a struct nor numeric matrix!');
    end
end
assignin('base', 'DATA', DATA);

%%
%% statistics
dataSize = size(DATA);
assignedVariables(2) = dataSize(1);

%%
%% read the definitions struct and create the variables 
excludeFields = {'setup'};
[ assignedVariables(1), variableNames ] = copyRawDataSet('', definitionToUse, dataSize, excludeFields);
if (isfield(definitionToUse, 'setup'))
    for j = 1:length(variableNames),
        if (isstruct(evalin('base', variableNames{j})))
            assignin('base', 'ABCDEFG_temp_variable_tmt_getDataFromFile_1234567890', definitionToUse.setup);
            evalString2 = [variableNames{j}, '.setup = ABCDEFG_temp_variable_tmt_getDataFromFile_1234567890;'];
            evalin('base', evalString2);
            evalString2 = ['clear(', char(39), 'ABCDEFG_temp_variable_tmt_getDataFromFile_1234567890', char(39), ');'];
            evalin('base', evalString2);
        end
    end
    
end

%%
%% debug output
if (debugOutput)
    disp(['   -> tmt_getDataFromFile:  file "', inputFileName, '" read']);
    disp(['                            ', num2str(assignedVariables(1)), ' from ', num2str(assignedVariables(2)), ' rows assigned']);
    disp(['                            variables created: "', strjoin(variableNames, '", "'), '"']);
    disp('');
end

% done

    function [ assignedVariables, variableNames ] = copyRawDataSet(fieldString, definitionStruct, dataSize, excludeFields)
        assignedVariables = 0;
        variableNames = {};
        if (isstruct(definitionStruct))
            fieldNames = fieldnames(definitionStruct);
            for i = 1:length(fieldNames),
                if ( any(strcmpi(fieldNames{i}, excludeFields)) )
                    % the field should be excluded -> got to next field
                    continue;
                end
                if (isstruct(definitionStruct.(fieldNames{i})))
                    % build the struct recursivly
                    if (~isempty(fieldString))
                        fieldStringTemp = [fieldString, '.'];
                    else
                        fieldStringTemp = fieldString;
                    end
                    [ assignedVariables_new, variableNames_new ] = copyRawDataSet([fieldStringTemp, fieldNames{i}], definitionStruct.(fieldNames{i}), dataSize, excludeFields);
                    if (isempty(fieldStringTemp))
                        variableNames{end +1} = fieldNames{i};
                    end
                    assignedVariables = assignedVariables + assignedVariables_new;
                    variableNames = [variableNames, variableNames_new];
                else %if (iscell(descStruct.(fieldNames{i})))
                    % get the rows
                    rawDataSelection = definitionStruct.(fieldNames{i});
                    if (rawDataSelection(end) <= dataSize(1))
                        if (~isempty(fieldString))
                            fieldStringTemp = [fieldString, '.'];
                        else
                            fieldStringTemp = fieldString;
                        end
                        copyRawData([fieldStringTemp, fieldNames{i}], rawDataSelection);
                        % stats
                        assignedVariables = assignedVariables + length(rawDataSelection);
                        if (isempty(fieldStringTemp))
                            variableNames{end +1} = fieldNames{i};
                        end
                    else
                        error(['The selected data set configuration has more predefined entries than available raw data rows!', char(10), 'Check the raw data and make sure the right configuration was selected!']);
                    end
                end
            end
        else
            % get the rows
            warning('The input data is not a struct! This is probaly an error! Check the assigned data!');
            rawDataSelection = definitionStruct;
            if (rawDataSelection(end) <= dataSize(1))
                copyRawData(fieldString, rawDataSelection);
                % stats
                assignedVariables = assignedVariables + length(rawDataSelection);
                if (isempty(strfind(fieldString, '.')))
                    variableNames{end +1} = fieldString;
                end
            else
                error(['The selected data set configuration has more predefined entries than available raw data rows!', char(10), 'Check the raw data and make sure the right configuration was selected!']);
            end
        end
    end

    function copyRawData(fieldString, rawDataSelection)
        % copy the data
        evalStringTemp = [fieldString, ' = DATA( [', num2str(rawDataSelection), '], : )', char(39), ';'];
        evalin('base', evalStringTemp);
    end

end

