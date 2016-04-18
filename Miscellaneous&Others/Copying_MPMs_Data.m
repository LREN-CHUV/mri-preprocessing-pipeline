ListofSubjectsFile = 'D:\Users DATA\Users\lester\Network_Tissue_Properties_Study\IDs_All_Groups_Together.txt';
SubjIDs = textread(ListofSubjectsFile,'%s');
Ns = length(SubjIDs);
MPMFolder = 'M:\CRN\LREN\SHARE\VBQ_Output_All\MPMs_All';
OutputFolder = 'D:\Users DATA\Users\lester\Network_Tissue_Properties_Study';
TargetSequenceName = 'mt_al_mtflash3d_v2l_1mm';
ListofFiles = {'c1s','c2s','c3s','rc1s','rc2s','_R1.nii','_A.nii','_MT.nii','_R2s.nii','iy_s','y_s'};
for i=1:Ns
    disp(['Copying Data from Subject: ',num2str(i),' of ',num2str(Ns),' ---> ',SubjIDs{i}]);
    SessionFolder = getListofFolders([MPMFolder,filesep,SubjIDs{i}]);
    Sequences = getListofFolders([MPMFolder,filesep,SubjIDs{i},filesep,SessionFolder{1}]);
    TargetSequenceFolder = [MPMFolder,filesep,SubjIDs{i},filesep,SessionFolder{1},filesep,TargetSequenceName];
    RepetitionFolder = getListofFolders(TargetSequenceFolder);
    FinalFolder2Copy = [TargetSequenceFolder,filesep,RepetitionFolder{1}];    
    Files2Copy = pickfiles(FinalFolder2Copy,{filesep},ListofFiles,{'c4s','c5s','Old_Segmentation'});
    if ~isempty(Files2Copy)
        OuputSubjectFolder = [OutputFolder,filesep,SubjIDs{i}];
        if ~exist(OuputSubjectFolder,'dir')
            mkdir(OuputSubjectFolder);
            for j=1:size(Files2Copy,1)
                copyfile(Files2Copy(j,:),OuputSubjectFolder);
            end;
        end;
    else
        disp(['Copying Data from Subject: ',SubjectFolders{i},' not MPM 1mm protocol !']);
    end;
end;