function [hf, hp] = fb_errorshade(tax,M,SEM,cuse,varargin)
% [hf, hp] = fb_errorshade(tax,M,SEM,varargin)
%
% Error-bar lines with shaded background
%
% errorshade(tax,M,SEM,varargin)
%  varargin can contain the variable 'color'
%
% Inputs:
%   tax : time vector
%   M : mean vector
%   SEM : standard error of mean (or another error metric) 
%   color : either as a character or RGB triplet
%
% Returns:
%   hf : fill handle
%   hp : line handle
%

% Parse input arguments
arg = parsevarargin(varargin);

% set default color
if nargin < 4 || isempty(cuse)
    cuse = [0 0 0];
end

% specify edge color as RGB triplet if  string was parsed
if ischar(arg.EdgeColor)
    if strcmp(arg.EdgeColor,'cuse')
        edgecolor = cuse;
    elseif strcmp(arg.EdgeColor,'none')
        edgecolor = 'none';
    end
end


hold on;
n = size(SEM,1);
% if error is one vector subtract SEM
if n == 1
    SEM = [SEM; SEM];
    SEM = M + [1;-1] .* SEM;
end


hf = fill([tax(1:end) tax(end:-1:1)],[SEM(1,:) SEM(2,[end:-1:1])], ...
    cuse);
set(hf,'EdgeColor',edgecolor);
set(hf,'FaceAlpha',arg.FaceAlpha);

hp =  plot(tax(1:end),M,'Color',cuse);
set(hp,'LineWidth',2)

  

end


function arg = parsevarargin(varargin)
%PARSEVARARGIN  Parse input arguments.
%   [PARAM1,PARAM2,...] = PARSEVARARGIN('PARAM1',VAL1,'PARAM2',VAL2,...)
%   parses the input arguments of the main function.

% Create parser object
p = inputParser;

% shading alpha
errorMsg = 'FaceAlpha must be between 0 and 1.';
validFcn = @(x) assert(x>0 & x<1,errorMsg);
addParameter(p,'FaceAlpha',0.4,validFcn);

% edge color
errorMsg = 'FaceAlpha must be RGB triplet or string';
validFcn = @(x) assert(ischar(x) | isvector(x),errorMsg);
addParameter(p,'EdgeColor','cuse',validFcn);

% Parse input arguments
parse(p,varargin{1,1}{:});
arg = p.Results;

end
