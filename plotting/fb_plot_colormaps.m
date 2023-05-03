function map = fb_plot_colormaps(varargin)
%
% map = fb_plot_colormaps(varargin)
% 
% returns on of the following colormaps:
%

% handle input
if numel(varargin) < 1 
    mapname = 'bwr';
elseif numel(varargin) > 1
    error('can only take one argument as input');
elseif ~isempty(varargin{1}) && ischar(varargin{1})
    mapname = varargin{1};
else
    error('unknown colormap name');
end


switch mapname
    case 'ccm'
        map = [ones(1,100); ones(1,50),linspace(1,0,50); linspace(1,0,100)]';
        
    case 'bwr'
        map = [linspace(0,1,50),ones(1,50); linspace(0,1,50),linspace(1,0,50); ones(1,50),linspace(1,0,50)]';
        
    case 'bwrlight'
        map = [linspace(0.6,1,50),ones(1,50); linspace(0.6,1,50),linspace(1,0.6,50); ones(1,50),linspace(1,0.6,50)]';
        
    case 'mwg'
        map = 0.7 .* [linspace(0,1,50),ones(1,50); ones(1,50),linspace(1,0,50); linspace(0,1,50),ones(1,50)]';
        
    case 'whitetohot'
        map = [];
end

end
