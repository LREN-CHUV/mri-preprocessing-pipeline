function block = block_VDM(Session)
        %%% 1. Create voxel displacement maps
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
end

