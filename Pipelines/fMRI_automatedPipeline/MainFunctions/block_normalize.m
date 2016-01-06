function [block, prefixNII] = block_normalize(Session,LBatch,prefixNII)

for i = 1:length(Session.EPI)
    block.spm.spatial.normalise.write.subj(i).def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{LBatch}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
    block.spm.spatial.normalise.write.subj(i).resample(1) = cfg_dep('Bias correction: Bias corrected images', substruct('.','val', '{}',{2+i}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
    block.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70;78 76 85];
    block.spm.spatial.normalise.write.woptions.vox = [2 2 2];
    block.spm.spatial.normalise.write.woptions.interp = 4;
end
prefixNII = ['w' prefixNII];

end