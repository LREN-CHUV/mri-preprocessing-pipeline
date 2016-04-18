function fMRI_automated_preproc_sand_forautomatedPipeline(Subj_folder,varargin)
% function needed:
% getAllFiles

%FUNCTION prefix = fMRIpreproc_auto(NIIs_folder)
% aims at doing all the preprocessing of the fMRI data
%------------------------------INPUTS--------------------------------------
% NIIs_folder : s of the name of the folder containing all sequences
% 

% varargin: OPTIONAL : 
% {1} Mode: a string ('interactive' or 'run') to see or not the job in the
% GUI before running it
% {2} volnum : scalar, minimal number of volumes per session
% {3} dummyscans : number of dummy files (for 3mm resolution EPI only)
%-------------------------------OUTPUTS------------------------------------
% create a number of files relative to spm preprocessing
% prefix : prefix of the files created
%
% USAGE : prefix = fMRIpreproc_auto('C:\TEMP\DL060989',[240 240 110 110],5);
% 14-03-21, @LREN, Sandrine Muller
% 14-06-27, @LREN, Sandrine Muller, Renaud Marquis, refacto

% % % % % 
% % % % % Subj_folder ='C:\TEMP\testfMRIauto';dummyscans = 5;Mode = 'interactive';volnum=100; runDartel = 1;
%
%
%%%% e.g.  fMRI_automated_preproc_sand_forautomatedPipeline('M:\CRN\LREN\COLLABORATIONS\fMRI_data\Compass-fMRI\Effect_of_RT\PR01146_LG280385','interactive',100,5);


%% Initialization
prefixNII = [];

if nargin>1
    if length(varargin)>3
        error('Improper number of dummy scans');
    elseif length(varargin)==1
        Mode = varargin{1};
        volnum = 50; % min number of scans to consider as a "correct" fMRI seq
        dummyscans = 5; % by default 5 dummies removed
    elseif length(varargin)==2
        Mode = varargin{1};
        volnum = varargin{2}; 
        dummyscans = 5; % by default 5 dummies removed
    elseif length(varargin)==3
        Mode = varargin{1};
        volnum = varargin{2}; 
        dummyscans = varargin{3}; % by default 5 dummies removed
    end
    fprintf('Preprocessing parameters: \n Mode: %s \n volnum:%d \n dummy scans %d\n',Mode,volnum,dummyscans);
else
    %Mode = 'run';
    Mode = 'interactive';
    volnum = 80; % min number of scans to consider as a "correct" fMRI seq
    dummyscans = 5;
    seqNamegrefield = 'gre_field';
    seqNameStruct = 'mprage';
    seqNameEPI= 'al_mepi';
    %pmDefaultFilePath = 'C:\DATA\SVN\sanmulle\Code\SPMbasics\fMRI_automatedPipeline\pm_defaults_Prisma_3mm.m';
    pmDefaultFilePath = 'D:\WORK\Automatic_Computation\fMRI_automatedPipeline_testedforCOMPASSsand_15-10-23\fMRI_automatedPipeline\beta_release\pm_defaults_Prisma_3mm.m';
    [p n e] = fileparts(which('spm'));
    TPMpaths = {strcat(p, filesep, 'tpm\TPM.nii,1');strcat(p, filesep, 'tpm\TPM.nii,2');strcat(p, filesep, 'tpm\TPM.nii,3');strcat(p, filesep, 'tpm\TPM.nii,4');strcat(p, filesep, 'tpm\TPM.nii,5');strcat(p, filesep, 'tpm\TPM.nii,6')};
    fprintf('Preprocessing parameters: \n Mode: %s \n volnum:%d \n dummy scans: %d\n gre field: %s\n Structural folder: %s\n EPI folder: %s\n pm default file: %s\n TPM paths: \t%s\t%s\t%s\t%s\t%s\t%s \n',Mode,volnum,dummyscans,seqNamegrefield,seqNameStruct,seqNameEPI,pmDefaultFilePath,TPMpaths{1,1},TPMpaths{2,1},TPMpaths{3,1},TPMpaths{4,1},TPMpaths{5,1});
end

%% Files and folders gestion
% by default, if no fieldmap no VDM etc.

%%% Build default config file:
[Sessions uniqueRes uniqueResIdx FileExt] = PrepareFiles_old(Subj_folder,volnum,dummyscans,seqNamegrefield,seqNameStruct,seqNameEPI, pmDefaultFilePath);


%% Preproc first part (VDM, bias field corection, coreg, segmentation)
for res = 1:length(uniqueRes)
    if length(uniqueRes)>1

        Session = reshapeSession(Sessions,uniqueResIdx == res,uniqueRes{res},FileExt); % Session relative to the resolution

        if ~isempty(Session.Phase)
            matlabbatch{1} = block_VDM(Session);
        else
            matlabbatch = {};
        end

        [block0 prefixNII] = block_realign_unwarp(Session, '');
        [block1 prefixNII] = block_BiasCorrect(Session,prefixNII);
        tempprefix = prefixNII;
        [block2 prefixNII] = block_coregister(Session,prefixNII);
        batchNumber = length([matlabbatch block1 block2]);
        block3= block_segment(Session,TPMpaths,1);
        matlabbatch = [matlabbatch block0 block1 block2 block3];

    else

        Session = Sessions;

        if ~isempty(Session.Phase)
            matlabbatch{1} = block_VDM(Session);
        else
            matlabbatch = {};
        end

        [block0 prefixNII] = block_realign_unwarp(Session, '');
        [block1 prefixNII] = block_BiasCorrect(Session,prefixNII);
        tempprefix = prefixNII;
        [block2 prefixNII] = block_coregister(Session,prefixNII);
        batchNumber = length([matlabbatch block1 block2]);
        block3 = block_segment(Session,TPMpaths,1);
        matlabbatch = [matlabbatch block0 block1 block2 block3];

    end


end



%% Preproc second part (nornmalization and smoothing)

[block4 prefixNII] = block_normalize(Session,length(matlabbatch), 'bu');
[block5 prefixNII] = block_smooth(Session, 8, prefixNII);
matlabbatch = [matlabbatch block4 block5];
spm_jobman(Mode,matlabbatch);
end