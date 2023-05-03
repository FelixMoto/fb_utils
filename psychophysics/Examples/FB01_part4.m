%% clear all, add path
% script to present two envelopes, high and low, one conditions both are 
% in natural carriers, second condition both unnatural carrier
% aka: (1) [1,1 + 3,3] and (2) [1,3 + 3,1]; carrier x envelope
% the sequence of the sentences is random for both conditions
% combinations are created for each participant

% run the script two times, one time low band (block 1) is attended, the
% second time the high band (block 2) is attended

% TASK: find gap in the attended stream

%==========================================================================
% clear and import dependencies
%==========================================================================
close all;
clearvars;
rng('shuffle');

addpath('Z:\FB00\utils');
addpath('Y:\Matlab\chimera');
D{1} = 'C:\Users\eeglab\Desktop\CNSLAB\FB01\experiment\Stimuli_3_bands\all';

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
fprintf('run this script two times (block 1 and 2). \n either low or high band is to be attended \n \n');
subj = input('Subject: ', 's');
ARG.subj = subj;
block = input('Block (1-2):');
ARG.block = block;
ARG.c = clock;

sname = sprintf('%sENVfreqEEG_%s_part4_block%d.mat',ARG.save_dir,subj,block);
GOOD_KEYS = [37,39]; % probably keys 1-2 on numpad 

%==========================================================================
% sound paramters
%==========================================================================
load_fs = 150; % sample rate of loaded envelopes
fs = 44100; % sample rate of played stimuli
ARG.Rate = fs;
ts = 1/fs;
ARG.fco = equal_xbm_bands(200,8000,3); % define freq band borders
ARG.cue_length = fs * 1.5;

% create noise cues with two channels
noise = randn(1,ARG.cue_length) * 0.08;
[b,a] = butter(4,2*[ARG.fco(1), ARG.fco(2)]/fs);
cue_low = filtfilt(b,a,noise);
cue_low = cue_low/max(cue_low);
cue{1} = [cue_low; cue_low];
[b,a] = butter(4,2*[ARG.fco(3), ARG.fco(4)]/fs);
cue_high = filtfilt(b,a,noise);
cue_high = cue_high/max(cue_high);
cue{2} = [cue_high; cue_high];

%==========================================================================
% intervals and conditions
%==========================================================================
gap_size = [450,600]; % silent gap length interval (ms)
ARG.ITT = [1000,1500]; % inter-trial time interval(ms)
ARG.gap_size_interval = gap_size;
ARG.gap_ratio = 0.2; % ratio of gaps in trials
% stimulus loop chooses from this list
cond = [1,1,3,3; 1,3,3,1]; % carrier x envelope for both sounds per row (condition)

% list for condition sequence
ARG.sequence = [];
ARG.sequence_legend = ('condition, sentence, carrier, envelope, gap occurence low (1 = yes), gap location, gap length, gap occurence high, gap location, gap length');

% go to directory for block
cd(D{1});
sentence_list = dir('*.mat');

% define list with gap occurences in all conditions
one = round(length(sentence_list) * ARG.gap_ratio);
random_gap = [zeros(1,length(sentence_list) - one), ones(1, one)];

fprintf('finished initializing parameters \n');

%% create envelope-modulated white noise
% each sentence and each condition per sentence appears only once

