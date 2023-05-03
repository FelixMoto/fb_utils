function hex = rgb2hex(rgb)
%
% hex = rgb2hex(rgb)
%

% If no value in RGB exceeds unity, scale from 0 to 255: 
if max(rgb(:))<=1
    rgb = round(rgb*255); 
else
    rgb = round(rgb); 
end

% Convert (Thanks to Stephen Cobeldick for this clever, efficient solution):
hex(:,2:7) = reshape(sprintf('%02X',rgb.'),6,[]).'; 
hex(:,1) = '#';

end
