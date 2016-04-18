function DCM2NII_VBQ_rev_parallel01(DicomInputFolder,NiFti_OutputFolder)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, September 30th, 2014

if ~strcmp(NiFti_OutputFolder(end),filesep)
    NiFti_OutputFolder = [NiFti_OutputFolder,filesep];
end;
if ~strcmp(DicomInputFolder(end),filesep)
    DicomInputFolder = [DicomInputFolder,filesep];
end;

ProtocolsFile = 'Protocols_definition.txt';

Subj_IDs2Compute = getListofFolders(DicomInputFolder);

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

Ns = length(Subj_IDs2Compute);  % Number of subjects ...
jm = findResource('scheduler','type','local'); %#ok
PipelineFunction = 'DCM2NII_VBQ_rev';
% DCM2NII_VBQ_rev(SubjectFolder,SubjID,OutputFolder,ProtocolsFile)
for i=1:Ns
    SubjID = Subj_IDs2Compute{i};
    JobID = ['job_',check_clean_IDs(SubjID)];
    SubjectFolder = [DicomInputFolder,SubjID,filesep];
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