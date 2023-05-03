function bool = detect_blink(eyelinkdefaults)
% bool = detect_blink(eyelinkdefaults)
%
% detect saccade onset and return true once this happens
%
% Parameters:
%   eyelinkdefaults - structure containing the default initialization
%   returned from EyelinkDoTrackerSetup in INIT_Eye
%
% outputs:
%   bool - frame wise flag whether the eye is occluded by blinking (1) or not (0)
%

el = eyelinkdefaults;

% this should do the trick already
% check whether there is pupil data
if Eyelink( 'NewFloatSampleAvailable') > 0
    bool = 1;
else
    bool = 0;
end



end