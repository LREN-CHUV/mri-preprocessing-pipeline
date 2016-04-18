SubjectFolder = 'D:\Users DATA\Users\lester\VBQ_Dicom_Data\PR00192';
SubjID = 'PR00192';
OutputFolder = 'D:\Users DATA\Users\lester\junk';
ProtocolsFile = 'D:\Users DATA\Users\lester\Automatic_Computation\Protocols_definition.txt';

spm_jobman('initcfg');

DCM2NII_VBQ_rev(SubjectFolder,SubjID,OutputFolder,ProtocolsFile);