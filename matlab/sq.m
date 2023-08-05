function y = sq(x)
% function y = sq(x)
%
% matlab squeeze fewer characters.
% takes input and removes singleton dimensions.
% might be slower, since this is build on top.
%
% input: x (double)
%
% returns: y
%

y = squeeze(x);

end
