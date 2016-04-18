clear;
InputDataFolder =  'D:\Users DATA\Users\lester\Sara_Data_New\Nifti';

SubjIDs = getListofFolders(InputDataFolder);
Ns = length(SubjIDs);
for i=1:Ns
    disp(['Subject ',num2str(i),'  of  ',num2str(Ns)]);
    SubjectFolder = [InputDataFolder,filesep,SubjIDs{i},filesep];
    SessionFolders = getListofFolders(SubjectFolder);
    for j=1:length(SessionFolders)
        SequencesFolder = getListofFolders([SubjectFolder,SessionFolders{j}]);
        for k=1:length(SequencesFolder)
            RepetitionFolders = getListofFolders([SubjectFolder,SessionFolders{j},filesep,SequencesFolder{k}]);
            for t=1:length(RepetitionFolders)
                SubjRepetFolder = [SubjectFolder,SessionFolders{j},filesep,SequencesFolder{k},filesep,RepetitionFolders{t}];
                ind = strfind(RepetitionFolders{t},SequencesFolder{k});
                if ~isempty(ind)
                    NewFolderName = RepetitionFolders{t};
                    NewFolderName = NewFolderName(1:ind-2);
                    if length(NewFolderName)<2
                        NewFolderName = ['0',NewFolderName]; %#ok
                    end;
                    system(['rename "',SubjRepetFolder,'" ',NewFolderName]);
                    %movefile(SubjRepetFolder,[SubjectFolder,SessionFolders{j},filesep,SequencesFolder{k},filesep,NewFolderName]);
                end;
            end;
        end;
        if length(SessionFolders{j})>2
           system(['rename "',[SubjectFolder,SessionFolders{j}],'" ',['0',num2str(j)]]); 
        end;
    end;
end;