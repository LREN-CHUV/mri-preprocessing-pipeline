function [Output FileExt] = DetectFiles(NIIs_folder,Folder)
% function that retrieves (non-recursively) files in a folder given:
% - the folder name (Folder)
% - the absolute path of the folder (NIIs_folder)
%
% It tries first to detect .nii files and tries then to detect .img files
% if no .nii files have been found
%

    FileExt = '.nii';
    
    Output = cellstr(spm_select('ExtFPList',Folder,'.nii'));
    if isdir(char(Output))
        Output = cellstr(spm_select('ExtFPList',Folder,'.img'));
        FileExt = '.img';
    end

    Output = regexprep(Output, ',1', '');

end