function [block prefixNII batchNum] = block_segment(Session,runDartel,prefixNII,batchNum)
% SPM Segment (SPM12b) (or New Segment in SPM8) : segmentation of
% structural scan coregistered to fMRI scans, using Unified Segmentation
% Approach
%
%--------------------------------------------------------------------------
% INPUTS:
%--------------------------------------------------------------------------
%
% Session : cell of structure containing filepaths by image types, default
% file for EPI image distortion correction (FieldMap) if B0 maps are present,
% resolution of EPI runs (detected from folder name)
%
% runDartel : scalar, if DARTEL create template will be performed next
% (seems to be premature but is already used here to output DARTEL imported
% tissue classes 1 to 3 (GM, WM, CSF) for further use in block_DARTEL)
%
% prefixNII : string, prefix of structural scan, added job after job in an
% incremental way
%
% batchNum : scalar, index for current SPM batch
%
%--------------------------------------------------------------------------
% OUTPUTS:
%--------------------------------------------------------------------------
%
% block : structure for SPM job (Segment (SPM12b) here)
%
% prefixNII : string, prefix of structural scan, added job after job in an
% incremental way
%
% batchNum : index for next SPM batch
%
%--------------------------------------------------------------------------
% 2014-07-07, @LREN, Renaud Marquis & Sandrine Muller, refacto
%--------------------------------------------------------------------------

% block.spm.spatial.preproc.channel.vols(1) = cfg_dep('Coregister: Estimate & Reslice: Coregistered Images', substruct('.','val', '{}',{batchNum-1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));

[p n e] = fileparts(Session.Struct{:});

block.spm.spatial.preproc.channel.vols = {strcat(p, filesep, prefixNII, n, e)};

block.spm.spatial.preproc.channel.biasreg = 0.001;
block.spm.spatial.preproc.channel.biasfwhm = 60;
block.spm.spatial.preproc.channel.write = [0 1];

[p n e] = fileparts(which('spm'));

block.spm.spatial.preproc.tissue(1).tpm = {strcat(p, filesep, 'tpm\TPM.nii,1')};
block.spm.spatial.preproc.tissue(1).ngaus = 1;
block.spm.spatial.preproc.tissue(1).native = [1 runDartel];
block.spm.spatial.preproc.tissue(1).warped = [0 0];
block.spm.spatial.preproc.tissue(2).tpm = {strcat(p, filesep, 'tpm\TPM.nii,2')};
block.spm.spatial.preproc.tissue(2).ngaus = 1;
block.spm.spatial.preproc.tissue(2).native = [1 runDartel];
block.spm.spatial.preproc.tissue(2).warped = [0 0];
block.spm.spatial.preproc.tissue(3).tpm = {strcat(p, filesep, 'tpm\TPM.nii,3')};
block.spm.spatial.preproc.tissue(3).ngaus = 2;
block.spm.spatial.preproc.tissue(3).native = [1 runDartel];
block.spm.spatial.preproc.tissue(3).warped = [0 0];
block.spm.spatial.preproc.tissue(4).tpm = {strcat(p, filesep, 'tpm\TPM.nii,4')};
block.spm.spatial.preproc.tissue(4).ngaus = 3;
block.spm.spatial.preproc.tissue(4).native = [0 0];
block.spm.spatial.preproc.tissue(4).warped = [0 0];
block.spm.spatial.preproc.tissue(5).tpm = {strcat(p, filesep, 'tpm\TPM.nii,5')};
block.spm.spatial.preproc.tissue(5).ngaus = 4;
block.spm.spatial.preproc.tissue(5).native = [0 0];
block.spm.spatial.preproc.tissue(5).warped = [0 0];
block.spm.spatial.preproc.tissue(6).tpm = {strcat(p, filesep, 'tpm\TPM.nii,6')};
block.spm.spatial.preproc.tissue(6).ngaus = 2;
block.spm.spatial.preproc.tissue(6).native = [0 0];
block.spm.spatial.preproc.tissue(6).warped = [0 0];
block.spm.spatial.preproc.warp.mrf = 1;
block.spm.spatial.preproc.warp.cleanup = 1;
block.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
block.spm.spatial.preproc.warp.affreg = 'mni';
block.spm.spatial.preproc.warp.fwhm = 0;
block.spm.spatial.preproc.warp.samp = 3;
block.spm.spatial.preproc.warp.write = [1 1];

batchNum = batchNum+1;

end