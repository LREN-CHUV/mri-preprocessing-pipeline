function [DataFolderName,PipelineFunction,InputParameters,CheckTime,ProtocolsFile,Ns2run] = Read_pipeline_config(PipelineConfigFile) %#ok<*STOUT>

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, May 31st, 2014

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

%VBQ_pipeline(ConvOutputFolder,MPM_OutputFolder,GlobalMPMFolder,ProtocolsFile,SubjectFolder,SubjID)
InputParameters = {ConvOutputFolder,ServerFolder,MPM_OutputFolder,GlobalMPMFolder,MPM_Template,ProtocolsFile};
DataFolderName = DataFolderName; %#ok
PipelineFunction = PipelineFunction; %#ok
CheckTime = CheckTime; %#ok
ProtocolsFile = ProtocolsFile; %#ok
Ns2run = Number_of_Sessions2StartRuning;

end