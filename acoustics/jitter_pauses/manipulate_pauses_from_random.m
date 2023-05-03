function [y,ycomp,keepjit] = manipulate_pauses_from_random(y,ycomp,ncomp,sigma,jitterfactor,minlen)
%
%   [y,ycomp,keepjit] = manipulate_pauses_from_random(y,ycomp,ncomp,sigma,jitterfactor,minlen)
%
% creates a random normal distribution with mu = 0 and sd =
% sigma*jitterfactor, then randomly samples from that distribution and
% changes the pauses indicated in ycomp with the new jitter samples
%
% minlen is the min. length of any new pauses
%
% returns the new time series, the new component vector and an array
% indicating the original pause length and the jitter
%

% create normpdf kernel with given sigma
x = 3*sigma;
X = [-x:1:x];
MU = 0;
Y = normpdf(X,MU,sigma*jitterfactor);

% create flat dist. if we dont want to jitter the pauses
if jitterfactor == 0
    X = zeros(size(X));
    Y = ones(size(X));
end

% keep track of new jitters
keepjit = zeros(ncomp,2);
keepjit(1,1) = length(find(ycomp==1));
keepjit(ncomp,1) = length(find(ycomp==ncomp));

% loop pauses w/o first and last pause
for comp = 2:ncomp-1
    % get component and it's length
    CC = find(ycomp==comp);
    CClen = CC(end) - CC(1);
    
    % constraint is min. 20 ms and not longer than 300% of original length
    jitter = Inf; % set to infinity to get while loop going
    while CClen + jitter < minlen || CClen + jitter > 3*CClen
        jitter = randsample(X,1,true,Y); % can be neg. or pos.
        jitter = round(jitter); % convert to integer
    end
    % keep track of pause length and change
    keepjit(comp,1) = CClen;
    keepjit(comp,2) = jitter; 
    % create new pause length
    newlen = CClen + jitter;
    newpause = zeros(newlen,1);
    % insert new pauses
    y = [y(1:CC(1)-1); newpause; y(CC(end)+1:end)];
    % also update comp vector
    ycomp = [ycomp(1:CC(1)-1); comp+newpause; ycomp(CC(end)+1:end)];
end

end
