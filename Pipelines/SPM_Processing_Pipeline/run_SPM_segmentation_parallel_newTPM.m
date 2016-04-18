clear;
ServerFolder = 'M:\CRN\LREN\SHARE\VBQ_Output_All\MPMs_All';
TemplateImage = 'nwTPM_sl2.nii';
WhichImage = '_MT_m.nii';
%SubjectList = getListofFolders(ServerFolder);
SubjectList = {'140318_1_660'};
SPM_segmentation_parallel_newTPM(SubjectList,ServerFolder,TemplateImage,WhichImage);
