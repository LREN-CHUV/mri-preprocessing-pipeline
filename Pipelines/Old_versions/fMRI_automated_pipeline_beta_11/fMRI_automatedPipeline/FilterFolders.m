function out = FilterFolders(FolderNames,str,nstr)
% Selects and returns folders in NIIs_folders with a particular name (str)
% and exclude folders with another particular name (nstr)
%
%--------------------------------------------------------------------------
% INPUTS:
%--------------------------------------------------------------------------
%
% FolderNames : cell of strings, folders to filter
%
% str : token to find in FolderNames, e.g. 'gre_field_mapping.*'
%
% nstr : token not to be found in FolderNames, e.g. '.*rl.*'
%
%--------------------------------------------------------------------------
% OUTPUTS:
%--------------------------------------------------------------------------
%
% out : cell of strings, filtered folders
%
%--------------------------------------------------------------------------
% 2014-07-07, @LREN, Renaud Marquis & Sandrine Muller, refacto
%--------------------------------------------------------------------------

out = FolderNames(~cellfun(@isempty,regexpi(FolderNames,str)),1);%find folders related to str
out = out(cellfun(@isempty,regexp(out,nstr,'start')),1); % exclude folders that could be already preprocessed

end