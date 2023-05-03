function handles = inlay_subplot(sbh,Position)
%
% handles = inlay_subplot(sbh,Position)
% inserts a new subplot into an axisting one that can be used as an inlay
%
% Parameters
% ----------
% sbh : outer subplot handles
% Position : inlay position given relative to the axes scaling of the 
%            subplot [x y w h]
%
% Returns
% handles : handles of the inlay subplot
%

%
% TODO:
% take existing subplot as reference and create new axes (using axes)
%
% by default out y axis to the left or right, depending where the inlay is
% situated (this should be related to the axes scaling of the outer
% subplot)
% -> take urgumenta to change this and to change the location of the x axis
% as well
%
% return handles in a way that data can be plotted in the inlay
%
% comment function, write description
%
%
% example:
% figure
% ax1 = axes('Position',[0.1 0.1 0.7 0.7]);
% ax2 = axes('Position',[0.65 0.65 0.28 0.28]);
%


% get position argument
outer_position = sbh.Position;
% axes limits
xlimits = sbh.XAxis.Limits;
ylimits = sbh.YAxis.Limits;
% axes scaling factor
xscaling = diff(xlimits) / outer_position(3);
yscaling = diff(ylimits) / outer_position(4);


% define inlay position
% [ x y width height ]
inlay_pos = Position ./ [xscaling yscaling xscaling yscaling];
% shift by outer plot position and subtract subplot axes offset as well
inlay_pos = [outer_position([1,2]) 0 0] - [(xlimits(1)/xscaling) (ylimits(1)/yscaling) 0 0] + inlay_pos;
handles = axes('Position',inlay_pos);

% set x axis location to top 
if Position(2) > diff(ylimits)/2
    handles.XAxisLocation = 'top';
end
% set y axis lcoation depending on axes location in outer plot
if Position(1) > diff(xlimits)/2
    handles.YAxisLocation = 'right';
end

end
