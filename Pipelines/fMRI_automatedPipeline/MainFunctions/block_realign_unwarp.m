function [block prefixNII] = block_realign_unwarp(Session, prefixNII)

%%% 2. Realign and unwrap

for i = 1:length(Session.EPI)
    block.spm.spatial.realignunwarp.data(i).scans = Session.EPI{1,i}(:,1);
    
    if ~isempty(Session.Phase)
        block.spm.spatial.realignunwarp.data(i).pmscan(1) = cfg_dep(['Presubtracted Phase and Magnitude Data: Voxel displacement map (Subj 1, Session ' num2str(i) ')'], substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','vdmfile', '{}',{i}));
        block.spm.spatial.realignunwarp.uwroptions.prefix = 'u';
        prefixNII = ['u' prefixNII];
    else
        block.spm.spatial.realignunwarp.uwroptions.prefix = 'r';
        prefixNII = ['r' prefixNII];
    end
end
block.spm.spatial.realignunwarp.eoptions.quality = 0.9;
block.spm.spatial.realignunwarp.eoptions.sep = 4;
block.spm.spatial.realignunwarp.eoptions.fwhm = 5;
block.spm.spatial.realignunwarp.eoptions.rtm = 0;% 1 : to the mean
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

end