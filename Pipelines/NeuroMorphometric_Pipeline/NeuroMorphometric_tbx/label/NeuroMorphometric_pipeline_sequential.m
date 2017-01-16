function NeuroMorphometric_pipeline_sequential(PipelineConfigFile)


%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, May 18th, 2014

if ~exist('PipelineConfigFile','var')
    PipelineConfigFile = which('Neuromorphic_pipeline_config.txt');
    if isempty(PipelineConfigFile)
        disp('pipeline config file does not exist ! Please specify ...');
        return;
    end;
end;

[MPMInputFolder,LocalFolder,AtlasingServerFolder,ProtocolsFile,TPM_Template,TableFormat] = Read_NeuroMorphometric_pipeline_config(PipelineConfigFile); %#ok<*STOUT>

if ~strcmp(MPMInputFolder(end),filesep)
     MPMInputFolder = [MPMInputFolder,filesep];
end;
if ~strcmp(AtlasingServerFolder(end),filesep)
     AtlasingServerFolder = [AtlasingServerFolder,filesep];
end;
s = which('spm.m');
if  ~isempty(s)
    spm_path = fileparts(s);
else
    disp('Please add SPM toolbox in the path .... ');
    return;
end;
s = which([mfilename,'.m']);  % pipeline daemon path.
pipeline_daemon_path = fileparts(s);
path_dependencies = {spm_path,pipeline_daemon_path}; %#ok

SubjectFolders = getListofFolders(MPMInputFolder);
SubjectFolders_Atlasing = getListofFolders(AtlasingServerFolder);
ind = not(ismember(SubjectFolders,SubjectFolders_Atlasing));
SubjectFolders = SubjectFolders(ind);

%SubjectFolders ={'PR00101'};%{'PR01930_AF251153'}; %{'PR01925_AR121248'};
%SubjectFolders = SubjectFolders(1:floor(length(SubjectFolders)/2));

disp(['Number of Subjects to Run: ',num2str(length(SubjectFolders))]);

Ns = length(SubjectFolders);  % Number of subjects ...
%NeuroMorphometric_pipeline(SubjID,InputDataFolder,LocalFolder,AtlasingOutputFolder,ProtocolsFile,TableFormat,TPM_Template)
for i=1:Ns
    SubjID = SubjectFolders{i};
    NeuroMorphometric_pipeline(SubjID,MPMInputFolder,LocalFolder,AtlasingServerFolder,ProtocolsFile,TableFormat,TPM_Template);    
end;
                                            
end
