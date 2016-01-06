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

ServerFolder = 'M:\CRN\LREN\USERS_BACKUP\aruef\NCCR\MapCompB0B1\maps_comp_new_1echo_prisma\MPMs';
LocalFolder = 'M:\CRN\LREN\USERS_BACKUP\aruef\NCCR\MapCompB0B1\maps_comp_new_1echo_prisma\MPMs';
TemplateImage = 'nwTPM_sl2.nii';
WhichImage = 'T1PDR2s_MPRAGE.nii';
SubjectList = getListofFolders(ServerFolder);
SPM_segmentation_parallel(SubjectList,ServerFolder,LocalFolder,TemplateImage,WhichImage);
