function DWI_pipeline(DataFolder,MPMDataFolder,MPRAGEFolder,OutputFolder,ProtocolsFile,SubjectID)

%% David Slater, Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, June 25th, 2014

if ~strcmp(DataFolder(end),filesep)
    DataFolder = [DataFolder,filesep];
end;
if ~strcmp(OutputFolder(end),filesep)
    OutputFolder = [OutputFolder,filesep];
end;
if ~strcmp(MPMDataFolder(end),filesep)
    MPMDataFolder = [MPMDataFolder,filesep];
end;
if ~strcmp(MPRAGEFolder(end),filesep)
    MPRAGEFolder = [MPRAGEFolder,filesep];
end;

SubjectFolder = [DataFolder,SubjectID,filesep];
SessionFolders = getListofFolders(SubjectFolder);
Ns = length(SessionFolders);  % Number of sessions ...
%% Detecting MT or other anatomical image in AnatomicDataFolder ...

Anatomical_Image = getValid_Anatomic_Image(MPMDataFolder,MPRAGEFolder,ProtocolsFile,SubjectID);

if ~isempty(Anatomical_Image)
    Subj_OutputFolder = [OutputFolder,SubjectID,filesep];
    if ~exist(Subj_OutputFolder,'dir')
        mkdir(Subj_OutputFolder);
    end;    
    for i=1:Ns
        Session = SessionFolders{i};
        [valid_protocols_diff,valid_protocols_fieldmap,valid_ReadoutTimes]  = get_DWI_sequences([SubjectFolder,SessionFolders{i},filesep],ProtocolsFile); % number of valid protocols ...
        for j=1:length(valid_protocols_diff)
            RepetFolders = getListofFolders([SubjectFolder,Session,filesep,valid_protocols_diff{j},filesep]); % number of repetitions ...
            FieldmapNiiFiles = cellstr(pickfiles([SubjectFolder,Session,filesep,valid_protocols_fieldmap{j}],'.nii'));
            ReadoutTime = str2double(valid_ReadoutTimes{j});
            for k=1:length(RepetFolders)
                NiiFile = pickfiles([SubjectFolder,Session,filesep,valid_protocols_diff{j},filesep,RepetFolders{k}],'.nii');
                bvalsFile = pickfiles([SubjectFolder,Session,filesep,valid_protocols_diff{j},filesep,RepetFolders{k}],'.bvals');
                bvecsFile = pickfiles([SubjectFolder,Session,filesep,valid_protocols_diff{j},filesep,RepetFolders{k}],'.bvecs');
                if (~isempty(NiiFile))&&(~isempty(bvalsFile))&&(~isempty(bvecsFile))
                    DWIpath  = deblank(NiiFile(1,:));
                    DWIoutputfolder=[Subj_OutputFolder Session filesep RepetFolders{k} filesep];
                    if ~exist(DWIoutputfolder,'dir')
                        mkdir(DWIoutputfolder);
                    end;
                    %             NEED TO ADD PATH TO PROCESSED MT ANATOMICAL IMAGE
                    DW_PipelineWrapper(DWIpath,FieldmapNiiFiles,Anatomical_Image,DWIoutputfolder,SubjectID,Session,RepetFolders{k},valid_protocols_diff{j},ReadoutTime);
                end;
            end;
        end;
    end;
end;
end
