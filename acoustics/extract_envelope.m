function [env,fco] = extract_envelope(y, fs, fs_new, f_min, f_max, N)
%
%   envelope = extract_envelope(y, fs, fs_new, f_min, f_max, N)
%
% function to extract the envelopes of a given signal
% the signal will be bandpass filtered between f_min and f_max and divided
% into N bands of equal width along the human basilar membrane 
% the envelope will then be extraceted from each frequency band
% if the signal has multiple channels, only the first one will be used
% if fs == Fs, the signal will not be resampled
%
% inputs:   signal (array): one-dimensional array containing signal
%           fs (integer): sample rate of signal
%           Fs (integer): new sample rate
%           f_min (integer):  lower frequency border
%           f_max (integer):  upper frequency border
%           N (integer):  number of envelopes extracted within frequency band
%
% returns:  num_bands x length(signal) sized matrix containing envelopes
%           envelope frequency boundaries
%
% 
%
% CAVE: path to MATLAB library chimera is necessary to work

addpath('Y:\Matlab\chimera');

% handle input
if ~isvector(y)
    error('input signal must be vector');
else 
    y = y(:);
end

if ~isempty(fs_new)
    doresample = true;
else
    doresample = false;
end

% create freq band cut offs
fco = equal_xbm_bands(f_min, f_max, N);

% demean signal 
y = y - mean(y);

% input matrix
L = length(y);
env = zeros(L,N);
 
for k = 1:N
    [b,a] = butter(3,2*[fco(k) fco(k+1)]/fs);
    tmp = filtfilt(b,a,y);
    tmp2 = abs(hilbert(tmp));

    % save envelopes
    env(:,k) = tmp2;
end


% resample signal
if doresample == true
    env = resample(env,fs_new,fs);
end


end

