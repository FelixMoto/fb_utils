function bf10 = fb_stat_tstat2BF(T,df)
% Bayes Factors from built-in t-tests.
% bf10 = fb_stat_BF_from_ttest(T,df)    - one sample
%
%
% To calculated BF based on the outcome of a T-test, pass the following 
% parameters:
% T  - The T-value resulting from a standard T-Test output 
% df - degrees of freedom from the T-test
%
% OUTPUT
% bf10 - The Bayes Factor for the hypothesis that the mean is different
%           from zero. Using JZS priors. 
%

%
% Based on: Rouder et al. J. Math. Psych. 2012
% 
% adapted and modified from:
% https://de.mathworks.com/matlabcentral/fileexchange/69794-bayesfactor
%


% get t test parameters
N = df + 1;
r = sqrt(2)/2; % scale

% flatten input, remember shape
Tshape = size(T);
T = T(:);

% Use the formula from Rouder et al.
% This is the formula in that paper; it does not use the
% scale numerator. Here we use the scale  (Checked against Morey's R package and
% http://pcl.missouri.edu/bayesfactor)
for i = 1:numel(T)
    t = T(i);
    numerator = (1+t.^2/df).^(-N/2);
    fun  = @(g) ( ((1+N.*g.*r.^2).^-0.5) .* (1+t.^2./((1+N.*g.*r.^2).*df)).^(-N/2) .* (2*pi).^(-1/2) .* g.^(-3/2).*exp(-1./(2*g))  );
    % Integrate over g
    bf01(i) = numerator/integral(fun,0,inf);
end
% reshape
bf01 = reshape(bf01,Tshape);
% Return BF10
bf10 = 1./bf01;


end