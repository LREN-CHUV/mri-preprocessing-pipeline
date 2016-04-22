function [DataFolderName,ProtocolsFile,PipelineParmsConfigFile,MPM_OutputFolder,ServerFolder] = Read_Preproc_mpm_maps_paths(PathsPipelineConfigFile) %#ok<*STOUT>

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, July 8th, 2014

if ~exist(PathsPipelineConfigFile,'file')    
    disp('pipeline config file does not exist ! Please specify ...'); 
    return;
end;

fid = fopen(PathsPipelineConfigFile,'r');
i=0;
while ~feof(fid)
   i = i+1;
   jline = fgetl(fid);
   ComandLines{i} = deblank(jline); %#ok
end; 
fclose(fid);

for i=1:length(ComandLines)
    eval(ComandLines{i});    
end;

DataFolderName = DataFolderName; %#ok
ProtocolsFile = ProtocolsFile; %#ok
PipelineParmsConfigFile =  PipelineParmsConfigFile; %#ok
MPM_OutputFolder = MPM_OutputFolder; %#ok 
ServerFolder = ServerFolder; %#ok

end