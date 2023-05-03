function B = flatten(A,dims)
%
% B = flatten(A,dims)
%
% takes input A and flattens the dimensions given with dims. If dims is not
% specified flattens yields B = A(:).
%

if nargin < 2 || isempty(dims)
    B = A(:);
elseif length(dims) == 1
    error('can not flatten fewer than two dimensions');
else
    tailshape = size(A);
    tailshape(dims(1)) = prod(tailshape(dims));
    tailshape(dims(2:end)) = [];
    B = reshape(A,tailshape);
end


end