% go through conditions ---------------------------------------------------
for k = 1:2
    % shuffle random gap index
    random_gap_low = random_gap(randperm(numel(random_gap)));
    random_gap_high = random_gap(randperm(numel(random_gap)));
    % choose sentences at random with each new condition 
    sentence_idx = randperm(length(sentence_list));
    
    % go through all sentence for each condition in random order ----------
    for m = 1:length(sentence_idx)
        fprintf('sentence %d / %d \n', m, length(sentence_idx));
        % load sentence with random order index
        load(sentence_list(sentence_idx(m)).name);
        env = resample(env',fs,load_fs)'; % needs to be transposed twice for resample
        [xenv,yenv] = size(env);
        voc_speech = zeros(2, yenv);

        % create modulated white noise ------------------------------------
        for d = 1:2
            en = cond(k,d*2); % envelope index (2,4)
            carr = cond(k,d*2-1); % carrier index (1,3)
            fprintf('carrier %d / envelope %d \n', carr, en);

            % create white gaussian noise
            y = randn(1,yenv)*0.08;
            % bandpass filter noise 
            [b,a] = butter(4,2*[ARG.fco(carr), ARG.fco(carr+1)]/fs);
            y = filtfilt(b,a,y);
            % amplitude modulation w/ envelope
            y_mod = y.*env(en,:);
            voc_speech(d,:) = y_mod;
        end
        
        % insert gap into low carrier -------------------------------------
        if random_gap_low(m) == 1
            % get gap length [sample rate]
            gap_len_low = round(randi(gap_size,1) * 0.001 * fs);
            % get gap location; start between 0.5 and 0.75 of sound length
            gap_loc_low = randi([ceil(length(y_mod) * 0.5), floor(length(y_mod) * 0.75)]);
            % create gap in voc_sum
            voc_speech(1,gap_loc_low:gap_loc_low + gap_len_low) = 0;
            % cosine ramp for smoother gaps
            voc_speech(1,1:gap_loc_low) = cosine_ramp(voc_speech(1,1:gap_loc_low),0.008,fs);
            voc_speech(1,gap_loc_low:gap_loc_low + gap_len_low) = cosine_ramp(voc_speech(1,gap_loc_low:gap_loc_low + gap_len_low),0.008,fs);
            
        end
        % insert gap into high carrier ------------------------------------
        if random_gap_high(m) == 1
            % get gap length [sample rate]
            gap_len_high = round(randi(gap_size,1) * 0.001 * fs);
            % get gap location; start between 0.5 and 0.75 of sound length
            gap_loc_high = randi([ceil(length(y_mod) * 0.5), floor(length(y_mod) * 0.75)]);
            % create gap in voc_sum
            voc_speech(2,gap_loc_high:gap_loc_high + gap_len_high) = 0;
            % cosine ramp for smoother gaps
            voc_speech(2,1:gap_loc_high) = cosine_ramp(voc_speech(2,1:gap_loc_high),0.008,fs);
            voc_speech(2,gap_loc_high:gap_loc_high + gap_len_high) = cosine_ramp(voc_speech(2,gap_loc_high:gap_loc_high + gap_len_high),0.008,fs);
            
        end
        
        % append sequence -------------------------------------------------
        if random_gap_low(m) == 1 && random_gap_high(m) == 1
            ARG.sequence = [ARG.sequence; k,sentence_idx(m),carr,en,random_gap_low(m),gap_loc_low,gap_len_low,random_gap_high(m),gap_loc_high,gap_len_high];
        elseif random_gap_low(m) == 1 && random_gap_high(m) ~= 1
            ARG.sequence = [ARG.sequence; k,sentence_idx(m),carr,en,random_gap_low(m),gap_loc_low,gap_len_low,random_gap_high(m),NaN,NaN];
        elseif random_gap_low(m) ~= 1 && random_gap_high(m) == 1
            ARG.sequence = [ARG.sequence; k,sentence_idx(m),carr,en,random_gap_low(m),NaN,NaN,random_gap_high(m),gap_loc_high,gap_len_high];
        else
            ARG.sequence = [ARG.sequence; k,sentence_idx(m),carr,en,random_gap_low(m),NaN,NaN,random_gap_high(m),NaN,NaN];
        end
        
        % sum and normalize noise -----------------------------------------
        voc_sum = sum(voc_speech);
        voc_sum = voc_sum/std(voc_sum) * 0.07;
        voc_sum(find(voc_sum>1)) = 1;
        voc_sum(find(voc_sum<-1)) = -1;
        
        % duplicate for 2 channels ----------------------------------------
        voc_sum = [voc_sum;voc_sum];
        all_sentences{m} = voc_sum;
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

for j = 1:length(all_conds)
    WaitSecs(2);
    for p = 1:length(sentence_list)
        INIT_fixation_cross;
        run = sprintf('condition %d, sentence %d \n',j, p);
        fprintf(run);
        Trial = Trial + 1;
        
        % every 4 trials repeat cue sound and wait ------------------------
        if mod(p,4) == 1
            PsychPortAudio('FillBuffer', pahandle, cue{block});
            PsychPortAudio('Start', pahandle, 1, inf, 0);
            CueStart = PsychPortAudio('RescheduleStart', pahandle, 0, 1);
            WaitSecs(2);
        end
        
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
        
        % gap either in low or high stream (depending on block)
        % gap occurence in either ARD.sequence 5 or 8 -> 3*(1|2)+2
        if ARG.sequence(Trial, 3*block+2) == 1 % gap in sound 
            if ~isnan(resp)
                if resp == GOOD_KEYS(1)  % numpad 1
                    resp_code=1;
                    fprintf('correct\n');
                elseif resp == GOOD_KEYS(2)
                    fprintf('wrong\n');
                end
            else
                fprintf('wrong button\n');
            end
        elseif ARG.sequence(Trial, 3*block+2) == 0 % no gap in sound
            if ~isnan(resp)
                if resp == GOOD_KEYS(1)  % numpad 1
                    fprintf('wrong\n');
                elseif resp == GOOD_KEYS(2)
                    resp_code=1;
                    fprintf('correct\n');
                end
            else
                fprintf('wrong button\n');
            end
        end
        
        % ASSERT SOUND IS FINISHED BEFORE CONTINUE!!!
        
        % append Result once per trial ------------------------------------
        RT = t3-t2;
        Result(Trial,:) = [j, p, RT, resp, resp_code];
        Timing(Trial,:) = [t1,t2,t3,StartTime];
        WaitSecs(pause_jitter);
        
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
pause(1);
Priority(0);

Screen('CloseAll');
PsychPortAudio('close');
zzz;
fprintf('DONE!! \n');
