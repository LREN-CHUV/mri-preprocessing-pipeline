function DWI_pipeline(DataFolder,OutputFolder,ProtocolsFile,SubjectID)

%% David Slater, Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, June 25th, 2014

if ~strcmp(DataFolder(end),filesep)
    DataFolder = [DataFolder,filesep];
end;
if ~strcmp(OutputFolder(end),filesep)
    OutputFolder = [OutputFolder,filesep];
end;

Subj_OutputFolder = [OutputFolder,SubjectID,filesep];
SubjectFolder = [DataFolder,SubjectID,filesep];
SessionFolders = getListofFolders(SubjectFolder);
Ns = length(SessionFolders);  % Number of sessions ...
for i=1:Ns
    Session = SessionFolders{i};
    [valid_protocols_diff,valid_protocols_fieldmap]  = get_DWI_sequences([SubjectFolder,SessionFolders{i},filesep],ProtocolsFile); % number of valid protocols ...
    for j=1:length(valid_protocols_diff)        
        RepetFolders = getListofFolders([SubjectFolder,Session,filesep,valid_protocols_diff{j},filesep]); % number of repetitions ...
        FieldmapNiiFiles = cellstr(pickfiles([SubjectFolder,Session,filesep,valid_protocols_fieldmap{j}],{'.nii'}));
        if length(FieldmapNiiFiles)>2
            FieldmapNiiFiles = FieldmapNiiFiles([1,3]); % Taking 1st and 3rd images when we have more than 2 images for fieldmapping.
        end;
        for k=1:length(RepetFolders)
            NiiFile  = pickfiles([SubjectFolder,Session,filesep,valid_protocols_diff{j},filesep,RepetFolders{k}],{'.nii'});
            bvalFile = pickfiles([SubjectFolder,Session,filesep,valid_protocols_diff{j},filesep,RepetFolders{k}],{'.bval'});
            bvecFile = pickfiles([SubjectFolder,Session,filesep,valid_protocols_diff{j},filesep,RepetFolders{k}],{'.bvec'});            
            if (~isempty(NiiFile))&&(~isempty(bvalFile))&&(~isempty(bvecFile))
                bvecs = load(bvecFile);
                if sum(bvecs(:).^2)>0
                    DWIpath  = deblank(NiiFile(1,:));
                    DWIoutputfolder=[Subj_OutputFolder,Session,filesep,valid_protocols_diff{j},filesep,RepetFolders{k},filesep];
                    if ~exist(DWIoutputfolder,'dir')
                        mkdir(DWIoutputfolder);
                    end;
                    DW_PipelineWrapper(DWIpath,FieldmapNiiFiles,DWIoutputfolder,SubjectID,Session,RepetFolders{k});
                end;
            end;
        end;
    end;
end;

end
