function [out_FolderNames,out_SubFolderNames] = getListofFolders_date(InputFolder,pdate)


%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, May 16th, 2014

DirList = dir(InputFolder);
dirindex = [DirList.isdir];
DirList = DirList(dirindex);
FolderNames = {DirList.name}';
FolderNames = setdiff(FolderNames,{'.';'..'});
in_date = datenum(pdate,'dd.mm.yyyy');
FoldersDate = cell2mat({DirList.datenum})';
FoldersDate = FoldersDate(3:end);

ind = FoldersDate>=in_date;

FolderNames = FolderNames(ind);

if ~strcmp(InputFolder(end),filesep)
    InputFolder = [InputFolder,filesep];
end;
out_SubFolderNames = {};
out_FolderNames = {};
for i=1:length(FolderNames)
    DataFolder = [InputFolder,FolderNames{i}];
    t = getListofFolders(DataFolder);
    for j=1:length(t)
        out_FolderNames = vertcat(out_FolderNames,FolderNames(i)); %#ok
    end;
    out_SubFolderNames = vertcat(out_SubFolderNames,t); %#ok
end;

return;