%% tmt_bsCreateParameterSet
function [setup]=tmt_bsCreateParameterSets(setup)
% Input
% setup: struct with fieldname=param_name and value= [all possible values]

%   TU Berlin --- Fachgebiet Regelungssystem
%   Author: Markus Valtin
%   Copyright © 2017 Markus Valtin. All rights reserved.
%
%   This program is free software: you can redistribute it and/or modify it under the terms of the 
%   GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
%
%   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

if ~isfield(setup,'bs_state')
    %bs_state not present yet -> create the parameter sets
    
    %get legend of combination matrix
    tempFieldNames = fieldnames(setup)';
    
    % set up the bs_state struct
    setup.bs_state = struct();    
    setup.bs_state.legend = {};
    
    %% check the parameter sets + get sizes + convert everything to a cell + check inputs
    setup.bs_state.numberOfParameterSets = 1;
    setupParam = {};
    for fieldNameCell = tempFieldNames
        fieldName = char(fieldNameCell);
        
        % check if field is empty
        if (isempty(setup.(fieldName)))
            %setup = rmfield(setup, fieldName);
            continue;
        end
        
        % add the field to the legend
        setup.bs_state.legend = [ setup.bs_state.legend fieldNameCell ];
        
        % get field size
        setup.bs_state.numberOfParameterSets = setup.bs_state.numberOfParameterSets * length(setup.(fieldName));
        
        % convert to cell
        if (iscell(setup.(fieldName)))
            % check that all cell elements have the same type
            for i_elem = 1:length(setup.(fieldName))
                if (~(isnumeric(setup.(fieldName){i_elem}) || ischar(setup.(fieldName){i_elem})))
                    error(['The field ', fieldName, ' has mixed data types! Only strings or numbers are allowed.']);
                end
            end
            setupParam{end +1} = setup.(fieldName);
            continue;
        end
        if (isnumeric(setup.(fieldName)))
            setupParam{end +1} = num2cell(setup.(fieldName));
        else
            error(['Field type of the field ', fieldName, ' is not supported!']);
        end
    end
    
    % get all combinations of setupParam
    setup.bs_state.parameterSets = allcomb(setupParam{1:end});
    
    % number of parameters
    setup.bs_state.numberOfParameters = length(setup.bs_state.legend);
        
    % add statistics
    setup.bs_state.parameterSets = [setup.bs_state.parameterSets num2cell([1:setup.bs_state.numberOfParameterSets]') ];
    setup.bs_state.parameterSets = [setup.bs_state.parameterSets num2cell( ones(setup.bs_state.numberOfParameterSets, 1) *setup.bs_state.numberOfParameterSets )];
    
    % add current parameter set counter
    setup.bs_state.currentParameterSet = 1;
else
    warning('Parameter-Sets already created or you have used the fieldname "bs_state" which is reserved and can not be used!')
end

    %% helper function from FEX
    function A = allcomb(varargin)
        % ALLCOMB - All combinations
        %    B = ALLCOMB(A1,A2,A3,...,AN) returns all combinations of the elements
        %    in the arrays A1, A2, ..., and AN. B is P-by-N matrix is which P is the product
        %    of the number of elements of the N inputs. This functionality is also
        %    known as the Cartesian Product. The arguments can be numerical and/or
        %    characters, or they can be cell arrays.
        %
        %    Examples:
        %       allcomb([1 3 5],[-3 8],[0 1]) % numerical input:
        %       % -> [ 1  -3   0
        %       %      1  -3   1
        %       %      1   8   0
        %       %        ...
        %       %      5  -3   1
        %       %      5   8   1 ] ; % a 12-by-3 array
        %
        %       allcomb('abc','XY') % character arrays
        %       % -> [ aX ; aY ; bX ; bY ; cX ; cY] % a 6-by-2 character array
        %
        %       allcomb('xy',[65 66]) % a combination
        %       % -> ['xA' ; 'xB' ; 'yA' ; 'yB'] % a 4-by-2 character array
        %
        %       allcomb({'hello','Bye'},{'Joe', 10:12},{99999 []}) % all cell arrays
        %       % -> {  'hello'  'Joe'        [99999]
        %       %       'hello'  'Joe'             []
        %       %       'hello'  [1x3 double] [99999]
        %       %       'hello'  [1x3 double]      []
        %       %       'Bye'    'Joe'        [99999]
        %       %       'Bye'    'Joe'             []
        %       %       'Bye'    [1x3 double] [99999]
        %       %       'Bye'    [1x3 double]      [] } ; % a 8-by-3 cell array
        %
        %    ALLCOMB(..., 'matlab') causes the first column to change fastest which
        %    is consistent with matlab indexing. Example:
        %      allcomb(1:2,3:4,5:6,'matlab')
        %      % -> [ 1 3 5 ; 1 4 5 ; 1 3 6 ; ... ; 2 4 6 ]
        %
        %    If one of the arguments is empty, ALLCOMB returns a 0-by-N empty array.
        %
        %    See also NCHOOSEK, PERMS, NDGRID
        %         and NCHOOSE, COMBN, KTHCOMBN (Matlab Central FEX)
        
        % for Matlab R2011b
        % version 4.0 (feb 2014)
        % (c) Jos van der Geest
        % email: jos@jasen.nl
        
        % History
        % 1.1 (feb 2006), removed minor bug when entering empty cell arrays;
        %     added option to let the first input run fastest (suggestion by JD)
        % 1.2 (jan 2010), using ii as an index on the left-hand for the multiple
        %     output by NDGRID. Thanks to Jan Simon, for showing this little trick
        % 2.0 (dec 2010). Bruno Luong convinced me that an empty input should
        % return an empty output.
        % 2.1 (feb 2011). A cell as input argument caused the check on the last
        %      argument (specifying the order) to crash.
        % 2.2 (jan 2012). removed a superfluous line of code (ischar(..))
        % 3.0 (may 2012) removed check for doubles so character arrays are accepted
        % 4.0 (feb 2014) added support for cell arrays
        
        narginchk(1,Inf) ;
        
        NC = nargin ;
        
        % check if we should flip the order
        if ischar(varargin{end}) && (strcmpi(varargin{end},'matlab') || strcmpi(varargin{end},'john')),
            % based on a suggestion by JD on the FEX
            NC = NC-1 ;
            ii = 1:NC ; % now first argument will change fastest
        else
            % default: enter arguments backwards, so last one (AN) is changing fastest
            ii = NC:-1:1 ;
        end
        % check for empty inputs
        if any(cellfun('isempty',varargin(ii))),
            warning('ALLCOMB:EmptyInput','Empty inputs result in an empty output.') ;
            A = zeros(0,NC) ;
        elseif NC > 1
            isCellInput = cellfun(@iscell,varargin) ;
            if any(isCellInput)
                if ~all(isCellInput)
                    error('ALLCOMB:InvalidCellInput', ...
                        'For cell input, all arguments should be cell arrays.') ;
                end
                % for cell input, we use to indices to get all combinations
                ix = cellfun(@(c) 1:numel(c), varargin,'un',0) ;
                
                % flip using ii if last column is changing fastest
                [ix{ii}] = ndgrid(ix{ii}) ;
                
                A = cell(numel(ix{1}),NC) ; % pre-allocate the output
                for k=1:NC,
                    % combine
                    A(:,k) = reshape(varargin{k}(ix{k}),[],1) ;
                end
            else
                % non-cell input, assuming all numerical values or strings
                % flip using ii if last column is changing fastest
                [A{ii}] = ndgrid(varargin{ii}) ;
                % concatenate
                A = reshape(cat(NC+1,A{:}),[],NC) ;
            end
        elseif NC==1,
            A = varargin{1}(:) ; % nothing to combine
            
        else % NC==0, there was only the 'matlab' flag argument
            A = zeros(0,0) ; % nothing
        end
        
    end

end
