%SubjectFolder = 'Z:\IRMMP16\prisma\2014\20140605\PR00198';
%SubjectFolder = 'Z:\IRMMP16\prisma\2014\20140610\PR00198';
SubjectFolder = 'Z:\IRMMP16\prisma\2014\20140625\PR00188';
%SubjID = 'PR00198';
SubjID = 'PR00188';
%OutputFolder = 'D:\Users DATA\Users\lester\AAA_Case_198_Repeated';
OutputFolder = 'D:\Users DATA\Users\lester\AAA_Case_188_2Dates';
ProtocolsFile = 'Protocols_definition.txt';

Subj_OutputFolder = DCM2NII_VBQ_rev(SubjectFolder,SubjID,OutputFolder,ProtocolsFile);