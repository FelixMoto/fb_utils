function PCx = ppc(X,varargin)
%
% PCx = ppi(X)
% computes pair-wise phase-consistency from observation matrix X, between
% each column of X.
% assumes input data to be angular data from hilbert transform.
%
% PCx = ppi(X,Y)
% computes the pair-wise phase-consistency between columns of X and Y. X
% and Y must therefore have the same number of observations and columns.
%
%

% handle input
if ~isnumeric(X)
    error('X must be numeric array');
end

if ~isempty(varargin) && isnumeric(varargin{1})
   Y = varargin{1};
   varargin(1) = [];

   % Convert two inputs to equivalent single input.
   if numel(X)~=numel(Y)
      error('X and Y must have same number of elements');
   elseif size(X,1) ~= size(Y,1)
       error('X and Y must have same number of observations');
   elseif size(X,2) ~= size(Y,2)
       error('X and Y must have same number of columns');
   end
else
    % copy X 
    Y = X;
end

% get size 
[~,ncols] = size(X);
PCx = zeros(ncols,ncols);

% find subscripts for lower triangular 
itril = reshape([1:ncols*ncols], [ncols,ncols]);
itril = tril(itril);
[Itril,Jtril] = ind2sub([ncols,ncols], find(itril(:) > 0));
numtril = length(Itril);

for i = 1:numtril
    PCx(Itril(i),Jtril(i)) = abs(mean(exp(1i*(X(:,Itril(i)) - Y(:,Jtril(i))))));
end

% copy lower triangular
PCx = PCx + tril(PCx,-1)';

end
