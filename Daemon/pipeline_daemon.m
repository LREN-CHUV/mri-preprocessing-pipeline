function pipeline_daemon(PipelineConfigFile)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, May 18th, 2014

%% VBQ_pipeline(ConvOutputFolder,MPM_OutputFolder,GlobalMPMFolder,ProtocolsFile,SubjectFolder,SubjID)
%%  ===========   Main  Program  ===========   %%
if ~exist('PipelineConfigFile','var')
    PipelineConfigFile = which('pipeline_config.txt');
    if isempty(PipelineConfigFile)
        disp('pipeline config file does not exist ! Please specify ...');
        return;
    end;
end;
CopyDataConfigFile = which('CopyData_config.txt');
if isempty(CopyDataConfigFile)
    disp('Data Copying config file does not exist ! Please specify ...');
    return;
end;
[DataFolder,PipelineFunction,InputParameters,CheckTime,ProtocolsFile,Ns2run] = Read_pipeline_config(PipelineConfigFile);

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
if ~strcmpi(DataFolder(end),filesep)
    DataFolder = [DataFolder,filesep];    
end;
if ~exist('CheckTime','var')
    CheckTime = 30; % in seconds
end;
Processed_ListFile = 'List_of_Processed_Data.txt';
fid = fopen(Processed_ListFile,'r');
finished_list = textscan(fid,'%s');
finished_list = finished_list{1};
fclose(fid);
% --- Data copying process ---%
jm = findResource('scheduler','type','local');
copydata_job = createJob(jm,'Name','copydata');  % Creating job for copying data to local folder from dicom server.
set(copydata_job,'PathDependencies',path_dependencies);
createTask(copydata_job,@copydata_daemon,0,{CopyDataConfigFile});
submit(copydata_job);
running_list = {};
while 1
    list2run = Check4NewData(DataFolder,finished_list,running_list,CheckTime,ProtocolsFile,Ns2run);
    %  Starting processing pipeline in parallel along datasets
    for i=1:length(list2run)
        SubjID = list2run{i};
        JobID = ['job_',check_clean_IDs(SubjID)];
        SubjectFolder = [DataFolder,SubjID,filesep];
        InputParametersF = horzcat(InputParameters,{SubjectFolder,SubjID});  %#ok       
        NameField = 'Name'; %#ok
        PathDependenciesField = 'PathDependencies'; %#ok
        createJob_cmd = [JobID,' = createJob(jm,NameField,SubjID);']; % create Job command
        setpathJob_cmd = ['set(',JobID,',','PathDependenciesField',',path_dependencies);']; % set spm path as dependency
        createTask_cmd = ['createTask(',JobID,',@',PipelineFunction,',0,','InputParametersF',');']; % create Task command
        submitJob_cmd = ['submit(',JobID,');']; % submit a job command
        eval(createJob_cmd); eval(setpathJob_cmd); eval(createTask_cmd); eval(submitJob_cmd);
    end;
    running_list = vertcat(running_list,list2run); %#ok 
    %  Checking for finished jobs ...
    finished_jobs = findJob(jm,'State','finished');
    justfinished_list = cell(length(finished_jobs),1);
    fid = fopen(Processed_ListFile,'a+');
    for i=1:length(finished_jobs)
        justfinished_list{i} = finished_jobs(i).Name;
        fprintf(fid,'%s  \r',justfinished_list{i});
    end;
    fclose(fid);
    if ~isempty(finished_jobs)
        destroy(finished_jobs);
    end;
    for i=1:length(finished_jobs)
        eval(['clear ','job_',check_clean_IDs(justfinished_list{i})]);
    end;
    finished_list = vertcat(finished_list,justfinished_list); %#ok 
    running_list = setdiff(running_list,justfinished_list);
    % To know which data is running ...
    running_jobs = findJob(jm,'State','running');
    running_jobs_list = cell(length(running_jobs),1);
    for i=1:length(running_jobs)
        running_jobs_list{i} = running_jobs(i).Name;
    end;
    if ~isempty(running_jobs_list)
        disp('Data running: '); disp(running_jobs_list');
    else
        disp('Do not exist data running ... ');
    end;
    pause(30);
end;

end

%% ======= Internal Functions ======= %%
function list2run = Check4NewData(DataFolder,finished_list,running_list,CheckTime,ProtocolsFile,Ns2run)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, May 18th, 2014

if ~strcmp(DataFolder(end),filesep)
    DataFolder = [DataFolder,filesep];
end;
if ~exist('CheckTime','var')
    CheckTime = 30; % in seconds
end;
input_list = getListofFolders(DataFolder);
list2run = {};
if ~isempty(input_list)
    input_list = setdiff(input_list,vertcat(finished_list,running_list));
    Ns = length(input_list);
    i = 0;
    while isempty(list2run)&&(i<Ns)
        i = i + 1;
        InputFolder = [DataFolder,input_list{i}];
        is_folders_OK = Check4Folders_VBQ(InputFolder,ProtocolsFile,Ns2run); % Checking for the right folders for MPMs computation
        if is_folders_OK
            [Nfiles1,Nbytes1] = getNumberFiles(InputFolder);
            pause(CheckTime); % Waiting some time ...
            [Nfiles2,Nbytes2] = getNumberFiles(InputFolder);
            if (Nbytes1==Nbytes2)&&(Nfiles1==Nfiles2)
                list2run = input_list(i);
            end;
        end;
    end;    
end;
if ~isempty(list2run)
    disp('New data ready for processing: '); disp(list2run');    
else
    disp('Do not exist new data available for processing ... ');
end;

end
%% is_folders_OK = Check4Folders_VBQ(InputFolder,ProtocolsFile,Ns2run)
function is_folders_OK = Check4Folders_VBQ(InputFolder,ProtocolsFile,Ns2run)

if ~strcmp(InputFolder(end),filesep)
    InputFolder = [InputFolder,filesep];
end;
Sessions  = getListofFolders(InputFolder);

Nrepet = 0;
if (length(Sessions)==1)    % Case when number of sessions is equal to one. Checking if number of repetitions is bigger than one.
    Nprot = get_Number_Prot(ProtocolsFile,[InputFolder,Sessions{1},filesep]); % Number of protocols
    if Nprot>0
        Nrepet = zeros(Nprot,1);
        for j=1:Nprot
            Nrepet(j) = get_Number_Rep(ProtocolsFile,[InputFolder,Sessions{1},filesep],j);
        end;
        Nrepet = min(Nrepet);
    end;
end;

if (length(Sessions)==Ns2run)||(isempty(Ns2run))||(Nrepet>1)
    B0_p = cellstr(get_protocol_names(ProtocolsFile,'__MPM__','[fieldmap]'));
    B1_p = cellstr(get_protocol_names(ProtocolsFile,'__MPM__','[B1]'));
    MT_p = cellstr(get_protocol_names(ProtocolsFile,'__MPM__','[MT]'));
    PD_p = cellstr(get_protocol_names(ProtocolsFile,'__MPM__','[PD]'));
    T1_p = cellstr(get_protocol_names(ProtocolsFile,'__MPM__','[T1]'));
    
    Np = length(T1_p);
    Ns = length(Sessions);
    is_folders_OK = zeros(Ns,1);
    for i=1:Ns
        for j=1:Np
            t = exist([InputFolder,Sessions{i},filesep,B0_p{j}],'dir')&&exist([InputFolder,Sessions{i},filesep,B1_p{j}],'dir')&& ...
                exist([InputFolder,Sessions{i},filesep,MT_p{j}],'dir')&&exist([InputFolder,Sessions{i},filesep,PD_p{j}],'dir')&& ...
                exist([InputFolder,Sessions{i},filesep,T1_p{j}],'dir');
            is_folders_OK(i) = is_folders_OK(i) + t;
        end;
    end;    
    is_folders_OK = logical(prod(is_folders_OK));
else
    is_folders_OK = false;
end;

end

%% Nrep = get_Number_Rep(ProtocolsFile,DataFolder,j)
function Nrep = get_Number_Rep(ProtocolsFile,DataFolder,j)
% Note: MT, PD, T1 protocols have two folders per repetition, the 1st have magnitude images, the 2nd phase images.
cprotocol = get_section_protocol(ProtocolsFile,'__MPM__','[MT]',DataFolder);
Nr_MT = length(getListofFolders([DataFolder,cprotocol{j}]));
cprotocol = get_section_protocol(ProtocolsFile,'__MPM__','[PD]',DataFolder);
Nr_PD = length(getListofFolders([DataFolder,cprotocol{j}]));
cprotocol = get_section_protocol(ProtocolsFile,'__MPM__','[T1]',DataFolder);
Nr_T1 = length(getListofFolders([DataFolder,cprotocol{j}]));
Nrep = min([Nr_MT,Nr_PD,Nr_T1]/2);

end
%% [cprotocol,Np] = get_section_protocol(ProtocolsFile,ProcessingSTep,MRIModality,DataFolder)
function [cprotocol,Np] = get_section_protocol(ProtocolsFile,ProcessingSTep,MRIModality,DataFolder)

pname = get_protocol_names(ProtocolsFile,ProcessingSTep,MRIModality); % protocol name ..
pname = cellstr(pname);
subj_protocols = getListofFolders(DataFolder);
ind = ismember(pname,subj_protocols);
cprotocol = pname(ind);
Np = length(cprotocol);
%cprotocol = char(pname(ind));
%Np = size(cprotocol,1);
end

%% Nprot = get_Number_Prot(ProtocolsFile,DataFolder)
function Nprot = get_Number_Prot(ProtocolsFile,DataFolder)

[~,Np_MT] = get_section_protocol(ProtocolsFile,'__MPM__','[MT]',DataFolder);
[~,Np_PD] = get_section_protocol(ProtocolsFile,'__MPM__','[PD]',DataFolder);
[~,Np_T1] = get_section_protocol(ProtocolsFile,'__MPM__','[T1]',DataFolder);
Nprot = min([Np_MT,Np_PD,Np_T1]);

end

%% 
function IDout = check_clean_IDs(IDin)

IDout= IDin(isstrprop(IDin,'alphanum'));

end

% function list2run = Check4NewData(DataFolder,finished_list,running_list,CheckTime)
% 
% %% Lester Melie-Garcia
% % LREN, CHUV. 
% % Lausanne, May 18th, 2014
% 
% if ~exist('CheckTime','var')
%     CheckTime = 30; % in seconds
% end;
% input_list = getListofFolders(DataFolder);
% if ~isempty(input_list)
%     input_list = setdiff(input_list,vertcat(finished_list,running_list));
%     %Ns = length(input_list);
%     Ns = 1;  %  I'm taking here one by one ...
%     Nfiles1 = zeros(Ns,1); Nfiles2 = zeros(Ns,1);
%     Nbytes1 = zeros(Ns,1); Nbytes2 = zeros(Ns,1);
%     for i=1:Ns
%         InputFolder = [DataFolder,input_list{i}];
%         [Nfiles1(i),Nbytes1(i)] = getNumberFiles(InputFolder);
%     end;
%     pause(CheckTime);
%     for i=1:Ns
%         InputFolder = [DataFolder,input_list{i}];
%         [Nfiles2(i),Nbytes2(i)] = getNumberFiles(InputFolder);
%     end    
%     list2run = input_list(Nbytes1==Nbytes2);
% else
%     list2run = {};
% end;
% if ~isempty(list2run)
%     disp('New data ready for processing: '); disp(list2run');    
% else
%     disp('Do not exist new data available for processing ... ');
% end;
% 
% end
