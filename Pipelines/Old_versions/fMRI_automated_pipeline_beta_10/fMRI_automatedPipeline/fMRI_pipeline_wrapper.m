function fMRI_pipeline_wrapper(DataFolder,MPMDataFolder,MPRAGEFolder,OutputFolder,ProtocolsFile,SubjectID)

%% Renauld Marquis, Sandrine Muller, Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, May 5th, 2015

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
    % Copy here the fMRI and Anatomic data. 
    for i=1:Ns
        Session = SessionFolders{i};
        [valid_protocols_fMRI,valid_protocols_fieldmap]  = get_fMRI_sequences([SubjectFolder,SessionFolders{i},filesep],ProtocolsFile); % number of valid protocols ...
        for j=1:length(valid_protocols_fMRI)
            RepetFolders = getListofFolders([SubjectFolder,Session,filesep,valid_protocols_fMRI{j},filesep]); % number of repetitions ...
            FieldmapNiiFiles = cellstr(pickfiles([SubjectFolder,Session,filesep,valid_protocols_fieldmap{j}],'.nii'));
            for k=1:length(RepetFolders)
                NiiFile = pickfiles([SubjectFolder,Session,filesep,valid_protocols_fMRI{j},filesep,RepetFolders{k}],'.nii');
                fMRIpath  = deblank(NiiFile(1,:));
                fMRIoutputfolder=[Subj_OutputFolder Session filesep RepetFolders{k} filesep];
                if ~exist(fMRIoutputfolder,'dir')
                    mkdir(fMRIoutputfolder);
                end;
                %             NEED TO ADD PATH TO PROCESSED MT ANATOMICAL IMAGE
                %DW_PipelineWrapper(DWIpath,FieldmapNiiFiles,Anatomical_Image,DWIoutputfolder,SubjectID,Session,RepetFolders{k},valid_protocols_diff{j});
                %[matlabbatch Session Opts prefixNIIf] = fMRI_automated_preproc(RootPath, SubjectID, Config_file)
            end;
        end;
    end;    
end;
end