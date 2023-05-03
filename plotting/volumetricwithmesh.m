function handle = volumetricwithmesh(cfg,data,insourcemodel)
%
% handle = plot_volumetricwithmesh(cfg,data)
% takes volumetric input data and plots it together with a 3D mesh of the
% cortical surface
%
% assumes fieldtrip available in path
%
% Parameters
% ----------
%   cfg : structure
%       defines input arguments
%
%   data : double
%       nvox by 1 matrix of volumentric data
%   insourcemodel : double
%       nvox by 1 matrix indicating where in the sourcemodel the data is 
%       located
%

% handle input
cfg = checkarg(cfg,'intrpmethod','nearest');
cfg = checkarg(cfg,'sourcemodel','standard_sourcemodel3d6mm');
cfg = checkarg(cfg,'templateT1','single_subj_T1_1mm.nii');
cfg = checkarg(cfg,'sourceatlas','sourceatlas_grid.mat');
cfg = checkarg(cfg,'headshape','cortex_8196.surf.gii');
cfg = checkarg(cfg,'atlasdir','ROI_MNI_V4.nii');


% load sourcemodel
load(cfg.sourceatlas);

% get template MRI
mri = ft_read_mri(cfg.templateT1);
mri = ft_convert_units(mri, 'cm');

% put data into whole brain structure
sourcemodel.fun = zeros(size(sourcemodel.pos,1),1);
sourcemodel.fun(insourcemodel) = data; 

% interpolate
cfgp = [];
cfgp.interpmethod = cfg.intrpmethod; 
cfgp.parameter = 'fun';
intrp = ft_sourceinterpolate(cfgp, sourcemodel, mri);
intrp.coordsys = 'mni';
intrp.fun(isnan(intrp.fun)) = 0;

% get linear to 3D indices
ind = find(intrp.fun);
[I1,I2,I3] = ind2sub(size(intrp.fun),ind);
[ofx,ofy,ofz] = size(intrp.fun);
INV = [I1,I2,I3] - [ofx,ofy,ofz]./2;


headmodel = ft_read_headshape(cfg.headshape);
meanpos = mean(headmodel.pos,1);
% fit origin in both data matrices
INVfit = INV + meanpos;


% plot surface with triangulation surface
handle = figure;
C = zeros(size(headmodel.pos,1),1);
trisurf(headmodel.tri,headmodel.pos(:,1),headmodel.pos(:,2),headmodel.pos(:,3),...
    C,'FaceAlpha',0,'EdgeAlpha',0.1)
hold on
markersize = 0.1;
scatter3(INVfit(:,1),INVfit(:,2),INVfit(:,3),markersize,intrp.fun(ind));
colorbar

axis vis3d
axis equal


end

