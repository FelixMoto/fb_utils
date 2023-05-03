function predY = predict_glm(X,beta,bias,tmin,tmax,fs,lagtype)
%
% predY = predict_glm(X,beta,bias)
%

% handle input
if ~iscell(X)
    X = mat2cell(X,size(X,1),size(X,2));
end

% get optional arguments
if nargin < 4 || isempty(tmin)
    tmin = 0;
end
if nargin < 5 || isempty(tmax)
    tmax = 0;
end
if nargin < 6 || isempty(fs)
    fs = 1;
end
if nargin < 7 || isempty(lagtype)
    lagtype = 'single';
end

% get length of trials
triallenX = cellfun(@(x) size(x,1), X);

% convert time to samples and create lags
tmin = floor(tmin/1000*fs);
tmax = ceil(tmax/1000*fs);
lags = tmin:tmax;
nlags = length(lags);

% concatenate all trials
stim = cat(1,X{:});
[nrow,ncolx] = size(stim);
[~,~,ncoly] = size(beta);
colix = [1:ncolx];


% create matrix with time lags
stim = generateLags(stim,lags);

% reshape model weights
beta = reshape(beta,[ncolx*nlags,ncoly]);


% add bias term
biasterm = ones(length(stim),1);

% predict
if strcmp(lagtype,'single')
    predY = zeros(nlags,ncoly);
    for ilag = 1:nlag
        icol = colix + (ilag-1) * ncolx;
        predY(ilag,:) = [biasterm, stim(:,icol)] * [bias'; beta(icol,:)];
    end
    predY = mean(predY,1);
elseif strcmp(lagtype,'multi')
    predY = [biasterm, stim] * [bias'; beta];
end


% transform to cell
predY = mat2cell(predY,triallenX,ncoly);

end
