function [Segments, Iss] = segment_pauses(audio,fs,thrs,winlen,minlen)
% [Segments, Iss] = segment_pauses(audio,fs,thrs,winlen,minlen)
%
% segments a vector containing audio at silent intervals defined by the RMS
% threshold
%
% inputs:
%   audio: 1D vector with the audio in mono
%   fs: audio sample rate, (default) is 44100 Hz
%   thrs: silent interval threshold, (default) < 0.3
%   winlen: RMS normalization window length, (default) is 5 s
%   minlen: minimum length of pauses, (default) is 0.5 s
%
% returns:
%   Segments: cell array of audio segments
%   Iss: indexing start and stop of each segment from original audio
%

% handle input
if ~isvector(audio)
    error('audio must be 1D array');
else
    x = audio(:);
end

if nargin < 2 || isempty(fs)
    fs = 44100;
end
if nargin < 3 || isempty(thrs)
    thrs = 0.3;
end
if nargin < 4 || isempty(winlen)
    winlen = 5 * fs;
end
if nargin < 5 || isempty(minlen)
    minlen = 0.5 * fs;
end


% get amplitude and smooth with square window
squarelen = round(0.02 * fs);
squarewin = ones(squarelen,1);
xh = abs(hilbert(x));
xh = conv(xh,squarewin,'same'); % makes conncomp way faster

xlen = length(xh);
nstep = floor(xlen/winlen); % n window slides


% RMS normalization with sliding window
x_rms = zeros(size(xh));
for istep = 1:nstep
    idx = [1:winlen]+(istep-1)*winlen;
    x_rms(idx,:) = xh(idx,:) ./ rms(xh(idx,:));
end

% norm overlap
if mod(xlen,winlen) > 0
    idx = [winlen*nstep+1:xlen];
    x_rms(idx,:) = xh(idx,:) ./ rms(xh(idx,:));
end


% make binary vector and search for connected pauses
x_thrs = zeros(size(x_rms));
x_thrs(x_rms <  thrs) = 1;
x_thrs(x_rms >= thrs) = 0;

% find pauses of size minlen
[out, Ncomp] = conncomp_binary1d(x_thrs,minlen);


% cut original audio within each silent pause
Segments = cell(1,Ncomp-1);
iSeg = zeros(Ncomp-1,2);
offset = round(0.3 * minlen); % margin left and right
for icomp = 1:Ncomp-1
    leftci = find(out == icomp);
    rightci = find(out == icomp+1);
    Segments{icomp} = audio(leftci(end-offset+1):rightci(offset),:);
    iSeg(icomp,:) = [leftci(end-offset+1), rightci(offset)];
end


% if audio starts/ends with no pause, get those segments as well 
if out(1) == 0
    rightci = find(out == 1);
    startseg = {audio(1:rightci(offset),:)};
    Segments = [startseg, Segments];
    iSeg = [[1, rightci(offset)]; iSeg];
end
if out(end) == 0
    leftci = find(out == Ncomp);
    endseg = {audio(leftci(end-offset+1):end,:)};
    Segments = [Segments, endseg];
    iSeg = [iSeg; [leftci(end-offset+1), xlen]];
end


% handle output
if nargout > 1
    Iss = iSeg;
end


end
