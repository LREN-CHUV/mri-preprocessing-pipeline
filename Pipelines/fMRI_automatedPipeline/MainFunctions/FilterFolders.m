function temp = FilterFolders(FolderNames,str)
% selects and returns folders in NIIs_folders with a particular name (str) and
% exclude folders with another particular name (nstr)
%
% USAGE:
% str = 'gre_field_mapping.*'

temp = FolderNames(~cellfun(@isempty,regexpi(FolderNames,str)),1);%find folders related to str

end