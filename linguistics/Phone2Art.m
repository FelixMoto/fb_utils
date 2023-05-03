function [Mapping,out] = Phone2Art(phoneVec,dim)
% [Mapping,out] = Phone2Art(phoneVec,dim)
%
% map phonemes from ARPAbet onto articulatory features
% Although phonemes form a mutually exclusive set of descriptors,
% articulatory features do not.
%
% expects a column cell array of ARPAbet phoneme labels
%

% the following structure defines the mapping between phonemes and
% articulatory features based on 
%
% N. Chomsky, M. Halle, The Sound Pattern of English (1968)
% Mesgarani et al. 2014, Science

% define phoneme mapping
Mapping.FeatureLabels = {'dorsal', 'coronal', 'labial',...
    'high', 'front', 'low', 'low', 'back',...
    'plosive', 'fricative', 'syllabic', 'nasal',...
    'voiced', 'obstruent', 'soronant'};

% resonants
Mapping.PhoneDict.AA = [6,7,10,12,14];
Mapping.PhoneDict.AE = [5,6,10,12,14];
Mapping.PhoneDict.AH = [];
Mapping.PhoneDict.AO = [6,7,10,12,14];
Mapping.PhoneDict.AW = [10,12,14];
Mapping.PhoneDict.AY = [10,12,14];
Mapping.PhoneDict.EH = [5,6,10,12,14];
Mapping.PhoneDict.EY = [10,12,14];
Mapping.PhoneDict.IH = [4,5,10,12,14];
Mapping.PhoneDict.IY = [4,5,10,12,14];
Mapping.PhoneDict.L  = [12,13,14];
Mapping.PhoneDict.OW = [10,12,14];
Mapping.PhoneDict.R  = [12,13,14];
Mapping.PhoneDict.UW = [4,7,10,12,14];
Mapping.PhoneDict.Y  = [12,14];

% fricatives
Mapping.PhoneDict.DH = [9,12,13];
Mapping.PhoneDict.F  = [3,9,13];
Mapping.PhoneDict.S  = [2,9,13];
Mapping.PhoneDict.SH = [1,9,13];
Mapping.PhoneDict.TH = [9,13];
Mapping.PhoneDict.V  = [3,9,12,13];
Mapping.PhoneDict.Z  = [2,9,12,13];

% plosives
Mapping.PhoneDict.B  = [3,8,12,13];
Mapping.PhoneDict.D  = [2,8,12,13];
Mapping.PhoneDict.G  = [1,8,12,13];
Mapping.PhoneDict.K  = [1,8,13];
Mapping.PhoneDict.P  = [3,8,13];
Mapping.PhoneDict.T  = [2,8,13];

% nasals
Mapping.PhoneDict.M  = [3,11,12,13,14];
Mapping.PhoneDict.N  = [2,11,12,13,14];
Mapping.PhoneDict.NG = [1,11,12,13,14];

% yet undefined
Mapping.PhoneDict.ER = [];
Mapping.PhoneDict.CH = [];
Mapping.PhoneDict.HH = [];
Mapping.PhoneDict.JH = [];
Mapping.PhoneDict.UH = [];
Mapping.PhoneDict.W  = [];


Nfeatures = length(Mapping.FeatureLabels);


%% actual mapping
if nargin > 2
    error('too many input arguments');
elseif nargin == 1
    % compute over first dimension if no dim is given
    dim = 1;
end

InputLen = size(phoneVec,dim);
ArtArray = zeros(InputLen, Nfeatures);

for iPoint = 1:InputLen
    if ~isempty(phoneVec{iPoint})
        phone = phoneVec{iPoint};
        phone = Mapping.PhoneDict.(char(phone));
        slice = zeros(1,Nfeatures);
        slice(:,phone) = 1;
        ArtArray(iPoint,:) = slice;
    else
        % if segment in silent (no phoneme)
        slice = zeros(1,Nfeatures);
        ArtArray(iPoint,:) = slice;
    end
end

% output
out = ArtArray;


end

