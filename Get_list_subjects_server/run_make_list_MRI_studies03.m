clear;
ServerDataFolder = '\\filearc\data\CRN\LREN\IRMMP16\prisma\2014\';
NewOutputXLSFile = 'D:\Users DATA\Users\lester\LREN_Server_data_info_All_Data.xls';
OldXLSFile = 'D:\Users DATA\Users\lester\LREN_Server_data_info_All_Data_19Nov2015132923.xls';
ProtocolsFile = 'D:\Users DATA\Users\lester\Automatic_Computation\Protocols_definition.txt';

Subj_IDs = make_list_MRI_studies04(ServerDataFolder,NewOutputXLSFile,OldXLSFile,ProtocolsFile);

