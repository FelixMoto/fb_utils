function ind_out = gridneighbors3D(sz,ind,rad)
%
% get neighbors in 3D space for a grid point ind in a space of size sz
%


% parse flexible size of volume
% parse shape of volume (cube, sphere)
% parse on or more peak indices 

% return volumetric indices
% return grid point distance to center
if ~isvector(sz) && length(sz) ~= 3
    error('shape size must be 3D');
end
if ~isvector(ind)
    error('ind must be a vector');
end

if nargin < 3 || isempty(rad)
    rad = 1;
elseif mod(rad,2) ~= 0
    error('radius must be uneven number');
end

n = length(ind);
kernel = [-rad:1:rad];

for ii = 1:n
    [x,y,z] = ind2sub(sz,ind(ii));
    [A,B,C] = ndgrid(x+kernel,y+kernel,z+kernel);
    ind_out{ii} = sub2ind(sz,A(:),B(:),C(:));
end


end
    
