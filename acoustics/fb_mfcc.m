function coeff = fb_mfcc(audio,fs,varargin)
% coeff = fb_mfcc(audio,fs,varargin)
%
% function that computes the mel-frequency ceptral coefficients (MFCC) of
% an input signal. This is done by successively computing the mel-spaced
% ceptrum on a tapered window.
%
% inputs:
%   audio: 1D input signal 
%   fs: sample rate (Hz)
%
%   ncoeff (optional): number of MFCCs to return (0 < ncoeff < 40),
%          (default) 13
%   LogEnergy (optional): if log energy should be computed and how to
%           append to coeff. Either 'append', appends to the first row of
%           coeff, 'replace' replaces first row of coeff with log energy or
%           'ignore', does not return log energy. (default) is 'Append'.
%   alpha (optional): pre-emphasis coefficient alpha. Must be numeric and
%           0.9 < a < 1.0. (default) is 1.0
%
% returns:
%   coeff: returns the Ncoeff by Nwindows matrix of coefficients 
%   

% Parse input arguments
arg = parsevarargin(varargin);
ncoeff = arg.ncoeff;

% handle input
if ~isvector(audio)
    error('audio must be 1D vector');
else
    x = audio(:);
end

if nargin < 2 || isempty(fs)
    fs = 44100;
end


% parameters
xlen = length(x);
winlen = round(0.04 * fs);
overlap = round(0.02 * fs);
win = hamming(winlen);
f = fs*(0:(winlen/2))/winlen;

% triangular filter parameters
K = winlen/2+1;
R = [0, 8000]; % frequency limits
ntrifilt = 32;

% set up triangular mel-spaced filters
[H,~,~] = trifbank(ntrifilt,K,R,fs);

% determine number of windowing steps
nstep = 1 + floor((xlen-winlen)/(winlen-overlap));

% pad end with last digit
overhang = xlen - (winlen+(nstep-1)*overlap);
if overhang > 0
    pad = ones(winlen-overhang,1) .* x(end);
    x = [x; pad];
    nstep = nstep + 1;
end


% allocate space
coeff =  zeros(ncoeff,nstep); 
logEnergy = zeros(1,nstep);

% pre-emphasis time signal
% via y(n) = x(n) - ax(n-1), with 0.9 < a < 1.0
kernel = [1, -arg.alpha]; % coefficients for x(n) and x(n-1)
x = conv(sound,kernel,'same'); % same as filter(kernel, 1, x)

for istep = 1:nstep
    % index and attenuate window
    idx = [1:winlen] + (istep-1) * overlap;
    xwin = x(idx) .* win;
    
    % log energy
    logEnergy(:,istep) = log(sum(xwin.^2));
    
    % mel cepstral coeffs
    xfft = abs(fft(xwin));
    p = xfft(1:winlen/2+1);
    trif = log10(sum(repmat(p',[ntrifilt,1]) .* H, 2));
    y = dct(trif);
    
    coeff(:,istep) = y(1:ncoeff);
end

% append log energy if desired
if strcmp(arg.LogEnergy,'append')
    coeff = [logEnergy; coeff];
elseif strcmp(arg.LogEnergy,'replace')
    coeff(1,:) = logEnergy;
end


end


function arg = parsevarargin(varargin)
%PARSEVARARGIN  Parse input arguments.
%   [PARAM1,PARAM2,...] = PARSEVARARGIN('PARAM1',VAL1,'PARAM2',VAL2,...)
%   parses the input arguments of the main function.

% Create parser object
p = inputParser;

% Number of Coefficients to return
errorMsg = 'Number of Coefficients must be between 0 and 40.';
validFcn = @(x) assert(x<40 && x>0,errorMsg);
addParameter(p,'ncoeff',13,validFcn);


% Log Energy appending
regOptions = {'append','replace','ignore'};
validFcn = @(x) any(validatestring(x,regOptions));
addParameter(p,'LogEnergy','append',validFcn);

% Pre emphasis alpha
errorMsg = 'Pre-emphasis alpha must be between 0.9 and 1.0';
validFcn = @(x) assert(isnumeric(x) && x<1.0 && x>0.9,errorMsg);
addParameter(p,'alpha',1.0,validFcn);


% Parse input arguments
parse(p,varargin{1,1}{:});
arg = p.Results;

% Redefine partially-matched strings
arg.LogEnergy = validatestring(arg.LogEnergy,regOptions);

end
