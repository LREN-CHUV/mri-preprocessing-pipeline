function [block prefixNII batchNum] = block_realign(Session, prefixNII, RegisterToMean, Reslice, batchNum)
% SPM realign: estimate (realignment of fMRI scans to the mean (two-pass
% procedure (first to the first, then to the mean))
%
%--------------------------------------------------------------------------
% INPUTS:
%--------------------------------------------------------------------------
%
% Session : cell of structure containing filepaths by image types, default
% file for EPI image distortion correction (FieldMap) if B0 maps are present,
% resolution of EPI runs (detected from folder name)
%
% prefixNII : string, prefix of fMRI scan, added job after job in an
% incremental way
%
% RegisterToMean : scalar, 1 if fMRI scans have to be realigned to the mean
% (two-pass procedure) or to the first
%
% batchNum : scalar, index for current SPM batch
%
%--------------------------------------------------------------------------
% OUTPUTS:
%--------------------------------------------------------------------------
%
% block : structure for SPM job (Realign: estimate here)
%
% prefixNII : string, prefix of fMRI scan, added job after job in an
% incremental way, updated
%
% batchNum : index for next SPM batch
%
%--------------------------------------------------------------------------
% 2014-07-07, @LREN, Renaud Marquis & Sandrine Muller, refacto
%--------------------------------------------------------------------------

block.spm.spatial.realign.estwrite.data = Session.EPI;
block.spm.spatial.realign.estwrite.eoptions.quality = 1; % 1 isn't much more computationally intensive as compared to default 0.9
block.spm.spatial.realign.estwrite.eoptions.sep = 4;
block.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
block.spm.spatial.realign.estwrite.eoptions.rtm = RegisterToMean;
block.spm.spatial.realign.estwrite.eoptions.interp = 2;
block.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
block.spm.spatial.realign.estwrite.eoptions.weight = '';
if Reslice == 1
    block.spm.spatial.realign.estwrite.roptions.which = [2 1];
    prefixNII = ['r' prefixNII];
    % in case GLM must be done in native space, then reslicing of images is
    % necessary (so they all have the same orientation matrix)
elseif Reslice == 0
    block.spm.spatial.realign.estwrite.roptions.which = [0 1];
    prefixNII = ['' prefixNII]; % because only the mean will be resliced, and it will just have the "mean" prefix
    % better not reslice images only once (during normalization), but GLM
    % cannot be done with images not normalized then!
else
    error('Don''t know whether to reslice functional scans or not')
end
block.spm.spatial.realign.estwrite.roptions.interp = 4;
block.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
block.spm.spatial.realign.estwrite.roptions.mask = 1;
block.spm.spatial.realign.estwrite.roptions.prefix = 'r';

batchNum = batchNum+1;

end