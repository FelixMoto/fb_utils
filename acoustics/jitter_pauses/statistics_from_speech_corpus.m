function pauses = statistics_from_speech_corpus(params,path,suffix,passbands,varargin)
%
%   out = get_statistics_from_corpus(path,suffix)
%
% this function loads all sound files with the given suffix in the given
% path and computes the statistics of pauses in speech utterances
%
% i.e. it assumes that the sound files contain clear spoken speech only,
% finds the silent pauses defined by a given threshold
%
% inputs:
%   path - to directory containing corpus files (string)
%   suffix - file ending (string)
%           'wav' (default), 
%           'mat' - expects fields sound (column vector) and Fs with
%           sample rate
%   params - structure containing parameters for defining pauses
%           defaults are:
%             params.threshold = 0.1;
%             params.fmin = 100;
%             params.fmax = 10000;
%             params.nbands = 12;
%             params.lowpass = 30;
%             params.minsize = 0.03;
%             params.mindist = 0.06;
%


% handle input
if ~ischar(path) || ~ischar(suffix)
    error('path and suffix must be character arrays');
end
% go into folder
if path(end) ~= '\' || path(end) ~= '/'
    path = [path '\'];
end

if nargin < 4
    % default values
    params.threshold = 0.1;
    params.fmin = 100;
    params.fmax = 10000;
    params.nbands = 12;
    params.average = true;
    params.minsize = 0.03;
    params.mindist = 0.06;
end

if isempty(varargin)
    verbose = true;
end

% list files
allfiles = [path '*.' suffix];
listfiles = dir(allfiles);
nfiles = length(listfiles);

% number of output bands if evelope is averaged or not
if params.average == true
    Noutbands = 1;
else
    Noutbands = params.nbands;
end

Gaps = cell(Noutbands,1);
Ncomp = zeros(nfiles,Noutbands);

% Verbose mode
if verbose == true
    v = verbosemode([],[],nfiles);
end

% run analysis
for ifile = 1:nfiles
    % load sound file
    filename = [path, listfiles(ifile).name];
    if suffix == 'mat'
        load(filename,'sound','Fs');
        y = sound;
    else
        [y, Fs] = audioread(filename);
    end

    % force mono, subtract mean, norm to [0 1]
    y = y(:,1);
    y = y-mean(y);
    y = y./max(y);

    % generate subbands
    env = create_subbands(y,Fs,[],passbands);
    env = abs(hilbert(env)); 
    if params.average == true
        env = mean(env,2);
    end
    env = env./max(env,[],1);

    % generate coefficients and low pass filter
    [b,a] = butter(3,2*30/Fs); % 30 Hz low pass
    env = filtfilt(b,a,env);

    % find quiet points, find components
    ysilent = (env < params.threshold);
    c_size = round(params.minsize * Fs); 
    c_dist = round(params.mindist * Fs);
    for iband = 1:Noutbands
        [ycomp, ncomp] = conncomp_binary1d(ysilent(:,iband),c_size,c_dist);
        gaps = hist(ycomp,ncomp);
        gaps = gaps(2:end-1); % discard out-of-sentence gaps
        Gaps{iband} = [Gaps{iband} gaps];
        Ncomp(ifile,iband) = ncomp;
    end
    
    % Verbose mode
    if verbose == true
        v = verbosemode(v,ifile,nfiles);
    end
end

% output stats
pauses.nfiles = nfiles;
pauses.Ncomp = Ncomp;
pauses.dist = Gaps;
pauses.sd = cellfun(@std,Gaps);
pauses.skewness = cellfun(@skewness,Gaps);
pauses.kurtosis = cellfun(@kurtosis,Gaps);

% unpack for more convenience
if Noutbands == 1
    pauses.dist = pauses.dist{1};
end
    
end


function v = verbosemode(v,i,j)
% v = verbosemode(i,j)
% outputs command line message with how many of all files are already
% computed

if isempty(v)
    v.msg = ['%d/%d files'];
    v.count = 0;
    i = 0;
end

if i == 0
    fprintf('Compute statistics from speech corpus: \n');
elseif i <= j
    fprintf(repmat('\b',1,v.count)); % \b is one backspace
    v.count = fprintf(v.msg,i,j);
end

if i == j
    fprintf('\n');
end

end
