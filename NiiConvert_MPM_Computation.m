function NiiConvert_MPM_Computation(SubjectFolder,SubjID,NiFti_OutputFolder,NiFti_Server_OutputFolder,ProtocolsFile,OutputFolder,GlobalMPMFolder,MPM_Template,ServerFolder,doUNICORT)


%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, May 18th, 2014

Subj_NiiFolder = DCM2NII_VBQ_rev(SubjectFolder,SubjID,NiFti_OutputFolder,ProtocolsFile);
if ~strcmp(Subj_NiiFolder(end),filesep)
    Subj_NiiFolder = [Subj_NiiFolder,filesep];
end;
if ~strcmp(NiFti_Server_OutputFolder(end),filesep)
    NiFti_Server_OutputFolder = [NiFti_Server_OutputFolder,filesep];
end;
mkdir(NiFti_Server_OutputFolder,SubjID);
copyfile(Subj_NiiFolder,[NiFti_Server_OutputFolder,SubjID]);
%[Subj_OutputFolder,SubjOutMPMFolder] = Preproc_mpm_maps_extended_fixed(Subj_NiiFolder,SubjID,OutputFolder,GlobalMPMFolder,ProtocolsFile,MPM_Template,ServerFolder,doUNICORT)
Preproc_mpm_maps_extended_fixed(Subj_NiiFolder,SubjID,OutputFolder,GlobalMPMFolder,ProtocolsFile,MPM_Template,ServerFolder,doUNICORT);

end