function RegModel = fb_stat_partialRegress(X,Y,Groups)
%
% computes partial regression models by grouping input variables Y
%

% assert same size
if size(X,1) ~= size(Y,1)
    error('X and Y must have same number of rows');
end

% get N columns
ncols = size(X,2);

% define each column as a gorup if not specified otherwise
if nargin < 3 || isempty(Groups)
    Groups = num2cell([1:ncols]);
end
npred = length(Groups);

% define intercept vector
offset = ones(length(Y),1);

% fit model with all predictors
[beta, R_square] = fitmodel(X,Y);

RegModel.beta = beta;
RegModel.R_square = R_square;

% fit models for all given predictors
for ipred = 1:npred
    % get grouped predictors
    col_pred = Groups{ipred};
    all_pred = 1:ncol;
    % leave grouped ones out and compute model for the ones left
    all_pred(col_pred) = [];
    x_pred = X(:,all_pred);
    [~, R_squareReduced] = fitmodel([offset x_pred], Y);
    
    % save to struct
    %RegModel.beta = beta;
    RegModel.R_squarePartial(ipred,:) = R_square - R_squareReduced;
end

end


function [beta,R_square] = fitmodel(X,Y)

% fit model
beta = X\Y;
% predict Y
yhat = X * beta;
% compute amount accounted variance
R_square = 1 - sum((Y - yhat).^2,1) ./ sum((Y - mean(Y,1)).^2);

end
