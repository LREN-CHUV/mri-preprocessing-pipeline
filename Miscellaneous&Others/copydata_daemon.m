function copydata_daemon(CopyDataConfigFile)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, May 18th, 2014

if ~exist('CopyDataConfigFile','var')
    CopyDataConfigFile = which('CopyData_config.txt');
    if isempty(CopyDataConfigFile)
        disp('Pipeline copy data config file does not exist ! Please specify ...');
        return;
    end;
end;

[DataFolder,OutputFolder,CheckTime,pdate,ProtocolsFile] = Read_copydata_config(CopyDataConfigFile);
if ~strcmp(DataFolder(end),filesep)
    DataFolder = [DataFolder,filesep];
end;
if ~strcmp(OutputFolder(end),filesep)
    OutputFolder = [OutputFolder,filesep];
end;
if ~exist(OutputFolder,'dir')    
    mkdir(OutputFolder);    
end;
Processed_ListFile = 'List_of_Copied_Data.txt';
fid = fopen(Processed_ListFile,'r');
copied_list = textscan(fid,'%s');
copied_list = copied_list{1};
fclose(fid);
while 1
    [SubjID,Data2CopyFolder] = Check4NewData_copy(DataFolder,copied_list,CheckTime,pdate,OutputFolder,ProtocolsFile);
    if ~isempty(SubjID)
        Subj_OutputFolder = [OutputFolder,SubjID,filesep];
        if exist(Subj_OutputFolder,'dir')
            out_list = getListofFolders(Subj_OutputFolder);
            in_list = getListofFolders(Data2CopyFolder);
            session_list = setdiff(in_list,out_list);
            if ~isempty(session_list)
                disp(['Copying data to be processed from subject : ',SubjID]);
                copyfile(Data2CopyFolder,Subj_OutputFolder);
                disp(['Copying data to be processed from subject : ',SubjID,' .... Done !']);
            end;
        else
            mkdir(Subj_OutputFolder);
            disp(['Copying data to be processed from subject : ',SubjID]);
            copyfile(Data2CopyFolder,Subj_OutputFolder);
            disp(['Copying data to be processed from subject : ',SubjID,' .... Done !']);
        end;
        copied_list = vertcat(copied_list,{SubjID}); %#ok
        fid = fopen(Processed_ListFile,'a+');
        fprintf(fid,'%s  \r',SubjID);
        fclose(fid);
    end;
end;

end

%% ======= Internal Functions ======= %%
function [Subj2copy,InputFolder] = Check4NewData_copy(DataFolder,copied_list,CheckTime,pdate,OutputFolder,ProtocolsFile)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, May 18th, 2014

if ~exist('CheckTime','var')
    CheckTime = 30; % in seconds
end;
[FolderNames,input_list] = getListofFolders_date(DataFolder,pdate);
[input_list,FolderNames] = Check_input_list(FolderNames,input_list,copied_list,DataFolder,OutputFolder);
[FolderNames,inds] = sort(FolderNames);  % Ordering by date, the older goes first ...
input_list = input_list(inds);
Ns = length(input_list);
Subj2copy = {}; i = 0;
while isempty(Subj2copy)&&(i<Ns)
    i = i + 1;
    InputFolder = [DataFolder,FolderNames{i},filesep,input_list{i}];
    is_folders_OK = Check4Folders(InputFolder,ProtocolsFile); % Checking for the right folders for MPMs computation
    if is_folders_OK
        [Nfiles1,Nbytes1] = getNumberFiles(InputFolder);
        pause(CheckTime); % Waiting some time ...
        [Nfiles2,Nbytes2] = getNumberFiles(InputFolder);
        if (Nbytes1==Nbytes2)&&(Nfiles1==Nfiles2)
            Subj2copy = input_list{i};
        end;
    end;
end;
if ~isempty(Subj2copy)
    disp('New data ready for copy: '); disp(Subj2copy);   
else
    disp('Do not exist new data available to copy ... ');
end;

end

%% 
%% [new_input_list,new_FolderNames] = Check_input_list(FolderNames,input_list,copied_list,DataFolder,OutputFolder)
function [new_input_list,new_FolderNames] = Check_input_list(FolderNames,input_list,copied_list,DataFolder,OutputFolder)

new_input_list = {};
ind = [];
for i=1:length(input_list)
    N  = sum(ismember(copied_list,input_list(i)));
    Ni = sum(ismember(input_list,input_list(i)));
    if N==0
        new_input_list = vertcat(new_input_list,input_list(i)); %#ok
        ind = [ind,i];  %#ok
    else
        if (Ni-N)>0
            InputFolder  = [DataFolder,FolderNames{i},filesep,input_list{i}];
            Sessions_in  = getListofFolders(InputFolder);
            Sessions_out = getListofFolders([OutputFolder,input_list{i}]);
            if ~isempty(setdiff(Sessions_in,Sessions_out))
                new_input_list = vertcat(new_input_list,input_list(i)); %#ok
                ind = [ind,i];  %#ok
            end;
        end;
    end;
end;
new_FolderNames = cellstr(char(FolderNames{ind}));

end

%% is_folders_OK = Check4Folders(InputFolder,ProtocolsFile)
function is_folders_OK = Check4Folders(InputFolder,ProtocolsFile)

if ~strcmp(InputFolder(end),filesep)
    InputFolder = [InputFolder,filesep];
end;
Sessions  = getListofFolders(InputFolder);
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

end

