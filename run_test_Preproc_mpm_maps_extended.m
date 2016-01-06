clear;
SubjectFolder =  'D:\Users DATA\Users\lester\ZZZ_Nifti_Data_MPMs\PR00145';
%SubjectFolder =  'D:\Users DATA\Users\lester\DataNifti\AL060680';
SubjID = 'PR00145';
%SubjID = 'AL060680';
OutputFolder = 'D:\Users DATA\Users\lester\ZZZ_ZZZ_test\MPMs\';
GlobalMPMFolder = 'D:\Users DATA\Users\lester\ZZZ_ZZZ_test\GlobalMPMs\';
ProtocolsFile = 'D:\Users DATA\Users\lester\Automatic_Computation\Protocols_definition.txt';
MPM_Template = 'nwTPM_SL.nii';
ServerFolder = 'D:\Users DATA\Users\lester\ZZZ_MPMs_Results\ServerOutput\';
doUNICORT = false;

Preproc_mpm_maps_extended_fixed(SubjectFolder,SubjID,OutputFolder,GlobalMPMFolder,ProtocolsFile,MPM_Template,ServerFolder,doUNICORT);