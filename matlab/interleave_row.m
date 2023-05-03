function c = interleave_row(a,b)
%   c = interleave_row(a,b)
% interleaves rows of a two 2D matrices a and b
%
% Example:
% A             C
% [11 13]       [11 13]
% [12 14]       [21 23]
% B        ->
% [21 23]       [12 14]
% [22 24]       [22 24]

% handle input
if ~ismatrix(a) 
    error('a must be 1D or 2D vector');
end
if ~ismatrix(b) 
    error('b must be 1D or 2D vector');
end

if size(a,1) ~= size(b,1) || size(a,2) ~= size(b,2)
    error('matrices must be of same size');
end

c = reshape([a(:) b(:)]', 2*size(a,1),[]);

end
