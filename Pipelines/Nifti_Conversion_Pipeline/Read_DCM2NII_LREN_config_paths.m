function [ServerDataFolder,ProtocolsFile,NiFti_Local_OutputFolder,NiFti_Server_OutputFolder] = Read_DCM2NII_LREN_config_paths(PathsPipelineConfigFile) %#ok<*STOUT>

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, May 9th, 2016

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

ServerDataFolder = ServerDataFolder; %#ok
ProtocolsFile = ProtocolsFile; %#ok
NiFti_Local_OutputFolder = NiFti_Local_OutputFolder; %#ok
NiFti_Server_OutputFolder = NiFti_Server_OutputFolder; %#ok

end