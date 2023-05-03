function y = intrp_discrete_time(x,dur)
% y = intrp_discrete_time(x,dur)
%
% linearly interpolates input vector x, so that each point x(1) to x(n) is 
% of duration dur(1) to dur(n)
%
% if x is a 2D matrix, interpolation works along first dimension
%
% Example:
% A = [1 2];
% Dur = [2 4];
%
% y = intrp_discrete_time(A,Dur);
% y = [1 1 2 2 2 2];

% handle input
if ~ismatrix(x)
    error('x must be a matrix');
elseif isvector(x)
    x = x(:);
end

if ~isvector(dur)
    error('dur must be 1D vector');
end

[nrow,ncol] = size(x);
timing = cumsum(dur);
segstart = [1; timing(1:end-1)+1];

maxlen = sum(dur);
out = zeros(maxlen,ncol);

for ix = 1:nrow
    i_seg = segstart(ix) : segstart(ix) + dur(ix) -1;
    out(i_seg,:) = x(ix);
end

y = out;

end
