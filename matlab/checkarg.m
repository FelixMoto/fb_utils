function struct = checkarg(struct,keyword,defaultval)
%
% takes a structure, checks for a field.
% if the field does not exist or is empty, the defualtval will be
% substituted.
%
% neat trick: use a function as a defaultval to assign its output to the
% struct.
% example use:
%
%   struct = checkarg(struct,'ax',gca);
%   -> assigns the current axis as default but can be overwritten with any
%   other axis
%
% and even coole trick is to assign a function handle to the struct
%   struct = checkarg(struct,'metric',@mean);
%   val = struct.metric(someData);
%

if ~isfield(struct,keyword) || isempty(struct.(keyword))
    struct.(keyword) = defaultval;
end

end
