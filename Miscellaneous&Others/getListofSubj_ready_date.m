function [list_ready,Folders_ready] = getListofSubj_ready_date(InputFolder,pdate,ProtocolsFile,analytype)

%% Input Parameters
%  InputFolder : Folder with subfolders organized per data .. see dicom server organization.
%    pdate : date in dd.mm.yyyy format since when the subjects will be listed.
% ProtocolsFile : Full path of the file where the protocols for each MRI image modality is defined for each step of the processing pipeline.
%  analytype : step of analysis defined in the ProtocolsFile. i.e __MPM__ for MPMs computation ; __DWI__  for diffusion data computation.
%
%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, June 22th, 2014

if ~strcmpi(InputFolder(end),filesep)
    InputFolder = [InputFolder,filesep];    
end;

[FolderNames,SubjIDs] = getListofFolders_date(InputFolder,pdate);
[FolderNames,inds] = sort(FolderNames);
SubjIDs = SubjIDs(inds);

Ns = length(SubjIDs);  % Number of subjects to be analyzed
list_ready = {}; Folders_ready = {};
for i=1:Ns
    SubjectFolder = [InputFolder,FolderNames{i},filesep,SubjIDs{i},filesep];
    SessionFolders = getListofFolders(SubjectFolder);
    Nsession = length(SessionFolders);
    Nprot = zeros(Nsession,1);
    for j=1:Nsession
        DataFolder = [SubjectFolder,SessionFolders{j}];
        switch analytype
            case '__MPM__'
                [~,~,~,~,~,Nprot(j)] = get_valid_MPM_Protocols(ProtocolsFile,DataFolder);                
            case '__DWI__'
                [~,Nprot(j)] = get_section_protocol(ProtocolsFile,analytype,'[diffusion]',DataFolder);             
        end;        
        if sum(Nprot)>0
            list_ready = vertcat(list_ready,SubjIDs(i)); %#ok<AGROW>
            Folders_ready = vertcat(Folders_ready,cellstr(SubjectFolder)); %#ok<AGROW>
        end;
    end;
end;

end