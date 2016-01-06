function preproc_dartel_norm_job_all(InputFolder)

%% Elisabeth Roggenhofer, Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, October 21st, 2014

if strcmp(InputFolder(end),filesep)
    InputFolder = InputFolder(1:end-1);
end;
s = which('spm.m');
if  isempty(s)
    disp('Please add SPM toolbox in the path .... ');
    return;
end;

spm_jobman('initcfg');

rc1_Images = pickfiles(InputFolder,{[filesep,'rc1'],'.nii'});
rc2_Images = pickfiles(InputFolder,{[filesep,'rc2'],'.nii'});

c1_Images = pickfiles(InputFolder,{[filesep,'c1'],'.nii'});
c2_Images = pickfiles(InputFolder,{[filesep,'c2'],'.nii'});

matlabbatch{1}.spm.tools.dartel.warp.images = {cellstr(rc1_Images),cellstr(rc2_Images)};
matlabbatch{1}.spm.tools.dartel.warp.settings.template = 'Template';
matlabbatch{1}.spm.tools.dartel.warp.settings.rform = 0;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).rparam = [4 2 1e-006];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).K = 0;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).slam = 16;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).rparam = [2 1 1e-006];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).K = 0;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).slam = 8;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).rparam = [1 0.5 1e-006];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).K = 1;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).slam = 4;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).rparam = [0.5 0.25 1e-006];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).K = 2;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).slam = 2;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).rparam = [0.25 0.125 1e-006];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).K = 4;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).slam = 1;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).its = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).rparam = [0.25 0.125 1e-006];
matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).K = 6;
matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).slam = 0.5;
matlabbatch{1}.spm.tools.dartel.warp.settings.optim.lmreg = 0.01;
matlabbatch{1}.spm.tools.dartel.warp.settings.optim.cyc = 3;
matlabbatch{1}.spm.tools.dartel.warp.settings.optim.its = 3;
matlabbatch{2}.spm.tools.dartel.mni_norm.template(1) = cfg_dep('Run Dartel (create Templates): Template (Iteration 6)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','template', '()',{7}));
matlabbatch{2}.spm.tools.dartel.mni_norm.data.subjs.flowfields(1) = cfg_dep('Run Dartel (create Templates): Flow Fields', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '()',{':'}));
matlabbatch{2}.spm.tools.dartel.mni_norm.data.subjs.images = {cellstr(c1_Images),cellstr(c2_Images)};
matlabbatch{2}.spm.tools.dartel.mni_norm.vox = [NaN NaN NaN];
matlabbatch{2}.spm.tools.dartel.mni_norm.bb = [NaN NaN NaN
                                               NaN NaN NaN];
matlabbatch{2}.spm.tools.dartel.mni_norm.preserve = 1;
matlabbatch{2}.spm.tools.dartel.mni_norm.fwhm = [4 4 4];

spm_jobman('run',matlabbatch); clear matlabbatch;

end
