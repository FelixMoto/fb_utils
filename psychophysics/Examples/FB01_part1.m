
%% clear all, add path
% script to present one band-passed white noise modulated with an envelope
% extracted from speech recordings
% combination of pass-band frequency and envelope are presented in a random
% sequence
% combinations are created for each participant
% response buttons for participants are up and down keys

%==========================================================================
% clear and import dependencies
%==========================================================================
close all;
clearvars;
rng('shuffle');

addpath('Z:\FB00\utils');
addpath('Y:\Matlab\chimera');
D{1} = 'C:\Users\eeglab\Desktop\CNSLAB\FB01\experiment\Stimuli_3_bands\Block_1';
D{2} = 'C:\Users\eeglab\Desktop\CNSLAB\FB01\experiment\Stimuli_3_bands\Block_2';

%% basic paramters, subject data and inputs

ARG.save_dir = 'C:\Users\eeglab\Desktop\CNSLAB\FB01\experiment\data\log_data\';
ARG.paradigm = 'ENVfreqEEG';
ARG.Do_trigger = 1; % set to 0 when testing on a different computer !
ARG.Do_Eye = 0;
ARG.SNDCARD = 'Realtek'; %in EEG room
ARG.screenNr = 2;

%==========================================================================
% subject info and time
%==========================================================================
fprintf('run this script two times (block 1 and 2).\n stimuli are split into two blocks for time reasons \n \n');
subj = input('Subject: ', 's');
ARG.subj = subj;
block = input('Block (1-2):');
ARG.block = block;
ARG.c = clock;

% doesn't work yet!
sname = sprintf('%sENVfreqEEG_%s_part1_block%d.mat',ARG.save_dir,subj,block);
GOOD_KEYS = [37,39]; % probably keys 1-2 on numpad
%==========================================================================
% sound paramters
%==========================================================================
load_fs = 150; % sample rate of loaded envelopes
fs = 44100; % sample rate of played stimuli 
ARG.Rate = fs;
ARG.fco = equal_xbm_bands(200,8000,3); % define freq band borders

%==========================================================================
% intervals and conditions
%==========================================================================
gap_size = [450,600]; % silent gap length interval (ms)
ARG.ITT = [1000,1500]; % inter-trial time interval(ms)
ARG.gap_size_interval = gap_size;
ARG.gap_ratio = 0.2; % ratio of gaps in trials
cond = [1,1; 1,3; 2,2; 3,1; 3,3]; % all conditions; carrier x envelope
cond_idx = randperm(length(cond)); % choose condition at random with each new sentence 

% list for condition sequence and responses
ARG.sequence = [];
ARG.sequence_legend = ('sentence, carrier, envelope, gap occurence (1 = yes), gap location, gap length');
Result = []; % particpants response
Timing = [];

% go to directory for block
cd(D{block});
sentence_list = dir('*.mat');

% define list with gap occurences in all conditions
one = round(length(sentence_list) * ARG.gap_ratio);
random_gap = [zeros(1,length(sentence_list) - one), ones(1, one)];

fprintf('finished initializing parameters \n');

%% create envelope-modulated white noise
% each sentence and each condition per sentence appears only once

