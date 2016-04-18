clear;
NeuroMorphoInputFolder = 'M:\CRN\LREN\SHARE\ZZZ_Neuromorphics_Atlasing\';
ProtocolsFile = 'Protocols_definition.txt';
OutputXLSFileName = 'D:\Users DATA\Users\lester\LREN_Server_MPMs_Vols_Data_Files\LREN_All_Subjects_MPMs_Table_test.xls';
%OutputXLSFileName = '';
%PreviousOutputXLSFileName = 'M:\CRN\LREN\SHARE\LREN_All_Subjects_MPMs_Table_09Mar2016152832.xls';
PreviousOutputXLSFileName = '';
%NewOutputXLSFileName= make_MPMs_region_based_ResultsTable(NeuroMorphoInputFolder,ProtocolsFile,PreviousOutputXLSFileName,OutputXLSFileName);
NewOutputXLSFileName= make_MPMs_region_based_ResultsTable_plus_sigma(NeuroMorphoInputFolder,ProtocolsFile,PreviousOutputXLSFileName,OutputXLSFileName);
