clear; clc;
%SubjSessionFolder = 'D:\ZZZ_test\fMRI_Sandrine_Pipeline\PR01146_LG280385\01\';
SubjSessionFolder = 'D:\Users DATA\Users\lester\ZZZ_ZZZ_Sandrine\Input_Folder\PR01146_LG280385\01';
grefieldSequenceName = 'gre_field_mapping_1acq_rl_64ch';
StructSequenceName = 'MPRAGE_P3';
EPISequenceName = 'al_mepi2d_v2f_3mm';
volnum = 80; % min number of scans to consider as a "correct" fMRI seq
dummyscans = 5;
Mode = 'interactive';
pmDefaultFilePath = 'D:\Users DATA\Users\lester\Automatic_Computation\Pipelines\fMRI_automatedPipeline\FieldMap_defaults\fieldmap_defaults_SVN_2015-09-07\pm_defaults_Prisma_3mm.m';

itwasprocessed = fMRI_preprocessing(SubjSessionFolder,Mode,volnum,dummyscans,grefieldSequenceName, ...
                                    StructSequenceName,EPISequenceName,pmDefaultFilePath);

% [Sessions,uniqueRes,uniqueResIdx,FileExt] = PrepareFiles(SubjSessionFolder,volnum,dummyscans,grefieldSequenceName, ...
%                                                          StructSequenceName,EPISequenceName, pmDefaultFilePath)


%%
% NIIs_folder = 'D:\ZZZ_test\fMRI_Sandrine_Pipeline\PR01146_LG280385\01';
% Mode = 'interactive';
% volnum = 80; % min number of scans to consider as a "correct" fMRI seq
% dummyscans = 5;
% seqNamegrefield = 'gre_field_mapping_1acq_rl_64ch';
% seqNameStruct = 'MPRAGE_P3';
% seqNameEPI= 'al_mepi2d_v2f_3mm';
% pmDefaultFilePath = 'C:\DATA\SVN\sanmulle\Code\SPMbasics\fMRI_automatedPipeline\pm_defaults_Prisma_3mm.m';
% [Sessions uniqueRes uniqueResIdx FileExt] = PrepareFiles_old(NIIs_folder,volnum,dummyscans,seqNamegrefield,seqNameStruct,seqNameEPI, pmDefaultFilePath);