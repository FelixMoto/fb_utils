function y = fb_preprocess_trials(cfg,x)
%
% expects the to be filtered dimension along the second axis. e.g. channel x
% time x trials
%
% Parameters
% ----------
%   cfg : structure
%       containing fields specifying the preprocessing steps. These can
%       include:
%
%       continuous: (true, false) whether data should be filtered trial-wise or all
%           concatenated together (default true)
%       fs: sample rate in Hz
%       filter: (true, false) whether data should be filtered.
%           (default false)
%       filtertype: ('butter') type used for filtering (default butter)
%       filterord: filter order (default 4)
%       filterfreq: filter cut off frequencies. must be a two element
%           vector 
%       filterwindow: if filter should be symmetrical (default 1)
%       demean: (true, false) whether mean of data should be subtracted
%           (default false)
%       rescale: (true, false) whether data should be rescaled with its
%           global standard deviation (default false)
%       hilbert: (true, false) whether data should be hilbert transformed
%           (default false)
%       zcopnorm: (true, false) whether data should be copula normalized.
%           relevant for computing mutual information. (default false)
%       angle: (true, false) whether to compute phase angle. can only be
%           done when hilbert is true (default false)
%
%   x : double || cell
%       input data, either as a 3D double array or a cell array containing
%       2D doubles
%
% Returns
% -------
%   y : double || cell
%       processed data in the form of input x
%
%
% TODO:
% - create filter within function, specify different filters (lowpass, highpass,
%   bandpass, etc.)
% - update function description
% - make possible to use any combination of preprocessing steps, e.g.
%   without filtering
%

% handle input
cfg = checkarg(cfg,'continuous',true);
cfg = checkarg(cfg,'fs',[]);
cfg = checkarg(cfg,'filter',false);
cfg = checkarg(cfg,'filtertype','butter');
cfg = checkarg(cfg,'filterord',4);
cfg = checkarg(cfg,'filterfreq',[]);
cfg = checkarg(cfg,'filterwindow',1);
cfg = checkarg(cfg,'demean',false);
cfg = checkarg(cfg,'rescale',false);
cfg = checkarg(cfg,'hilbert',false);
cfg = checkarg(cfg,'zcopnorm',false);
cfg = checkarg(cfg,'angle',false);

if cfg.filter == true && isempty(cfg.fs)
    error('Sample rate must me given');
end
if cfg.filter == true && isempty(cfg.filterfreq)
    error('Band stop frequencies must me given');
end

if ~cfg.hilbert && cfg.zcopnorm
    warning('Can only copula normalize with hilbert data');
end
if ~cfg.hilbert && cfg.angle
    warning('Can only compute phase angle with hilbert data');
end

% make filter
if cfg.filter == true
    ARGF.mode = cfg.filtertype;
    ARGF.Freqs = cfg.filterfreq;
    ARGF.order = cfg.filterord;
    ARGF.rate = cfg.fs;
    ARGF.window = cfg.filterwindow;
    Filt = ck_filt_makefilters(ARGF);
    Filt = Filt{1};
end


% check if input is cell type
Iscell = iscell(x);

% get input size
if Iscell
    ntrl = length(x);
    nrow = size(x{1},1);
else
    [nrow,ncol,ntrl] = size(x);
end



% filter data
if cfg.filter == true
    if cfg.continuous
        % concatenate trials
        if Iscell
            trlIdx = cellfun(@(ix) size(ix,2), x);
            x = [x{:}];
        else
            x = reshape(x,[nrow,ncol*ntrl]);
        end
        y = ck_filt_applyfilter(x,Filt);
    elseif ~cfg.continuous && ~Iscell
        % keep trials separate
        y = zeros(size(x));
        for t = 1:ntrl
            y(:,:,t) = ck_filt_applyfilter(x(:,:,t),Filt);
        end
    elseif ~cfg.continuous && Iscell
        y = cell(1,ntrl);
        for t = 1:ntrl
            y{t} = ck_filt_applyfilter(x{t},Filt);
        end
    end
else
    y = x;
end 
clear x


% concat trials if not already done
if ~cfg.continuous
    if Iscell
        trlIdx = cellfun(@(ix) size(ix,2), y);
        y = [y{:}];
    else
    y = reshape(y,[nrow,ncol*ntrl]);
    end
end

% zscore to global distribution
if cfg.demean
    y = y - mean(y,2);
end
if cfg.rescale
    y = y ./ std(y,[],2);
end

% hilbert transform
if cfg.hilbert
    y = ck_filt_hilbert(y);
    if cfg.zcopnorm
        y = copnorm([real(y') imag(y')])';
        nrow = 2*nrow; % real and imag
    elseif cfg.angle
        y = angle(y')';
    end
end


% reshape or pack in cell array again
if Iscell
    y = mat2cell(y,nrow,trlIdx);
else
    y = reshape(y,[nrow,ncol,ntrl]);
end


end


