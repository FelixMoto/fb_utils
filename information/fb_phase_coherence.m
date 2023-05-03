function pcv = fb_phase_coherence(X, Y, index)

% function to calculate phase coherence between envelopes from files and
% eeg signal
% 
% Parameters:   
%   X   :   array or matrix with input data
%           if X is a matrix, fb_phase_coherence treats each row as a
%           separate channel
%   Y   :   array with input data; cannot be a matrix
%   index   :   logical array indexing sample points to use for pcv
%               computatiton
%
% returns:  data structure containing the phase coherence values
%           
%

if nargin > 2
    comp_idx = find(index);
else
    comp_idx = find(ones(size(Y)));
end

% hilbert transform and angle
eeg = angle(hilbert(X')'); % transpose for correct orientation
env = angle(hilbert(Y')'); 
% angle difference
angle_diff = eeg - env;

% DOES NOT WORK YET!!!
% only use data points from indices
angle_diff = angle_diff(:,comp_idx);

coherence = abs(mean(exp(1i*angle_diff),2,'omitnan'));


pcv = coherence;
