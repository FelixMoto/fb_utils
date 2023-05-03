function [beta,acc,bias] = crossval_glm(X,Y,tmin,tmax,fs,lambda,nfolds,lagtype)
%
% [beta,acc] = crossval_glm_Y(X,Y,tmin,tmax,fs,lambda,nfolds,lagtype)
% linear model of form (X'X+aI)\X'Y/delta that fits X onto Y.
% Assumes data points in first and variables in second non-singleton
% dimension.
%
% Parameters
% ----------
%   X : cell || double
%       array containing Nrow-by-Ncolx matrices
%   Y : cell || double 
%       array containing Nrow-by-Ncoly matrices
%   tmin : double (optional)
%       start time of lags. default is 0.
%   tmax : double (optional)
%       end time of lags. default is 0.
%   fs : double (optional)
%       data sample rate in Hz. default is 1.
%   lambda : double (optional)
%       regularization factor. if lambda is an array, runs through all
%       lambdas 
%   nfolds : double (optional)
%       number of crossvalidation folds 
%   lagtype : str (optional)
%       specifies whether single or multiple lag model should be used.
%       can either be 'single' (default) or 'multi' 
%
% Returns
% -------
%   beta : double
%       model weights of size [nlambdas x nfolds x ncolx x nlags x ncoly]
%   acc : double
%       model prediction accuracy of size [nlambdas x nfolds x ncoly x 
%       nlags]. if lagtype is 'multi', then nlags = 1.
%   

% handle input
if ~iscell(X)
    X = mat2cell(X,size(X,1),size(X,2));
    nfolds = 1;
elseif iscell(X) && length(X) == 1
    if nfolds ~= 1
        warning('setting nfolds to 1');
    end
    nfolds = 1;
end

if ~iscell(Y)
    Y = mat2cell(Y,size(Y,1),size(Y,2));
end

% get number of columns
ncolx = size(X{1},2);
ncoly = size(Y{1},2);
colix = [1:ncolx];

% X and Y must have same number of obervation per trial and in total
triallenX = cellfun(@(x) size(x,1), X);
triallenY = cellfun(@(x) size(x,1), Y);
ntrl = length(triallenX);
if length(triallenX) ~= length(triallenY)
    error('X and Y must have same number trials');
end
if ~all(triallenX == triallenY)
    error('X and Y must have same number observations');
end
if sum(triallenX) ~= sum(triallenY)
    error('X and Y must have same number observations in each trial');
end
if sum(triallenX) < ncolx || sum(triallenY) < ncoly
    error('X and Y must have more observations than columns');
end

% get optional parameters
if nargin < 2 || isempty(tmin)
    tmin = 0;
end
if nargin < 3 || isempty(tmax)
    tmax = 0;
end
if nargin < 5 || isempty(fs)
    fs = 1;
end
delta = 1/fs;
if nargin < 6 || isempty(lambda)
    lambda = 0;
end
if nargin < 7 || isempty(nfolds)
    nfolds = 1;
end
if nargin < 8 || isempty(lagtype)
    lagtype = 'single';
end

% convert time to samples and create lags
tmin = floor(tmin/1000*fs);
tmax = ceil(tmax/1000*fs);
lags = tmin:tmax;
nlags = length(lags);
numlagacc = nlags;

% reg parameters
nlambdas = length(lambda);
% set up regularization matrix
if strcmp(lagtype,'single')
    aI = sparse(eye(ncolx+1));
elseif strcmp(lagtype,'multi')
    aI = sparse(eye(nlags*ncolx+1));
    numlagacc = 1;
end


% split n trials in cell array into as equal parts as possible
foldsize = floor(ntrl/nfolds);

% allocate space
beta = zeros(nlambdas,nfolds,ncolx,nlags,ncoly);
bias = zeros(nlambdas,nfolds,1,1,ncoly);
acc = zeros(nlambdas,nfolds,ncoly,numlagacc);


% fit linear model
for ilambda = 1:nlambdas
    aI = lambda(ilambda) .* aI ./ delta;
    aI(1,1) = 0;

    for ifold = 1:nfolds
        % index triald for training and testing
        i_test = foldsize*(ifold-1)+1:min(foldsize*ifold,ntrl);
        Itrl = [1:ntrl];
        i_train = Itrl;
        i_train(i_test) = [];
        
        % conat trials and add bias
        X_test = cat(1,X{i_test});
        Y_test = cat(1,Y{i_test});
        if nfolds == 1
            X_train = X_test;
            Y_train = Y_test;
        else
            X_train = cat(1,X{i_train});
            Y_train = cat(1,Y{i_train});
        end
        
        % set up offset
        biastrain = ones(size(X_train,1),1);
        biastest = ones(size(X_test,1),1);
        
        % create matrix with time lags
        X_train = generateLags(X_train,lags);
        X_test = generateLags(X_test,lags);
        
        
        if strcmp(lagtype,'single')
            for ilag = 1:nlags
                % fit model
                icol = colix + (ilag-1) * ncolx;
                iXt = [biastrain, X_train(:,icol)];
                w = (iXt'*iXt + aI)\iXt'*Y_train/delta;
                beta(ilambda,ifold,:,ilag,:) = w(2:end,:);
                bias(ilambda,ifold,:,ilag,:) = w(1,:);
                
                % evaluate model
                iXr = [biastest, X_test(:,icol)];
                Y_pred = iXr * w;
                acc(ilambda,ifold,:,ilag) = sum(Y_test.*Y_pred,1)./sqrt(sum(Y_test.^2,1).*sum(Y_pred.^2,1));
            end
        elseif strcmp(lagtype,'multi')
            % fit model
            iXt = [biastrain, X_train];
            w = (iXt'*iXt + aI)\iXt'*Y_train/delta;
            beta(ilambda,ifold,:,:,:) = reshape(w(2:end,:),[ncolx,nlags,ncoly]);
            bias(ilambda,ifold,:,:,:) = reshape(w(1,:),[1,1,ncoly]);

            % evaluate model
            iXr = [biastest, X_test];
            Y_pred = iXr * w;
            acc(ilambda,ifold,:) = sum(Y_test.*Y_pred,1)./sqrt(sum(Y_test.^2,1).*sum(Y_pred.^2,1));
        end
        
    end

end


end
