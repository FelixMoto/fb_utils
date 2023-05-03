function out = Phone2Viseme(phones,Corpus)
% out = Phone2Viseme(phones,Corpus)
%
% takes input array phones containing a cell array of phonemes into
% an array of viseme class labels 
%
% input:
% phones: cell array containing ARPAbet phoneme trascriptions
% VisemeCorpus: nested cell array containing ARPAbet phoneme grouping arrays
%               - if not specified, uses default Corpus 

% handle input
if ~isvector(phones)
    error('phones should be a 1D vector');
else
    phones = phones(:);
end

if nargin < 2 || isempty(Corpus)
    Corpus = VisemeCorpus;
end

% allocate output
out = zeros(size(phones));

for I = 1:length(phones)
    vis = 0;
    for J = 1:length(Corpus)
        if any(strcmp(phones{I},Corpus{J}))
            vis = J;
        end
    end
    out(I) = vis;
end

end
