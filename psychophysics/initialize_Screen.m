PsychDefaultSetup(1);
screens = Screen('Screens');
screenNumber = max(screens);

white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
gray = floor(white/2);
[window, windowRect]=PsychImaging('OpenWindow',screenNumber, 80/250);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
ifi=Screen('GetFlipInterval', window);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
