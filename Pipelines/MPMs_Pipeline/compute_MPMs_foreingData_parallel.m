function compute_MPMs_foreingData_parallel(InputFolder)

%% Lester Melie Garcia
% LREN, CHUV
% February 4th 2016

if ~exist('InputFolder','dir')
   InputFolder = 'M:\CRN\LREN\SHARE\4Lester\data_MRI\';
end;
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

SubjectFolders = getListofFolders(InputFolder);
disp(['Number of Subjects to Run: ',num2str(length(SubjectFolders))]);

OutputFolder = 'D:\Users DATA\Users\lester\ZZZ_Bogdan_again';
MTSubDirLabel = 'MT';
PDSubDirLabel = 'PD';
T1SubDirLabel = 'T1';
doUNICORT = 'true';
MPM_Template = 'nwTPM_sl3.nii';

Ns = length(SubjectFolders);  % Number of subjects ...
jm = findResource('scheduler','type','local'); %#ok
%compute_MPMs_foreingData(SubjectFolder,SubjID,OutputFolder,MTSubDirLabel,PDSubDirLabel,T1SubDirLabel,MPM_Template,doUNICORT)
PipelineFunction = 'compute_MPMs_foreingData';
for i=1:Ns
    SubjID = SubjectFolders{i};
    SubjectFolderIn = [InputFolder,SubjectFolders{i},filesep];
    JobID = ['job_',check_clean_IDs(SubjID)];
    InputParametersF = horzcat({SubjectFolderIn},{SubjID},{OutputFolder},{MTSubDirLabel},{PDSubDirLabel},{T1SubDirLabel},{MPM_Template},{doUNICORT}); %#ok
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