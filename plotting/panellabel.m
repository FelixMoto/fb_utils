function [phout,axinv] = panellabel(AX,STR,SIZE)
%
% handle = panellabel(ax,str,SIZE)
%
% creates a panel label for the given subplots ax. ax can also span
% multuple subplots
%
% default location of the panel label is in the top left
%
% return the label handle and the invisible xis handle
%


% get current axis is none is given
if isempty(AX) || ~exist('AX')
    AX = gca;
end

if nargin < 3 || isempty(SIZE)
    SIZE = 24;
end

% what position
wposname = 'Position';

% get axis that includes most top left corner and return position
if length(AX) > 1
    OPos = cat(1,AX(:).(wposname)); 
    Pextend = [OPos(:,1) sum(OPos(:,[2,4]),2)]; % min x and max y
    minX = min(Pextend(:,1));
    maxY = max(Pextend(:,2));
    ax_ind = (Pextend(:,1) == minX & Pextend(:,2) == maxY);
    if isempty(find(ax_ind))
        OPos = AX(1).(wposname);
        warning('Could not find single top left corner. Take first axis instead.');
    else
        OPos = AX(ax_ind).(wposname);
    end
else
    % if only one axis is given
    OPos = AX.(wposname);
end

% create new position vector with fixed size
newpos = [OPos(1)-0.13 OPos(2)+OPos(4)+0.03-0.1 0.1 0.1];

% create new invisible axis
axinv = axes('pos',newpos,'visible','off'); % formerly OPos

%%% OLD CODE
% % set axes limits to scale with size of plot
% axinv.XAxis.Limits = axinv.XAxis.Limits .* OPos(3) + OPos(1);
% axinv.YAxis.Limits = axinv.YAxis.Limits .* OPos(4) + OPos(2);
% % define text position and scale as well
% tx = -0.08;
% ty = 0.9;
% dx = tx .* OPos(3) + OPos(1);
% dy = ty .* OPos(4) + OPos(2);
% % print text
% phout = text(dx, dy, STR,'FontSize',SIZE);

% define text position
tx = 0.5;
ty = 0.75;
% print text
phout = text(tx, ty, STR,'FontSize',SIZE);

end
