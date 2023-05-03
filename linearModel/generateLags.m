function Y = generateLags(X,lags,dim)
%
% Y = generateLags(X,lags,dim)
% takes matrix X and shifts all columns along the first dimension for all
% lags in lags = [tmin:fs:tmax].
%
% Parameters
% ----------
%   X : double
%       input matrix
%   lags : double
%       time lags in sample points
%   dim : double (optional)
%       dimension to work along. default is first axis.
%
% Returns
% -------
%   Y : double
%       matrix with time shifted features. time shifted copies of X are
%       stacked along the second axis.
%

% handle input
if ~ismatrix(X)
    error('X must be a vector or matrix');
end
if nargin < 5 || isempty(dim)
    dim = 1;
end

% transpose if work along second dimension
if  dim == 2
    X = X';
end

% get input size
[nrow,ncol] = size(X);
colix = [1:ncol];

% get lag size
nlags = length(lags);

Y = zeros(nrow,ncol*nlags);
for ilag = 1:nlags
    istart = lags(ilag);
    icol = colix + (ilag-1) * ncol;
    if istart < 0
        Y(1:end+istart,icol) = X(1-istart:end,:);
    elseif istart == 0
        Y(:,icol) = X;
    elseif istart > 0
        Y(1+istart:end,icol) = X(1:end-istart,:);
    end
end




end
