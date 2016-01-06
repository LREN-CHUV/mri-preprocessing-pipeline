function [block prefixNIIs batchNum] = block_coregister(Session,prefixNIIs,RegisterToMean,prefixNIIf,batchNum)
% SPM coregister estimate : Coregister structural scan to functional scan
% (no reslicing, no interpolation)
%
%--------------------------------------------------------------------------
% INPUTS:
%--------------------------------------------------------------------------
%
% Session : cell of structure containing filepaths by image types, default
% file for EPI image distortion correction (FieldMap) if B0 maps are present,
% resolution of EPI runs (detected from folder name)
%
% RegisterToMean : scalar, 1 if fMRI scans were realigned to the mean
% (two-pass procedure) or to the first
%
% prefixNIIs : string, prefix of structural scan, added job after job in an
% incremental way
%
% prefixNIIf : string, prefix of fMRI scans, added job after job in an
% incremental way
%
% batchNum : scalar, index for current SPM batch
%
%--------------------------------------------------------------------------
% OUTPUTS:
%--------------------------------------------------------------------------
%
% block : structure for SPM job (Coregister: estimate here)
%
% prefixNIIs : string, prefix of structural scans, added job after job in an
% incremental way, updated
%
% batchNum : index for next SPM batch
%
%--------------------------------------------------------------------------
% 2014-07-07, @LREN, Renaud Marquis & Sandrine Muller, refacto
%--------------------------------------------------------------------------

[p n e] = fileparts(Session.EPI{1}{1});
if RegisterToMean == 1
    if ~isempty(Session.Phase)
        % block.spm.spatial.coreg.estwrite.ref = {strcat(p, filesep, 'mean', prefixNIIf, n, e)};
        block.spm.spatial.coreg.estimate.ref = {strcat(p, filesep, 'bmeanu', n, e)};
    else
        block.spm.spatial.coreg.estimate.ref = {strcat(p, filesep, 'bmean', n, e)};
    end
elseif RegisterToMean == 0
    block.spm.spatial.coreg.estimate.ref = {strcat(p, filesep, prefixNIIf, n, e)};
else
    error('Unknown case for RegisterToMean')
end

% if RegisterToMean == 1
%     block.spm.spatial.coreg.estwrite.ref(1) = cfg_dep('Realign & Unwarp: Unwarped Mean Image', substruct('.','val', '{}',{batchNum-1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','meanuwr'));
% elseif RegisterToMean == 0
%     block.spm.spatial.coreg.estwrite.ref(1) = cfg_dep('Realign & Unwarp: Unwarped First Image', substruct('.','val', '{}',{batchNum-1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','uwr'));
% else
%     error('Unknown case for RegisterToMean')
% end
block.spm.spatial.coreg.estimate.source = Session.Struct;
block.spm.spatial.coreg.estimate.other = {''};
block.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
block.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
block.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
block.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
% Change to estimate instead of estimate and write to prevent
% interpolation.
% block.spm.spatial.coreg.estwrite.roptions.interp = 4;
% block.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
% block.spm.spatial.coreg.estwrite.roptions.mask = 0;
% block.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
% prefixNIIs = ['r' prefixNIIs];

prefixNIIs = ['' prefixNIIs]; % because the resampled image suffers from loss of information, whereas changing only the header is better (anyway both files are coregistered)

batchNum = batchNum+1;

end