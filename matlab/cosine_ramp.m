
function [original]=cosramp(original, l_ramp, Fs);
%
% function [original]=cosramp(original, length of ramp, Sample rate);
%
% cosine-ramps 2nd dimension(s) of input vector
%

if min(size(original))==1
  % 1 d
  original = original(:)';
else
  % ensure 2xd
  if size(original,1)~=2
    original = original';
  end
end


x=round(Fs*l_ramp);
z=0:(1/x):1;
ramp=(-0.5*cos(pi*z))+0.5;
ramp = ramp;


% ramp vector
y = ones(size(original));
y(:,[1:length(ramp)]) = repmat(ramp,[size(y,1),1]);
y(:,length(y)-[1:length(ramp)]+1) = repmat(ramp,[size(y,1),1]);

original = original.*y;


