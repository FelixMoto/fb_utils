function [concat_trls, trl_idx] = fb_concat_trials(data, index)
% [concat_trls, trl_idx] = fb_concat_trials(data, index)
% function to concatenate trials from a cell array into a long matrix.
% good for estimating metrics over several trials at once.
%
% Parameters
% ----------
%       data : cell array 
%           matrices to concatenate
%           data will be concatenated in the second dimension, thus the
%           first dimension must be equal
%       index : 1xN array (optional)
%           indexing which trials from data should be concatenated
%
% Returns
% -------
%       concat_trls : double 
%           conatenated trials as a 2-D matrix
%       trl_idx : 1xN array 
%            indexing the last sample point of each trial in concatrls
%
% to separate trials into cell array structure, use fb_separate_trials
%

% handle input
if nargin > 1
   	trl_conc = [data{index}];
    num_trls = length(index);
else
    trl_conc = [data{:}];
    num_trls = length(data);
    index = [1:length(data)];
end

% create array for reindexing trial endpoints after concatenation
for k = 1:num_trls
    len(k) = size(data{index(k)},2);
    if k > 1
        len(k) = len(k) + len(k-1);
    end
end

concat_trls = trl_conc;
trl_idx = len;

end
