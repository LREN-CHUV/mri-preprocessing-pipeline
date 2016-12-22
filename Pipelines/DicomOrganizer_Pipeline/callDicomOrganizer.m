PathsPipelineConfigFile = 'dicomOrganizer_paths.txt';
PipelineConfigFile = 'dicomOrganizer_config.txt';

SubjectID = '3130';

[InputFolder,OutputFolder] = Read_dicomOrganizer_paths(PathsPipelineConfigFile);
DataStructure = Read_dicomOrganizer_config(PipelineConfigFile);

dicomOrganizer(InputFolder,OutputFolder,SubjectID,DataStructure);