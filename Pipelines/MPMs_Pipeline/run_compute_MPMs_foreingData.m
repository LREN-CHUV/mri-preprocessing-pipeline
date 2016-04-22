clear;
OutputFolder = 'D:\Users DATA\Users\lester\ZZZ_Bogdan_again_one_case';
SubjectFolder = 'M:\CRN\LREN\SHARE\4Lester\data_MRI\024_C';
SubjID = '024_C';
MTSubDirLabel = 'MT';
PDSubDirLabel = 'PD';
T1SubDirLabel = 'T1';
doUNICORT = 'true';
MPM_Template = 'nwTPM_sl3.nii';
compute_MPMs_foreingData(SubjectFolder,SubjID,OutputFolder,MTSubDirLabel,PDSubDirLabel,T1SubDirLabel,MPM_Template,doUNICORT);

