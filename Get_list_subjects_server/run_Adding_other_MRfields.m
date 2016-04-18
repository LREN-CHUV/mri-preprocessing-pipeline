ServerDataFolder = '\\filearc\data\CRN\LREN\IRMMP16\prisma\2014\'; % K:\IRMMP16\prisma\2014
NewOutputXLSFile = 'D:\Users DATA\Users\lester\LREN_Server_data_info_All_Data.xls';
OldOutputXLSFile = 'M:\CRN\LREN\SHARE\LREN_Server_data_info_All_Data_12Nov2015154807.xls';
ProtocolsFile = 'D:\Users DATA\Users\lester\Automatic_Computation\Protocols_definition.txt';
data_xls = Adding_other_MRfields(ServerDataFolder,NewOutputXLSFile,OldOutputXLSFile,ProtocolsFile);