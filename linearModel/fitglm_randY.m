function [beta_true, beta_rand] = fitglm_randY(X,Y,aI,delta,nrand) %#codegen
%
% [beta_true, beta_rand] = glm_randY(X,Y,aI,nrand)
% linear model of form (X'X+aI)\X'Y/delta that fits X onto Y and repeats 
% this process for Y shifted along first dimension nrand times.
% Assumes data points in first and variables in second dimension.
%
% inputs:
%   X : double
%       N-by-M matrix
%   Y : double 
%       N-by-P matrix
%   aI : double
%       regularization matrix of size N-by-N
%   delta : double
%       sample rate
%   nrand : double
%       number of shifts along first dimension
%
% returns:
%   beta_true : double
%       model weights of size 
%   beta_rand : double
%       random model weights of size
%

% function handle
ctrf = @(x,y,aI,d) (x'*x + aI)\x'*y/d;

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

nrows = size(X,1);
ncoeff = size(X,2);

% true model
beta_true = ctrf(X,Y,aI,delta);

% random model
beta_rand = zeros(ncoeff,nrand);
shifts = randi([1,nrows],nrand,1);
for irand = 1:nrand
    ishift = shifts(irand);
    idx = [(ishift:nrows),(1:ishift-1)]';
    Y_shift = Y(idx);
    betas = ctrf(X,Y_shift,aI,delta);
    for icoeff = 1:ncoeff
        beta_rand(icoeff,irand) = betas(icoeff);
    end
end


end
