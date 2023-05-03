function pcorr = fb_stat_padjust(pvals,method)
% pcorr = padjust(pvals,method)
%
% adjust p values from multiple tests
%
% Parameters
% ---------
% pvals : array containing p values of m tests
% method : optional. states correction method. either bonferroni (default) 
%          or benjamini-hochberg.
%          The Benjamini-Hochberg procedure adjusts p values for positive
%          or no dependence.
%          
% Output
% ------
% pcorr : corrected p values
%

% check input
if ~isnumeric(pvals)
    error('pvals must be numeric');
end
if ~strcmp(method,'bonferroni') && ~strcmp(method,'benjamini-hochberg')
    error(['select valid method' newline 'either "bonferroni" or "benjamini-hochberg"']);
end
if nargin < 2 || isempty(method)
    method = 'bonferroni';
end

% flatten, get number of tests
pval_shape = size(pvals);
pvals = pvals(:);
m = length(pvals);

switch method
    case 'bonferroni'
        pcorr = m * pvals;
    case 'benjamini-hochberg'
        [pcorr, i] = sort(pvals);
        pcorr = m * pcorr ./[1:m]';
        
        % threshold p values in descending order
        for k = m:-1:1
            pcorr(pcorr(1:k)>pcorr(k)) = pcorr(k);
        end
        
        % rearrange to original order
        [~,iu] = sort(i);
        pcorr = pcorr(iu);
end

% threshold p values to reasonable results
pcorr(pcorr>1) = 1;

% reshape to original form
pcorr = reshape(pcorr,pval_shape);

end
