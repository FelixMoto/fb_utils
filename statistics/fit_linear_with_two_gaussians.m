function [coefficients] = fit_linear_with_two_gaussians(X,Y)
%
%
%

% check inputs
X = X(:);
Y = Y(:);

% create table with input data
tbl = table(X', Y');

% create function handle - linear model with two added gaussians
modelfun = @(b,x) b(1) + b(2) * x + b(3) * exp(-(x(:, 1) - b(4)).^2/b(5)) + b(6) * exp(-(x(:, 1) - b(7)).^2/b(8));  

% initialize beta0
beta0 = zeros(8,1);

% fit model
mdl = fitnlm(tbl, modelfun, beta0);

% consider nlinfit.m

% unpack coefficients
coefficients = mdl.Coefficients{:, 'Estimate'};

end
