function DWI_pipeline_parallel(PipelineConfigFile)


%% Lester Melie-Garcia, David Slater
% LREN, CHUV. 
% Lausanne, July 10th, 2014
% Modified April 20th, 2015

% DWI_pipeline(DataFolder,OutputFolder,ProtocolsFile,SubjectID)

if ~exist('PipelineConfigFile','var')
    PipelineConfigFile = which('DWI_pipeline_config.txt');
    if isempty(PipelineConfigFile)
        disp('pipeline config file does not exist ! Please specify ...');
        return;
    end;
end;

%[InputFolder,ProtocolsFile,OutputFolder] = Read_DWI_pipeline_config(PipelineConfigFile); %#ok<*STOUT>
[InputFolder,ProtocolsFile,MPMDataFolder,MPRAGEFolder,OutputFolder] = Read_DWI_pipeline_config(PipelineConfigFile); %#ok<*STOUT>

if ~strcmpi(InputFolder(end),filesep)
    InputFolder = [InputFolder,filesep];    
end;
if ~strcmpi(OutputFolder(end),filesep)
    OutputFolder = [OutputFolder,filesep];    
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
s = which('DWIInit.m');
DWIpipeline_daemon_path = fileparts(s); 
xf = genpath(DWIpipeline_daemon_path); xf = strsplit(xf,';');
path_dependencies = horzcat(spm_path,xf); %#ok

ValidSubjectIDs = get_List_Diffusion_Studies(InputFolder,ProtocolsFile);

Subj_IDs_Done = getListofFolders(OutputFolder);
BlackList = {}; % Problems for converting Diffusion data ...
Subj_IDs_Done = vertcat(Subj_IDs_Done,BlackList);

ind = not(ismember(ValidSubjectIDs,Subj_IDs_Done));
Subj_IDs2Compute = ValidSubjectIDs(ind,:);

Ns = length(Subj_IDs2Compute);  % Number of subjects ...
jm = findResource('scheduler','type','local'); %#ok
PipelineFunction = 'DWI_pipeline';  % DWI_pipeline(InputFolder,MPMDataFolder,MPRAGEFolder,OutputFolder,ProtocolsFile,SubjectID)
for i=1:Ns
    SubjID = Subj_IDs2Compute{i};
    JobID = ['job_',check_clean_IDs(SubjID)];
    InputParametersF = horzcat({InputFolder},{MPMDataFolder},{MPRAGEFolder},{OutputFolder},{ProtocolsFile},{SubjID}); %#ok
    NameField = 'Name'; %#ok
    PathDependenciesField = 'PathDependencies'; %#ok
    createJob_cmd = [JobID,' = createJob(jm,NameField,SubjID);']; % create Job command
    setpathJob_cmd = ['set(',JobID,',','PathDependenciesField',',path_dependencies);']; % set spm path as dependency
    createTask_cmd = ['createTask(',JobID,',@',PipelineFunction,',0,','InputParametersF',');']; % create Task command
    submitJob_cmd = ['submit(',JobID,');']; % submit a job command
    eval(createJob_cmd); eval(setpathJob_cmd); eval(createTask_cmd); eval(submitJob_cmd);
end;
                                            
end

%% ======= Internal Functions ======= %%
function IDout = check_clean_IDs(IDin)

IDout= IDin(isstrprop(IDin,'alphanum'));

end