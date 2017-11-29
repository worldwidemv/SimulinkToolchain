function tf = my_contains(s, pattern, varargin)

if (exist('contains.m','file'))
    tf = contains(s, pattern, varargin{:});
    return
else
    
end
    
disp('contains: using backported version ...');
out = strfind(s, pattern);
tf = ~isempty(out);
end
