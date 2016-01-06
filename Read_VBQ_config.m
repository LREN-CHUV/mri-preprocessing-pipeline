function InputParameters = Read_VBQ_config(VBQConfigFile)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, May 21st, 2014

if ~exist(VBQConfigFile,'file')    
    disp('VBQ config file does not exist ! Please specify ...'); 
    return;
end;

fid = fopen(VBQConfigFile);
ComandLines = textscan(fid,'%s');
ComandLines = ComandLines{1};
fclose(fid);

for i=1:length(ComandLines)
    eval(ComandLines{i});    
end;

InputParameters = {ConvOutputFolder,MPM_OutputFolder,GlobalMPMFolder,ProtocolsFile};

end