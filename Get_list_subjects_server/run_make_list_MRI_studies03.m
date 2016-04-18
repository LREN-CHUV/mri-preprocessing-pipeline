clear;
ServerDataFolder = '\\filearc\data\CRN\LREN\IRMMP16\prisma\2014\';
NewOutputXLSFile = 'D:\Users DATA\Users\lester\LREN_Server_Data_Info_Excel_Files\LREN_Server_data_info_All_Data.xls';
OldXLSFile = 'M:\CRN\LREN\SHARE\LREN_Server_data_info_All_Data_31Mar2016110405.xls';

ProtocolsFile = 'D:\Users DATA\Users\lester\Automatic_Computation_under_Organization\Protocols_definition.txt';

Subj_IDs = make_list_MRI_studies03(ServerDataFolder,NewOutputXLSFile,OldXLSFile,ProtocolsFile);

