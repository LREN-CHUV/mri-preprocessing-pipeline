function Opts = Read_fMRI_config(PipelineConfigFile) %#ok<*STOUT>

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, July 8th, 2014

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

Opts.MinVolNum = MinVolNum; 
Opts.RunDARTEL = RunDARTEL; 
Opts.Mode = Mode; 
Opts.TokenEPI = TokenEPI; 
Opts.RegisterToMean = RegisterToMean; 
Opts.FWHM = FWHM; 
Opts.DetectResolution = DetectResolution; 
Opts.StructMT = StructMT; 
Opts.StructMPRAGE = StructMPRAGE; 
Opts.DirStructure = DirStructure; 
Opts.MaskMag = MaskMag; 
Opts.Threshold_masking_MT_with_PDw = Threshold_masking_MT_with_PDw; 
Opts.Reslice = Reslice; 
Opts.SpecialTokenStruct = SpecialTokenStruct; 
Opts.FilterAlreadyPreprocessedSMRI = FilterAlreadyPreprocessedSMRI; 
Opts.FilterAlreadyPreprocessedFMRI = FilterAlreadyPreprocessedFMRI; 

end
