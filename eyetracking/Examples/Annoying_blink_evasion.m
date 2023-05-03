%
% create small eye tracking psychophysics demo to test estup in 205
%
% present a small form on the screen only as long as participants are
% blinking
%

close all
clearvars


%% parameters

ARG.screenNr = 2;
ARG.SNDCARD = 'Realtek'; % Creative or Realtek
ARG.Sound_attenuation = 0.5;
ARG.Do_Eye = 1;
ARG.dummymode = 0; % 1 for dummy mode (use mouse)


% dummy etname for INIT_Eye - used to store file
etname = 'demo.edf';       

%% initailize hardware
% usual order is screen, trigger, sound, eyelink

% initialize screen -------------------------------------
INIT_screen;


% initialize sound -------------------------------------
ARG.Rate = 44100;
INIT_snd;


% initialze eye tracker -------------------------------------
dummymode = ARG.dummymode;
INIT_Eye;

% start recording eye position
if ARG.Do_Eye, Eyelink('StartRecording');  WaitSecs(1); end


%% main

% get the eye that is being tracked
eye_used = Eyelink('EyeAvailable');

colour = [100, 0, 0];


% instructions to start paradigm
WaitSecs(1);
DrawFormattedText(w, 'Taste zum Start', 'center', 500, [250 250 250]);
vbl = Screen('Flip', w);
[secs, keyCode] = KbWait(-1,2);
vbl = Screen('FLip', w);


% define key to stop paradigm
stopkey = KbName('space');

% loop till error or space bar is pressed
while 1 
    % Check recording status, stop display if error
    error=Eyelink('CheckRecording');
    if(error~=0) 
        break;
    end
    % check for keyboard press
    [keyIsDown, secs, keyCode] = KbCheck;
    % if spacebar was pressed stop display
    if keyCode(stopkey)
        break;
    end
    
    
    % probably better with detecting blink onset and offset, so script is
    % faster
    [x,y] = getGazePosition(el,eye_used);
    bool = detect_blink(el);
    if bool
        gazeRect = [center(1)-8 center(2)-8 center(1)+8, center(2)+8];
        Screen('FillRect', w, colour, gazeRect);
        Screen('Flip',w);
        WaitSecs(0.02); 
    else
        % erase screen - either this way or used 'FillRect' with bg color
        Screen('Flip',w);
    end
     

end
 



Screen('CloseAll');
PsychPortAudio('Close')
