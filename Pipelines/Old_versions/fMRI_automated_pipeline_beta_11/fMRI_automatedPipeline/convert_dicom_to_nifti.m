function convert_dicom_to_nifti(varargin)

matlabbatch{1}.spm.util.import.dicom.data = cellstr(spm_select(Inf,'any','Select all DICOM files to convert'));
matlabbatch{1}.spm.util.import.dicom.root = 'patid_date';
if nargin < 1
    output_folder = uigetdir('','Select output folder for converted files');
else
    output_folder = varargin{1};
end
matlabbatch{1}.spm.util.import.dicom.outdir = {output_folder};
matlabbatch{1}.spm.util.import.dicom.protfilter = '.*';
matlabbatch{1}.spm.util.import.dicom.convopts.format = 'nii';
matlabbatch{1}.spm.util.import.dicom.convopts.icedims = 0;

% spm_jobman('interactive',matlabbatch);
spm_jobman('run',matlabbatch);

end