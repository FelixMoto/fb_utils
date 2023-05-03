function map = customColormap(varargin)
%
% deprecated
%
% new function is called fb_plot_colormaps
%

warning('old function. use fb_plot_colormaps intead');

mapname = varargin;
map = fb_plot_colormaps(mapname);

end
