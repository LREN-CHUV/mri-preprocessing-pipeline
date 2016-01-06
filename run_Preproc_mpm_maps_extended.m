%SubjectFolder = 'D:\WORK\LREN\test_folder\Data2Process\PR00200';
%SubjectFolder = 'G:\Cimarron\PR00188';
Conv_SubjOutputFolder = 'D:\WORK\LREN\test_folder\DataNifti\20080129.NOACH_John.MT025\';
SubjID = '20080129.NOACH_John.MT025';
ProtocolsFile = 'D:\WORK\Automatic_Computation\Protocols_definition.txt';
MPM_OutputFolder = 'D:\WORK\LREN\test_folder\MPMs';
GlobalMPMFolder = 'D:\WORK\LREN\test_folder\GlobalMPMs';
MPM_Template = 'nwTPM_SL.nii';
ServerFolder = 'D:\WORK\LREN\test_folder\Server_Folder';

doUNICORT = true;
%doUNICORT = false;

spm_jobman('initcfg');

[Subj_OutputFolder,SubjOutMPMFolder] = ...
Preproc_mpm_maps_extended(Conv_SubjOutputFolder,SubjID,MPM_OutputFolder,GlobalMPMFolder,ProtocolsFile,MPM_Template,ServerFolder,doUNICORT);

%Preproc_mpm_maps_rev(Conv_SubjOutputFolder,SubjID,MPM_OutputFolder,GlobalMPMFolder,ProtocolsFile,MPM_Template);