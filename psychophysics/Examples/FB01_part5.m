%% clear all, add path
% script to noise vocoded speech with different numbers of bands
% three conditions: 3,6,12 band vocoded speech
% all sentences are presented in random order per condition

% TASK: identify the target word which occured in the sentence

% one target and two distractor words are presented on screen after
% sentence
% target words should occur in second half of the sentence

%==========================================================================
% clear and import dependencies
%==========================================================================
close all;
clearvars;
rng('shuffle');

addpath('Z:\FB00\utils');
addpath('Y:\Matlab\chimera');
D{1} = 'C:\Users\eeglab\Desktop\CNSLAB\FB01\experiment\Stimuli_3_bands\all';
D{2} = 'C:\Users\eeglab\Desktop\CNSLAB\FB01\experiment\Stimuli_6_bands\all';
D{3} = 'C:\Users\eeglab\Desktop\CNSLAB\FB01\experiment\Stimuli_12_bands\all';

%% basic paramters, subject data and inputs

ARG.save_dir = 'C:\Users\eeglab\Desktop\CNSLAB\FB01\experiment\data\log_data\';
ARG.paradigm = 'ENVfreqEEG';
ARG.Do_trigger = 1; % set to 0 when testing on a different computer !
ARG.Do_Eye = 0;
ARG.SNDCARD = 'Realtek';
ARG.screenNr = 2;

%==========================================================================
% subject info and time
%==========================================================================
subj = input('Subject: ', 's');
ARG.subj = subj;
ARG.c = clock;

sname = sprintf('%sENVfreqEEG_%s_part5.mat',ARG.save_dir,subj);
GOOD_KEYS = [37,40,39]; % keys 1-3 on numpad 

%==========================================================================
% sound paramters
%==========================================================================
load_fs = 150; % sample rate of loaded envelopes
fs = 44100; % sample rate of played stimuli
ARG.Rate = fs;
ARG.bands_for_fco = [3,6,12];

%==========================================================================
% intervals and conditions
%==========================================================================
ARG.ITT = [1000,1500]; % inter-trial time interval(ms)
%ARG.gap_size_interval = gap_size;

% list for condition sequence
ARG.sequence = [];
ARG.sequence_legend = ('sentence, words, index of target');
ARG.answer = [];
ARG.target_idx = [];

targets = load('C:\Users\eeglab\Desktop\CNSLAB\FB01\experiment\targets.mat');
targets = targets.targets;
distractors = load('C:\Users\eeglab\Desktop\CNSLAB\FB01\experiment\distractors.mat');
distractors = distractors.distractors;

fprintf('finished initializing parameters \n');

%% create vocoded speech

