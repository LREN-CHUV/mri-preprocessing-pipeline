function [block newpaths] = CopyTo(Files,TargetFolder)
% SPM Copy files (Basic IO operations) (this is a simple operation that
% could be done through one line of code, but this function puts the
% command in the job structure for later use, therefore leaving data
% untouched before running the whole preprocessing)
%
%--------------------------------------------------------------------------
% INPUTS:
%--------------------------------------------------------------------------
%
% Files: cell of strings with filepaths to copy
%
% TargetFolder : cell of string, target directory where to copy Files
%
%--------------------------------------------------------------------------
% OUTPUTS:
%--------------------------------------------------------------------------
%
% block : structure for SPM job (Copy files here)
%
% newpaths : new filepaths for Files copied
%
%--------------------------------------------------------------------------
% 2014-08-19, @LREN, Renaud Marquis, refacto
%--------------------------------------------------------------------------

block.cfg_basicio.file_dir.file_ops.file_move.files = Files;
block.cfg_basicio.file_dir.file_ops.file_move.action.copyto = cellstr(TargetFolder);

for F = size(Files,1)
    [p n e] = fileparts(Files{F});
    newpaths{F} = strcat(TargetFolder,filesep,n,e);
end

end