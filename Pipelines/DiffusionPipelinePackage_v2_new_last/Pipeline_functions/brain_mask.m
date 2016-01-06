function [outputname, biasout] = brain_mask(filename,outputname,TPMfilename,save_bias_field)
% brain_mask(filename,outputname,TPMfilename,save_bias_field)
%
% Creates brain mask for GM, WM and CSF voxels
%
% filename = file path of nifti file to mask
% outputname = path name of output mask
% TPMfilename = location of tissue probability map (TPM) to use
% save_bias_field = if true the estimated bias field will also be saved

if nargin<4 || ~save_bias_field==1
    save_bias_field=0;
end

if ~exist(TPMfilename,'file')
    [FileName,PathName]=uigetfile('.nii','Please select the tissue probability map (TPM)');
    TPMfilename = fullfile(PathName,FileName);
end

[pathstr, name, ext] = fileparts(filename);

[pathname, ~] = fileparts(TPMfilename);

MNIsubcorticalmask=pickfiles(pathname,{'MNIsubcortical_mask'});

spm_jobman('initcfg');

%-----------------------------------------------------------------------
% Job saved on 09-Jan-2014 18:00:34 by cfg_util (rev $Rev: 5703 $)
% spm SPM - SPM12b (5704)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.spatial.preproc.channel.vols = {[filename ',1']};
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write = [save_bias_field 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[TPMfilename ',1']};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[TPMfilename ',2']};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {[TPMfilename ',3']};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {[TPMfilename ',4']};
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {[TPMfilename ',5']};
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {[TPMfilename ',6']};
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write = [0 0];
matlabbatch{2}.spm.util.imcalc.input(1) = cfg_dep('Segment: c1 Images', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{1}, '.','c', '()',{':'}));
matlabbatch{2}.spm.util.imcalc.input(2) = cfg_dep('Segment: c2 Images', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{2}, '.','c', '()',{':'}));
matlabbatch{2}.spm.util.imcalc.input(3) = cfg_dep('Segment: c3 Images', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{3}, '.','c', '()',{':'}));
matlabbatch{2}.spm.util.imcalc.output = outputname;
matlabbatch{2}.spm.util.imcalc.outdir = {''};
matlabbatch{2}.spm.util.imcalc.expression = '(i1+i2+i3)>0';
matlabbatch{2}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{2}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{2}.spm.util.imcalc.options.mask = 0;
matlabbatch{2}.spm.util.imcalc.options.interp = 1;
matlabbatch{2}.spm.util.imcalc.options.dtype = 4;

spm_jobman('run',matlabbatch)

clear matlabbatch

spm_jobman('initcfg');

matlabbatch{1}.spm.spatial.preproc.channel.vols = {filename ',1'};
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[TPMfilename ',1']};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[TPMfilename ',2']};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {[TPMfilename ',3']};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {[TPMfilename ',4']};
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {[TPMfilename ',5']};
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {[TPMfilename ',6']};
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write = [1 1];
matlabbatch{2}.spm.util.defs.comp{1}.def(1) = cfg_dep('Segment: Inverse Deformations', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','invdef', '()',{':'}));
matlabbatch{2}.spm.util.defs.out{1}.pull.fnames = {MNIsubcorticalmask};
matlabbatch{2}.spm.util.defs.out{1}.pull.savedir.saveusr = {pathstr};
matlabbatch{2}.spm.util.defs.out{1}.pull.interp = 4;
matlabbatch{2}.spm.util.defs.out{1}.pull.mask = 0;
matlabbatch{2}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];

spm_jobman('run',matlabbatch);

if ~exist(pathstr,'dir')
    pathstr = 'pwd';
end

subcort_nii=niftiRead([pathstr '\' 'wMNIsubcortical_mask.nii']);

brainmask_nii=niftiRead(outputname);

% Dilate mask to ensure full brain inclusion
dilatepath = which('imdilate');
if ispc && ~isempty(dilatepath)
    brainmask_nii.data = imdilate(brainmask_nii.data,ones(5, 5, 5));
    brainmask_nii.data = imerode(brainmask_nii.data,ones(4, 4, 4));
elseif isunix
    [status, cmdout] = unix(['maskfilter ' outputname ' dilate ' outputname ' -npass 5']);
    [status, cmdout] = unix(['maskfilter ' outputname ' erode ' outputname ' -npass 4']);
    brainmask_nii=niftiRead(outputname);
end

newmask=zeros(size(brainmask_nii.data));

newmask(subcort_nii.data>0 | brainmask_nii.data>0)=1;

if(numel(brainmask_nii.pixdim)>3), TR = brainmask_nii.pixdim(4);
else                       TR = 1;
end

dtiWriteNiftiWrapper(int16(newmask), brainmask_nii.qto_xyz, outputname, 1, '', [],[],[],[], TR);

pause(2)

if exist([outputname '.gz'],'file')>0
    gunzip([outputname '.gz'])
    delete([outputname '.gz'])
end

% Delete c1 to c5 segmentations
deletepath = [pathstr filesep 'c1' name ext];
if exist(deletepath,'file')>0
    delete(deletepath);
end
deletepath = [pathstr filesep 'c2' name ext];
if exist(deletepath,'file')>0
    delete(deletepath);
end
deletepath = [pathstr filesep 'c3' name ext];
if exist(deletepath,'file')>0
    delete(deletepath);
end
deletepath = [pathstr filesep 'c4' name ext];
if exist(deletepath,'file')>0
    delete(deletepath);
end
deletepath = [pathstr filesep 'c5' name ext];
if exist(deletepath,'file')>0
    delete(deletepath);
end

% Delete iy_ and y_ files
deletepath = [pathstr filesep 'y_' name ext];
if exist(deletepath,'file')>0
    delete(deletepath);
end
deletepath = [pathstr filesep 'iy_' name ext];
if exist(deletepath,'file')>0
    delete(deletepath);
end

% Delete seg8.mat
deletepath = [pathstr filesep name '_seg8.mat'];
if exist(deletepath,'file')>0
    delete(deletepath);
end

delete([pathstr '\' 'wMNIsubcortical_mask.nii']);

% if exist([outputname '.gz'],'file')>0
%     maskout = [outputname '.gz'];
% else
%     maskout = outputname;
% end

if exist([pathstr filesep 'BiasField_' name ext],'file')>0
    biasout = [pathstr filesep 'BiasField_' name ext];
else biasout = '';
end
