clear;
ServerDataFolder = 'K:\IRMMP16\prisma\2014\';
%OutputXLSFile = 'M:\CRN\LREN\SHARE\VBQ_Output_All\Server_data_info.xls';
OutputXLSFile = 'D:\LREN_Server_data_info_All_Data.xls';
%OutputXLSFile = 'M:\CRN\LREN\SHARE\VBQ_Output_All\Server_data_info.xls';
Subj_IDs = make_list_MRI_studies01(ServerDataFolder,OutputXLSFile);

% DataFolders1 = getListofFolders('M:\CRN\LREN\SHARE\VBQ_Output_All\MPMs_All');
% DataFolders2 = getListofFolders('M:\CRN\LREN\SHARE\VBQ_Output\MPMs');
% 
% Subj_IDs_MPM = vertcat(DataFolders1,DataFolders2);
% 
% ind = not(ismember(Subj_IDs(:,1),Subj_IDs_MPM));
% 
% Subj_IDs2Compute = Subj_IDs(ind,:);