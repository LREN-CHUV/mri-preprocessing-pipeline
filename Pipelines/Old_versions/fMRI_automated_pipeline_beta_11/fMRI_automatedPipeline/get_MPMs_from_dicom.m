function get_MPMs_from_dicom(varargin)

matlabbatch{1}.spm.util.import.dicom.data = cellstr(spm_select(Inf,'any','Select all DICOM files to convert'));
matlabbatch{1}.spm.util.import.dicom.root = 'patid_date';
matlabbatch{1}.spm.util.import.dicom.outdir = {'C:\DATA\DICOMconvert SPM'};
matlabbatch{1}.spm.util.import.dicom.protfilter = '.*';
matlabbatch{1}.spm.util.import.dicom.convopts.format = 'nii';
matlabbatch{1}.spm.util.import.dicom.convopts.icedims = 0;

% spm_jobman('interactive',matlabbatch);
spm_jobman('run',matlabbatch);

clear matlabbatch

if nargin < 1
    Root = uigetdir('','Select the folder whose name is the date and time of acquisition and that contains all .nii files');
else
    Root = varargin{1};
end
cd(Root)
FieldMapFol = dir('gre_field_mapping_1acq_rl*');
B1mapFol = dir('al_B1mapping_v2d*');
MTfol = dir('mt_al_mtflash3d_v2l*');
PDfol = dir('pd_al_mtflash3d_v2l*');
T1fol = dir('t1_al_mtflash3d_v2l*');

MagnToMask = cellstr(spm_select('ExtFPList',[Root,'\',FieldMapFol(1).name],strcat('^*.nii')));

brain_mask(MagnToMask,1);

matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.b1_type = '3D_EPI_v2b';
matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.subj.output.outdir = {Root};
matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.subj.raw_fld.b0 = cellstr([cellstr(spm_select('ExtFPList',[Root,'\',FieldMapFol(1).name],strcat('^masked_*.*nii')));cellstr(spm_select('ExtFPList',[Root,'\',FieldMapFol(2).name],strcat('^*.nii')))]);
matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.subj.raw_fld.b1 = cellstr(spm_select('ExtFPList',[Root,'\',B1mapFol(1).name],strcat('^*.nii')));
matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.subj.raw_mpm.MT = cellstr(spm_select('ExtFPList',[Root,'\',MTfol(1).name],strcat('^*.nii')));
matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.subj.raw_mpm.PD = cellstr(spm_select('ExtFPList',[Root,'\',PDfol(1).name],strcat('^*.nii')));
matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.subj.raw_mpm.T1 = cellstr(spm_select('ExtFPList',[Root,'\',T1fol(1).name],strcat('^*.nii')));

% spm_jobman('interactive',matlabbatch);
spm_jobman('run',matlabbatch);

end