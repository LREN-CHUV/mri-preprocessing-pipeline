function FolderNames = detectFolders(NIIs_folder)
% function listing the subfolders names of NIIs_folder

    folderList = dir(NIIs_folder);
    folderList = folderList(3:end);
    for i = 1:length(folderList)
        FolderNames{i,1} = getfield(folderList(i,1),'name');
    end
    
end