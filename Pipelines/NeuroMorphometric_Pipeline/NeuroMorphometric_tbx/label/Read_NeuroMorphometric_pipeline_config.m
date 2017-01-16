function [MPMInputFolder,LocalFolder,AtlasingServerFolder,ProtocolsFile,TPM_Template,TableFormat] = Read_NeuroMorphometric_pipeline_config(PipelineConfigFile) %#ok<*STOUT>

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, October 9th, 2015

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

MPMInputFolder = MPMInputFolder; %#ok 
LocalFolder = LocalFolder; %#ok
AtlasingServerFolder = AtlasingServerFolder; %#ok
ProtocolsFile = ProtocolsFile; %#ok
TPM_Template = TPM_Template; %#ok
TableFormat = TableFormat; %#ok

end