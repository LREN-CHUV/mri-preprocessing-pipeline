function MPRAGE_synth_parallel(InputDataFolder,SubjectList)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, May 8th, 2015

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

Ns = length(SubjectList);  % Number of subjects ...
jm = findResource('scheduler','type','local'); %#ok
PipelineFunction = 'MPRAGE_synth'; % MPRAGE_synth(InputDataFolder,SubjectID)
for i=1:Ns
    SubjID = SubjectList{i};
    JobID = ['job_',check_clean_IDs(SubjID)];
    InputParametersF = horzcat({InputDataFolder},{SubjID}); %#ok
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