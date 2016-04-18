function DW_PipelineWrapper(DWIpath,FieldmapNiiFiles, Anatomical_Image,Subj_OutputFolder,SubjectID,Session,RepeatNum,SequenceName,ReadoutTime)
% DWIpath   = filepath of diffusion nifti data e.g. 'D:\MBdata\Subject1v3_DS\raw\20140605_081835cmrrmbep2ddiff165dirsMB3s021a001.nii'
% FieldmapNiiFiles = a cell structure listing paths to subject field map images
% Anatomical_Image = path to preprocessed MT MPM. MPRAGE as alternative
% OutputDir = where to save the processed data e.g. '\\ProjectDirectory\Diffusion\SubjectID\SessionNumber
% SubjectID = the subject ID / PR number
% Session = the scan session for this subject
% RepeatNum = The repeat number for the diffusion data

%% Define bval and bvec files
[filepath, filename] = fileparts(DWIpath);
% splitrawname = strsplit(filename,'.');

% bval=[filepath filesep char(splitrawname(1)) '.bval'];
% bvec=[filepath filesep char(splitrawname(1)) '.bvec'];

bval = pickfiles(filepath,{'.bval'});
bvec = pickfiles(filepath,{'.bvec'});
% if ~exist(bval,'file')
%     [uppath, upname] = fileparts(filepath);
%     bval = pickfiles(uppath,{'.bval'});
%     bvec = pickfiles(uppath,{'.bvec'});
% end

%% Create default directory structure and copy files

% Can ensure that each session and repeat has a separate directory
% Subj_OutputFolder = fullfile(Subj_OutputFolder,Session,RepeatNum)

if ~exist([Subj_OutputFolder filesep 'raw'],'dir')
    mkdir([Subj_OutputFolder filesep 'raw'])
end

if exist(Anatomical_Image,'file')
    [anatpath, anatname, anatext] = fileparts(Anatomical_Image);
    copyfile(Anatomical_Image,[Subj_OutputFolder filesep 'raw' filesep anatname anatext]);
    
    % Find all quantitative MPM files and copy to qMRI folder
    qMPMs = cellstr(pickfiles(anatpath,{'.'},{'_A.nii','_MT.nii','_R1.nii','_R2s.nii'}));
    for i=1:length(qMPMs)
        if exist(qMPMs{i},'file')
            if ~exist([Subj_OutputFolder filesep 'qMRI'],'dir')
                mkdir([Subj_OutputFolder filesep 'qMRI'])
            end
            [~, MPMname, MPMext] = fileparts(qMPMs{i});
            copyfile(qMPMs{i},[Subj_OutputFolder filesep 'qMRI' filesep MPMname MPMext]);
        end
    end
    
    Anatomical_Image = [Subj_OutputFolder filesep 'raw' filesep anatname anatext];
else Anatomical_Image = '';
end

[~, DWIname, DWIext] = fileparts(DWIpath);
newDWIpath = [Subj_OutputFolder filesep 'raw' filesep DWIname DWIext];
copyfile(DWIpath,newDWIpath);
copyfile(bval,[Subj_OutputFolder filesep 'raw' filesep filename '.bvals']);
copyfile(bvec,[Subj_OutputFolder filesep 'raw' filesep filename '.bvecs']);

% Ensure that all copied field maps have _grefieldmap suffix
for i=1:length(FieldmapNiiFiles)
    copyfile(FieldmapNiiFiles{i},[Subj_OutputFolder 'raw' filesep filename '_grefieldmap' num2str(i) '.nii']);
end;

%% Initiate pipeline with reorganised data

dwParams                    = dtiInitParams;
dwParams.SubjectID          = SubjectID;
dwParams.SessionNum         = Session;
dwParams.RepeatNum          = RepeatNum;
dwParams.SequenceName       = SequenceName;
% Add lookup to find readout time from sequence name
dwParams.EPI_readout_time = ReadoutTime; %EPI_readout_lookup(SequenceName);


DWIInit(newDWIpath, Anatomical_Image, dwParams);
