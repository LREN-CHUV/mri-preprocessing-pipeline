InputFolder = 'D:\Users DATA\Users\lester\Network_Tissue_Properties_Study';
SubjIDs = getListofFolders(InputFolder);
Ns = length(SubjIDs);
OutputFolder = 'D:\Users DATA\Users\lester\Network_Tissue_Properties_Study_for_Stats';

for i=1:Ns
    disp(['Copying Data from Subject: ',num2str(i),' of ',num2str(Ns),' ---> ',SubjIDs{i}]);
    InputSubjectFolder = [InputFolder,filesep,SubjIDs{i}];
    OutputSubjectFolder = [OutputFolder,filesep,SubjIDs{i}];
    mkdir(OutputSubjectFolder);
    Files2Copy = pickfiles(InputSubjectFolder,{'fin_dart_'});
    if ~isempty(Files2Copy)
        for j=1:size(Files2Copy,1)
            copyfile(Files2Copy(j,:),OutputSubjectFolder);
        end;
    end;
end;
