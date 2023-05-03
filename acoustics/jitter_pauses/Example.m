%
% EXAMPLE for jittering pauses in a sound file of spoken speech
% 
% the algorithm is designed to work similarly as described in Kayser et al.
% 2015 [1].
%
% the broadband amplitude envelope is thresholded to find silent pauses
% between utterances. then the distribution of the pause lengths is
% computed. Then the standard deviation is used to sample changes in pause
% lengths to manipulate the temporal structure of the speech.
%
% utilizes the CHIMERA TOOLBOX
%
% References:
%   [1] Kayser, S.J., Ince, R.A.A., Gross, J., Kayser, C., 2015. Irregular 
%       Speech Rate Dissociates Auditory Cortical Entrainment, Evoked 
%       Responses, and Frontal Alpha. J. Neurosci. 14619-701.
%       https://doi.org/10.1523/JNEUROSCI.2243-15.2015
%

% path to folder containing files
path_to_speech_corpus = 'C:\Users\fbroehl\Documents\FB03\matsounds';
% file format (without a dot)
% expects wav or mat files; mat files are expected to contain fields
% 'sound' and 'Fs'
suffix = 'mat';

% default values
params = [];
params.threshold = 0.08; % this value is somewhat dependent on the speech material
% too low or too high values will find no pauses
params.fmin = 100; % lower and upper freq limits for envelope extraction
params.fmax = 10000;
params.nbands = 10; % number of bands used
params.average = false; % whether envelopes are averaged or pauses are computed for each individually 
params.minsize = 0.03; % min size and distance of pauses in seconds
params.mindist = 0.06;
params.minlen = 0.02; % minimum length constraint for jitter_pauses

% logarithmically spaced passbands are created with the CHIMERA TOOLBOX
passbands = equal_xbm_bands(params.fmin,params.fmax,params.nbands);


% compute statistics for pauses 
pauses = statistics_from_speech_corpus(params,path_to_speech_corpus,suffix,passbands)

%%%%%%%%%%
% pause statistics can be computed once, saved to file and loaded later
%%%%%%%%%%



%% load one example sound
filename = 'adj_1.mat';
sound = load(filename);
y = sound.sound(:,1);
Fs = sound.Fs;

cfg = [];
cfg.nbands = params.nbands;
cfg.average = false;
cfg.noisevoc = false;
jitfac = [0,0,0,0,0, 0.5,0.5,0.5,0.5,0.5];
jitfac = fliplr(jitfac);
[y_mod, ARG] = jitter_pauses(cfg,y,Fs,pauses.sd,jitfac,passbands);




%% plot results
if params.average == false
    maxlen = max(cellfun(@length,y_mod));
    Y_modmat = zeros(maxlen,params.nbands);
    for iband = 1:params.nbands
        ilength = length(y_mod{iband});
        Y_modmat(1:ilength,iband) = y_mod{iband};
    end
    Y_mod = mean(Y_modmat,2);
    Y_mod = Y_mod./max(Y_mod);
else
    Y_mod = y_mod;
end


figure
subplot(211);
plot(y./max(y));
hold on
plot([1,length(y)], [params.threshold, params.threshold], 'r--');
ylim([-1.2,1.2]);
title('original waveform');

subplot(212);
plot(Y_mod);
hold on
plot([1,length(Y_mod)], [params.threshold, params.threshold], 'r--');
ylim([-1.2,1.2]);
title('waveform with jittered pauses');



