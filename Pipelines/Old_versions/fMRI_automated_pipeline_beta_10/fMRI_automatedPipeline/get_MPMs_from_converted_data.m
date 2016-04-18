function [block MT1st] = get_MPMs_from_converted_data(NIIs_folder,FolderNames,Opts)

FieldMapFol = FilterFolders(FolderNames,'gre_field_mapping_1acq_rl.*','gre_field_mapping_1acq_rl_64ch.*'); % only this one is valid for MPMs (the one ending with "64ch" is for EPI image distortion correction)
B1mapFol = FilterFolders(FolderNames,'al_B1mapping.*','');
MTfol = FilterFolders(FolderNames,'mt_al_mtflash.*','');
PDfol = FilterFolders(FolderNames,'pd_al_mtflash.*','');
T1fol = FilterFolders(FolderNames,'t1_al_mtflash.*','');

if strcmpi(Opts.DirStructure,'DICOMimport')
    Mag = detect_nii_img_files(NIIs_folder,FieldMapFol{1});
    Phase = detect_nii_img_files(NIIs_folder,FieldMapFol{2});
    B1 = detect_nii_img_files(NIIs_folder,B1mapFol);
    MT = detect_nii_img_files(NIIs_folder,MTfol{1});
    PD = detect_nii_img_files(NIIs_folder,PDfol{1});
    T1 = detect_nii_img_files(NIIs_folder,T1fol{1});
else % LRENpipeline case (even if usually it should never be the case)
    FieldMapFols = detectFolders(strcat(NIIs_folder,filesep,FieldMapFol{1}));
    Mag = detect_nii_img_files(NIIs_folder,strcat(FieldMapFol,filesep,FieldMapFols{1}));
    Phase = detect_nii_img_files(NIIs_folder,strcat(FieldMapFol,filesep,FieldMapFols{2}));
    B1fol = detectFolders(strcat(NIIs_folder,filesep,B1mapFol{1}));
    B1 = detect_nii_img_files(NIIs_folder,strcat(B1mapFol,filesep,B1fol{1}));
    MTf = detectFolders(strcat(NIIs_folder,filesep,MTfol{1}));
    MT = detect_nii_img_files(NIIs_folder,strcat(MTfol,filesep,MTf{1}));
    PDf = detectFolders(strcat(NIIs_folder,filesep,PDfol{1}));
    PD = detect_nii_img_files(NIIs_folder,strcat(PDfol,filesep,PDf{1}));
    T1f = detectFolders(strcat(NIIs_folder,filesep,T1fol{1}));
    T1 = detect_nii_img_files(NIIs_folder,strcat(T1fol,filesep,T1f{1}));
end

if any(cellfun(@isempty,Mag)) || any(cellfun(@isempty,Phase))  || any(cellfun(@isempty,B1)) || any(cellfun(@isempty,MT)) || any(cellfun(@isempty,PD)) || any(cellfun(@isempty,T1))
    MPMdataOK = 'MPM data incomplete for VBQ create multiparameter maps';
end

% Mask magnitude images:
if Opts.MaskMag == 1
    block = brain_mask(Mag,1);
end
if exist('block','var')
    Njob = size(block,2);
else
    Njob = 0;
end
Mag = spm_file(Mag,'prefix','masked_');

block{Njob+1}.spm.tools.VBQ.crt_maps.mp_img_b_img.b1_type = '3D_EPI_v2b';
block{Njob+1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.subj.output.indir = 1;
block{Njob+1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.subj.raw_fld.b0 = cellstr([Mag;Phase]);
block{Njob+1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.subj.raw_fld.b1 = B1;
block{Njob+1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.subj.raw_mpm.MT = MT;
block{Njob+1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.subj.raw_mpm.PD = PD;
block{Njob+1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.subj.raw_mpm.T1 = T1;

MT1st = MT{1};

if exist('MPMdataOK','var')
    block = MPMdataOK;
end

end