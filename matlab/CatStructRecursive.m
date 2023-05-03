function out = CatStructRecursive(in,dim)
% out = CatStructRecursive(in)
% recursively goes through all fields and subfields and concatenates all
% entries
%
% in: a structure array
% 
% example use:
% s(1).time  = [240x1 double]
% s(1).a.b.c = [240x3 double]
% s(1).a.b.d = [240x3 double]
% 
% s(2).time  = [120x1 double]
% s(2).a.b.c = [120x3 double]
% s(2).a.b.d = [120x3 double]
%
% dim = 1; % concatenate along first dimension
% s_cat = CatStructRecursive(s,dim);
%
%

% adapted and modified by 
% https://de.mathworks.com/matlabcentral/answers/169501-merge-structures-with-subfields#answer_164678


if nargin < 2
    dim = 1;
end

for field = fieldnames(in)'
    field = field{1};
    out.(field) = CatStructRecurse(arrayfun(@(s) s.(field), in, 'UniformOutput', false),dim,field);
end

end

function out = CatStructRecurse(sc,dim,nfield)
   %sc: a cell array of scalar structures
if isstruct(sc{1})
    for field = fieldnames(sc{1})'
        field = field{1};
        out.(field) = CatStructRecurse(cellfun(@(s) s.(field), sc, 'UniformOutput', false),dim,field);
    end
else
    try
        out = cat(dim,sc{:});
    catch
        error('could not concatenate field: %s \n',nfield);
    end
end


end
