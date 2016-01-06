
%addpath C:\DATA\label
%training_dir = 'C:\DATA\label\training_data';

addpath D:\WORK\LREN\NeuroMorphometric_tbx\label
training_dir = 'D:\WORK\LREN\NeuroMorphometric_tbx\label\training_data';

spm_dir  = spm('dir');

path(spm_dir,path);

PP = spm_select(Inf,'nifti','Select images');

tic;
for i=1:size(PP,1),
    P=PP(i,:);
    
    clear preproc warp1
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Run Segmentation to obtain tissue probability maps and
    % Inverse deformation fields.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tpm   = fullfile(spm('dir'),'tpm','TPM.nii');
    for k=1:size(P,1),
        preproc.channel(k).vols = {deblank(P(k,:))};
        preproc.channel(k).biasreg = 0.001;
        preproc.channel(k).biasfwhm = 60;
        preproc.channel(k).write = [0 0];
    end
    preproc.tissue(1).tpm = {[tpm ',1']};
    preproc.tissue(1).ngaus = 1;
    preproc.tissue(1).native = [1 1];
    preproc.tissue(1).warped = [0 0];
    preproc.tissue(2).tpm = {[tpm ',2']};
    preproc.tissue(2).ngaus = 1;
    preproc.tissue(2).native = [1 1];
    preproc.tissue(2).warped = [0 0];
    preproc.tissue(3).tpm = {[tpm ',3']};
    preproc.tissue(3).ngaus = 2;
    preproc.tissue(3).native = [0 0];
    preproc.tissue(3).warped = [0 0];
    preproc.tissue(4).tpm = {[tpm ',4']};
    preproc.tissue(4).ngaus = 3;
    preproc.tissue(4).native = [0 0];
    preproc.tissue(4).warped = [0 0];
    preproc.tissue(5).tpm = {[tpm ',5']};
    preproc.tissue(5).ngaus = 4;
    preproc.tissue(5).native = [0 0];
    preproc.tissue(5).warped = [0 0];
    preproc.tissue(6).tpm = {[tpm ',6']};
    preproc.tissue(6).ngaus = 2;
    preproc.tissue(6).native = [0 0];
    preproc.tissue(6).warped = [0 0];
    preproc.warp.mrf = 1;
    preproc.warp.cleanup = 1;
    preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    preproc.warp.affreg = 'mni';
    preproc.warp.fwhm = 0;
    preproc.warp.samp = 3;
    preproc.warp.write = [0 0];
    out1 = spm_preproc_run(preproc);
    
    % Cleanup
    delete(out1.param{1});
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Refine the registration with the templates in the
    % training directory
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    warp1.images{1}(1) = out1.tiss(1).rc;
    warp1.images{2}(1) = out1.tiss(2).rc;
    warp1.templates = cellstr(spm_select('FPList',training_dir,'^Template_.*\.nii'));
    out2 = spm_shoot_warp(warp1);
    
    % Cleanup
    delete(out1.tiss(1).rc{1});
    delete(out1.tiss(2).rc{1});
    delete(out2.vel{1});
    delete(out2.jac{1});
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Perform the label fusion
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    PT     = strvcat(out1.tiss(1).c{1}, out1.tiss(2).c{1});
    labels = do_prop(PT,out2.def{1}, training_dir);
    
    % Cleanup
    delete(out1.tiss(1).c{1});
    delete(out1.tiss(2).c{1});
    delete(out2.def{1});
end

toc;

