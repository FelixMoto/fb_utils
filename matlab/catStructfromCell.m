function struct = catStructfromCell(CellIn,dim)
%
% DOES NOT WORK!!!
%
% struct = catStructfromCell(CellIn,dim)
%
% recursively walk through cell array containing similar structures and
% concatenate all entries along the input dimension
%

% check input
if ~iscell(CellIn)
    error('CellIn must be cell array')
end

% concat along first dimension by default
if isempty(dim)
    dim = 1;
end

struct = [];
for icell = 1:length(CellIn)
    for field = fieldnames(CellIn{icell})
        field = field{1};
        struct.(field) = catRecursive(struct,CellIn{icell}.(field),dim);
        %struct.(field) = catRecursive(arrayfun(@(s) s.(field), CellIn{icell}, 'UniformOutput', false), dim);
    end
end

end

%% recursion function here
function out = catRecursive(out,StructIn, dim)
%
%
%


if isstruct(StructIn)
    for field = fieldnames(StructIn)'
        field = field{1};
        out.(field) = catRecursive(out, StructIn.(field), dim);
        %out.(field) = catRecursive(cellfun(@(s) s.(field), StructIn, 'UniformOutput',false));
    end
else
    out = cat(dim,out,StructIn);
end

end