function out = ArpabetCorpus()
% out = ArpabetCorpus()
%
% return the 2-letter Arpabet phoneme corpus sorted into phonetic subgroups
% the ARPAbet represents phonemes of general american english. this might 
% not work well for other languages 
%

% phoneme groups
arpa2.fricatives = {'V','DH','Z','ZH','F','TH','S','SH','CH','JH','AW','AY','OY','IX'};
arpa2.plosives = {'B','D','G','P','T','K'};
arpa2.vowels = {'IY','IH','EY','EH','AE','AA','AO','OW','UH','UW','ER','AX','AH'};
arpa2.semivowels = {'EL','L','R','W','WH','Y'};
arpa2.nasals = {'M','N','NX','NG','EM','EN'};
%arpa2.others = {'DX','HH','Q'};


out = arpa2;


end

