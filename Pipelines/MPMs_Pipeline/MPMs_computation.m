function MPMs_computation(MT_Images,PD_Images,T1_Images,doUNICORT,b0_Images,b1_Images)

% This function computes the Multiparametric Maps (MPMs)(R2*, R1, MT, PD).
%% Input Parameters:
%   MT_Images : MT image. 
%   PD_Images : Proton density image.
%   T1_Images : T1 image
%   doUNICORT : Flag variable to indicate if UNICORT approach is used to compute the MPMs.
%   b0_Images : Field map b0 image.
%   b1_Images : Field map b1 image.
%
%% Output Parameters:
%  Multiparametric Maps (MPMs)(R2*, R1, MT, PD)
%    *_R2s.nii : Transverse relaxation rate - R2* [1/ms]	
%    *_MT.nii  : Magnetization Transfer (MT)
%    *_A.nii   : Proton Density (%), maximum value 100%
%    *_R1.nii  : Longitudinal Relaxation Rate - R1 [1000/s]
%
%% Anne Ruef, Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, October 21st, 2014

%%

spm_jobman('initcfg');

if ~doUNICORT
    % MPMs computation using the standard way, B0 and B1 images are used this case
    matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.b1_type = '3D_EPI_v2b';
    matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.sdata_multi.output.indir = 1;
    %matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.sdata_multi.output.outdir = cellstr(Subj_OutputFolder);
    matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.sdata_multi.raw_fld.b0 = cellstr(b0_Images);
    matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.sdata_multi.raw_fld.b1 = cellstr(b1_Images);
    matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.sdata_multi.raw_mpm.MT = cellstr(MT_Images);
    matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.sdata_multi.raw_mpm.PD = cellstr(PD_Images);
    matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.sdata_multi.raw_mpm.T1 = cellstr(T1_Images);
    matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.sdata_multi.raw_mpm.pdmask_choice.no_pdmask = 0;
else
    % MPMs computation using UNICORT, B0 and B1 images are not necessary in this case
    matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_unicort.data_spec.subj.output.indir = 1;
    matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_unicort.data_spec.subj.raw_mpm.MT = cellstr(MT_Images);
    matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_unicort.data_spec.subj.raw_mpm.PD = cellstr(PD_Images);
    matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_unicort.data_spec.subj.raw_mpm.T1 = cellstr(T1_Images);
end;
%% Sending the MPM job ...
spm_jobman('run',matlabbatch); 

end