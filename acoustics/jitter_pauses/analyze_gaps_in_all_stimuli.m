%
% go through all files from matsounds, analyze silent periods in a manner
% similar to Kayser 2015 and see if the algorithm works
%

close all
clearvars

nambase{1} = 'adj';
nambase{2} = 'num';

% subbands
fmin = 200; % in Hz
fmax = 6000;
nbands = 11;
lowpass = 30; % in Hz

% component clustering
threshold = 0.08;
minsize = 0.03; % in seconds
mindist = 0.06;
nfiles = 90;

% collect size of gaps
Gaps = [];

% STDs for manipulation
stdext = [0.3, 0.6, 0.9];

%% main
for base = 1:length(nambase)
    for file = 1:nfiles
        filename = sprintf('matsounds/%s_%d',nambase{base},file);
        load(filename,'sound','Fs');
        
        % force mono, subrtract mean, norm to [0 1]
        y = sound(:,1);
        y = y-mean(y);
        y = y./max(y);
        
        % generate subbands
        env = extract_envelope(y,Fs,[],fmin,fmax,nbands);
        env = mean(env,1);
        env = env./max(env);
        
        % generate coefficients and low pass filter
        [b,a] = butter(3,2*lowpass/Fs);
        env = filtfilt(b,a,env);
        
        % find quiet points, find components
        ysilent = (env < threshold);
        c_size = round(minsize * Fs); c_dist = round(mindist * Fs);
        [ycomp, ncomp] = conncomp_binary1d(ysilent,c_size,c_dist);
        gaps = hist(ycomp,ncomp);
        gaps = gaps(2:end-1); % discard out-of-sentence gaps
        Gaps = [Gaps gaps];
    end
end

%% try manipulation on last loaded sentence

% max. likelihoods
MeanGaps = mean(Gaps);
StdGaps = std(Gaps);
manipStdGaps = stdext .* StdGaps;

% test pause manipulation
y_mod = y;
y_mod(ysilent) = 0;
y_modcopy = y_mod;
ycomp_mod = ycomp; % copy to reindex pauses as well

% create normpdf kernel with new sigma
X = [-3000:1:3000];
MU = 0;
Y = normpdf(X,MU,manipStdGaps(3));

% constraint parameter
minlen = 0.02/Fs;

% keep track of new jitters
keepjit = zeros(ncomp-2,1);

% loop pauses w/o first and last pause
for comp = 2:ncomp-1
    % get component and it's length
    CC = find(ycomp_mod==comp);
    CClen = CC(end) - CC(1);
    
    % constraint is min. 20 ms and not longer than 300% of original length
    jitter = Inf; % set to infinity to get while loop going
    while CClen + jitter < minlen || CClen + jitter > 3*CClen
        jitter = randsample(X,1,true,Y); % can be neg. or pos.
    end
    keepjit(comp) = jitter; 
    % create new pause length
    newlen = CClen + jitter;
    newpause = zeros(newlen,1);
    % insert new pauses
    y_mod = [y_mod(1:CC(1)-1); newpause; y_mod(CC(end)+1:end)];
    % also update comp vector
    ycomp_mod = [ycomp_mod(1:CC(1)-1); comp+newpause; ycomp_mod(CC(end)+1:end)];
    
end


    
%% plot
GapsFs = Gaps./Fs;
[H, X] = hist(GapsFs,20);

figure
bar(X, H./sum(H),1);
xlabel('Pause Duration (s)','FontWeight','bold');
ylabel('% Pauses','FontWeight','bold');

centralmoment = @(x,n) mean((x-mean(x)).^n);

