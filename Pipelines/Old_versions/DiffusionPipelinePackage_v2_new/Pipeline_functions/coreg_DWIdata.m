function coreg_DWIdata(anat_image,mnb0_image,DWIdata,comment)
% 
% Coreg b0 data to structural without resampling. Update header in relevant
% DWIdata
% 


[pathstr, name, ext] = fileparts(mnb0_image);

spm_jobman('initcfg');


%-----------------------------------------------------------------------
% Job saved on 01-May-2015 10:47:55 by cfg_util (rev $Rev: 5703 $)
% spm SPM - SPM12b (5704)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.spatial.coreg.estimate.ref = {[anat_image ',1']};
matlabbatch{1}.spm.spatial.coreg.estimate.source = {[mnb0_image ',1']};
matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];


spm_jobman('run',matlabbatch);

mnb0_nii = niftiRead(mnb0_image);
DWI_nii  = niftiRead(DWIdata);

if(numel(DWI_nii.pixdim)>3), TR = DWI_nii.pixdim(4);
else                       TR = 1;
end

dtiWriteNiftiWrapper(DWI_nii.data, mnb0_nii.qto_xyz, DWIdata, 1, comment, [],[],[],[], TR);
dtiWriteNiftiWrapper(mnb0_nii.data, mnb0_nii.qto_xyz, mnb0_image, 1, comment, [],[],[],[], TR);

gunzip([mnb0_image '*.gz'])
gunzip([DWIdata '*.gz'])


