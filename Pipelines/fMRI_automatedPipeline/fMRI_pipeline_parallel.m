function fMRI_pipeline_parallel(PipelineConfigFile)


%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, October 25th, 2015

if ~exist('PipelineConfigFile','var')
    PipelineConfigFile = which('fMRI_PipelineConfigFile.txt');
    if isempty(PipelineConfigFile)
        disp('pipeline config file does not exist ! Please specify ...');
        return;
    end;
end;

[InputFolder,ProtocolsFile,OutputFolder,ServerFolder,TPMs,Mode,MinimumVolsNumber] = Read_fMRI_pipeline_config(PipelineConfigFile);

if ~strcmpi(InputFolder(end),filesep)
    InputFolder = [InputFolder,filesep];    
end;
if ~strcmpi(OutputFolder(end),filesep)
    OutputFolder = [OutputFolder,filesep];    
end;
if ~strcmpi(ServerFolder(end),filesep)
    ServerFolder = [ServerFolder,filesep];    
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

%SubjectFolders = getListofFolders(InputFolder);
%SubjectFolders = textread('D:\Users DATA\Users\lester\ZZZ_ZZZ_Sandrine\ListSubjectsRTeffectStudy_15-10-28.txt','%s');
%SubjectFolders = {'PR01209_AT060487';'PR01214_NR030194'};
% SubjectFolders = {'PR01275_JD191191'};
SubjectFolders = {'PR01102_ILL030379';'PR01335_MJ170846';'PR01345_DR240466';'PR01360_JB060340';'PR01378_MC220359'};

Ns = length(SubjectFolders);  % Number of subjects ...

%fMRI_pipeline_main(DataFolder,OutputFolder,ProtocolsFile,SubjectID,Mode,MinimumVolsNumber,ServerFolder)
%% Iteratively ...
% for i=1:Ns
%     SubjID = SubjectFolders{i};
%     fMRI_pipeline_main(InputFolder,OutputFolder,ProtocolsFile,SubjID,TPMs,Mode,MinimumVolsNumber,ServerFolder);
% end;
%% In parallel ...
jm = findResource('scheduler','type','local'); %#ok
PipelineFunction = 'fMRI_pipeline_main';  %
for i=1:Ns
    SubjID = SubjectFolders{i};
    JobID = ['job_',check_clean_IDs(SubjID)];
    InputParametersF = horzcat({InputFolder},{OutputFolder},{ProtocolsFile},{SubjID},{TPMs},{Mode},{MinimumVolsNumber},{ServerFolder}); %#ok
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