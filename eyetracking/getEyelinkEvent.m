function bool = getEyelinkEvent(eyelinkdefaults,eventtype)
% bool = onset_saccade(eyelinkdefaults)
%
% detect saccade onset and return true once this happens
%
% Parameters:
%   eyelinkdefaults - structure containing the default initialization
%   returned from EyelinkDoTrackerSetup in INIT_Eye
%
% outputs:
%   bool - frame wise flag whether a saccade onset occured (1) or not (0)
%

el = eyelinkdefaults;

% check inputs
if ~ischar(eventtype)
    error('eventtype must be of type char');
end
if sum(strcmp(fieldnames(el),eventtype)) == 0
    disp(fieldnames(el));
    error('eventtype is no fieldname in eyelinkdefaults');
end

evtype = Eyelink('getnextdatatype');

% find event type
if evtype==el.(eventtype)		% if the subject started a saccade 
    if Eyelink('isconnected') == el.connected % if we're really measuring eye-movements
        evt = Eyelink('getfloatdata', evtype); % get data
    end
    bool = 1;
else
    bool = 0;
end

end