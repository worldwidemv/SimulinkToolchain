%% tmt_bsGetParameterSet
function [setup, param, status]=tmt_bsGetParameterSet(setup)
% INPUT:
% setup: struct with fieldname=param_name and value= [all possible values]
%           + 'bs_comb' and 'bs_state'
%       ---- run tmt_bsCreateParameterSet to get correct Input

%   TU Berlin --- Fachgebiet Regelungssystem
%   Author: Markus Valtin
%   Copyright © 2017 Markus Valtin. All rights reserved.
%
%   This program is free software: you can redistribute it and/or modify it under the terms of the 
%   GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
%
%   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

% check if the input is valid
if isstruct(setup) && isfield(setup,'bs_state')
    %run tmt_bsCreateParameterSet to get correct Input
    
    % check if the input is valid
    if (setup.bs_state.currentParameterSet > setup.bs_state.numberOfParameterSets)
        setup.bs_state.currentParameterSet = setup.bs_state.numberOfParameterSets;
        warning('No valid Parameter-Set left!');
    end
    % looping over parameter in the current parameter set and creating struct
    for i=1:setup.bs_state.numberOfParameters
        param.(setup.bs_state.legend{i}) = setup.bs_state.parameterSets{ setup.bs_state.currentParameterSet, i };
    end;
    
    % add the status output
    status = [setup.bs_state.parameterSets{ setup.bs_state.currentParameterSet, setup.bs_state.numberOfParameters +1},...
        setup.bs_state.parameterSets{ setup.bs_state.currentParameterSet, setup.bs_state.numberOfParameters +2} ];
    
    % increase the current parameter-set counter
    setup.bs_state.currentParameterSet = setup.bs_state.currentParameterSet +1;
else
    error('Parameter-Sets could not be extracted because the bs_state field is missing! -> Run tmt_bsCreateParameterSet to get correct Input!')
end
end
