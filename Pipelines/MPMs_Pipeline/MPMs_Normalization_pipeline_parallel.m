function MPMs_Normalization_pipeline_parallel(InputFolder,TemplateFile,FWHMsmooth)

%% Lester Melie-Garcia
% LREN, CHUV
% Lausanne, February 8th 2016

if ~exist('InputFolder','var')    
    InputFolder = 'D:\Users DATA\Users\lester\Network_Tissue_Properties_Study\';
else
    if isempty(InputFolder)
        InputFolder = 'D:\Users DATA\Users\lester\Network_Tissue_Properties_Study\';
    end;
end;
if ~exist('TemplateFile','var')
    TemplateFile = 'D:\Users DATA\Users\lester\Network_Tissue_Properties_Study_Template\Template_6.nii';
else
    if isempty(TemplateFile)
        TemplateFile = 'D:\Users DATA\Users\lester\Network_Tissue_Properties_Study_Template\Template_6.nii';
    end;
end;
if ~exist('FWHMsmooth','var')    
    FWHMsmooth = 6;
else
    if isempty(FWHMsmooth)
        FWHMsmooth = 6;
    end;
end;

SubjectFolders = getListofFolders(InputFolder);
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

Ns = length(SubjectFolders);  % Number of subjects ...

jm = findResource('scheduler','type','local'); %#ok
PipelineFunction = 'MPMs_Normalization';  % MPMs_Normalization(InputFolder,Template,FWHMsmooth)
for i=1:Ns
    SubjID = SubjectFolders{i};
    SubjectInputFolder = [InputFolder,SubjID];
    JobID = ['job_',check_clean_IDs(SubjID)];
    InputParametersF = horzcat({SubjectInputFolder},{TemplateFile},{FWHMsmooth}); %#ok
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