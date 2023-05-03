function out = Phone2Class(phoneVec,Corpus,group)
% out = Phone2Class(phoneVec,Corpus,group)
%
% takes an array of phonemes and a corpus of phonemes and returns an array
% of phonemes transformed into class integer labels
%
% Corpus can either contain a cell array of unique Phonemes
% or
% a struc with fieldnames subclassing phonemes in separate cell arrays
%
% class labels are derived by the phoneme occurence within the corpus or by
% the occurence in the given group
% empty and non-existing phonemes are returned as zeros
%
% if group = 1 (default), then assume that each Corpus is a single array
% and phonemes are labeled independently
% if group = 2, then labels are generated with subclasses (i.e. fricatives,
% plosives, etc.)
%

% take input cell array and create class labeled vector
UniquePhones = Corpus;

% get fieldnames
if group == 2
    Gfieldnames = fieldnames(Corpus);
end

% allocate output array
arrout = zeros(1,length(phoneVec));

for iPhone = 1:length(phoneVec)
    tmpPhone = char(phoneVec{iPhone});
    if length(tmpPhone) > 2
        tmpPhone = tmpPhone(1:2);
    end

    if ~isempty(tmpPhone)
        if group == 1
            classP = find(strcmp(tmpPhone,UniquePhones));
            arrout(iPhone) = classP;
        elseif group == 2
            for k = 1:length(Gfieldnames)
                if any(strcmp(tmpPhone,Corpus.(Gfieldnames{k})))
                    arrout(iPhone) = k;
                end
            end
        end
    else
        arrout(iPhone) = 0;
    end
end
    

% output
out = arrout;

end