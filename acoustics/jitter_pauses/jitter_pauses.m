function [Y_mod, ARG] = jitter_pauses(params,y,Fs,sigma,jitterfactor,passbands)
%
%   [Y_mod, ARG] = jitter_pauses(params,y,Fs,sigma,jitterfactor,passbands)
%
% takes the input signal y, finds the silent pauses between utterances and
% manipulates the length of theses pauses randomly
%
% inputs:
%   params: structure with basic paramters. (default) are:
%       params.threshold = 0.1; 
%       params.fmin = 100; 
%       params.fmax = 10000; 
%       params.nbands = 12; 
%       params.average = true; 
%       params.minsize = 0.03; 
%       params.mindist = 0.06; 
%       params.minlen = 0.02; 
%       params.noisevoc = false;
%
%   y: 1D vector (containing spoken speech)
%   Fs: sample rate
%   sigma: standard deviation of the distribtion of pause durations on the
%          data set
%   jitterfactor: factor modulation sigma, (default) 1, can also be an
%                 array of size nbands-by-1 for individual jittering of
%                 each frequency band
%   passbands: array of length nbands+1 indication the band cutoff
%              frequencies
%
% returns:
%   Y_mod: modulated signal. If params.average is set to false, Y_mod will
%          be an nbands-by-1 cell array containing the subbands.
%   ARG: structure containing details
%

% handle input
% default parameters
if ~isfield(params,'threshold'); params.threshold = 0.1; end
if ~isfield(params,'fmin'); params.fmin = 100; end
if ~isfield(params,'fmax'); params.fmax = 10000; end
if ~isfield(params,'nbands'); params.nbands = 12; end
if ~isfield(params,'average'); params.average = true; end
if ~isfield(params,'minsize'); params.minsize = 0.03; end
if ~isfield(params,'mindist'); params.mindist = 0.06; end
if ~isfield(params,'minlen'); params.minlen = 0.02; end
if ~isfield(params,'noisevoc'); params.noisevoc = false; end

if ~isvector(y)
    error('Y must be a 1D vector');
else
    y = y(:);
end

if ~isnumeric(Fs)
    error('Fs should be numeric single digit');
end
if ~isnumeric(sigma)
    error('sigma should be numeric');
end
if ~isnumeric(jitterfactor)
    error('Jitterfactor should be numeric');
end

if ~isvector(passbands)
    error('Passbands must be a 1D vector');
end


% number of output bands if envelope is averaged or not
if params.average == true
    Noutbands = 1;
else
    Noutbands = params.nbands;
    if length(params.minsize) == 1
        params.minsize = repmat(params.minsize,[Noutbands,1]);
    end
    if length(params.mindist) == 1
        params.mindist = repmat(params.mindist,[Noutbands,1]);
    end
    if length(params.minlen) == 1
        params.minlen = repmat(params.minlen,[Noutbands,1]);
    end
    if length(sigma) == 1
        sigma = repmat(sigma,[Noutbands,1]);
    end
    if length(jitterfactor) == 1
        jitterfactor = repmat(jitterfactor,[Noutbands,1]);
    end
end



% subtract mean, normalize
y = y-mean(y);
y = y./max(y);

% create subbands and envelopes
subbands = create_subbands(y,Fs,[],passbands);
envelopes = abs(hilbert(subbands));

% low pass filter
[b,a] = butter(3,2*30/Fs); % 30 Hz lowpass
envelopes =  filtfilt(b,a,envelopes);

% create gaussian noise carrier for nvs
if params.noisevoc == true
    carriers = randn(size(y));
    carriers = create_subbands(carriers,Fs,[],passbands);
    y = carriers .* envelopes;
end
% average across frequency bands
if params.average == true
    envelopes = mean(envelopes,2);
    y = mean(y,2);
else
    y = subbands;
end

% normalize
envelopes = envelopes./max(envelopes,[],1);


% find connected components (i.e. pauses)
ysilent = (envelopes < params.threshold); % first threshold
% allocate memory
Y_mod = cell(Noutbands,1); 
Ycomp = cell(Noutbands,1);
Ncomp = zeros(Noutbands,1);
for iband = 1:Noutbands
    % find connected components
    c_size = round(params.minsize(iband) * Fs); 
    c_dist = round(params.mindist(iband) * Fs);
    [ycomp, ncomp] = conncomp_binary1d(ysilent(:,iband),c_size,c_dist);

    % minimum manipulated pause length 
    minlen = round(params.minlen(iband)/Fs);
    % either use full signal or one subband at a time
    [y_mod,ycomp,keepjit] = manipulate_pauses_from_random(y(:,iband),...
        ycomp,ncomp,sigma(iband),jitterfactor(iband),minlen);
    
    % assign output
    Y_mod{iband} = y_mod;
    Ycomp{iband} = ycomp;
    Ncomp(iband) = ncomp;
end

% unpack for convenience
if Noutbands == 1
    Y_mod = Y_mod{1};
end

ARG.ncomp = ncomp;
ARG.ycomp = ycomp;
ARG.pauselength = keepjit;
ARG.passbands = passbands(:);

end




