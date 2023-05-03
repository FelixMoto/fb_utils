function fb_checkEEGImpedance(directory,extension)
% checkImpedance(dir,extension)
%   takes raw EEG files from a dictionary, loads their headers and checks
%   the EEG impedance
%
%   does not yet do anything, because i cant find impedance values in the
%   .bdf file header...
%

files = dir([directory '*' extension]);
nfiles = length(files);

for ifile = 1:nfiles
    bdffile = [files(ifile).folder files(ifile).name];
    cfg.dataset = bdffile;
    hdr = ft_read_header(cfg.dataset);
end


end