% all conditions ----------------------------------------------------------
for k = 1:3
    fco = equal_xbm_bands(200,8000,ARG.bands_for_fco(k));
    cd(D{k}); % go to dir with envelopes (3,6,12)
    sentence_list = dir('*.mat');
    % choose sentences at random with each new condition 
    sentence_idx = randperm(length(sentence_list));
    % create new empty list for answers and target_idx for each condition
    answer_list = [];
    target_idx_list = [];
    
    % all sentences per condition -----------------------------------------
    for m = 1:length(sentence_idx)
        fprintf('condition %d / ', k);
        fprintf('sentence %d \n', m);
        load(sentence_list(sentence_idx(m)).name);
        env = resample(env',fs,load_fs)'; % needs to be transposed twice for resample
        [xenv,yenv] = size(env);
        voc_speech = zeros(xenv, yenv);

        % all freq bands per sentence -------------------------------------
        for d = 1:xenv
            y = randn(1,yenv)*0.08;
            [b,a] = butter(4,2*[fco(d), fco(d+1)]/fs);
            y_mod = filtfilt(b,a,y);
            y_mod = y_mod.*env(d,:);
            voc_speech(d,:) = y_mod;
        end
        % sum of all sounds --------------------------------------------
        voc_speech_sum = sum(voc_speech);
        voc_speech_sum = voc_speech_sum/std(voc_speech_sum) * 0.07; % normalize
        voc_speech_sum(find(voc_speech_sum>1)) = 1;
        voc_speech_sum(find(voc_speech_sum<-1)) = -1;
        voc_speech_sum = [voc_speech_sum; voc_speech_sum]; % 2 channels
        all_sentences{m} = voc_speech_sum;
        
        % create target and distractor words for that sentence ------------
        % shuffle and find index of target word
        answer = [targets(sentence_idx(m)), distractors(sentence_idx(m),:)];
        answer = answer(randperm(numel(answer)));
        target_idx = find(contains(answer, targets(sentence_idx(m))));
        answer_list = [answer_list; answer];
        target_idx_list = [target_idx_list; target_idx];
        
        % append ARG.sequence ---------------------------------------------
        ARG.sequence = [ARG.sequence; sentence_idx(m), answer, target_idx];
        
    end
    all_conds{k} = all_sentences;
    all_answers{k} = answer_list;
    all_targets{k} = target_idx_list;
end

fprintf('finished loading sounds \n');


%% initialize screen and sound

%==========================================================================
% initialize screen
%==========================================================================
%Screen('Preference', 'SkipSyncTests', 1); % only for other setups
IMG_BGND = 80;
screens = Screen('Screens');
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

for j = 1:length(all_conds)
    WaitSecs(2);
    for p = 1:length(sentence_list)
        INIT_fixation_cross;
        fprintf('condition %d, sentence %d \n',j, p);
        Trial = Trial + 1;

        % load sounds -----------------------------------------------------
        PsychPortAudio('FillBuffer', pahandle, all_conds{1,j}{1,p});
        PsychPortAudio('Start', pahandle, 1, inf, 0);

        % calculate pause time and jitter ---------------------------------
        T = length(all_conds{1,j}{1,p})/fs;
        T_half = T/2;
        pause_jitter = randi(ARG.ITT, 1) * 0.001; % [seconds]
        
        % send trigger and store timing -----------------------------------
        t1 = GetSecs;
        if ARG.Do_trigger, io64(cogent.io.ioObj,address,Trial); end

        % present stimulus ------------------------------------------------
        StartTime = PsychPortAudio('RescheduleStart', pahandle, 0, 1);
        t2 = GetSecs;
        % wait until stimulus is finished plus buffer
        WaitSecs(T + 0.25);
        
        % present target and distractor words on screen -------------------
        % left(1), center(2), right(3)
        % might need adjustment for screen width
        DrawFormattedText(w, all_answers{1,j}{p,1}, SX*0.2, 'center', [250,250,250]);
        DrawFormattedText(w, all_answers{1,j}{p,2}, 'center', 'center', [250,250,250]);
        DrawFormattedText(w, all_answers{1,j}{p,3}, SX*0.7, 'center', [250,250,250]);
        Screen('Flip', w);
        
        % get subject response --------------------------------------------
        % GET CORRECT KEY CODES!
        [secs, KeyCode] = KbWait([],2); % 2 means wait for second keystroke
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

        if ~isnan(resp)
            if resp == GOOD_KEYS(all_targets{1,j}(p))  % correct
                resp_code=1;
                fprintf('correct\n');
            elseif resp ~= GOOD_KEYS(all_targets{1,j}(p)) % wrong
                fprintf('wrong\n');
            end
        else
            fprintf('wrong button\n');
            
        end
        
        % ask for confidence ----------------------------------------------
        DrawFormattedText(w, 'wie sicher?', 'center', SY*0.35, [250,250,250]);
        DrawFormattedText(w, 'sehr', SX*0.2, SY*0.6, [250,250,250]);
        DrawFormattedText(w, 'mittel', 'center', SY*0.6, [250,250,250]);
        DrawFormattedText(w, 'wenig', SX*0.7, SY*0.6, [250,250,250]);
        Screen('Flip', w);
        
        % get subject response --------------------------------------------
        [secs, KeyCode] = KbWait([],2); % 2 means wait for second keystroke
        conf = find(KeyCode);
        
        if length(conf) > 1
            conf = conf(1);
        end
        if sum(conf==GOOD_KEYS)==0
            conf = NaN;
        end
        conf_code = 0;
        
        if ~isnan(conf)
            if conf == GOOD_KEYS(1)  % very confident
                conf_code=1;
            elseif conf == GOOD_KEYS(2)
                conf_code=2;
            elseif conf == GOOD_KEYS(3)
                conf_code=3;
            end
        else
            fprintf('wrong button\n');
        end
        
        % append Result once per trial ------------------------------------
        RT = t3-t2;
        Result(Trial,:) = [j, p, RT, resp, resp_code, conf, conf_code];
        Timing(Trial,:) = [t1,t2,t3,StartTime];
        WaitSecs(pause_jitter); % waits until sound has finished
        
        % save data ---------------------------------------------------------------
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
WaitSecs(1);
Priority(0);

Screen('CloseAll');
PsychPortAudio('close');
zzz;
fprintf('DONE!! \n');

