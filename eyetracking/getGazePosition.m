function [x,y] = getGazePosition(eyelinkdefaults,eye_used)
% [x,y] = getGazePosition(eyelinkdefaults,eye_used)
%
% return the gaze position in x and y coordinates for the specified eye
%

el = eyelinkdefaults;

% default empty values
x = 0; y = 0;

% check for presence of a new sample update
if Eyelink('NewFloatSampleAvailable') > 0
    % get the sample in the form of an event structure
    evt = Eyelink('NewestFloatSample');
    if eye_used ~= -1 % do we know which eye to use yet?
        % if we do, get current gaze position from sample
        x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
        y = evt.gy(eye_used+1);
    end
end

end
