function [block batchNum] = block_VDM(Session,batchNum)
% SPM VBQ create multiparameters B0/B1 images
%
%--------------------------------------------------------------------------
% INPUTS:
%--------------------------------------------------------------------------
%
% Session : cell of structure containing filepaths by image types, default
% file for EPI image distortion correction (FieldMap) if B0 maps are present,
% resolution of EPI runs (detected from folder name)
%
% batchNum : scalar, index for current SPM batch
%
%--------------------------------------------------------------------------
% OUTPUTS:
%--------------------------------------------------------------------------
%
% block : structure for SPM job (Voxel Displacement Map here)
%
% batchNum : index for next SPM batch
%
%--------------------------------------------------------------------------
% 2014-07-07, @LREN, Renaud Marquis & Sandrine Muller, refacto
%--------------------------------------------------------------------------

%%% Create voxel displacement maps
block.spm.tools.fieldmap.presubphasemag.subj.phase = Session.Phase;
block.spm.tools.fieldmap.presubphasemag.subj.magnitude = Session.Magnitude;
block.spm.tools.fieldmap.presubphasemag.subj.defaults.defaultsfile = Session.PMdefaultfile;
for i = 1:length(Session.EPI)
    block.spm.tools.fieldmap.presubphasemag.subj.session(i).epi = Session.EPI{1,i}(1,1);
end
block.spm.tools.fieldmap.presubphasemag.subj.matchvdm = 1;
block.spm.tools.fieldmap.presubphasemag.subj.sessname = 'session';
block.spm.tools.fieldmap.presubphasemag.subj.writeunwarped = 0;
block.spm.tools.fieldmap.presubphasemag.subj.anat = '';
block.spm.tools.fieldmap.presubphasemag.subj.matchanat = 0;

batchNum = batchNum+1;

end

