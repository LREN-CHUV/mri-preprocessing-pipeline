function pnew = duplicateFolders(str,resName)
% function which aims at duplicating the folders in case there are multiple
% resolutions

[p n e] = fileparts(str);
pnew = strcat(p,'_',resName);
copyfile(p,pnew);

end