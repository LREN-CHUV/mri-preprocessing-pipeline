function SPM_segmentation_pipeline(ServerFolder,LocalFolder,SubjectID,TemplateImage,WhichImage)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, April 23rd, 2015

s = which('spm.m');
if  ~isempty(s)
    spm_path = fileparts(s);
else
    disp('Please add SPM toolbox in the path .... ');
    return;
end;
if ~strcmp(ServerFolder(end),filesep)
    ServerFolder = [ServerFolder,filesep];
end;
if ~strcmp(LocalFolder(end),filesep)
    LocalFolder = [LocalFolder,filesep];
end;
if ~exist('WhichImage','var')
    WhichImage = '_R1_m.nii';
else
    if isempty(WhichImage)
        WhichImage = '_R1_m.nii';
    end;
end;

SujectServerFolder = [ServerFolder,SubjectID];
if exist(SujectServerFolder,'dir')
    SubjectLocalFolder = [LocalFolder,SubjectID];
    if ~exist(SubjectLocalFolder,'dir')
        mkdir(SubjectLocalFolder);
    end;
    if ~strcmpi(ServerFolder,LocalFolder)
       copyfile(SujectServerFolder,SubjectLocalFolder); 
    end;    
    Image2Segment = pickfiles(SubjectLocalFolder,{WhichImage});
    Ni = size(Image2Segment,1);
    for i=1:Ni
        matlabbatch{1}.spm.spatial.preproc.channel.vols(1) = cellstr(Image2Segment(i,:));
        matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001;
        matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
        matlabbatch{1}.spm.spatial.preproc.channel.write = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[spm_path,filesep,'tpm',filesep,TemplateImage,',1']};
        matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 2;
        matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 1];
        matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[spm_path,filesep,'tpm',filesep,TemplateImage,',2']};
        matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 2;
        matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 1];
        matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0]; %#ok<*AGROW>
        matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {[spm_path,filesep,'tpm',filesep,TemplateImage,',3']};
        matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
        matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {[spm_path,filesep,'tpm',filesep,TemplateImage,',4']};
        matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
        matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {[spm_path,filesep,'tpm',filesep,TemplateImage,',5']};
        matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
        matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
        matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {[spm_path,filesep,'tpm',filesep,TemplateImage,',6']};
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
        %% Sending the segmentation job ...
        spm_jobman('run',matlabbatch); clear matlabbatch;        
    end;
end