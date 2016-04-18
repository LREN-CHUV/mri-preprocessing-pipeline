function NeuroMorphometric_pipeline_xls_only(SubjID,MPMsInputFolder,AtlasingOutputFolder,ProtocolsFile)

%% Lester Melie Garcia
% LREN, Lausanne
% October 7th, 2015

if ~strcmp(AtlasingOutputFolder(end),filesep)
    AtlasingOutputFolder = [AtlasingOutputFolder,filesep];
end;
if ~strcmp(MPMsInputFolder(end),filesep)
    MPMsInputFolder = [MPMsInputFolder,filesep];
end;
Subj_OutputFolder = [MPMsInputFolder,SubjID,filesep];
SessionFolders = getListofFolders(Subj_OutputFolder); % Number of sessions ...
Nsess = length(SessionFolders);
for i=1:Nsess
    MT_Folders = get_valid_MT_Protocols(ProtocolsFile,[Subj_OutputFolder,SessionFolders{i},filesep]);
    for j=1:length(MT_Folders)
        RepetitionFolders = getListofFolders([Subj_OutputFolder,SessionFolders{i},filesep,MT_Folders{j}]); % Number of repetitions ...
        for r=1:length(RepetitionFolders)
            SubjectWorkingFolder  = [Subj_OutputFolder,SessionFolders{i},filesep,MT_Folders{j},filesep,RepetitionFolders{r}];
            SubjectAtlasingFolder = [AtlasingOutputFolder,SubjID,filesep,SessionFolders{i},filesep,MT_Folders{j},filesep,RepetitionFolders{r}];
            c1ImageFileName = pickfiles(SubjectWorkingFolder,{[filesep,'c1'];'.nii'},{filesep},{'Old_Segmentation'});
            c2ImageFileName = pickfiles(SubjectWorkingFolder,{[filesep,'c2'];'.nii'},{filesep},{'Old_Segmentation'});
            c3ImageFileName = pickfiles(SubjectWorkingFolder,{[filesep,'c3'];'.nii'},{filesep},{'Old_Segmentation'});
            if exist(SubjectAtlasingFolder,'dir')
                OutputAtlasFile = pickfiles(SubjectAtlasingFolder,{'.nii';'label'});
                OutputVolumeFile = pickfiles(SubjectAtlasingFolder,{'.txt';'volumes'});
                if (~isempty(OutputAtlasFile))&&(~isempty(OutputVolumeFile))
                    if isempty(pickfiles(SubjectAtlasingFolder,{'_Neuromorphics_Vols_MPMs_global_std_values.xls'}))
                        disp([SubjID,' ----> To be Done !']);
                        OutputCSVFile = [SubjectAtlasingFolder,filesep,SubjID,'_Neuromorphics_Vols_MPMs_global_std_values.xls']; % '_Neuromorphics_Vols_MPMs_values.csv'
                        %save_vols_MPMs_globals2csv(OutputVolumeFile,OutputAtlasFile,SubjectWorkingFolder,OutputCSVFile,c1ImageFileName,c2ImageFileName,c3ImageFileName);
                        save_vols_MPMs_globals2csv_plus_sigma(OutputVolumeFile,OutputAtlasFile,SubjectWorkingFolder,OutputCSVFile,c1ImageFileName,c2ImageFileName,c3ImageFileName);
                    end;
                end;
            end;
        end;
    end;
end;

end
%%  =========   Internal  Functions  ========= %%
%% function [MT_p,Nprot] = get_valid_MT_Protocols(ProtocolsFile,DataFolder)
function [MT_p,Nprot] = get_valid_MT_Protocols(ProtocolsFile,DataFolder)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, October 7th, 2015

if ~strcmpi(DataFolder(end),filesep)
    DataFolder = [DataFolder,filesep];    
end;

MT_p = cellstr(get_protocol_names(ProtocolsFile,'__MPM__','[MT]'));
Np = length(MT_p);
ind_prot = [];
for j=1:Np
    if exist([DataFolder,MT_p{j}],'dir')
        ind_prot = [ind_prot,j];  %#ok<AGROW>
    end;
end;

if ~isempty(ind_prot)
    MT_p = MT_p(ind_prot);
    MT_p = unique(MT_p);
end;

Nprot = length(MT_p);

end
