function fMRI_pipeline_main(DataFolder,OutputFolder,ProtocolsFile,SubjectID,TPMs,Mode,MinimumVolsNumber,ServerFolder)

%% Lester Melie-Garcia, Sandrine Muller, Renaud Marquis
% LREN, CHUV. 
% Lausanne, October 25th, 2015

if ~strcmp(DataFolder(end),filesep)
    DataFolder = [DataFolder,filesep];
end;
if ~strcmp(OutputFolder(end),filesep)
    OutputFolder = [OutputFolder,filesep];
end;
if ~exist('Mode','var')
    Mode = 'run';
end;
if ~exist('MinimumVolsNumber','var')
    MinimumVolsNumber = 80;
end;    
Subj_OutputFolder = [OutputFolder,SubjectID,filesep];
SubjectFolder = [DataFolder,SubjectID,filesep];
SessionFolders = getListofFolders(SubjectFolder);
Ns = length(SessionFolders);  % Number of sessions ...
itwasprocessed = false; itwasprocessed_here = false;
for i=1:Ns
    Session = SessionFolders{i};
    [valid_protocols_EPI,valid_protocols_fieldmap,valid_protocols_anatomic,valid_pmDefaultFile,NDummyScans] = get_fMRI_sequences([SubjectFolder,SessionFolders{i},filesep],ProtocolsFile); % number of valid protocols ...
    for j=1:length(valid_protocols_EPI)      
        if (~isempty(valid_protocols_EPI))&&(~isempty(valid_protocols_fieldmap))&&(~isempty(valid_protocols_anatomic))            
            if ~exist(Subj_OutputFolder,'dir')
                mkdir(Subj_OutputFolder);
                copyfile(SubjectFolder,Subj_OutputFolder);
                Ini_List_Files = getAllFiles(Subj_OutputFolder);
            end;
            SessionOutputfolder = [Subj_OutputFolder,Session,filesep];
            grefieldSequenceName = valid_protocols_fieldmap{j};
            StructSequenceName = valid_protocols_anatomic{j};
            EPISequenceName = valid_protocols_EPI{j};
            pmDefaultFile = valid_pmDefaultFile{j};
            dummyscans = NDummyScans(j);
            %fMRI_preprocessing(SubjSessionFolder,Mode,volnum,dummyscans,grefieldSequenceName,StructSequenceName,EPISequenceName,pmDefaultFilePath)
            Change_Anatomic_FileName([SessionOutputfolder,StructSequenceName]);
            itwasprocessed_here = fMRI_preprocessing(SessionOutputfolder,Mode,MinimumVolsNumber,dummyscans,grefieldSequenceName, ...
                                                     StructSequenceName,EPISequenceName,pmDefaultFile,TPMs);            
        end;
        itwasprocessed = or(itwasprocessed,itwasprocessed_here);
    end;
end;

if itwasprocessed
    Out_List_Files = getAllFiles(Subj_OutputFolder);
    Reorganize_Files(Subj_OutputFolder,Ini_List_Files,Out_List_Files);
end;

% Copying results from Local Folder to Server ... if ServerFolder is defined.
if exist('ServerFolder','var')&&itwasprocessed
    if ~strcmp(ServerFolder(end),filesep)
        ServerFolder = [ServerFolder,filesep];
    end;
    SujectServerFolder = [ServerFolder,SubjectID];
    if ~exist(SujectServerFolder,'dir')
        mkdir(SujectServerFolder);
    end;
    copyfile(Subj_OutputFolder,SujectServerFolder);
end;

end

%%  ======= Internal  Functions =======  %%
function Reorganize_Files(Subj_OutputFolder,Ini_List_Files,Out_List_Files)

Files2Delete = intersect(Out_List_Files,Ini_List_Files);
for i=1:length(Files2Delete)
    delete(Files2Delete{i});
end;
sizeTree = folderSizeTree(Subj_OutputFolder);
mem = cell2mat(sizeTree.size); % Folders size ..
flevel = cell2mat(sizeTree.level); % Folders level ...
ind = find((flevel==2)&(mem==0));
for i=1:length(ind)
    rmdir(sizeTree.name{ind(i)},'s');  % Removing empty folders ...
end;
sizeTree = folderSizeTree(Subj_OutputFolder);
mem = cell2mat(sizeTree.size); % Folders size ..
flevel = cell2mat(sizeTree.level); % Folders level ...
ind = find((flevel==3)&(mem==0));
for i=1:length(ind)
    rmdir(sizeTree.name{ind(i)},'s');  % Removing de remaining empty folders ...
end;

end

function Change_Anatomic_FileName(InputFolder)

if ~strcmp(InputFolder(end),filesep)
    InputFolder = [InputFolder,filesep];
end;
RepFolder = getListofFolders(InputFolder);
AnatImage = pickfiles([InputFolder,RepFolder{1}],{'.nii'});
AnatImage = AnatImage(1,:);
[FilePath,FileName,FileExt] = fileparts(AnatImage);
AnatOutFileName = [FilePath,filesep,'r',FileName,FileExt];
movefile(AnatImage,AnatOutFileName);

end