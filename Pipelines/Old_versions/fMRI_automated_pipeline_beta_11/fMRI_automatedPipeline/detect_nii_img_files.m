function [Output FileExt] = detect_nii_img_files(NIIs_folder,Folder)
% Function that retrieves (non-recursively) image files in a given folder
% using spm_select function
%
% Nota bene: file extensions (of fMRI scans) other than .nii or .img formats
% are not detected!
%--------------------------------------------------------------------------
% INPUTS
%--------------------------------------------------------------------------
%
% NIIs_folder : string, absolute path of folder which contains subfolder(s)
% to detect
%
% Folder : string, relative path of folder within NIIs_folder
%
%--------------------------------------------------------------------------
% OUTPUTS
%--------------------------------------------------------------------------
%
% Output : cell of strings, absolute filepaths of images found
%
% FileExt : string, file extension of files discovered
%
%--------------------------------------------------------------------------
% 2014-08-19, @LREN, Renaud Marquis & Sandrine Muller, refacto
%--------------------------------------------------------------------------

    FileExt = '.nii';
    
    % Try first to detect .nii files, and if nothing is found, try to detect
    % .img files
    Output = cellstr(spm_select('ExtFPList',strcat(NIIs_folder,filesep,Folder),'.nii'));
    if isdir(char(Output)) || isempty(char(Output))
        Output = cellstr(spm_select('ExtFPList',strcat(NIIs_folder,filesep,Folder),'.img'));
        FileExt = '.img';
    end

    Output = regexprep(Output, ',1', '');

end