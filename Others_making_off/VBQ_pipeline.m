function VBQ_pipeline(ConvOutputFolder,ServerFolder,MPM_OutputFolder,GlobalMPMFolder,MPM_Template,ProtocolsFile,SubjectFolder,SubjID)

%% Input Parameters
%     SubjectFolder: Folder with dicom data.
%     SubjID : ID of the subject.
%  ConvOutputFolder : Folder where the converted data (*.nii) will be saved. The subject will have a subfolder in this folder named as SubjID value.
%  ServerFolder : Folder where the data will be copied as well.
%  ProtocolsFile : Full path of the file where the protocols for each MRI image modality is defined for each step of the processing pipeline.
%   MPM_OutputFolder : Folder where the MPMs will be saved.
%   GlobalMPMFolder : Folder where the selected files from MPMs will be saved for each subject (i.e  *_R2s.nii ;  *_R1.nii; *_A.nii).
%   MPM_Template : Name of the Template will be used at the MPMs computation step for segmenting MT image.
%
%% Anne Ruef, Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, May 21st, 2014

%% 1. Coverting dicom data to Nifti format 
if ~strcmpi(ConvOutputFolder(end),filesep)
    ConvOutputFolder = [ConvOutputFolder,filesep];    
end;
spm_jobman('initcfg');
Conv_SubjOutputFolder = DCM2NII_VBQ_rev(SubjectFolder,SubjID,ConvOutputFolder,ProtocolsFile);
disp(['Data conversion for subject :  ',SubjID,'    ...... Done!']);
copy_data2Server(Conv_SubjOutputFolder,ConvOutputFolder,ServerFolder,SubjID);  % if ServerFolder is empty, the Nifti data wont be copy to the server 
    
%% 2. Computing MPM maps
%Conv_SubjOutputFolder = ['D:\WORK\LREN\test_folder\DataNifti\',SubjID];
[Subj_OutputFolder,SubjOutMPMFolder] = Preproc_mpm_maps_rev(Conv_SubjOutputFolder,SubjID,MPM_OutputFolder,GlobalMPMFolder,ProtocolsFile,MPM_Template);
copy_data2Server(Subj_OutputFolder,MPM_OutputFolder,ServerFolder,SubjID);  % if ServerFolder variable is empty,  Nifti data wont be copy to the server
copy_data2Server(SubjOutMPMFolder,GlobalMPMFolder,ServerFolder,SubjID);    % if ServerFolder variable is empty,  Nifti data wont be copy to the server

end

%%  =====      Internal Functions    =====  %%

%% function copy_data2Server(InputFolder)
function copy_data2Server(SubjInputFolder,InputFolder,ServerFolder,SubjID)

if ~isempty(ServerFolder)
    if ~exist(ServerFolder,'dir')
        mkdir(ServerFolder);
    end;
    if ~strcmpi(ServerFolder(end),filesep)
        ServerFolder = [ServerFolder,filesep];
    end;
    if ~strcmpi(InputFolder(end),filesep)
        InputFolder = [InputFolder,filesep];
    end;
    ind = strfind(InputFolder,filesep);
    ServerFolderName = InputFolder(ind(end-1)+1:ind(end)-1);
    SubjOutputServerFolder = [ServerFolder,ServerFolderName,filesep,SubjID];
    if ~exist(SubjOutputServerFolder ,'dir')
        mkdir(SubjOutputServerFolder);
    end;
    copyfile(SubjInputFolder,SubjOutputServerFolder);
end;

end





