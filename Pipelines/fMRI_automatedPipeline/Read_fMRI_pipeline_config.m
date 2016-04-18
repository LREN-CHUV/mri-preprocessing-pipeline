function [InputFolder,ProtocolsFile,OutputFolder,ServerFolder,TPMs,Mode,MinimumVolsNumber] = Read_fMRI_pipeline_config(PipelineConfigFile)

%% Lester Melie-Garcia, Sandrine Muller, Renaud Marquis
% LREN, CHUV. 
% Lausanne, October 25th, 2015

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
ServerFolder = ServerFolder; %#ok
TPMs = TPMs; %#ok
Mode = Mode; %#ok
MinimumVolsNumber = MinimumVolsNumber; %#ok

end
