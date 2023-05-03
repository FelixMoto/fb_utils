
if ~isfield(ARG,'RATE')
  ARG.RATE = 44100;
end
  
  
devices = PsychPortAudio('GetDevices');
for l=1:length(devices)
    if ~isempty(strfind(devices(l).DeviceName,ARG.SNDCARD))
        deviceid = devices(l).DeviceIndex;
    end
end


InitializePsychSound(1); %force low latency
PsychPortAudio('Verbosity', 10);
mode=[]; 
reqlatencyclass=0;
buffersize = 0;    
suggestedLatencySecs = [0.015];
channels=2;
pahandle = PsychPortAudio('Open', deviceid, mode, reqlatencyclass, ARG.Rate, channels,[],suggestedLatencySecs);
