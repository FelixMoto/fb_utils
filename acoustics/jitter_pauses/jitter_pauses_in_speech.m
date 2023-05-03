function [y_mod, ARG] = jitter_pauses_in_speech(y,Fs,sigma,jitterfactor,passbands,params)
%
%   [y_mod, ARG] = jitter_pauses(y,Fs,sigma,jitterfactor,passbands,params)
%
% takes the input signal y, finds the silent pauses between utterances and
% manipulates the length of theses pauses randomly
%
% y must be a 1D vector containing spoken speech 
%


% handle input
if ~isvector(y)
    error('Y must be a 1D vector');
else
    y = y(:);
end

if ~isvector(passbands)
    error('passbands must be a 1D vector');
end

if nargin < 6
    % default values
    params.threshold = 0.1; % must be within [0 1]
    params.fmin = 100;
    params.fmax = 10000;
    params.nbands = 12;
    params.minsize = 0.03;
    params.mindist = 0.06;
    params.minlen = 0.02;
end


% subtract mean, normalize
y = y-mean(y);
y = y./max(y);

% create subbands and envelope
subbands = create_subbands(y,Fs,[],passbands);
subbands = abs(hilbert(subbands));
subband = mean(subbands,2);
% low pass filter
[b,a] = butter(3,2*30/Fs); % 30 Hz lowpass
subband =  filtfilt(b,a,subband);
% normalize
subband = subband./max(subband);


% find connected components (i.e. pauses)
ysilent = (subband < params.threshold);
c_size = round(params.minsize * Fs); 
c_dist = round(params.mindist * Fs);
[ycomp, ncomp] = conncomp_binary1d(ysilent,c_size,c_dist);

% manipulate pause length 
minlen = round(params.minlen/Fs);
[y_mod,ycomp,keepjit] = manipulate_pauses_from_random(y,ycomp,ncomp,sigma,jitterfactor,minlen);


ARG.ncomp = ncomp;
ARG.ycomp = ycomp;
ARG.pauselength = keepjit;

end




