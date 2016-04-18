function [DataFolder,OutputFolder,CheckTime,StartDate,ProtocolsFile] = Read_copydata_config(CopyDataConfigFile)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, June 4th, 2014

if ~exist(CopyDataConfigFile,'file')    
    disp('pipeline config file does not exist ! Please specify ...'); 
    return;
end;

fid = fopen(CopyDataConfigFile,'r');
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

DataFolder = DataFolder;  %#ok
OutputFolder = OutputFolder; %#ok
CheckTime = CheckTime; %#ok
StartDate = StartDate; %#ok
ProtocolsFile =  ProtocolsFile; %#ok

end