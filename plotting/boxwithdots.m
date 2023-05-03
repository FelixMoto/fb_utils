function boxwithdots(Data,colorcode,barpos,dotside,varargin)
% boxwithdots(Data,colorcode,barpos,dotside)
% do the boxplots with the respective dots next to them. 

% Parse input arguments
arg = parsevarargin(varargin);

% get Data size
[nrows,ncols] = size(Data);

if nargin < 2 || isempty(colorcode)
    colorcode = 'b';
elseif ismatrix(colorcode)
    set(gca,'ColorOrder',colorcode,'NextPlot','replacechildren');
end
if nargin < 3 || isempty(barpos)
    barpos = [1:ncols];
end
if nargin < 4 || isempty(dotside)
    dotside = 1;
end


% individual data jitter
X = repmat([1:ncols],[nrows,1]);
jitter = randn(size(X)) .* 0.03;
offset = 0.3 * dotside; % shift to side of boxplots
X = X + jitter + offset;

% change data to orientation
if strcmp(arg.Orientation,'horizontal')
    dotX = Data;
    dotY = X;
else
    dotX = X;
    dotY = Data;
end


% plot data
boxplot(Data,'width',0.2,'symbol','','plotstyle',arg.Plotstyle, ...
    'position',barpos,'colors',colorcode,'Orientation',arg.Orientation);

% set box and median marker thickness
a = get(get(gca,'children'),'children');
t = get(a,'tag');
box = a(strcmpi(t,'box'));
set(box,'LineWidth',arg.Thickness);
MarkerTags = {'medianinner','medianouter'};
for itag = 1:numel(MarkerTags)
    idx = strcmpi(t,MarkerTags{itag});
    obj = a(idx);
    set(obj,'MarkerSize',arg.Thickness*1.2);
end

hold on
plot(dotX,dotY,'.','MarkerSize',arg.MarkerSize);
hold off



end

function arg = parsevarargin(varargin)
%PARSEVARARGIN  Parse input arguments.
%   [PARAM1,PARAM2,...] = PARSEVARARGIN('PARAM1',VAL1,'PARAM2',VAL2,...)
%   parses the input arguments of the main function.

% Create parser object
p = inputParser;

% Boxplot style
errorMsg = 'Not a supported plotstyle.';
validFcn = @(x) assert(strcmp(x,'traditional')||strcmp(x,'compact'),errorMsg);
addParameter(p,'Plotstyle','traditional',validFcn);

% Boxplot orientation
errorMsg = 'Must be either horizontal or vertical.';
validFcn = @(x) assert(strcmp(x,'horizontal')||strcmp(x,'vertical'),errorMsg);
addParameter(p,'Orientation','vertical',validFcn);

% Boxplot width
errorMsg = 'Must be scalar.';
validFcn = @(x) assert(x>0,errorMsg);
addParameter(p,'Thickness',4,validFcn);

% Marker size
errorMsg = 'Must be scalar.';
validFcn = @(x) assert(x>0,errorMsg);
addParameter(p,'MarkerSize',8,validFcn);


% Parse input arguments
parse(p,varargin{1,1}{:});
arg = p.Results;

end