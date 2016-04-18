SubjectFolder ='D:\WORK\LREN\anne\DATA\prisma_data\AL060680';
ConvOutputFolder = 'D:\WORK\LREN\test_folder\DataNifti';
SubjID = 'AL060680';
ProtocolsFile = 'D:\WORK\Automatic_Computation\Protocols_definition.txt';
MPM_OutputFolder = 'D:\WORK\LREN\test_folder\MPMs';
GlobalMPMFolder = 'D:\WORK\LREN\test_folder\GlobalMPMs';
MPM_Template = 'nwTPM_SL.nii';
VBQ_pipeline(ConvOutputFolder,MPM_OutputFolder,GlobalMPMFolder,MPM_Template,ProtocolsFile,SubjectFolder,SubjID);