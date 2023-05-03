function [thhandles,axinv] = paneltitle(AX,STRING,SIZE)
%
% [thhandles,axinv] = paneltitle(AX,STRING,SIZE)
%
% create invisible axis of the size spanning all axes in AX and writes a
% panel title on top
%

% get current axis is none is given
if isempty(AX) || ~exist('AX')
    AX = gca;
end

if nargin < 3 || isempty(SIZE)
    SIZE = 14;
end


% get position spanning all axes in AX
if length(AX) > 1
    OPos = cat(1,AX(:).Position); 
    pmin = min(OPos(:,[1,2]),[],1);
    pmax = max(OPos(:,[1,2]) + OPos(:,[3,4]),[],1);
    OPos = [pmin pmax-pmin];
else
    % if only one axis is given
    OPos = AX.Position;
end

% create new invisible axis
axinv = axes('pos',OPos,'visible','off');
% write title text
thhandles = text(0.5,1.1,STRING,'FontSize',SIZE,'FontWeight','bold','HorizontalAlignment','center');

end
