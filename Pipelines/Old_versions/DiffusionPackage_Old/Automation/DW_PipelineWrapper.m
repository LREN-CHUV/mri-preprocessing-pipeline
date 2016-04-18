function DW_PipelineWrapper(DWIpath,FieldmapNiiFiles,Subj_OutputFolder,SubjectID,Session,RepeatNum)
% DWIpath   = filepath of diffusion nifti data e.g. 'D:\MBdata\Subject1v3_DS\raw\20140605_081835cmrrmbep2ddiff165dirsMB3s021a001.nii'
% OutputDir = where to save the processed data e.g. '\\ProjectDirectory\Diffusion\SubjectID\SessionNumber


%% Define bval and bvec files as
[filepath, filename] = fileparts(DWIpath);
% splitrawname = strsplit(filename,'.');

% bval=[filepath filesep char(splitrawname(1)) '.bval'];
% bvec=[filepath filesep char(splitrawname(1)) '.bvec'];

bval = pickfiles(filepath,{'.bval'});
bvec = pickfiles(filepath,{'.bvec'});

%% Check that each of the files exists. If not update logs.
% 
% if ~exist(DWIpath,'file')
%     %     DWIpath file does not exist. Add to data check log.
% end
% 
% if ~exist(bval,'file')
%     %     bval file does not exist. Add to data check log.
% end
% 
% if ~exist(bvec,'file')
%     %     bvec file does not exist. Add to data check log.
% end
% 

%% Create default directory structure and copy files

if ~exist([Subj_OutputFolder filesep 'raw'],'dir')
    mkdir([Subj_OutputFolder filesep 'raw'])
end


copyfile(DWIpath,[Subj_OutputFolder filesep 'raw']);
copyfile(bval,[Subj_OutputFolder filesep 'raw' filesep filename '.bvals']);
copyfile(bvec,[Subj_OutputFolder filesep 'raw' filesep filename '.bvecs']);

for i=1:length(FieldmapNiiFiles)
    copyfile(FieldmapNiiFiles{i},[Subj_OutputFolder 'raw' filesep filename '_grefieldmap' num2str(i) '.nii']);
end;

%% Initiate pipeline with reorganised data

dwParams                    = dtiInitParams;
dwParams.SubjectID          = SubjectID;
dwParams.SessionNum         = Session;
dwParams.RepeatNum          = RepeatNum;
dwParams.fitNODDI           = 0;


DWIInit([Subj_OutputFolder 'raw' filesep filename '.nii'], 'MNI', dwParams);
