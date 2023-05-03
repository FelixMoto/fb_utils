[xCenter, yCenter] = RectCenter(screenRect);
fixCrossDimPix = 40;
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0, 0, -fixCrossDimPix, fixCrossDimPix];
allCoords = [xCoords; yCoords];
lineWidthPix = 4;
Screen('DrawLines', w, allCoords,lineWidthPix, 250, [xCenter yCenter], 2);

Screen('Flip', w);