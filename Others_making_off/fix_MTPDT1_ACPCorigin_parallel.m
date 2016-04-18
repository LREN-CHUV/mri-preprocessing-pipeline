function fix_MTPDT1_ACPCorigin_parallel(InputFolder)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, July 8th, 2014

MTSequence = {'MT_Optimized'};
PDSequence = {'PD_weighted'};
T1Sequence = {'T1_weighted'};
if ~strcmpi(InputFolder(end),filesep)
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
Ns = length(SubjectFolders);  % Number of subjects ...
jm = findResource('scheduler','type','local'); %#ok
PipelineFunction = 'fix_MTPDT1_ACPCorigin'; % fix_MTPDT1_ACPCorigin(InputFolder,SubjID,MTSequence,PDSequence,T1Sequence)

for i=1:Ns
    SubjID = SubjectFolders{i};
    JobID = ['job_',check_clean_IDs(SubjID)];
    InputParametersF = horzcat({InputFolder},{SubjID},{MTSequence},{PDSequence},{T1Sequence}); %#ok
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
