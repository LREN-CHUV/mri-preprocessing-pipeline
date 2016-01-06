function [outpath] = reslice_image(refimage,sliceimage,outpath)
% [outpath] = reslice_image(refimage,sliceimage,outpath)
% 
% Reslices sliceimage to refimage space
% 
% refimage = the reference image
% sliceimage = the image to reslice into same space as refimage
% outpath = path to save resliced image to
% 

[path, name] = fileparts(sliceimage);

spm_jobman('initcfg');

%-----------------------------------------------------------------------
% Job saved on 24-Jul-2015 13:26:28 by cfg_util (rev $Rev: 5797 $)
% spm SPM - SPM12b (5953)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.spatial.coreg.write.ref = {[refimage ',1']};
matlabbatch{1}.spm.spatial.coreg.write.source = {[sliceimage ',1']};
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 4;
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';

spm_jobman('run',matlabbatch)

movefile([path filesep 'r' name '.nii'],outpath,'f')

nii = niftiRead(outpath);

mask = zeros(size(nii.data));
mask(nii.data>0.1) = 1;

if(numel(nii.pixdim)>3), TR = nii.pixdim(4);
else                       TR = 1;
end

dtiWriteNiftiWrapper(int16(mask), nii.qto_xyz, outpath, 1, '', [],[],[],[], TR);

if exist([outpath '.gz'],'file')>0
    gunzip([outpath '.gz'])
    delete([outpath '.gz'])
end