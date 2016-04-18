function fMRI_pipeline_sequential(PipelineConfigFile)


%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, October 25th, 2015

if ~exist('PipelineConfigFile','var')
    PipelineConfigFile = which('fMRI_PipelineConfigFile.txt');
    if isempty(PipelineConfigFile)
        disp('pipeline config file does not exist ! Please specify ...');
        return;
    end;
end;

[InputFolder,ProtocolsFile,OutputFolder,ServerFolder,TPMs,Mode,MinimumVolsNumber] = Read_fMRI_pipeline_config(PipelineConfigFile);

if ~strcmpi(InputFolder(end),filesep)
    InputFolder = [InputFolder,filesep];    
end;
if ~strcmpi(OutputFolder(end),filesep)
    OutputFolder = [OutputFolder,filesep];    
end;
if ~strcmpi(ServerFolder(end),filesep)
    ServerFolder = [ServerFolder,filesep];    
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

%SubjectFolders = getListofFolders(InputFolder);
%SubjectFolders = textread('D:\Users DATA\Users\lester\ZZZ_ZZZ_Sandrine\ListSubjectsRTeffectStudy_15-10-28.txt','%s');

SubjectFolders = {'PR01335_MJ170846'}; % 

Ns = length(SubjectFolders);  % Number of subjects ...

%fMRI_pipeline_main(DataFolder,OutputFolder,ProtocolsFile,SubjectID,Mode,MinimumVolsNumber,ServerFolder)
%% Iteratively ...
for i=1:Ns
    SubjID = SubjectFolders{i};
    fMRI_pipeline_main(InputFolder,OutputFolder,ProtocolsFile,SubjID,TPMs,Mode,MinimumVolsNumber,ServerFolder);
end;

                                            
end

%% ======= Internal Functions ======= %%
function IDout = check_clean_IDs(IDin)

IDout= IDin(isstrprop(IDin,'alphanum'));

end