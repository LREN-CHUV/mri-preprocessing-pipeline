function DCM2NII_VBQ_rev_parallel_US(NiFti_OutputFolder)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, February 19th, 2014

if ~exist('NiFti_OutputFolder','var')
    %NiFti_OutputFolder = 'M:\CRN\LREN\SHARE\VBQ_Output_All\DataNifti_All\';
    NiFti_OutputFolder ='D:\Users DATA\Users\lester\US_dataset_Nifti_FCAP\';
    %NiFti_OutputFolder ='D:\Users DATA\Users\lester\US_dataset_Nifti_SCAP\';
end;
if ~strcmp(NiFti_OutputFolder(end),filesep)
    NiFti_OutputFolder = [NiFti_OutputFolder,filesep];
end;

ProtocolsFile = 'D:\Users DATA\Users\lester\Automatic_Computation\Protocols_definition_US_Data.txt';
%ServerDataFolder = 'K:\IRMMP16\prisma\2014\';
ServerDataFolder = 'D:\Users DATA\Users\lester\US_dataset_unzipped\';

Subj_IDs = getListofFolders(ServerDataFolder);
t = [];
for i=1:length(Subj_IDs)
    %if ~isempty(strfind(Subj_IDs{i},'SCAP'));
    if ~isempty(strfind(Subj_IDs{i},'FCAP'));
        t = [t,i];
    end;
end;

Subj_IDs = Subj_IDs(t);  % Taking only Anatomical studies ...

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

Ns = length(Subj_IDs);  % Number of subjects ...
jm = findResource('scheduler','type','local'); %#ok
PipelineFunction = 'DCM2NII_VBQ_rev_US';
% DCM2NII_VBQ_rev_US(SubjectFolder,SubjID,OutputFolder,ProtocolsFile)
for i=1:Ns
    SubjID = Subj_IDs{i};
    JobID = ['job_',check_clean_IDs(SubjID)];
    SubjectFolder = [ServerDataFolder,SubjID];
    InputParametersF = horzcat({SubjectFolder},{SubjID},{NiFti_OutputFolder},{ProtocolsFile}); %#ok
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