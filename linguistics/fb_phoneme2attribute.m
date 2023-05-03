function atr = fb_phoneme2attribute (phn,mode)
% phn = phoneme string
% cmd = 'list' or [] 
% mode = 'IPA' or 'Arpabet'
% e.x. : atr=phoneme2attribute('axh',[],'IPA') => atr = {'voiced'
% 'sonorant'    'syllabic'    'approximant'}
% atr= phoneme2attribute('AA') => atr = {'voiced'    'sonorant'
% 'syllabic'    'back'    'low'}
% 
% Neural Acoustic Processing Lab, 
% Columbia University, naplab.ee.columbia.edu
%
% updated line 33: making function possible to use with array of phonemes
%                  and therefore faster to use, i.e. phn{iphn}
%

% handle input
if ~iscell(phn)
    % to assume phn is always a cell
    phn = {phn};
end
if nargin < 2 || isempty(mode)
    mode = 'Arpabet';
end

nphn =  length(phn);

atr = cell(1,nphn);
atlist = fb_attribute2phoneme([],'list',mode);
for iphn = 1:nphn
    for cnt1 = 1:length(atlist)
        thisphn = fb_attribute2phoneme(atlist{cnt1},[],mode);
        if ~isempty(find(strcmpi(thisphn,phn{iphn})))
            atr{iphn}{end+1} = atlist{cnt1};
        end
    end
end
