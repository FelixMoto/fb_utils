function [out, N] = conncomp_binary1d(X,minsize,mindist)
%
%   out = conncomp_binary1d(X,minsize,mindist)
%
% find connected data points in a binary 1d array
% if minsize is given, only finds components of length > minsize
% if mindist is given, conjugates components that are closer together than
% mindist
%
% returns array with component labels in ascending order
%

% handle input
if ~isvector(X)
    error('input must be a vector');
else
    % ensure samples are in first axis
    X = X(:);
end

if nargin < 2
    clearComp = false;
elseif nargin > 1 && ~isempty(minsize)
    clearComp = true;
end

if nargin < 3
    conjComp = false;
elseif nargin > 2 && ~isempty(mindist)
    conjComp = true;
end

% initialize variables -----------------------
L = length(X);
labels = zeros(size(X));
nComp = 1;

% label all but last point -------------------
for i = 1:L-1
    if X(i) == 1
        labels(i) = nComp;
        if X(i+1) == 0
            nComp = nComp + 1; % update nComp 
        end
    end
end
% get last point here
if X(end) == 1
    labels(end) = nComp;
end


% clear components that are smaller than minsize 
if clearComp == true
    k = 1;
    while k <= nComp
        idxC = find(labels==k); % find components
        if length(idxC) < minsize
            labels(idxC) = 0; % set to zero
            tmpIdx = ismember(labels,[k+1:nComp]);
            labels(tmpIdx) = labels(tmpIdx) - 1;
            % update number of components and repeat index
            nComp = nComp - 1;
            k = k - 1;
        end
        k = k + 1;
    end
end

% conjugate clusters with pauses smaller than mindist
if conjComp == true
    k = 1;
    while k < nComp-1
        idxC = find(labels==k);
        idxCnext = find(labels==k+1);
        if (idxCnext(1) - idxC(end)) < mindist
            % conjugate components
            labels(idxC(1):idxCnext(end)) = k;
            % find subsequent components and reduce label
            tmpIdx = ismember(labels,[k+1:nComp]);
            labels(tmpIdx) = labels(tmpIdx) - 1;
            % update number of components 
            nComp = nComp - 1;
        end
        k = k + 1;
    end
end

% output
out = labels;
if nargout == 2
    N = nComp;
end

end
