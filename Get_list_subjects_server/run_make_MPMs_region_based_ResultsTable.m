NeuroMorphoInputFolder = 'M:\CRN\LREN\SHARE\ZZZ_Neuromorphics_Atlasing\';
ProtocolsFile = 'D:\MFiles\Get_list_subjects_server\Protocols_definition.txt';
OutputXLSFileName = 'D:\LREN_Server_MPMs_Vols_Data_Files\LREN_All_Subjects_MPMs_Table.xls';

PreviousOutputXLSFileName = 'M:\CRN\LREN\SHARE\LREN_All_Subjects_MPMs_Table_09Mar2016152832.xls';

NewOutputXLSFileName= make_MPMs_region_based_ResultsTable(NeuroMorphoInputFolder,ProtocolsFile,PreviousOutputXLSFileName,OutputXLSFileName);