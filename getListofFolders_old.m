function FolderNames = getListofFolders(InputFolder)


%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, May 16th, 2014

DirList = dir(InputFolder);
dirindex = [DirList.isdir];
DirList = DirList(dirindex);
FolderNames = {DirList.name}';
FolderNames = setdiff(FolderNames,{'.';'..'});

return;

