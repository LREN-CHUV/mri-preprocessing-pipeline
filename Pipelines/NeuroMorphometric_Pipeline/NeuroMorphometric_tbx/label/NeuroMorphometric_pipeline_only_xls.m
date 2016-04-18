function NeuroMorphometric_pipeline_only_xls(SubjID,InputDataFolder,LocalFolder,AtlasingOutputFolder,ProtocolsFile)

%% Lester Melie Garcia
% LREN, Lausanne
% October 7th, 2015

if ~strcmp(AtlasingOutputFolder(end),filesep)
    AtlasingOutputFolder = [AtlasingOutputFolder,filesep];
end;
if ~strcmp(InputDataFolder(end),filesep)
    InputDataFolder = [InputDataFolder,filesep];
end;
if ~strcmp(LocalFolder(end),filesep)
    LocalFolder = [LocalFolder,filesep];
end;
Subj_OutputFolder = [LocalFolder,SubjID,filesep];
mkdir(Subj_OutputFolder);
copyfile([InputDataFolder,SubjID],Subj_OutputFolder);
Ini_List_Files = getAllFiles(Subj_OutputFolder);

SessionFolders = getListofFolders(Subj_OutputFolder); % Number of sessions ...
Nsess = length(SessionFolders);
for i=1:Nsess
    MT_Folders = get_valid_MT_Protocols(ProtocolsFile,[Subj_OutputFolder,SessionFolders{i},filesep]);
    for j=1:length(MT_Folders)
        RepetitionFolders = getListofFolders([Subj_OutputFolder,SessionFolders{i},filesep,MT_Folders{j}]); % Number of repetitions ...
        for r=1:length(RepetitionFolders)
            SubjectWorkingFolder = [Subj_OutputFolder,SessionFolders{i},filesep,MT_Folders{j},filesep,RepetitionFolders{r}];
            c1ImageFileName = pickfiles(SubjectWorkingFolder,{[filesep,'c1'];'.nii'},{filesep},{'Old_Segmentation'});
            rc1ImageFileName = pickfiles(SubjectWorkingFolder,{[filesep,'rc1'];'.nii'},{filesep},{'Old_Segmentation'});
            c2ImageFileName = pickfiles(SubjectWorkingFolder,{[filesep,'c2'];'.nii'},{filesep},{'Old_Segmentation'});
            rc2ImageFileName = pickfiles(SubjectWorkingFolder,{[filesep,'rc2'];'.nii'},{filesep},{'Old_Segmentation'});
            c3ImageFileName = pickfiles(SubjectWorkingFolder,{[filesep,'c3'];'.nii'},{filesep},{'Old_Segmentation'});
            [OutputAtlasFile,OutputVolumeFile]= do_one_subject_with_segmentation(c1ImageFileName,c2ImageFileName,rc1ImageFileName,rc2ImageFileName, ...
                                                                                 SubjectWorkingFolder,SubjectWorkingFolder);
            OutputCSVFile = [SubjectWorkingFolder,filesep,SubjID,'_Neuromorphics_Vols_MPMs_global_values.xls']; % '_Neuromorphics_Vols_MPMs_values.csv'
            save_vols_MPMs_globals2csv(OutputVolumeFile,OutputAtlasFile,SubjectWorkingFolder,OutputCSVFile,c1ImageFileName,c2ImageFileName,c3ImageFileName);
            %save_vols_MPMs2csv(OutputVolumeFile,OutputAtlasFile,SubjectWorkingFolder,OutputCSVFile);
        end;
    end;
end;
Out_List_Files = getAllFiles(Subj_OutputFolder);
Reorganize_MPM_Files(Subj_OutputFolder,Ini_List_Files,Out_List_Files);

if ~strcmpi(AtlasingOutputFolder,LocalFolder)
    SubjOutputServerFolder = [AtlasingOutputFolder,SubjID];
    if ~exist(SubjOutputServerFolder ,'dir')
        mkdir(SubjOutputServerFolder);
    end;
    if ~isempty(MT_Folders)
        copyfile(Subj_OutputFolder,SubjOutputServerFolder);
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

%% function Reorganize_MPM_Files(Subj_OutputFolder,Ini_List_Files,Out_List_Files)
function Reorganize_MPM_Files(Subj_OutputFolder,Ini_List_Files,Out_List_Files)

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