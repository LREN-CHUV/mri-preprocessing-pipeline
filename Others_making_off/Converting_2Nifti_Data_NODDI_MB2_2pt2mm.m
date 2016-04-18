ServerDataFolder = '\\filearc\data\CRN\LREN\IRMMP16\prisma\2014\';
Subj_IDs = make_list_MRI_studies_NODDI_MB2_2pt2mm(ServerDataFolder);
NiFti_OutputFolder='D:\Users DATA\Users\lester\ZZZ_NODDI_MB2_2pt2mm\';
ProtocolsFile='D:\Users DATA\Users\lester\Automatic_Computation\Protocols_definition.txt';

for i=1:size(Subj_IDs,1)    
    SubjID = Subj_IDs{i,1};
    SubjectFolder = Subj_IDs{i,2};   
    Subj_NiiFolder = DCM2NII_VBQ_rev_diffusion(SubjectFolder,SubjID,NiFti_OutputFolder,ProtocolsFile);
end;



