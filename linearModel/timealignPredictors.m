function Xaligned = timealignPredictors(X,Lags,fs,relative)
%
% Xaligned = timealignPredictors(X,Lags,fs,relative)
% this function alignes the Predictors along the time dimension so that
% they start at the lag given in Lags. assumes the time dimension in the
% first axis.
%
% if fs is given, assumes Lags to be in seconds.
% if relative is true, relates the lags to each other by subtracting the
% minimum lag. (default) is true.
%
% assumes input to be either 2D time-by-feature matrix or Ntrials-by-1 cell
% array of such matrices.
%

% handle input
Iscell = iscell(X);
if Iscell
    if ~all(cellfun(@isnumeric,X))
        error('trials data must be 2D matrices');
    end
elseif ~ismatrix(X)
    error('X must be 2D matrix');
else
    X = {X}; % pack into cell
end

% get size
ntrl = numel(X);
trialY = cellfun(@(x) size(x,2),X,'UniformOutput',false);
if ~all([trialY{:}] == trialY{1})
    error('all trials must have same number of columns');
end
ncol = trialY{1};

% assert lags have same number of elements as columns
if numel(Lags) ~= ncol
    error('relLags must be fit number of columns in X');
end
Lags = Lags(:);

% convert to sample points if fs is given
if nargin > 2
    if isnumeric(fs) && numel(fs) == 1
        Lags = round(Lags .* fs);
    elseif ~isempty(fs)
        error('fs must be numeric');
    end
end

if nargin < 4 || isempty(relative)
    relative = true;
end

% relate lags to each other
if relative
    Lags = Lags - min(Lags);
end

% allocate space
Xaligned = cell(ntrl,1);

for icell = 1:ntrl
    tmp = zeros(size(X{icell}));
    for i = 1:ncol
        istart = Lags(i);
        if istart < 0
            tmp(1:end+istart,i) = X{icell}(1-istart:end,i);
        elseif istart == 0
            tmp(:,i) = X{icell}(:,i);
        elseif istart > 0
            tmp(1+istart:end,i) = X{icell}(1:end-istart,i);
        end
    end
    Xaligned{icell,1} = tmp;
end

% unpack if not originally in a cell
if ~Iscell && ntrl == 1
    Xaligned = Xaligned{1};
end


end
