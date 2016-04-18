function preproc_dartel_norm_job_all(InputFolder,OutputFolder,SubjectList,FWHMsmooth)

%% Input Parameters:
%   InputFolder : Folder with subfolders belonging to each subject data to  be used in Dartel.
%   OutputFolder : Folder where the data from 'InputFolder' will be copied to be used in DARTEL, in this way the original data is preserved. 
%                  If it is not defined the data woont be copied therefore DARTEL process will be done in the 'InputFolder'
%   
%   SubjectList : List of subjects. This could be either a string with the full path of the Subject list file or a column cell array with the subject's ID.
%                 If SubjectList is not defined or defined as empty SubjectList = '' , then all subjects in InputFolder will be used for DARTEL.
%   FWHMsmooth : Smooth Kernel. If it is not defined a FWHMsmooth= 6 (mm) will be used.
%
%% Elisabeth Roggenhofer, Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, October 21st, 2014

if ~strcmp(InputFolder(end),filesep)
    InputFolder = [InputFolder,filesep];
end;
if exist('OutputFolder','var')
    if ~strcmp(OutputFolder(end),filesep)
        OutputFolder = [OutputFolder,filesep];
    end;    
end;
if exist('SubjectList','var')
    if isempty(SubjectList)
        SubjectList = getListofFolders(InputFolder);
    else
        if ischar(SubjectList)
           fid = fopen(SubjectList);
           SubjectList = textscan(fid,'%s');
           SubjectList = SubjectList{1};
           fclose(fid);
           %SubjectList = textread(SubjectList,'%s');
        end;            
    end;
else
    SubjectList = getListofFolders(InputFolder);
end;
Ns = length(SubjectList);
if exist('OutputFolder','var')
    if ~strcmpi(OutputFolder,InputFolder)
        if ~exist(OutputFolder,'dir')
            mkdir(OutputFolder);
        end;
        for i=1:Ns
            disp(['Copying data subject: ',num2str(i),' of ',num2str(Ns),' ---> ',SubjectList{i},'  ...']);
            SubjInFolder  = [InputFolder,SubjectList{i},filesep];
            SubjOutFolder = [OutputFolder,SubjectList{i},filesep];
            if ~exist(SubjOutFolder,'dir')
                mkdir(SubjOutFolder);
            end;
            copyfile(SubjInFolder,SubjOutFolder);
        end;
    end;
else
    OutputFolder=InputFolder; % If OutputFolder is not defined then OutputFolder=InputFolder.
end;
if ~exist('FWHMsmooth','var')
    FWHMsmooth = 6;
end;
s = which('spm.m');
if  isempty(s)
    disp('Please add SPM toolbox in the path .... ');
    return;
end;

spm_jobman('initcfg');

rc1_Images = pickfiles(OutputFolder(1:end-1),{[filesep,'rc1'],'.nii'});
rc2_Images = pickfiles(OutputFolder(1:end-1),{[filesep,'rc2'],'.nii'});

c1_Images = pickfiles(OutputFolder(1:end-1),{[filesep,'c1'],'.nii'});
c2_Images = pickfiles(OutputFolder(1:end-1),{[filesep,'c2'],'.nii'});

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
matlabbatch{2}.spm.tools.dartel.mni_norm.fwhm = [FWHMsmooth,FWHMsmooth,FWHMsmooth];

spm_jobman('run',matlabbatch); clear matlabbatch;

end
