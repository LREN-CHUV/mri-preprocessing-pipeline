clear;
ServerFolder = 'M:\CRN\LREN\SHARE\VBQ_Output_All\MPMs_All';
TemplateImage = 'nwTPM_sl2.nii';
WhichImage = '_MT_m.nii';
SubjectList = getListofFolders(ServerFolder);
SPM_segmentation_parallel_newTPM_AC_PC_align(SubjectList,ServerFolder,TemplateImage,WhichImage);


% ServerFolder = 'M:\CRN\LREN\SHARE\VBQ_Output_All\MPMs_All';
% SubjectList = getListofFolders(ServerFolder);
% WhichImage = '_MT_m.nii';
% TemplateImage = 'nwTPM_sl2.nii';
% SubjectID = 'PR00194';
% SPM_segmentation_pipeline_newTPM_AC_PC_align(ServerFolder,SubjectID,TemplateImage,WhichImage);