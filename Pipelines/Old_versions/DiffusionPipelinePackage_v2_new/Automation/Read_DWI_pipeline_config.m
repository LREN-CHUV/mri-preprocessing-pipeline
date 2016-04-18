function [InputFolder,ProtocolsFile,MPMDataFolder,MPRAGEFolder,OutputFolder] = Read_DWI_pipeline_config(PipelineConfigFile)

%% Lester Melie-Garcia, David Slater
% LREN, CHUV. 
% Lausanne, July 10th, 2014
% Modified April 20th, 2015

if ~exist(PipelineConfigFile,'file')    
    disp('pipeline config file does not exist ! Please specify ...'); 
    return;
end;

fid = fopen(PipelineConfigFile,'r');
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

InputFolder = InputFolder; %#ok
ProtocolsFile = ProtocolsFile; %#ok
OutputFolder = OutputFolder; %#ok
MPMDataFolder = MPMDataFolder; %#ok
MPRAGEFolder = MPRAGEFolder; %#ok

end
