function [block prefixNII batchNum] = block_realign_unwarp(Session, prefixNII, RegisterToMean, batchNum)
% SPM realign and unwarp (realignment of fMRI scans to the mean (two-pass
% procedure (first to the first, then to the mean)) and correction of EPI
% distortions using VDM
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

for i = 1:length(Session.EPI)
    block.spm.spatial.realignunwarp.data(i).scans = Session.EPI{1,i}(:,1);
    
%     if ~isempty(Session.Phase)
        % block.spm.spatial.realignunwarp.data(i).pmscan(1) = cfg_dep(['Presubtracted Phase and Magnitude Data: Voxel displacement map (Session ' num2str(i) ')'], substruct('.','val', '{}',{batchNum}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','vdmfile', '{}',{i}));
        [p n e] = fileparts(Session.Phase{1});
        block.spm.spatial.realignunwarp.data(i).pmscan = {strcat(p, filesep, 'vdm5_sc', n, e)};
        block.spm.spatial.realignunwarp.uwroptions.prefix = 'u';
%     else
%         block.spm.spatial.realignunwarp.data(i).pmscan = {''};
%         block.spm.spatial.realignunwarp.uwroptions.prefix = 'r';
%     end
end

block.spm.spatial.realignunwarp.eoptions.quality = 1; % 1 isn't much more computationally intensive as compared to default 0.9
block.spm.spatial.realignunwarp.eoptions.sep = 4;
block.spm.spatial.realignunwarp.eoptions.fwhm = 5;
block.spm.spatial.realignunwarp.eoptions.rtm = RegisterToMean;
block.spm.spatial.realignunwarp.eoptions.einterp = 2;
block.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
block.spm.spatial.realignunwarp.eoptions.weight = '';
block.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
block.spm.spatial.realignunwarp.uweoptions.regorder = 1;
block.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
block.spm.spatial.realignunwarp.uweoptions.jm = 0;
block.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
block.spm.spatial.realignunwarp.uweoptions.sot = [];
block.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
block.spm.spatial.realignunwarp.uweoptions.rem = 1;
block.spm.spatial.realignunwarp.uweoptions.noi = 5;
block.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
block.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
block.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
block.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
block.spm.spatial.realignunwarp.uwroptions.mask = 1;

prefixNII = ['u' prefixNII];

batchNum = batchNum+1;

end