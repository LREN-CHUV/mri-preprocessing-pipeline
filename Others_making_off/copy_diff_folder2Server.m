LocalDiffFolder = 'D:\Users DATA\Users\lester\ZZZ_NODDI_MB2_2pt2mm\';
DiffFolders = getListofFolders(LocalDiffFolder);
ServerFolder = 'M:\CRN\LREN\SHARE\VBQ_Output_All\DataNifti_All\';
%ServerFolder = 'D:\Users DATA\Users\lester\ZZZ_ZZZ\';
%DiffFolders = {'PR00335_PZ140231'};

Ns = length(DiffFolders);
DiffFolderName = 'ep2d_diff_NODDI_MB2_2pt2mm';
for i=1:Ns
    disp(['Copying Folder Subject : ',DiffFolders{i},'... ',num2str(i),' of ',num2str(Ns)]);
    SubjFolder = [ServerFolder,DiffFolders{i},filesep];
    SessionFolders = getListofFolders(SubjFolder);
    ServerSubjFolder = [SubjFolder,SessionFolders{1},filesep];
    if ~exist([ServerSubjFolder,DiffFolderName],'dir')
        mkdir([ServerSubjFolder,DiffFolderName]);
    end;
    DestinationFolder  = [ServerSubjFolder,DiffFolderName,filesep];
    SourceSessionFolders = getListofFolders([LocalDiffFolder,DiffFolders{i}]);
    SourceFolder = [LocalDiffFolder,DiffFolders{i},filesep,SourceSessionFolders{1},filesep,DiffFolderName,filesep];
    copyfile(SourceFolder,DestinationFolder);
end;