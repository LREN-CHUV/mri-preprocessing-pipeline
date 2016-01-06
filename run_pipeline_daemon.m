DataFolderName = 'D:\Bern_2013\Anja_Data';
PipelineFunction = 'wait4me_job1';
InputParameters = {10};
pipeline_daemon(DataFolderName,PipelineFunction,InputParameters); %,FinishedDataListFile,CheckTime);

DataFolderName = 'D:\Bern_2013\Anja_Data';
PipelineFunction = 'wait4me_job1';
InputParameters = {10};

% ConvOutputFolder = 'D:\WORK\LREN\test_folder\DataNifti';
% MPM_OutputFolder = 'D:\WORK\LREN\test_folder\MPMs';
% GlobalMPMFolder = 'D:\WORK\LREN\test_folder\GlobalMPMs';
% ProtocolsFile = 'D:\WORK\Automatic_Computation\Protocols_definition.txt';
% InputParameters = {ConvOutputFolder,MPM_OutputFolder,GlobalMPMFolder,ProtocolsFile};
% 
% PipelineFunction = 'VBQ_pipeline';
% DataFolderName = 'D:\WORK\LREN\anne\DATA\prisma_data';
% pipeline_daemon(DataFolderName,PipelineFunction,InputParameters);

%%VBQ_pipeline(ConvOutputFolder,MPM_OutputFolder,GlobalMPMFolder,ProtocolsFile,SubjectFolder,SubjID);