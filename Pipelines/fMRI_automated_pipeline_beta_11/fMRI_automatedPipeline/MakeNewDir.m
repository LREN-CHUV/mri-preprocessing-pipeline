function block = MakeNewDir(ParentFolder,NewFolderName)
% SPM Make new directory (Basic IO operations) (this is a simple operation that
% could be done through one line of code, but this function puts the
% command in the job structure for later use, therefore leaving data
% untouched before running the whole preprocessing)
%
%--------------------------------------------------------------------------
% INPUTS:
%--------------------------------------------------------------------------
%
% ParentFolder : string, absolute path of parent folder of the new folder
% to create
%
% NewFolderName : cell of string, absolute path of new folder to create
%
%--------------------------------------------------------------------------
% OUTPUTS:
%--------------------------------------------------------------------------
%
% block : structure for SPM job (Make new directory here)
%
%--------------------------------------------------------------------------
% 2014-08-19, @LREN, Renaud Marquis, refacto
%--------------------------------------------------------------------------

block.cfg_basicio.file_dir.dir_ops.cfg_mkdir.parent = {ParentFolder};
block.cfg_basicio.file_dir.dir_ops.cfg_mkdir.name = NewFolderName;

end

