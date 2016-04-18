function Preproc_mpm_maps_extended_parallel_1echo(PipelineConfigFile)


%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, May 18th, 2014

if ~exist('PipelineConfigFile','var')
    PipelineConfigFile = which('Preproc_mpm_maps_pipeline_config.txt');
    if isempty(PipelineConfigFile)
        disp('pipeline config file does not exist ! Please specify ...');
        return;
    end;
end;

[InputFolder,ProtocolsFile,MPM_OutputFolder,GlobalMPMFolder,MPM_Template,ServerFolder,doUNICORT] = ...
                                                                           Read_Preproc_mpm_maps_config(PipelineConfigFile); %#ok<*STOUT>

if ~strcmp(InputFolder(end),filesep)
     InputFolder = [InputFolder,filesep];
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

%fid = fopen('D:\Users DATA\Users\lester\IDs94.txt');
%fid = fopen('D:\Users DATA\Users\lester\Sara_List_27.txt');
%T = textscan(fid,'%s');
%SubjectFolders = T{1};
SubjectFolders = {'PR00886_JC040979';'PR00888_SS020694';'PR00972_MZ010247';'PR00988_MS210563';'PR01099_BD310857'};  % For Elisabeth ...

Ns = length(SubjectFolders);  % Number of subjects ...
jm = findResource('scheduler','type','local'); %#ok
%PipelineFunction = 'Preproc_mpm_maps_extended'; % Preproc_mpm_maps_extended(Conv_SubjOutputFolder,SubjID,MPM_OutputFolder,GlobalMPMFolder,ProtocolsFile,MPM_Template,doUNICORT);
PipelineFunction = 'Preproc_mpm_maps_extended_fixed';

for i=1:Ns
    SubjID = SubjectFolders{i};
    JobID = ['job_',check_clean_IDs(SubjID)];
    SubjectFolder = [InputFolder,SubjectFolders{i},filesep];
    InputParametersF = horzcat({SubjectFolder},{SubjID},{MPM_OutputFolder},{GlobalMPMFolder}, ...
                               {ProtocolsFile},{MPM_Template},{ServerFolder},{doUNICORT}); %#ok
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