function DWIunwarped = DTI_DistCorr_withEC(fm_dir,anat_dir,DWIimgs,EPI_readout_time)

% P = spm_select(Inf,'image','Select DTI data');
% Q = spm_select(Inf,'image','Select images for B0 field map');

P = spm_select('FPList',[anat_dir '\'],'_b0*');
Q = spm_select('FPList',[fm_dir '\'],'sPR*');

pm_def = pm_defaults_diffusion(EPI_readout_time);

mag1=spm_vol(Q(1,:));
phase1=spm_vol(Q(2,:));
scphase=FieldMap('Scale',phase1.fname);
fm_imgs=char(scphase.fname,mag1(1,1).fname);

[~,DWIunwarped] = DTI_unwarp(fm_imgs,{P(1,:)},DWIimgs,pm_def);


% Move all field map files to a field map folder
fmdir=[fm_dir '\fieldmapnii'];

if ~exist(fmdir,'dir')
    mkdir(fmdir)
end

listing = dir([fm_dir '\bmask*']);
movefile([fm_dir '\' listing.name],fmdir)

listing = dir([fm_dir '\fpm*']);
movefile([fm_dir '\' listing.name],fmdir)

listing = dir([fm_dir '\m*.nii']);
movefile([fm_dir '\' listing.name],fmdir)

listing = dir([fm_dir '\sc*']);
movefile([fm_dir '\' listing.name],fmdir)

listing = dir([fm_dir '\vdm5*']);
movefile([fm_dir '\' listing.name],fmdir)

listing = dir([fm_dir '\unwarped*']);
movefile([fm_dir '\' listing(1).name],fmdir)
if size(listing,1)>1
    movefile([fm_dir '\' listing(2).name],fmdir)
end