% go through all conditions in random order 
for k = 1:length(cond_idx)
    fprintf('condition %d of %d \n', k, length(cond_idx));
    
    % shuffle random gap index
    random_gap = random_gap(randperm(numel(random_gap)));
    % choose sentences at random with each new condition 
    sentence_idx = randperm(length(sentence_list));
    
    % go through all sentence for each condition in random order
    for m = 1:length(sentence_idx)
        
        % load sentence with random order index
        load(sentence_list(sentence_idx(m)).name);
        env = resample(env',fs,load_fs)'; % needs to be transposed twice for resample
        [xenv,yenv] = size(env);
    
        % index for envelope in conditon
        en = cond(cond_idx(k),2);
        % index for freq band borders in condition
        carr = cond(cond_idx(k),1);
        fprintf('carrier %d / envelope %d \n', carr, en);

        % create white gaussian noise
        y = randn(1,yenv)*0.08;
        % bandpass filter noise 
        [b,a] = butter(4,2*[ARG.fco(carr), ARG.fco(carr+1)]/fs);
        y = filtfilt(b,a,y);
        % amplitude modulation w/ envelope
        y_mod = y.*env(en,:);
        
        if random_gap(m) == 1
            % get gap length
            gap_len = round(randi(gap_size,1) * 0.001 * fs);
            % get gap location
            gap_loc = randi([ceil(length(y_mod) * 0.5), floor(length(y_mod) * 0.75)]);
            % create gap in y_mod
            y_mod(gap_loc:gap_loc + gap_len) = 0;
            % cosine ramp for smoother gaps
            y_mod(1:gap_loc) = cosine_ramp(y_mod(1:gap_loc),0.008,fs);
            y_mod(gap_loc:gap_loc + gap_len) = cosine_ramp(y_mod(gap_loc:gap_loc + gap_len),0.008,fs);
            
            ARG.sequence = [ARG.sequence;sentence_idx(m),carr,en,random_gap(m),gap_loc,gap_len];
        else
            ARG.sequence = [ARG.sequence;sentence_idx(m),carr,en,random_gap(m),NaN,NaN];
        end
        % normalize to 1
        y_mod = y_mod/std(y_mod)*0.07;
        y_mod(find(y_mod>1)) = 1;
        y_mod(find(y_mod<-1)) = -1;
        
        % duplicate for 2 channels
        y_mod = [y_mod;y_mod];
        all_sentences{m} = y_mod;
    
    end
    all_conds{k} = all_sentences;
    fprintf('\n');
end

fprintf('finished loading sounds \n');

%% initialize screen and sound

%==========================================================================
% initialize screen
%==========================================================================
%Screen('Preference', 'SkipSyncTests', 1); % only for other setups
IMG_BGND = 80;
screens = Screen('Screens');
ARG.screenNr = 2;
INIT_screen;

%==========================================================================
% initialize eeg trigger
%==========================================================================
INIT_trigger;

%=======================================================================
% initialize Eye tracker
%=======================================================================
%dummymode=0;       % set to 1 to initialize in dummymode
%INIT_Eye;

%==========================================================================
% initialize sound
%==========================================================================
%InitializePsychSound % for other setups
INIT_snd;

fprintf('finished initializing screen, trigger, eye tracker, sound \n');
WaitSecs(1);

%% main loop - trials

DrawFormattedText(w, 'Drueck Taste zum Starten', 'center', 'center', [250,250,250]);
Screen('Flip', w);
[secs, KeyCode] = KbWait(-1,2);
fprintf('started run\n');
Trial = 0; % iterator for all trials

% loop through all conditions ---------------------------------------------
for j = 1:length(all_conds)
    WaitSecs(2);
    % loop through all stimuli --------------------------------------------
    for p = 1:length(sentence_list)
        INIT_fixation_cross;
        % print feedback
        fprintf('condition %d, sentence %d \n',j, p);
        Trial = Trial + 1;
        
        % load sounds -----------------------------------------------------
        PsychPortAudio('FillBuffer', pahandle, all_conds{1,j}{1,p});
        PsychPortAudio('Start', pahandle, 1, inf, 0);

        % calculate pause time and jitter ---------------------------------
        T = length(all_conds{1,j}{1,p})/fs;
        T_half = T/2;
        pause_jitter = randi(ARG.ITT, 1) * 0.001;

        % send trigger and store timing -----------------------------------
        % send EEG trigger
        t1 = GetSecs;
        if ARG.Do_trigger, io64(cogent.io.ioObj,address,Trial); end
        
        % present stimulus ------------------------------------------------
        StartTime = PsychPortAudio('RescheduleStart', pahandle, 0, 1);
        t2 = GetSecs;
        % wait until half of stimulus, then allow subjects to respond
        % response window: from half stimulus to 2s + half stimulus
        % gap occurs only in second half of stimulus
        WaitSecs(T);
        
        % get subject response --------------------------------------------
        % GET CORRECT KEY CODES!
        DrawFormattedText(w, 'ja', SX*0.25, SY*0.6, [250,250,250]);
        DrawFormattedText(w, 'nein', SX*0.7, SY*0.6, [250,250,250]);
        Screen('Flip', w);
        [secs, KeyCode] = KbWait([],2); % 2 means for second keystroke
        if ARG.Do_trigger, io64(cogent.io.ioObj,address,0); end % end trigger
        resp = find(KeyCode);
        disp(resp);
        t3 = GetSecs;
        
        if length(resp) > 1
            resp = resp(1);
        end
        if sum(resp==GOOD_KEYS)==0
            resp=NaN;
        end
        resp_code = 0;

        if ARG.sequence(Trial, 4) == 1 % gap in sound 
            if ~isnan(resp)
                if resp == GOOD_KEYS(1)  % numpad 1
                    resp_code=1;
                    fprintf('correct\n');
                elseif resp == GOOD_KEYS(2)
                    fprintf('wrong\n');
                end
            elseif isnan(resp)
                fprintf('wrong button\n');
            end
        else
            if ~isnan(resp)
                if resp == GOOD_KEYS(1)  % numpad 1
                    fprintf('wrong\n');
                elseif resp == GOOD_KEYS(2)
                    resp_code=1;
                    fprintf('correct\n');
                end
            elseif isnan(resp)
                fprintf('wrong button\n');
            end
        end
        
        % ASSERT SOUND IS FINISHED BEFORE CONTINUE!!!
        
        % append Result once per trial ------------------------------------
        RT = t3-t2;
        Result(Trial,:) = [j, p, RT, resp, resp_code];
        Timing(Trial,:) = [t1,t2,t3,StartTime];
        WaitSecs(pause_jitter);
        
        % save data -------------------------------------------------------
        save(sname, 'ARG', 'Result', 'Timing');
        
    end
    % create small break w/o fixation cross between conditions ------------
    Screen('Flip', w);
    WaitSecs(1 + pause_jitter);
    DrawFormattedText(w, 'Drueck Taste zum Fortfahren', 'center', 'center', [250,250,250]);
    Screen('Flip', w);
    [secs, KeyCode] = KbWait([], 2);
end

%==========================================================================
% finish trials
%==========================================================================
DrawFormattedText(w, 'Ende', 'center', 'center', [250,250,250]);
Screen('Flip', w);
pause(1);
Priority(0);

Screen('CloseAll');
PsychPortAudio('close');
zzz;
fprintf('DONE!! \n');
