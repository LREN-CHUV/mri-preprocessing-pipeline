function Subjs = Combine_Echoes_fMRI_dropout(ServerFolder,ListofSubjects)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, November 23rd, 2015

if ~strcmp(ServerFolder(end),filesep)
    ServerFolder = [ServerFolder,filesep];
end;

if exist('ListofSubjects','var')
    SubjFolders = ListofSubjects;
else
    SubjFolders = getListofFolders(ServerFolder);    
end;

Ns = length(SubjFolders);
fMRI_SequenceName = {'al_mepi2d_3mm_dropout'};
fMRI_SequenceNameEchoCombined = {'al_mepi2d_3mm_dropout_Echocombined'};
c = 0; Subjs = {};
for i=1:Ns
    disp(['Processing Subject : ',num2str(i),' of ',num2str(Ns), ' : ',SubjFolders{i}]);
    InSubj_Folder = [ServerFolder,SubjFolders{i},filesep];
    SessionFolders = getListofFolders(InSubj_Folder); % Number of sessions ...
    Nsess = length(SessionFolders);
    for j=1:Nsess
        SubjSequences = getListofFolders([InSubj_Folder,SessionFolders{j}]);
        if ismember(fMRI_SequenceName,SubjSequences)&&(~ismember(fMRI_SequenceNameEchoCombined,SubjSequences))
            if ~ismember(SubjFolders(i),Subjs)
                c = c + 1;
                Subjs(c) = SubjFolders(i); %#ok
                disp(['Subject --> ',SubjFolders{i},' : ',num2str(c)]);
            end;
            DataFolder = [InSubj_Folder,SessionFolders{j},filesep];
            EchoCombining(DataFolder,fMRI_SequenceName{1});
        end;
    end;
end;

end