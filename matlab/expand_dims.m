function y = expand_dims(x,dim)
%
% insert singleton dimension along axis dim
%

% check inputs
if dim > ndims(x)
    error('can not expand singleton dimensions at the end');
end
if isempty(dim) || nargin < 2
    dim = 1;
end

y = zeros([1, size(x)]);
S.subs = repmat({':'},1,ndims(x)+1);
S.subs{1} = 1;
S.type = '()';
y = subsasgn(y,S,x);

% shift singleton dimension if desired
if dim > 1
    dimord = [2:dim, 1, dim+1:ndims(x)+1];
    y = permute(y,dimord);
end

end