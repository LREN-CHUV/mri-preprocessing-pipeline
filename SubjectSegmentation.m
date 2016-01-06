function SubjectSegmentation(InputImage,OutputFolder)

%% Elisabeth Roggenhofer, Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, October 21st, 2014

%%

if ~strcmp(OutputFolder(end),filesep)
    OutputFolder = [OutputFolder,filesep];
end;
if ~exist('OutputFolder','dir')
    mkdir(OutputFolder);
end;
s = which('spm.m');
if  ~isempty(s)
    spm_path = fileparts(s);
else
    disp('Please add SPM toolbox in the path .... ');
    return;
end;

spm_jobman('initcfg');
MPM_Template = 'nwTPM_sl2.nii';

[~,FileName,FileExt] = fileparts(InputImage);
Subj_Image = [OutputFolder,FileName,FileExt];

copyfile(InputImage,OutputFolder);

%%
matlabbatch{1}.spm.spatial.preproc.channel.vols = cellstr(Subj_Image);
matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[spm_path,filesep,'tpm',filesep,MPM_Template,',1']};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[spm_path,filesep,'tpm',filesep,MPM_Template,',2']};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {[spm_path,filesep,'tpm',filesep,MPM_Template,',3']};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [1 1];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {[spm_path,filesep,'tpm',filesep,MPM_Template,',4']};
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {[spm_path,filesep,'tpm',filesep,MPM_Template,',5']};
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {[spm_path,filesep,'tpm',filesep,MPM_Template,',6']};
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write = [1 1];

spm_jobman('run',matlabbatch); clear matlabbatch;

end