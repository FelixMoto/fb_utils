function cmap = interp_colormap(Colors,n)
%
% cmap = interp_colormap(Colors,n)
% interpolates a matrix of two colors along the first dimension into n
% steps
%
% could be modified to allow interpolating more than two colors
%

% define arbitrary initial indices for two colors
x = [0 1]; 
% new sampling
xq = linspace(0,1,n);

cmap = interp1(x,Colors,xq);

end
