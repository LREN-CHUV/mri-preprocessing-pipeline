function Segmentation_parallel(InputFolder,OutputFolder)


%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, October 21st, 2014

if ~strcmp(InputFolder(end),filesep)
    InputFolder = [InputFolder,filesep];
end;
if ~strcmp(OutputFolder(end),filesep)
    OutputFolder = [OutputFolder,filesep];
end;

Subj_IDs2Compute = pickfiles(InputFolder(1:end-1),{'.nii'});

s = which('spm.m');
if  ~isempty(s)
    spm_path = fileparts(s);
else
    disp('Please add SPM toolbox in the path .... ');
    return;
end;
s = which([mfilename,'.m']);  % pipeline daemon path.
pipeline_path = fileparts(s); 
path_dependencies = {spm_path,pipeline_path}; %#ok

Ns = length(Subj_IDs2Compute);  % Number of subjects ...
jm = findResource('scheduler','type','local'); %#ok
PipelineFunction = 'SubjectSegmentation';

for i=1:Ns
    [~,SubjID] = fileparts(Subj_IDs2Compute(i,:));
    JobID = ['job_',check_clean_IDs(SubjID)];
    SubjectFolder = Subj_IDs2Compute(i,:);
    InputParametersF = horzcat({SubjectFolder},{OutputFolder}); %#ok
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