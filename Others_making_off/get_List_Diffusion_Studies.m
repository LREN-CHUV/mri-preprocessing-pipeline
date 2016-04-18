function ValidSubjectIDs = get_List_Diffusion_Studies(DataFolder,ProtocolsFile)

% This functions looks in Nifti Folder to pick those that have a valid Diffusion Protocol
%
%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, April 20th, 2015

if ~strcmp(DataFolder(end),filesep)
    DataFolder = [DataFolder,filesep];
end;

SubjectIDs = getListofFolders(DataFolder);
Ns = length(SubjectIDs);
ValidSubjectIDs = {};
for i=1:Ns
    disp([num2str(i),' -- Collecting Information from Subject : ',SubjectIDs{i}]); 
    SubjectFolder = [DataFolder,SubjectIDs{i},filesep];
    SessionFolders = getListofFolders(SubjectFolder);
    Nsession = length(SessionFolders);  % Number of sessions ...    
    for j=1:Nsession
        valid_protocols_diff  = get_DWI_sequences([SubjectFolder,SessionFolders{j},filesep],ProtocolsFile); % number of valid protocols ...
        if ~isempty(valid_protocols_diff)
            ValidSubjectIDs = vertcat(ValidSubjectIDs,SubjectIDs(i)); %#ok
        end;
    end;
end;

ValidSubjectIDs = unique(ValidSubjectIDs);

end