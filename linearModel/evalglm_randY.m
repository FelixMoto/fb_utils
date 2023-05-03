function [r_true, r_rand] = evalglm_randY(X,Y,coeff_true,coeff_rand) %#codegen
%
% [r_true, r_rand] = evalglm_randY(X,Y,coeff_true,coeff_rand)
% evaluates the linear model of form (X'X+aI)\X'Y/delta with coefficients
% from a true and a randomized model, generated from glm_randY.
% Assumes data points in first and variables in second dimension.
%
% inputs:
%   X : double
%       N-by-M matrix
%   Y : double 
%       N-by-P matrix
%   coeff_true : double
%       true model weights
%   coeff_rand : double
%       randomized model weights
%
% returns:
%   r_true : double
%       model weights of size 
%   r_rand : double
%       random model weights of size
%

% handle input
if size(X,1) < size(X,2)
    error('X must have more rows than columns');
end
if size(Y,1) < size(Y,2)
    error('Y must have more rows than columns');
end
if size(X,1) ~= size(Y,1)
    error('X and Y must have same number of rows');
end
if size(coeff_true,1) ~= size(X,2) || size(coeff_rand,1) ~= size(X,2)
    error('Number of weights must match number of columns in X');
end

% get number of coefficients
ncoeff = size(coeff_true,1);
nrows = size(X,1);

% mean Y
Ymean = repmat(mean(Y),nrows,1);

% true model prediction
Ypred = sum(X .* repmat(coeff_true',nrows,1),2);
Ypredmean = repmat(mean(Ypred),nrows,1);
covYpredY = (1/(nrows-1)) .* sum((Ypred-Ypredmean).*(Y-Ymean)); 
r_true = (covYpredY/(std(Ypred)*std(Y))) .^2;

% random model prediction
nrand = size(coeff_rand,2);
r_rand = zeros(nrand,1);
for irand = 1:nrand
    betas = zeros(ncoeff,1);
    for icoeff = 1:ncoeff
        betas(icoeff) = coeff_rand(icoeff,irand);
    end
    Ypred = sum(X .* repmat(betas',nrows,1),2);
    Ypredmean = repmat(mean(Ypred),nrows,1);
    covYpredY = (1/(nrows-1)) .* sum((Ypred-Ypredmean).*(Y-Ymean)); 
    r_rand(irand) = (covYpredY/(std(Ypred)*std(Y))) .^2;
end


end
