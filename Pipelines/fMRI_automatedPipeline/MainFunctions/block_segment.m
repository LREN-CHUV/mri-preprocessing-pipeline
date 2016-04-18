function block = block_segment(Session,TPMpaths,runDartel)


%%% Segment
block.spm.spatial.preproc.channel.vols(1) = Session.Struct;
block.spm.spatial.preproc.channel.biasreg = 0.001;
block.spm.spatial.preproc.channel.biasfwhm = 60;
block.spm.spatial.preproc.channel.write = [0 1];
% block.spm.spatial.preproc.tissue(1).tpm = {strcat(p, filesep, 'tpm\TPM.nii,1')};
block.spm.spatial.preproc.tissue(1).tpm = cellstr(TPMpaths{1});
block.spm.spatial.preproc.tissue(1).ngaus = 1;
block.spm.spatial.preproc.tissue(1).native = [1 runDartel];
block.spm.spatial.preproc.tissue(1).warped = [0 0];
% block.spm.spatial.preproc.tissue(2).tpm = {strcat(p, filesep, 'tpm\TPM.nii,2')};
block.spm.spatial.preproc.tissue(2).tpm = cellstr(TPMpaths{2});
block.spm.spatial.preproc.tissue(2).ngaus = 1;
block.spm.spatial.preproc.tissue(2).native = [1 runDartel];
block.spm.spatial.preproc.tissue(2).warped = [0 0];
% block.spm.spatial.preproc.tissue(3).tpm = {strcat(p, filesep, 'tpm\TPM.nii,3')};
block.spm.spatial.preproc.tissue(3).tpm = cellstr(TPMpaths{3});
block.spm.spatial.preproc.tissue(3).ngaus = 2;
block.spm.spatial.preproc.tissue(3).native = [1 runDartel];
block.spm.spatial.preproc.tissue(3).warped = [0 0];
% block.spm.spatial.preproc.tissue(4).tpm = {strcat(p, filesep, 'tpm\TPM.nii,4')};
block.spm.spatial.preproc.tissue(4).tpm = cellstr(TPMpaths{4});
block.spm.spatial.preproc.tissue(4).ngaus = 3;
block.spm.spatial.preproc.tissue(4).native = [0 0];
block.spm.spatial.preproc.tissue(4).warped = [0 0];
% block.spm.spatial.preproc.tissue(5).tpm = {strcat(p, filesep, 'tpm\TPM.nii,5')};
block.spm.spatial.preproc.tissue(5).tpm = cellstr(TPMpaths{5});
block.spm.spatial.preproc.tissue(5).ngaus = 4;
block.spm.spatial.preproc.tissue(5).native = [0 0];
block.spm.spatial.preproc.tissue(5).warped = [0 0];
% block.spm.spatial.preproc.tissue(6).tpm = {strcat(p, filesep, 'tpm\TPM.nii,6')};
block.spm.spatial.preproc.tissue(6).tpm = cellstr(TPMpaths{6});
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

end