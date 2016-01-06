PipelineConfigFile = which('Preproc_mpm_maps_pipeline_config.txt');

[InputFolder,ProtocolsFile,MPM_OutputFolder,GlobalMPMFolder,MPM_Template,ServerFolder,doUNICORT] = ...
    Read_Preproc_mpm_maps_config(PipelineConfigFile); %#ok<*STOUT>
SubjectFolder = 'M:\CRN\LREN\SHARE\VBQ_Output_All\DataNifti_All\PR01167_FB141244';
SubjID = 'PR01167_FB141244';

[Subj_OutputFolder,SubjOutMPMFolder] = Preproc_mpm_maps_extended_fixed(SubjectFolder,SubjID,MPM_OutputFolder,GlobalMPMFolder,ProtocolsFile,MPM_Template,ServerFolder,doUNICORT);