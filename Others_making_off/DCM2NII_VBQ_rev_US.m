function Subj_OutputFolder = DCM2NII_VBQ_rev_US(SubjectFolder,SubjID,OutputFolder,ProtocolsFile)

% This function convert the dicom files to Nifti format using
% the SPM tools and dcm2nii tool developed by Chris Rorden 
% Webpage: http://www.mccauslandcenter.sc.edu/mricro/mricron/dcm2nii.html
%
%% Input Parameters
%    SubjectFolder : Folder with dicom data.
%    SubjID : Subject identifier.
%    OutputFolder: Folder where the converted data will be saved.
%    ProtocolsFile : File with MRI protocol definitions.
%
%% Lester Melie-Garcia, Anne Ruef
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
TempCovFolder = 'Nifti_temp';
SessionFolders = getListofFolders(SubjectFolder);
Ns = length(SessionFolders);  % Number of sessions ...
Subj_OutputFolder = [OutputFolder,SubjID,filesep];
mkdir(Subj_OutputFolder);
matlabbatch{1}.spm.util.import.dicom.root = 'flat'; %'series'; %'patid';  
matlabbatch{1}.spm.util.import.dicom.protfilter = '.*'; 
matlabbatch{1}.spm.util.import.dicom.convopts.format = 'nii'; 
matlabbatch{1}.spm.util.import.dicom.convopts.icedims = 0; 
diffusion_protocol = cellstr(get_protocol_names(ProtocolsFile,'__Dicom2Nifti__','[diffusion]')); % protocol name ..
MT_protocol = cellstr(get_protocol_names(ProtocolsFile,'__Dicom2Nifti__','[MT]'));
PD_protocol = cellstr(get_protocol_names(ProtocolsFile,'__Dicom2Nifti__','[PD]'));
T1_protocol = cellstr(get_protocol_names(ProtocolsFile,'__Dicom2Nifti__','[T1]'));
for j=1:Ns
    Session = SessionFolders{j};
    if ~isempty(str2num(Session))  %#ok  % Just fixing the name padding a zero as prefix
        if str2num(Session)<10  %#ok
            Sessionstr = ['0',Session];
        else
            Sessionstr = Session;
        end;
    else
        if j<10
            Sessionstr = ['0',num2str(j)];
        else
            Sessionstr = num2str(j);
        end;
    end;
    OutputSessionFolder = [Subj_OutputFolder,Sessionstr,filesep];
    TempOutput = [Subj_OutputFolder,Sessionstr,filesep,TempCovFolder,filesep];
    if ~exist(TempOutput,'dir')
        mkdir(TempOutput);
    end;
    TempOutputSessionFolder = [TempOutput,TempCovFolder,filesep];
    matlabbatch{1}.spm.util.import.dicom.outdir = {TempOutputSessionFolder}; %#ok
    InitFolder = [SubjectFolder,Session,filesep];
    DummyFolder = getListofFolders(InitFolder);
    DataFolder = [InitFolder,DummyFolder{1},filesep];
    FolderNames = getListofFolders(DataFolder);    
    if ~isempty(FolderNames)
        for i=1:length(FolderNames)
            ind = strfind(FolderNames{i},'-');
            SeqNumber = str2num(FolderNames{i}(1:ind-1));  %#ok<ST2NM>
            SequenceName = FolderNames{i}(ind+1:end);
            which_prot = which_protocol(SequenceName,diffusion_protocol,MT_protocol,PD_protocol,T1_protocol);
            RepetFolders = getListofFolders([DataFolder,FolderNames{i}]);
            if length(RepetFolders)<1
                RepLabel = num2str(SeqNumber);
                if SeqNumber<10
                   RepLabel = ['000',num2str(SeqNumber)];    
                end;
                if (SeqNumber>=10)&&(SeqNumber<100)
                   RepLabel = ['00',num2str(SeqNumber)];    
                end;
                if (SeqNumber>=100)&&(SeqNumber<1000)
                   RepLabel = ['0',num2str(SeqNumber)];    
                end;
                %RepetFolders = {'01'};
                RepetFolders = {RepLabel};
                RepFlag = false;
            else
                RepFlag = true;
            end;
            for k=1:length(RepetFolders)
                if ~exist(TempOutputSessionFolder,'dir')
                    mkdir(TempOutputSessionFolder);
                end;
                if RepFlag
                    InSubDir = [DataFolder,FolderNames{i},filesep,RepetFolders{k},filesep];
                else
                    InSubDir = [DataFolder,FolderNames{i},filesep];
                end;
                switch which_prot
                    case {'MT','PD','T1'}
                        dicom_files = spm_select('FPListRec',InSubDir,'.*');
                        filehdr = spm_dicom_headers(dicom_files(1,:));
                        matlabbatch{1}.spm.util.import.dicom.data = cellstr(dicom_files); %#ok % Input Folder to be converted.
                        spm_jobman('run',matlabbatch);
                        OrgOutputFolder = Reorg_Nifti(FolderNames{i},OutputSessionFolder,TempOutputSessionFolder,RepetFolders{k});
                        if isfield(filehdr{1}, 'CSASeriesHeaderInfo')&&(~strcmpi(which_prot,'other'))
                            VBQ_mosaic2nii_correction(InSubDir,OrgOutputFolder);
                        end;
                    case 'diff'
                        %DWI2nii(InSubDir,Subj_OutputFolder,FolderNames{i},Sessionstr,SubjID,RepetFolders{k});
                        DWI2nii(InSubDir,Subj_OutputFolder,SequenceName,Sessionstr,SubjID,RepetFolders{k});
                    case 'other'
                        dicom_files = spm_select('FPListRec',InSubDir,'.*');
                        matlabbatch{1}.spm.util.import.dicom.data = cellstr(dicom_files); %#ok % Input Folder to be converted.
                        spm_jobman('run',matlabbatch);
                        %Reorg_Nifti(FolderNames{i},OutputSessionFolder,TempOutputSessionFolder,RepetFolders{k});
                        Reorg_Nifti(SequenceName,OutputSessionFolder,TempOutputSessionFolder,RepetFolders{k});
                end;
            end;
        end;
    end;
    rmdir(TempOutput,'s');
