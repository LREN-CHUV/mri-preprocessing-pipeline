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
% InputDataFolder = 'M:\CRN\LREN\SHARE\VBQ_Output_All\MPMs_All';
% MPRAGE_synth_parallel(InputDataFolder,SubjectList);

InputDataFolder = 'M:\CRN\LREN\USERS_BACKUP\aruef\NCCR\MapCompB0B1\maps_comp_new_1echo_prisma\MPMs';
SubjectList = getListofFolders(InputDataFolder);
MPRAGE_synth_parallel(InputDataFolder,SubjectList);