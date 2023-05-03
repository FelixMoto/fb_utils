function out = fb_circidx(input,shift,maxlen)
% function to circshift indices around max length
% something like:
% X X X X X X X X X
%     3->       8->
% shift by 3 
%
% -> circidx out:
% X X X X X X X X X
%   2       6
%
% inputs
%   array with indices
%   shift length (integer)
%   maximum length at which shift will break

arr = input + shift;
ovlap = length(arr(arr > maxlen));
arr = circshift(arr, ovlap);
arr(1:ovlap) = arr(1:ovlap) - maxlen;

out = arr;
end