end;
 
end

%%  =====      Internal Functions =====  %%
%% Reorg_Nifti(FolderName,Subj_OutputFolder,SubjID)
function OrgOutputFolder = Reorg_Nifti(FolderName,OutputSessionFolder,TempOutputSessionFolder,RepetFolder)

if ~strcmp(OutputSessionFolder(end),filesep)
    OutputSessionFolder = [OutputSessionFolder,filesep];
end;
if ~strcmp(TempOutputSessionFolder(end),filesep)
    TempOutputSessionFolder = [TempOutputSessionFolder,filesep];
end;
OrgOutputFolder = [OutputSessionFolder,FolderName];
if ~exist(OrgOutputFolder,'dir')
    mkdir(OrgOutputFolder);
end;

if ~isempty(str2num(RepetFolder))  %#ok  % Just fixing the name padding a zero as prefix
    if str2num(RepetFolder)<10  %#ok
        RepetFolder = ['0',RepetFolder];
    end;
end;

movefile(TempOutputSessionFolder,[OrgOutputFolder,filesep,RepetFolder]);
OrgOutputFolder = [OrgOutputFolder,filesep,RepetFolder];

end
%% DWI2nii(InSubDir,Subj_OutputFolder)
function DWI2nii(InSubDir,Subj_OutputFolder,diff_Folder,Sessionstr,SubjID,RepetFolder)

if ~strcmp(InSubDir(end),filesep)
    InSubDir = [InSubDir,filesep];
end;
if ~strcmp(Subj_OutputFolder(end),filesep)
    Subj_OutputFolder = [Subj_OutputFolder,filesep];
end;

OutputFolder = [Subj_OutputFolder,Sessionstr,filesep,diff_Folder,filesep,RepetFolder,filesep];
if ~exist(OutputFolder,'dir')
    mkdir(OutputFolder);
end;
job_dcm2nii_LREN(InSubDir,OutputFolder,'DTI');
bvecsFile = pickfiles(OutputFolder,'.bvec');
bvalsFile = pickfiles(OutputFolder,'.bval');
dataFile  = pickfiles(OutputFolder,'.nii');
if (~isempty(bvecsFile))&&(~isempty(bvalsFile))&&(~isempty(bvecsFile))
    if size(bvecsFile,1)>1
        for i=1:size(bvecsFile,1)
            movefile(bvecsFile(i,:),[OutputFolder,filesep,SubjID,'_',num2str(i),'.bvecs']);
        end;
    else
        movefile(bvecsFile,[OutputFolder,filesep,SubjID,'.bvecs']);
    end;
    if size(bvalsFile,1)>1
        for i=1:size(bvalsFile,1)
            movefile(bvalsFile(i,:),[OutputFolder,filesep,SubjID,'_',num2str(i),'.bvals']);
        end;
    else
        movefile(bvalsFile,[OutputFolder,filesep,SubjID,'.bvals']);
    end;
    if size(dataFile,1)>1
        for i=1:size(dataFile,1)
            movefile(dataFile(i,:),[OutputFolder,filesep,SubjID,'_data','_',num2str(i),'.nii']);
        end;
    else
        movefile(dataFile,[OutputFolder,filesep,SubjID,'_data.nii']);
    end;
end;

%Rep_Folders = getListofFolders(InSubDir);
% for i=1:length(Rep_Folders)
%     OutputFolder = [Subj_OutputFolder,Sessionstr,filesep,diff_Folder,filesep,Rep_Folders{i},filesep];
%     if ~exist(OutputFolder,'dir')
%         mkdir(OutputFolder);
%     end;
%     InputFolder = [InSubDir,Rep_Folders{i}];
%     job_dcm2nii_LREN(InputFolder,OutputFolder,'DTI');
%     bvecsFile = pickfiles(OutputFolder,'.bvec');
%     bvalsFile = pickfiles(OutputFolder,'.bval');
%     dataFile  = pickfiles(OutputFolder,'.nii');
%     if (~isempty(bvecsFile))&&(~isempty(bvalsFile))&&(~isempty(bvecsFile))
%         movefile(bvecsFile,[OutputFolder,filesep,SubjID,'.bvecs']);
%         movefile(bvalsFile,[OutputFolder,filesep,SubjID,'.bvals']);
%         movefile(dataFile,[OutputFolder,filesep,SubjID,'_data.nii']);
%     end;
% end;

end

%% function which_prot = which_protocol(FolderName,diffusion_protocol,MT_protocol,PD_protocol,T1_protocol)
function which_prot = which_protocol(FolderName,diffusion_protocol,MT_protocol,PD_protocol,T1_protocol)

if ismember(FolderName,diffusion_protocol)
    which_prot = 'diff';
elseif ismember(FolderName,MT_protocol)
    which_prot = 'MT';
elseif ismember(FolderName,PD_protocol)
    which_prot = 'PD';
elseif ismember(FolderName,T1_protocol)
    which_prot = 'T1';  
else
    which_prot = 'other';
end;

end




