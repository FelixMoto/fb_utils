%
% compute envelopes from spoken sentence, indepedently shift envelopes in
% time and create noise-vocoded speech
%
% prerequisites are:
%   chimera toolbox
%   ckmatlab
%
% test for potential paradigm in FB03
%

close all
clearvars


load adj_1 % -> sound; Fs;

% parameters -------------------------
nbands = 16;
fmin = 100;
fmax = 10000;
fco = equal_xbm_bands(fmin,fmax,nbands);
low_pass = 30; % (Hz)

% component parameters
thrs = 0.08;
minsize = 0.03; % in seconds
mindist = 0.06;

% manipuation parameters
StdGaps = 2.9749e+03; % taken from analysis script for all corpus sentences
% STDs for manipulation
stdext = [0.3, 0.6, 0.9];
manipStdGaps = stdext .* StdGaps;


%% create envelopes

% force mono, normalize
y = sound(:,1);
y = y-mean(y);
y = y./max(y);
% same size noise
noise = randn(size(y));

[lpb, lpa] = butter(3,2*low_pass/Fs);

ENV = zeros(length(y),nbands);
NOISE = ENV;

for i = 1:length(fco)-1
    [b,a] = butter(3,2*[fco(i), fco(i+1)]/Fs);
    tmpy = filtfilt(b,a,y);
    tmpy = abs(hilbert(tmpy));
    %tmpy = filtfilt(lpb,lpa,tmpy);
    ENV(:,i) = tmpy;
    
    tmpn = filtfilt(b,a,noise);
    NOISE(:,i) = tmpn;
end


%% analyze each envelope for pauses
% similar to kayser 2015 journal of neuroscience

NVS = ENV .* NOISE;
nvs = mean(NVS,2);

env = mean(ENV,2);
env = env-mean(env);
env = env./max(env);

% threshold, component size and distance
env_silent = (env < thrs);
c_size = round(minsize * Fs); c_dist = round(mindist * Fs);
[ycomp, ncomp] = conncomp_binary1d(env_silent,c_size,c_dist);


%% manipulate pauses

% test pause manipulation
y_mod = nvs;
y_mod(env_silent) = 0;
y_modcopy = y_mod;
ycomp_mod = ycomp; % copy to reindex pauses as well

% create normpdf kernel with new sigma
X = [-3000:1:3000];
MU = 0;
Y = normpdf(X,MU,manipStdGaps(3));

% constraint parameter
minlen = 0.02/Fs;

% keep track of new jitters
keepjit = zeros(ncomp-2,1);

% loop pauses w/o first and last pause
for comp = 2:ncomp-1
    % get component and it's length
    CC = find(ycomp_mod==comp);
    CClen = CC(end) - CC(1);
    
    % constraint is min. 20 ms and not longer than 300% of original length
    jitter = Inf; % set to infinity to get while loop going
    while CClen + jitter < minlen || CClen + jitter > 3*CClen
        jitter = randsample(X,1,true,Y); % can be neg. or pos.
    end
    keepjit(comp) = jitter; 
    % create new pause length
    newlen = CClen + jitter;
    newpause = zeros(newlen,1);
    % insert new pauses
    y_mod = [y_mod(1:CC(1)-1); newpause; y_mod(CC(end)+1:end)];
    % also update comp vector
    ycomp_mod = [ycomp_mod(1:CC(1)-1); comp+newpause; ycomp_mod(CC(end)+1:end)];
end












