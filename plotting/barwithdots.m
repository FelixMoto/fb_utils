function Handles = barwithdots(cfg,Data)
% has yet no outputs. work in progress
% assumes Data is a 2D matrix
% Handles = barwithdots(cfg,Data)
%

% check input data 
if ~ismatrix(Data) && ~isvector(Data)
    error('Data must be a matrix or a vector');
end

% get data size
[nrows,ncols] = size(Data);


% check input parameters
if ~exist('cfg','var')
    cfg = [];
end
% check default values
cfg = checkarg(cfg,'ax',gca); % use current axis as default
cfg = checkarg(cfg,'metric','mean');
cfg = checkarg(cfg,'error','sem');
% bar defaults
cfg = checkarg(cfg,'XAxis',[1:ncols]);
cfg = checkarg(cfg,'FaceColor',[0 0.45 0.75]);
cfg = checkarg(cfg,'FaceAlpha',0.3);
cfg = checkarg(cfg,'BarWidth',0.8);
cfg = checkarg(cfg,'OutlineWidth',0.5);
% error defaults
cfg = checkarg(cfg,'WhiskerSize',0.1);
cfg = checkarg(cfg,'WhiskerLineWidth',0.5);
% dot defaults
cfg = checkarg(cfg,'offset',0.0);
cfg = checkarg(cfg,'jitterrange',0.0);
cfg = checkarg(cfg,'connect',true);
cfg = checkarg(cfg,'MarkerSize',10);
cfg = checkarg(cfg,'MarkerEdgeWidth',0.5);
cfg = checkarg(cfg,'MarkerColor',[0 0.45 0.75]);
cfg = checkarg(cfg,'LineColor',[0 0 0]);
cfg = checkarg(cfg,'LineAlpha',0.2);

if size(cfg.FaceColor,1) == 1
    cfg.FaceColor = repmat(cfg.FaceColor,[ncols,1]);
end


if strcmp(cfg.metric,'mean')
    metricfun = @(x,dim) mean(x,dim,'omitnan');
end

if strcmp(cfg.error,'sem')
    errorfun = @(x,dim) std(x,[],dim,'omitnan') / sqrt(size(x,dim));
end

% data for bars with errors
datametric = metricfun(Data,1);
dataerror = errorfun(Data,1);
abserror = [datametric + dataerror; datametric - dataerror];

% individual data 
cfg.XAxis = cfg.XAxis(:)'; % assert vector orientation
X = repmat(cfg.XAxis,nrows,1);
jitter = cfg.jitterrange .* rand([nrows,ncols]) - cfg.jitterrange/2;
X = X + jitter + cfg.offset;

% plot bars with errorbars
hold on
for icol = 1:ncols
    xcol = cfg.XAxis(icol);
    
    % individual bars
    bh(icol) = bar(cfg.ax, xcol, datametric(icol), ...
        cfg.BarWidth, ...
        'FaceColor',cfg.FaceColor(icol,:),...
        'FaceAlpha',cfg.FaceAlpha, ...
        'LineWidth',cfg.OutlineWidth); 
    
    % error bars
    eh(icol) = plot([xcol,xcol],[abserror(1,icol),abserror(2,icol)], ...
        'Color','k', ...
        'LineStyle','-', ...
        'LineWidth', cfg.WhiskerLineWidth);
    
    % whiskers
    wh(icol,1) = plot(xcol + [-cfg.WhiskerSize, cfg.WhiskerSize], [abserror(1,icol),abserror(1,icol)], ...
        'Color','k', ...
        'LineStyle','-', ...
        'LineWidth', cfg.WhiskerLineWidth);
    wh(icol,2) = plot(xcol + [-cfg.WhiskerSize, cfg.WhiskerSize], [abserror(2,icol),abserror(2,icol)], ...
        'Color','k', ...
        'LineStyle','-', ...
        'LineWidth', cfg.WhiskerLineWidth);
end

% plot lines between individual data points 
if cfg.connect
    plot(X', Data', 'Color',[cfg.LineColor cfg.LineAlpha]);
end

% plot individual data points on top
for icol = 1:ncols
    ph(icol) = plot(X(:,icol),Data(:,icol),'o', ...
        'MarkerFaceColor',cfg.FaceColor(icol,:), ...
        'MarkerEdgeColor','k', ...
        'LineWidth',cfg.MarkerEdgeWidth);
end

hold off

% set axis properties
ax = cfg.ax;
ax.XTick = [1:ncols];

% assign handles to struct
Handles.bars = bh;
Handles.error = eh;
Handles.whisker = wh;
Handles.dots = ph;

end
