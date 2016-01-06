clear;
PipelineConfigFile = 'D:\Users DATA\Users\lester\ZZZ_Anne\Preproc_mpm_maps_pipeline_config_Anne.txt';
SubjectListFileName = 'D:\Users DATA\Users\lester\ZZZ_Anne\Subj4SyntT1w_prisma.txt';
%SubjectListFileName = 'D:\Users DATA\Users\lester\ZZZ_Anne\Subj4SyntT1w_rest.txt';
%IDs_problem = {'B0949-70-3';'B2011-01-0';'B2012-01-0'};
Preproc_mpm_maps_extended_parallel_based_on_subjectlists(SubjectListFileName,PipelineConfigFile);
