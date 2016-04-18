%clear;
% List_of_Subjects_File = 'D:\Users DATA\Users\lester\ZZZ_Elisabeth_Segmentation\PRlist.xlsx';
% [~,~,SubjectList] = xlsread(List_of_Subjects_File);
% ind = [];
% for i=1:length(SubjectList)
%     if ~isnan(SubjectList{i})
%         ind = [ind,i];
%     end;
% end;
% SubjectList = SubjectList(ind);

ServerFolder = 'M:\CRN\LREN\SHARE\VBQ_Output\MPMs';
LocalFolder = 'M:\CRN\LREN\SHARE\VBQ_Output\MPMs';
TemplateImage = 'nwTPM_sl2.nii';
WhichImage = '_MT.nii';
SubjectList = getListofFolders(ServerFolder);
SPM_segmentation_parallel(SubjectList,ServerFolder,LocalFolder,TemplateImage,WhichImage);
