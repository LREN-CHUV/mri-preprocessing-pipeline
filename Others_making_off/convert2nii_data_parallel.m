function convert2nii_data_parallel

InputFolder = 'D:\Users DATA\Users\lester\VBQ_Dicom_Data_All\';
OutputFolder = 'D:\Users DATA\Users\lester\DataNifti_All_New\';
if ~strcmp(OutputFolder(end),filesep)
    OutputFolder = [OutputFolder,filesep];
end;
if ~strcmp(InputFolder(end),filesep)
    InputFolder = [InputFolder,filesep];
end;
if ~exist(OutputFolder,'dir')
    mkdir(OutputFolder);
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
path_dependencies = {spm_path,pipeline_daemon_path};

ProtocolsFile = 'D:\Users DATA\Users\lester\Automatic_Computation\Protocols_definition.txt';
spm_jobman('initcfg');
SubjectFolders = getListofFolders(InputFolder);
Ns = length(SubjectFolders);  % Number of subjects ...
jm = findResource('scheduler','type','local'); %#ok<DFNDR>
PipelineFunction = 'DCM2NII_VBQ_rev';
for i=1:Ns
    SubjID = SubjectFolders{i};
    JobID = ['job_',check_clean_IDs(SubjID)];
    SubjectFolder = [InputFolder,SubjectFolders{i},filesep];
    InputParametersF = horzcat({SubjectFolder},{SubjID},{OutputFolder},{ProtocolsFile});
    NameField = 'Name'; 
    PathDependenciesField = 'PathDependencies';
    createJob_cmd = [JobID,' = createJob(jm,NameField,SubjID);']; % create Job command
    setpathJob_cmd = ['set(',JobID,',','PathDependenciesField',',path_dependencies);']; % set spm path as dependency
    createTask_cmd = ['createTask(',JobID,',@',PipelineFunction,',0,','InputParametersF',');']; % create Task command
    submitJob_cmd = ['submit(',JobID,');']; % submit a job command
    eval(createJob_cmd); eval(setpathJob_cmd); eval(createTask_cmd); eval(submitJob_cmd);
end;

end
%%
function IDout = check_clean_IDs(IDin)

IDout= IDin(isstrprop(IDin,'alphanum'));

end

