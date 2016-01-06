function [block newpaths] = MoveTo(Files,TargetFolder)
% SPM Move files (Basic IO operations) (this is a simple operation that
% could be done through one line of code, but this function puts the
% command in the job structure for later use, therefore leaving data
% untouched before running the whole preprocessing)
%
%--------------------------------------------------------------------------
% INPUTS:
%--------------------------------------------------------------------------
%
% Files: cell of strings with filepaths to move
%
% TargetFolder : cell of string, target directory where to move Files
%
%--------------------------------------------------------------------------
% OUTPUTS:
%--------------------------------------------------------------------------
%
% block : structure for SPM job (Move files here)
%
% newpaths : new filepaths for Files moved
%
%--------------------------------------------------------------------------
% 2014-08-19, @LREN, Renaud Marquis, refacto
%--------------------------------------------------------------------------

block.cfg_basicio.file_dir.file_ops.file_move.files = Files;
block.cfg_basicio.file_dir.file_ops.file_move.action.moveto = TargetFolder;

newpaths = spm_file(Files,'path',TargetFolder);

end