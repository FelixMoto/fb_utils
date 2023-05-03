function [x,argout] = fb_stepwise_response(brain, stim, Fs, varargin)
% compute MI with a striding window with variable overlap 
%
% input
% brain: brain data (cell array, chan x time)
% stim: stimulus data (cell array, chan x time)
%       brain and stim must be of same length
% Fs: sample rate - assumes same sample rate for both signals
% windowlen: length of striding window in seconds
% overlap: window overlap in seconds
% CHANS: channels to use from brain signal
% pad: 'false' (default) to return unpadded data
%       'true' to pad each cell to the maximum length
%
% returns:
% cell array with CHANS x step data for each trial
% 
% EXAMPLE:
% x = fb_stepwise_response(brain_cell, stim_cell, 150, 2, 1, 128);
%
%
% TO DO:
%  - padding or omitting of end
% maybe pad all matrices to same length at the end
%  - variable for cell array or double array input
%

% check input data types --------
if isnumeric(brain) || iscell(brain)
    if class(brain) == class(stim)
        if length(brain) ~= length(stim)
            error('Arrays must be of same length');
        end
    else
        error('Data must be same data type');
    end
else
    error('Wrong data type. Only Cell arrays and doubles accepted');
end

% varargin parameters -------------
fs = Fs;
if ~isempty(varargin)
    try
        windowlen = varargin{1};
    catch
        windowlen = 1;
    end
    try
        overlaplen = varargin{2};
    catch
        overlaplen = 0.5;
    end
    try
        CHANS = varargin{3};
    catch
        CHANS = 128;
    end
    try
        tail = varargin{4};
    catch
        tail = 'false';
    end
end
            
window = [1:windowlen*fs]; % striding window
overlap = floor(overlaplen*fs); % overlap

if isnumeric(brain)
    ntrl = 1;
elseif iscell(brain)
    ntrl = length(brain);
end

response = [];
for k = 1:ntrl
    tmp_brain = brain{k}; tmp_stim = stim{k}; % only if data is cell array
    nsteps = 2*floor(length(tmp_brain)/(windowlen*fs))-1;
    
    MI_true = zeros(CHANS,nsteps);
    for i = 1:nsteps
        I_segment = window + (i-1)*overlap;
        trl_brain = tmp_brain(:,I_segment)';
        trl_stim = tmp_stim(:,I_segment)';
        % compute MI
        for e = 1:CHANS
            MI_true(e,i) = mi_gg(trl_stim,trl_brain(:,e),'true','true');
        end
    end
    response{k} = MI_true;
end

% zero pad all entries to same maximum length
switch tail
    case 'true'
        maxlen = max(cellfun(@(x) size(x,2),response));
        minlen = min(cellfun(@(x) size(x,2),response));
        ARG.maxlen = maxlen; 
        ARG.minlen = minlen;
        for k = 1:length(response)
            diff = maxlen - size(response{k},2);
            response{k} = padarray(response{k}',diff, 'post')';
        end
end


x = response;
switch tail
    case 'true'
        if nargout == 2 
            x = response;
            argout = ARG;
        end
end

end
