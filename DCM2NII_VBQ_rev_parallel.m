function DCM2NII_VBQ_rev_parallel(NiFti_OutputFolder)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, September 30th, 2014

if ~exist('NiFti_OutputFolder','var')
    %NiFti_OutputFolder = 'M:\CRN\LREN\SHARE\VBQ_Output_All\DataNifti_All\';
    NiFti_OutputFolder ='D:\Users DATA\Users\lester\ZZZ_Nifti_Data_MPMs\';
end;
if ~strcmp(NiFti_OutputFolder(end),filesep)
    NiFti_OutputFolder = [NiFti_OutputFolder,filesep];
end;

ProtocolsFile = 'Protocols_definition.txt';
%ServerDataFolder = 'K:\IRMMP16\prisma\2014\';
%ServerDataFolder = 'Z:\IRMMP16\prisma\2014\';
ServerDataFolder = 'K:\NLG_LREN\IRMMP16\prisma\2014';
Subj_IDs = make_list_MRI_studies01(ServerDataFolder);

Subj_IDs_MPM = getListofFolders('M:\CRN\LREN\SHARE\VBQ_Output_All\DataNifti_All');
BlackList = {'PR00298_BD290679';'PR00303_LL030379';'PR00306_LK030379'}; % Problems for converting Diffusion data ...
Subj_IDs_MPM = vertcat(Subj_IDs_MPM,BlackList);

ind = not(ismember(Subj_IDs(:,1),Subj_IDs_MPM));
Subj_IDs2Compute = Subj_IDs(ind,:);

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

SubjectFolders = Subj_IDs2Compute(:,1);
Ns = length(SubjectFolders);  % Number of subjects ...
jm = findResource('scheduler','type','local'); %#ok
PipelineFunction = 'DCM2NII_VBQ_rev';
% DCM2NII_VBQ_rev(SubjectFolder,SubjID,OutputFolder,ProtocolsFile)
for i=1:Ns
    SubjID = SubjectFolders{i};
    JobID = ['job_',check_clean_IDs(SubjID)];
    SubjectFolder = Subj_IDs2Compute{i,2};
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