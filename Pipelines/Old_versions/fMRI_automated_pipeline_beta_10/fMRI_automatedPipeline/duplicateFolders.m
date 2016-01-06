function [block1 block2 newpath] = duplicateFolders(str,resName,Opts)
% Function which aims at duplicating the folders in case there are multiple
% resolutions, using CopyTo function
%
%--------------------------------------------------------------------------
% INPUTS:
%--------------------------------------------------------------------------
%
% str : string, absolute path to a file to duplicate
%
% resName : string indicating resolution for which scans need to be
% duplicated
%
%--------------------------------------------------------------------------
% OUTPUTS:
%--------------------------------------------------------------------------
%
% block : structure for SPM job (Copy files from CopyTo function here)
%
% newpath : updated paths of files duplicated (from CopyTo function)
%
%--------------------------------------------------------------------------
% 2014-08-19, @LREN, Renaud Marquis & Sandrine Muller, refacto
%--------------------------------------------------------------------------

[p1 n1 e1] = fileparts(str);
if strcmpi(Opts.DirStructure,'LRENpipeline')
    [p2 n2 e2] = fileparts(p1);
    [p n e] = fileparts(p2);
else
    [p n e] = fileparts(p1);
end
pnew = strcat(n,'_',resName);
if iscellstr(str)
    block1 = MakeNewDir(p,pnew);
    [block2 newpath] = CopyTo(str,strcat(p,filesep,pnew));
elseif ischar(str)
    block1 = MakeNewDir(p,pnew);
    [block2 newpath] = CopyTo({str},strcat(p,filesep,pnew));
else
    error('Cannot recognize data format')
end

end