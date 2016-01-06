function NiiConvert_MPM_Computation_serial(PipelineConfigFile,NiFti_OutputFolder)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, May 18th, 2014

%%  For Nifti Conversion Initializing ...

if ~exist('NiFti_OutputFolder','var')
    %NiFti_OutputFolder = 'M:\CRN\LREN\SHARE\VBQ_Output_All\DataNifti_All\';
    NiFti_OutputFolder ='D:\Users DATA\Users\lester\ZZZ_Nifti_Data_MPMs\';
end;
if ~strcmp(NiFti_OutputFolder(end),filesep)
    NiFti_OutputFolder = [NiFti_OutputFolder,filesep];
end;

NiFti_Server_OutputFolder = 'M:\CRN\LREN\SHARE\VBQ_Output_All\DataNifti_All';
ServerDataFolder = 'K:\NLG_LREN\IRMMP16\prisma\2014\';
Subj_IDs = make_list_MRI_studies01(ServerDataFolder);

Subj_IDs_MPM = getListofFolders(NiFti_Server_OutputFolder);
BlackList = {'PR00298_BD290679';'PR00303_LL030379';'PR00306_LK030379'}; % Problems for converting Diffusion data ...
Subj_IDs_MPM = vertcat(Subj_IDs_MPM,BlackList);

ind = not(ismember(Subj_IDs(:,1),Subj_IDs_MPM));
Subj_IDs2Compute = Subj_IDs(ind,:);

SubjectFolders = Subj_IDs2Compute(:,1);

Ns = length(SubjectFolders);  % Number of subjects ...

%% For MPMs Computation Initializing ...

if ~exist('PipelineConfigFile','var')
    PipelineConfigFile = which('Preproc_mpm_maps_pipeline_config.txt');
    if isempty(PipelineConfigFile)
        disp('pipeline config file does not exist ! Please specify ...');
        return;
    end;
end;
[~,ProtocolsFile,MPM_OutputFolder,GlobalMPMFolder,MPM_Template,ServerFolder,doUNICORT] = ...
                                                                           Read_Preproc_mpm_maps_config(PipelineConfigFile); %#ok<*STOUT>

%%
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

%%
%NiiConvert_MPM_Computation(SubjectFolder,SubjID,NiFti_OutputFolder,NiFti_Server_OutputFolder,ProtocolsFile,MPM_OutputFolder,GlobalMPMFolder,MPM_Template,ServerFolder,doUNICORT);
for i=1:Ns
    SubjID = SubjectFolders{i};
    SubjectFolder = Subj_IDs2Compute{i,2};
    NiiConvert_MPM_Computation(SubjectFolder,SubjID,NiFti_OutputFolder,NiFti_Server_OutputFolder,ProtocolsFile,MPM_OutputFolder,GlobalMPMFolder,MPM_Template,ServerFolder,doUNICORT);
end;
                                            
end

