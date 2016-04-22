function Preproc_mpm_maps_sequential(SubjectListFile,PathsPipelineConfigFile)


%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, September 3rd, 2015 

if ~exist('PathsPipelineConfigFile','var')
    PathsPipelineConfigFile = which('Preproc_mpm_maps_pipeline_config_paths.txt');
    if isempty(PathsPipelineConfigFile)
        disp('pipeline config file does not exist ! Please specify ...');
        return;
    end;
end;

[InputFolder,ProtocolsFile,PipelineParmsConfigFile,MPM_OutputFolder,ServerFolder] = Read_Preproc_mpm_maps_paths(PathsPipelineConfigFile);

if ~strcmp(InputFolder(end),filesep)
     InputFolder = [InputFolder,filesep];
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

if ~exist('SubjectListFile','var')
    if isempty(SubjectListFile)
        SubjectFolders = getListofFolders(InputFolder);
        NSubjFolder = length(SubjectFolders);
        isReady = zeros(NSubjFolder,1);
        for i=1:NSubjFolder
            disp(['Checking Data --> Subject ',num2str(i),' of ',num2str(NSubjFolder)]);
            isReady(i) = is_ready4MPMs([InputFolder,SubjectFolders{i}],ProtocolsFile);
        end;
        
        isReady = logical(isReady);
        SubjectFolders = SubjectFolders(isReady);
        
        SubjectFolders_MPMs = getListofFolders('M:\CRN\LREN\SHARE\VBQ_Output_All\MPMs_All\');
        %BlackList = {'PR00695_MB280421';'AL060680';'PR00459_GA050675';'PR00973_RC160189';'PR00979_RC160189'; 'PR00683_AL060680';'PR00689_KF250304'}; % {'PR00125'};
        BlackList = {'PR00459_GA050675';'PR00973_RC160189';'PR00979_RC160189';'AL060680';'PR00683_AL060680';'PR01085_AL060680';'PR01100_AL060680';'PR011195_DC080165'};
        SubjectFolders_MPMs = vertcat(SubjectFolders_MPMs,BlackList);
        
        ind = not(ismember(SubjectFolders,SubjectFolders_MPMs));
        SubjectFolders = SubjectFolders(ind);
    else
        SubjectFolders = textread(SubjectListFile,'%s'); 
    end;
else
    SubjectFolders = textread(SubjectListFile,'%s'); 
end;

disp(['Number of Subjects to Run: ',num2str(length(SubjectFolders))]);

Ns = length(SubjectFolders);  % Number of subjects ...
for i=1:Ns
    SubjID = SubjectFolders{i};
    Preproc_mpm_maps(InputFolder,SubjID,MPM_OutputFolder,ProtocolsFile,PipelineParmsConfigFile,ServerFolder);
end;
                                            
end
