clear;
ServerDataFolder = '\\filearc\data\CRN\LREN\IRMMP16\prisma\2014\'; % K:\IRMMP16\prisma\2014
%OutputXLSFile = 'M:\CRN\LREN\SHARE\VBQ_Output_All\Server_data_info.xls';
NewOutputXLSFile = 'D:\LREN_Server_data_info_All_Data.xls';
%OldXLSFile = 'M:\CRN\LREN\SHARE\LREN_Server_data_info_19Jan2015.xls';
OldXLSFile = 'M:\CRN\LREN\SHARE\LREN_Server_data_info_All_Data_12Nov2015154807.xls';
Subj_IDs = make_list_MRI_studies02(ServerDataFolder,NewOutputXLSFile,OldXLSFile);

% DataFolders1 = getListofFolders('M:\CRN\LREN\SHARE\VBQ_Output_All\MPMs_All');
% DataFolders2 = getListofFolders('M:\CRN\LREN\SHARE\VBQ_Output\MPMs');
% 
% Subj_IDs_MPM = vertcat(DataFolders1,DataFolders2);
% 
% ind = not(ismember(Subj_IDs(:,1),Subj_IDs_MPM));
% 
% Subj_IDs2Compute = Subj_IDs(ind,:);