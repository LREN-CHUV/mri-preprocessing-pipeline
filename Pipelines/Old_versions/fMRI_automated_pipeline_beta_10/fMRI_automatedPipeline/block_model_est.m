function [block batchNum] = block_model_est(batchNum)
% SPM Model estimation
%
%--------------------------------------------------------------------------
% INPUTS:
%--------------------------------------------------------------------------
%
% batchNum : scalar, index for current SPM batch
%
% ==> Nota bene: no other inputs needed here, because model estimation
% follows model specification, and uses SPM dependency function
%
%--------------------------------------------------------------------------
% OUTPUTS:
%--------------------------------------------------------------------------
%
% block : structure for SPM job (Model estimation here)
%
% batchNum : index for next SPM batch
%
%--------------------------------------------------------------------------
% 2014-08-19, @LREN, Renaud Marquis, refacto
%--------------------------------------------------------------------------

block.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{batchNum-1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
block.spm.stats.fmri_est.write_residuals = 0;
block.spm.stats.fmri_est.method.Classical = 1;

batchNum = batchNum+1;

end