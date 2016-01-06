function FolderNames = detectFolders(NIIs_folder)
% Function listing the subfolders names of a given folder
%
%--------------------------------------------------------------------------
% INPUTS
%--------------------------------------------------------------------------
%
% NIIs_folder : string, absolute path of folder which contains subfolder(s)
% to detect
%
%--------------------------------------------------------------------------
% OUTPUTS
%--------------------------------------------------------------------------
%
% FolderNames : cell of strings, subfolders detected
%
%--------------------------------------------------------------------------
% 2014-07-07, @LREN, Renaud Marquis & Sandrine Muller, refacto
%--------------------------------------------------------------------------

    folderList = dir(NIIs_folder);
    folderList = folderList(3:end);
    for i = 1:length(folderList)
        FolderNames{i,1} = getfield(folderList(i,1),'name');
        IdxFolders(i,1) = isdir(strcat(NIIs_folder, filesep, FolderNames{i,1})); % prevents to detect files instead of folders
    end
    if exist('IdxFolders','var')
        FolderNames = FolderNames(IdxFolders);
    else
        FolderNames = {};
    end
    
end