function x = fb_Entropy(X,Bins,Method)
% test different entropy methods
% inputs:
% X           signal/data vector
% Bins        number of bins (for 'own' method) (int)
% Method      method name (str)
%             'custom' (default)
%             'shannon'
% 
% returns:    Entropy

% handle input
if nargin < 3
    Method = 'custom';
end

switch Method
    case 'custom'
        N = hist(X, Bins);
        Nprob = N/sum(N);
        x = -sum(Nprob .* log2(Nprob+eps));
        
    case 'shannon'
        N = X(X~=0).^2;
        x = -sum(N.*log(eps+N));
end
