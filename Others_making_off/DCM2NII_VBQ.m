function Subj_OutputFolder = DCM2NII_VBQ(SubjectFolder,SubjID,OutputFolder,ProtocolsFile)

% This function convert the dicom files to Nifti format using
% the SPM tools and dcm2nii tool developed by Chris Rorden 
% Webpage: http://www.mccauslandcenter.sc.edu/mricro/mricron/dcm2nii.html
%
%% Input Parameters
%    SubjectFolder : Folder with dicom data.
%    SubjID : Subject identifier.
%    OutputFolder: Folder where the converted data will be saved.
%   ProtocolsFile : File with MRI protocol definitions.
%
%% Anne Ruef, Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, May 21st, 2014

if  ~exist(OutputFolder,'dir')
    mkdir(OutputFolder);
end;
if ~strcmp(OutputFolder(end),filesep)
    OutputFolder = [OutputFolder,filesep];
end;
if ~strcmp(SubjectFolder(end),filesep)
    SubjectFolder = [SubjectFolder,filesep];
end;

SessionFolders = getListofFolders(SubjectFolder);
Ns = length(SessionFolders);  % Number of sessions ...
Subj_OutputFolder = [OutputFolder,SubjID,filesep];
mkdir(Subj_OutputFolder);
matlabbatch{1}.spm.util.import.dicom.root = 'patid';  
matlabbatch{1}.spm.util.import.dicom.protfilter = '.*'; 
matlabbatch{1}.spm.util.import.dicom.convopts.format = 'nii'; 
matlabbatch{1}.spm.util.import.dicom.convopts.icedims = 0; 
matlabbatch{1}.spm.util.import.dicom.outdir = {Subj_OutputFolder};
diffusion_protocol = cellstr(get_protocol_names(ProtocolsFile,'__Dicom2Nifti__','[diffusion]')); % protocol name ..
for j=1:Ns
    Session = SessionFolders{j};
    DataFolder = [SubjectFolder,Session,filesep];
    FolderNames = getListofFolders(DataFolder);
    if ~isempty(FolderNames)
        for i=1:length(FolderNames)
            isdiff = ismember(FolderNames(i),diffusion_protocol);
            InSubDir = [DataFolder,FolderNames{i}];
            if ~isdiff
                matlabbatch{1}.spm.util.import.dicom.data = cellstr(spm_select('FPListRec',InSubDir,'.*'));  % Input Folder to be converted.
                spm_jobman('run',matlabbatch);
                Reorg_Nifti(FolderNames{i},Subj_OutputFolder,SubjID);
            else
                DWI2nii(InSubDir,Subj_OutputFolder,FolderNames{i},SubjID);                
            end;
        end;
        if ~isempty(str2num(Session))  %#ok  % Just fixing the name padding a zero as prefix
            if str2num(Session)<10  %#ok
                Session = ['0',Session]; %#ok
            end;
        end;
        movefile([Subj_OutputFolder,SubjID],[Subj_OutputFolder,Session]); % Renaming Folder with the Session name.
    end;
end;
 
end

%%  =====      Internal Functions =====  %%
%% Reorg_Nifti(FolderName,Subj_OutputFolder,SubjID)
function Reorg_Nifti(FolderName,Subj_OutputFolder,SubjID)

if ~strcmp(Subj_OutputFolder(end),filesep)
    Subj_OutputFolder = [Subj_OutputFolder,filesep];
end;
Session_Folder = [Subj_OutputFolder,SubjID,filesep]; 
Folder_List = getListofFolders(Session_Folder);
mkdir([Session_Folder,FolderName]);

for i=1:length(Folder_List)
    ind = strfind(Folder_List{i},FolderName);
    if ~isempty(ind)
        SubFolderName = Folder_List{i}(length(FolderName)+2:end);
        movefile([Session_Folder,Folder_List{i}],[Session_Folder,FolderName,filesep,SubFolderName]);
    end;
end;

end
%% DWI2nii(InSubDir,Subj_OutputFolder)
function DWI2nii(InSubDir,Subj_OutputFolder,diff_Folder,SubjID)

if ~strcmp(InSubDir(end),filesep)
    InSubDir = [InSubDir,filesep];
end;
if ~strcmp(Subj_OutputFolder(end),filesep)
    Subj_OutputFolder = [Subj_OutputFolder,filesep];
end;
% if ~isempty(str2num(Session))  %#ok  % Just fixing the name padding a zero as prefix
%     if str2num(Session)<10  %#ok
%         Session = ['0',Session];
%     end;
% end;
Rep_Folders = getListofFolders(InSubDir);
for i=1:length(Rep_Folders)
    OutputFolder = [Subj_OutputFolder,SubjID,filesep,diff_Folder,filesep,Rep_Folders{i},filesep];
    if ~exist(OutputFolder,'dir')
        mkdir(OutputFolder);
    end;
    InputFolder = [InSubDir,Rep_Folders{i}];
    job_dcm2nii_LREN(InputFolder,OutputFolder,'DTI');
    bvecsFile = pickfiles(OutputFolder,'.bvec');
    bvalsFile = pickfiles(OutputFolder,'.bval');
    dataFile  = pickfiles(OutputFolder,'.nii');
    if (~isempty(bvecsFile))&&(~isempty(bvalsFile))&&(~isempty(bvecsFile))
        movefile(bvecsFile,[OutputFolder,filesep,SubjID,'.bvecs']);
        movefile(bvalsFile,[OutputFolder,filesep,SubjID,'.bvals']);
        movefile(dataFile,[OutputFolder,filesep,SubjID,'_data.nii']);
    end;
end;

end

