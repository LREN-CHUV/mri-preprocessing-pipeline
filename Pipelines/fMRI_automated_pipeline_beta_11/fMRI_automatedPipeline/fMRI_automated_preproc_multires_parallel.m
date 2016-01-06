function [matlabbatch_par1 matlabbatch_across matlabbatch_par2 matlabbatch_par3 Session Opts prefixNIIf] = fMRI_automated_preproc_parallel(RootPath, SubjectID, varargin)
%--------------------------------------------------------------------------
% Flexible automated pipeline for preprocessing of fMRI data using SPM
%--------------------------------------------------------------------------
%
% EDIT : use matlabbatch_par1, then matlabbatch_across (DARTEL), then
% matlabbatch_par2 (normalize) and finally matlabbatch_par3 (smooth)
%
% EDIT : matlabbatch_par2 & matlabbatch_par3 can be combined
%
% Prerequisites:
%    -> SPM
%    -> bias correct toolbox (Sandrine, based on Antoine's code))
%    -> converted files (NifTi format (.nii or .img & .hdr file extension))
%
%--------------------------------------------------------------------------
% INPUTS:
%--------------------------------------------------------------------------
%
% RootPath :
%       - String, absolute path of root folder containing all subjects folder
% 
% SubjectID :
%       - String, ID of subject (LRENpipeline) and, in entension, name of folder
%       containing the subject's data (subject-based processing). In case
%       processing of whole dataset (all subjects) is needed, can be set to ''.
% 
% Opts (optional argument):
%       - By default, the function reads the file "config_fmri_pipeline.txt"
%       and extracts from it parameters for behavior of fMRI pipeline. This
%       can be hacked by an optional argument when calling this function. In
%       the latter case, Opts will be a structure
%       containing the following fields:
%
%               - MinVolNum: scalar, minimal number of EPI volumes in an
%               experimental session (used to ignore aborted experimental
%               runs).
%
%               - RunDARTEL: numerical, can be 1 (create DARTEL template from
%               sample and estimate flow fields to normalize to MNI space) or
%               0 (uses deformation fields with default SPM template instead).
%
%               - Mode: 'interactive' (see the resulting jobs in SPM Batch
%               Editor interface before running it) or 'run' (just run the
%               jobs).
%
%               - TokenEPI: string, keyword used to detect the folder(s)
%               containing the functional scans.
%
%               - RegisterToMean: 1 (during realignement, register to the
%               first and then to the mean using a two-pass procedure) or 0
%               (register to first only).
%
%               - FWHM: 1 x 3 numerical, defines the smoothing kernel in x-, y-
%               and z-directions (Full width at half maximum).
%
%               - DetectResolution: 1 (use the token "mm" to detect potential
%               presence of multiple EPI datasets at different resolutions (and
%               process them separately by duplicating folders containing B0
%               maps and structural scan)) or 0 (assumes all datasets (if
%               several in each subject's folder) have the same resolution).
%
%               - StructMT: scalar, rank of MT image for normalization when
%               multiple anatomical data are found. Either StructMT or
%               StructMPRAGE has to be set to 1, and the other to 2.
%
%               - StructMPRAGE: scalar, rank of MPRAGE image for normalization
%               when multiple anatomical data are found. Either StructMT or
%               StructMPRAGE has to be set to 1, and the other to 2.
%
%               - DirStructure: string, can be either 'LRENpipeline' or
%               'DICOMimport'. SPM DICOM import is generally used by users
%               for data acquired from outside of lab, whereas the other
%               option aims at automated preprocessing of LREN Prisma's data.
%               This is meant to deal with different types of organization of data.
%               NB: see NOTA BENE section under OUTPUTS below.
%
%               - MaskMag: scalar, can be 1 (mask the magnitude image of B0
%               maps for EPI image distortion correction to prevent "schur"
%               and related errors) or 0 (don't mask the magnitude image).
%               This also applies to masking of magnitude image of B0 maps
%               for creation of multiparameter maps using VBQ.
%
%               - Threshold_masking_MT_with_PDw: scalar, threshold for masking
%               MT map created using VBQ using PDw. Usually it is
%               recommended to set it to 100 or so. This step is removing
%               noisy values in voxels close to the edges of the brain
%               to obtain a better segmentation of the structural scan,
%               and subsequently a better normalization of brain images.
%
%               - Reslice: when realigning images, reslicing can be
%               performed. This is usually not necessary as normalization
%               to MNI space will anyhow reslice images (and one
%               interpolation is better than two), but in case GLM
%               analysis has to be done in native space, this option can be
%               specified.
%               Reslice is then a scalar that can be equal to 0
%               (Realign estimate) or 1 (Realign : estimate and reslice).
%
%               - SpecialTokenStruct: Common anatomical data are MPRAGE or
%               MPMs. These protocols will be linked with a sequence name
%               containing the keyword “mprage” or respectively “mt_al_mtflash”,
%               “pd_al_mtflash”, and “t1_al_mtflash”. For special cases a
%               special token can be informed via this parameter. When set
%               to ‘’, the pipeline looks for anatomical data such as MPRAGE
%               or MPMs according to the default tokens defined above.
%               However any token can be specified in the form of a string,
%               such as e.g. “structural”. It has to be noted that in the
%               latter case the anatomical data will be assumed to be ready
%               for coregistration (i.e. if some particular MPM data have a
%               different sequence name, the masked MT map should be available
%               before running the fMRI pipeline).
%
%               - FilterAlreadyPreprocessedSMRI: Data that are already
%               preprocessed will be often encountered, especially with
%               anatomical scan. This option simply avoids confusion for
%               the pipeline when detecting files that are the output of a
%               previous preprocessing (such as files beginning with c1, c2,
%               etc.) and prevents to consider them as a multitude of
%               unpreprocessed files. Although it is recommended to leave
%               this option to 1 (filtering), it can be disabled (0).
%
%               - FilterAlreadyPreprocessedFMRI: Sometimes the pipeline will
%               also encounter fMRI data that have already (partially)
%               preprocessed. Again, this option simply avoids confusion
%               for the pipeline when detecting files that are the output
%               of a previous preprocessing and prevents to consider them
%               as a multitude of unpreprocessed files. Contrarily to the
%               other option, this one is unnecessary and is left to 0
%               (no filtering is applied) because although the majority of
%               jobs will overwrite the previously processed files, the
%               realignment of functional volumes shouldn’t be done multiple
%               times. Even though it could be easily checked if realignment
%               has been already performed with a relatively high level of
%               confidence (the headers of the files are usually at least
%               slightly different for each file), the original files are
%               in this case not available anymore and it is necessary to
%               start again from a backup of the converted data (or recomputed
%               them from the DICOM!) because otherwise : 1) the data will
%               be realigned twice ; 2) the realignment parameters file will
%               be incorrect, preventing any additional motion correction
%               at the first level analysis.
%
%..........................................................................
% NB: Opts can be field interactively by running the function Users.m
% EDIT: beware, Users.m is not anymore up-to-date and will not fill all
% fields of Opts. It is recommended to change the file
% fmri_pipeline_config.txt instead.
%..........................................................................
%--------------------------------------------------------------------------
% RECOMMENDED USAGES:
%--------------------------------------------------------------------------
%
% ==> For LREN automated pipeline, use the following (minimal call):
%
%       >> fMRI_automated_preproc(RootPath, SubjectID);
%
% And check that "Mode" == 'run'.
%
% ==> For casual users use the following (complete call): 
%
%       >> [matlabbatch Session Opts prefixNIIf] =
%               fMRI_automated_preproc(RootPath, SubjectID, Opts);
%
% And I recommend to check that "Mode" (or Opts.Mode) == 'interactive'.
%
% NB: do not add the backslash at the end of RootPath or at the beginning
% of SubjectID. Do it as in the example below:
%
%       >> fMRI_automated_preproc('C:\DATA\my_study', 'subj_01');
%
%--------------------------------------------------------------------------
% OUTPUTS:
%--------------------------------------------------------------------------
%
% matlabbatch : cell array of structures containing all informations on the
% jobs for SPM
%
% Session : cell array of structures containing original files detected by
% the algorithms
%
% Opts : structure containing inputs to the main function (sent back for
% checking and log purposes)
%
% prefixNIIf : string, final file prefix that will be used for further
% processing steps (e.g. 1st level GLM analysis)
%
% The variables above are also automatically saved in a .mat file beginning
% with "Log_fMRI_automated_preproc_" and ending with a
% "date-hour-minutes"-like tag.
% This .mat file can further be loaded in Matlab's workspace and the jobs
% called back in SPM Batch Editor interface) via a call to function spm_jobman.
% To check later if a Log_fMRI_automated_preproc_... .mat file is containing a
% valid job, load it and use:
%              >> iscell(matlabbatch)
%
%--------------------------------------------------------------------------
% NOTA BENE:
%--------------------------------------------------------------------------
% Directory structure is declared in :
% Opts.DirStructure (or at the line "DirStructure:" in the .txt config
% file):
%
%     %-------------------------------------------------------
%     % % Folder hierarchy type 1
%     % % (SPM DICOM import output with setting "patid_date"):
%     %-------------------------------------------------------
%     % -> root
%     %    -> subject ID
%     %       -> sequence (MR protocol) _ protocol run number
%     %          -> image files
%     %-------------------------------------------------------
%     
%     %-------------------------------------------------------
%     % % Folder hierarchy type 2
%     % % (LREN's automated pipeline):
%     %-------------------------------------------------------
%     % -> subject ID
%     %    -> session (experimental run number)
%     %       -> sequence (MR protocol)
%     %          -> repetition (protocol run number)
%     %             -> image files
%     %-------------------------------------------------------
%
%--------------------------------------------------------------------------
% WARNING FOR ADVANCED USERS:
%--------------------------------------------------------------------------
%
% Filenames for default files for EPI image distortion using FieldMap
% toolbox must have a maximal length of 63 characters (without the
% extension), otherwise SPM will truncate them and the module Presubtracted
% Phase and Magnitude Data will fail !
%
%--------------------------------------------------------------------------
% Renaud Marquis & Sandrine Muller, @LREN, last revised 2014-08-19
%--------------------------------------------------------------------------

%% Set parameters
% If optional argument entered, read Opts structure
% Else, read fmri_pipeline_config.txt

if nargin > 2 % if user-specified parameters
    Opts = varargin{1};
    SubjectID = ''; % because this is assumed to be a dataset-based program in this case
else
%     % set the structural scan to use: (EDIT: NOT DONE ANYMORE, BECAUSE
%     PIPELINES NEED TO BE INDEPENDENT FROM EACH OTHERS)
%     % --> sMRI pipeline done => use masked MT map <==> (FlagStructural == 'MT')
%     % --> No MPMs available => use MPRAGE <==> (FlagStructural == 'MPRAGE')
%     % (if MPMs available but sMRI not done, following function shouldn't be lauched)
%     Opts.FlagStructural = FlagStructural;

    % read default config file
    [p n e] = fileparts(which('fMRI_automated_preproc'));
    Config_file = strcat(p,filesep,'fmri_pipeline_config.txt');
    Fid = fopen(Config_file);
    clear Config
    Config = textscan(Fid,'%s%s');
    clear C D
    D = {'MinVolNum:'
    'RunDARTEL:'
    'Mode:'
    'TokenEPI:'
    'RegisterToMean:'
    'FWHM:'
    'DetectResolution:'
    'StructMT:'
    'StructMPRAGE:'
    'DirStructure:'
    'MaskMag:'
    'Threshold_masking_MT_with_PDw:'
    'Reslice:'
    'SpecialTokenStruct:'
    'FilterAlreadyPreprocessedSMRI:'
    'FilterAlreadyPreprocessedFMRI:'};
    for i = 1:size(Config{1},1)
        for j = 1:size(D,1)
            C{i,j} = strcmpi(Config{1}{i},D{j});
        end
    end
    C = cell2mat(C);
    [row col] = find(C);
    clear Opts
    Opts.MinVolNum = str2double(Config{2}{col(1)});
    Opts.RunDARTEL = str2double(Config{2}{col(2)});
    Opts.Mode = Config{2}{col(3)}(2:(end-1));
    %     Opts.TokenStruct = Config{2}{col(4)}(2:(end-1)); % not necessary
    %     anymore, detected from foldername hierarchically whether MPM or
    %     MPRAGE data are available. However, can be configured to bypass
    %     Opts.StructMT and Opts.StructMPRAGE and look for a specified token,
    %     "structural_scan", e.g.
    Opts.TokenEPI = Config{2}{col(4)}(2:(end-1));
    Opts.RegisterToMean = str2double(Config{2}{col(5)});
    Opts.FWHM = [str2double(Config{2}{col(6)}(2)) str2double(Config{2}{col(6)}(4)) str2double(Config{2}{col(6)}(6))];
    Opts.DetectResolution = str2double(Config{2}{col(7)});
    %     Opts.DummyScans = 0; % not necessary anymore: this step can be
    %     done at modelisation (GLM) step instead by dismissing the n-th
    %     scans when selecting them
    Opts.StructMT = str2double(Config{2}{col(8)}); % rank of MT image for normalization
    Opts.StructMPRAGE = str2double(Config{2}{col(9)}); % rank of MPRAGE image for normalization
    Opts.DirStructure = Config{2}{col(10)}(2:(end-1)); % whether the converted data is following folder hierarchy "1" or "2"
    Opts.MaskMag = str2double(Config{2}{col(11)});
    Opts.Threshold_masking_MT_with_PDw = str2double(Config{2}{col(12)});
    Opts.Reslice = str2double(Config{2}{col(13)});
    Opts.SpecialTokenStruct = Config{2}{col(14)}(2:(end-1));
    Opts.FilterAlreadyPreprocessedSMRI = str2double(Config{2}{col(15)});
    Opts.FilterAlreadyPreprocessedFMRI = str2double(Config{2}{col(16)});
end

% NB: if wanted to use another anatomical scan like an MPRAGE T1w, but the
% token is different, create a structure containing the fields above (see
% fmri_pipeline_config.txt) and add the following field:
%       Opts.TokenStruct
% VBQ create maps will not be performed.

%% Initialization

prefixNIIf = []; % initialize prefix for functional scans
prefixNIIs = []; % initialize prefix for structural scans
batchNum = 1; % initialize
matlabbatch_par1 = {}; % initialize
matlabbatch_par2 = {}; % initialize
matlabbatch_par3 = {}; % initialize
Session = {}; % initialize
CheckValid = [];

%% Processing of study data or subject data:

NIIs = strcat(RootPath,filesep,SubjectID);
if isempty(SubjectID)
    temp = detectFolders(NIIs);
    Subj_folder = strcat(repmat(cellstr(RootPath),length(temp),1),filesep,temp);
else
    Subj_folder = {NIIs};
end

%% Directories structure

if strcmpi(Opts.DirStructure,'DICOMimport')
    
    fprintf('\nFolder hierarchy assumed:\nSPM DICOM import "patid_date" (sub/seq_rep)\n')
    
    NIIs_folder = NIIs; %# MODIFIED 2015-08-31 (Subj_folder replaced by NIIs)
    
elseif strcmpi(Opts.DirStructure,'LRENpipeline')
    
    fprintf('\nFolder hierarchy assumed:\nLREN pipeline (sub/sess/seq/rep)\n')
    
%     fprintf('\nfMRI preprocessing of subject: %s\n',SubjectID) %# MODIFIED 2015-08-31
    for s = 1:length(Subj_folder) %# MODIFIED 2015-08-31
        temp = detectFolders(Subj_folder{s}); % detect experimental sessions within subject folder %# MODIFIED 2015-08-31
        for r = 1:length(temp)
            NIIs_folder{s,r} = cellstr(strcat(repmat(Subj_folder{s},length(temp{r}),1),filesep,temp{r}));
        end
    end
    NIIs_folder = NIIs_folder(~cellfun(@isempty,NIIs_folder));
    NIIs_folder = cellfun(@unique,NIIs_folder);
    
else
    warning('Unrecognized DirStructure in fmri_pipeline_config.txt')
end

%% Files and folders gestion:

for sub = 1:length(NIIs_folder) % all subjects
    
    [Sessions uniqueRes uniqueResIdx block CheckValidSub{sub}] = prepare_fMRI_session_coregFun2Str(NIIs_folder{sub},Opts,CheckValid);

    if isempty(CheckValidSub{sub})
        
        if ~isempty(block)
            for b = 1:size(block,2)
                matlabbatch_par1{sub}{batchNum-1+b} = block{b}; % because prepare_fMRI_session can sometimes output jobs (copy/move data, mask_MT_with_PDw, get_MPMs_from_converted_data, brain_mask,...)
            end
            batchNum=batchNum+b; % set batch number of next part of preprocessing
            clear block
        end
        
        %% First part of preprocessing: realign (and unwarp), bias correct, coregister and segment
        for res = 1:length(uniqueRes)
            if length(uniqueRes)>1
                
                [Session{sub,res} block] = reshapeSession_special(Sessions,uniqueResIdx == res,uniqueRes{res},Opts); % Session relative to the resolution
                                
                if ~isempty(block)
                    for b = 1:size(block,2)
                        matlabbatch_par1{sub}{batchNum-1+b} = block{b}; % because prepare_fMRI_session can sometimes output jobs (copy/move data, mask_MT_with_PDw, get_MPMs_from_converted_data, brain_mask,...)
                    end
                    batchNum=batchNum+b; % set batch number of next part of preprocessing
                    clear block
                end
            else % if there is just one EPI resolution for this subject, just roughly set Session = Sessions
                Session{sub,res} = Sessions;
                Session{sub,res}.EPIresolution = Sessions.EPIresolution(unique(uniqueResIdx));
                if ~isempty(Session{sub,res}.Phase)
                    Session{sub,res}.PMdefaultfile = Sessions.PMdefaultfile(unique(uniqueResIdx));
                end
            end
            
            if ~isempty(Session{sub,res}.Phase)
                [matlabbatch_par1{sub}{batchNum} batchNum] = block_VDM(Session{sub,res},batchNum);
                [matlabbatch_par1{sub}{batchNum} prefixNIIf batchNum] = block_realign_unwarp(Session{sub,res},'',Opts.RegisterToMean,batchNum);
            else % if no B0 maps found, no EPI image distortion correction
                [matlabbatch_par1{sub}{batchNum} prefixNIIf batchNum] = block_realign(Session{sub,res},'',Opts.RegisterToMean,Opts.Reslice,batchNum);
            end
            
            [matlabbatch_par1{sub}{batchNum} prefixNIIf batchNum] = block_bias_correct(Session{sub,res},Opts.RegisterToMean,prefixNIIf,batchNum);
            
            [matlabbatch_par1{sub}{batchNum} prefixNIIf batchNum] = block_coreg_funct_2_struct(Session{sub,res},Opts.RegisterToMean,prefixNIIf,batchNum);

        end
        
        %% Segment (done apart here because functional scans coregistered to structural scans (instead of the reverse):
        
        [matlabbatch_par1{sub}{batchNum} prefixNIIs batchNum] = block_segment(Session{sub,res},Opts.RunDARTEL,prefixNIIs,batchNum);
        
        prefixSub{sub} = prefixNIIf; % store all characters of the file prefix for further checking
        
    else
        
        warning('One session / subject could not be processed, processing the rest...')
        if strcmpi(SubjectID,'')
            save(strcat(NIIs_folder{sub}, filesep, 'WARNING_fMRI_automated_preproc_', datestr(now,'yyyy-mm-dd-HH-MM-SS-FFF'), '.mat'),'CheckValid');
        else
            save(strcat(char(NIIs_folder{sub}), filesep, 'WARNING_fMRI_automated_preproc_', datestr(now,'yyyy-mm-dd-HH-MM-SS-FFF'), '.mat'),'CheckValid');
        end
        prefixNIIf = [];
        prefixSub{sub} = prefixNIIf; % store all characters of the file prefix for further checking;
    end
    
    batchNum = 1;
end

% Check if B0 maps only for some subjects (to avoid different preprocessings):
if length(NIIs_folder) ~= sum(strcmp(prefixSub{1},prefixSub))
    %     warning('B0 maps only for some subjects')
    warning('ERROR: either invalid preprocessing, either different preprocessings for all subjects')
    save(strcat(RootPath, filesep, 'WARNING_fMRI_automated_preproc_', datestr(now,'yyyy-mm-dd-HH-MM-SS-FFF'), '.mat'),'prefixSub');
end

%% DARTEL

if Opts.RunDARTEL == 1
    if sum(sum(cellfun(@isempty,Session))) % if only some (this will appear if not all subjects have same runs), return error
        CheckValid.PartialMultiRes = 'Only some subjects with fMRI at multiple resolutions: cannot deal with such a case';
        warning('Only some subjects with fMRI at multiple resolutions: cannot deal with such a case')
        save(strcat(RootPath, filesep, 'WARNING_fMRI_auto_preproc_', datestr(now,'yyyy-mm-dd-HH-MM'), '.mat'),'CheckValid');
    else
        for k = 1:size(Session,2) % for each resolution
            [matlabbatch_across{batchNum} batchNum] = block_DARTEL(Session, k, prefixNIIs, batchNum);
        end
        % below: "u" for flow fields, but "rc1" because DARTEL-imported
        % gray matter tissue class (output of block_segment) used for
        % block_DARTEL. And flow fields also have a suffix ("Template").
        prefixNIIs = ['u_rc1' prefixNIIs]; % done outside here to prevent replication of prefixing when multiple resolution
        suffixNIIs = ['_Template'];
    end
elseif Opts.RunDARTEL == 0
    prefixNIIs = ['y_' prefixNIIs];
    suffixNIIs = [''];
    matlabbatch_across = '';
else
    CheckValid.DARTEL = 'Opts.RunDARTEL has to be equal to 0 or 1';
end

%% Second part of preprocessing: normalize and smooth

%%%% Normalize (1 or all subject(s))
[block_par2 prefixNIIf batchNum] = block_normalize(Session, Opts.RunDARTEL, prefixNIIs, prefixNIIf, suffixNIIs, batchNum);

for b = 1:size(block_par2,2)
    matlabbatch_par2{b} = {block_par2{b}}; % because output of block_normalize contains multiple jobs when multiple subjects
end

batchNum=batchNum+b; % set batch number of next part of preprocessing
clear block

%%% Smooth (1 or all subject(s))
[block_par3 prefixNIIf batchNum] = block_smooth(Session, Opts.FWHM, prefixNIIf, batchNum);
for b = 1:size(block_par3,2)
    matlabbatch_par3{b} = {block_par3{b}}; % because output of block_normalize contains multiple jobs when multiple subjects
end
batchNum=batchNum+b;
clear block

%% SAVE AND RUN

% Check whether errors occured or not and run batch (or return errors):
if isempty(CheckValid) && sum(~cellfun(@isempty,CheckValidSub))==0 %# MODIFIED 2015-08-31
    fprintf('Jobs for parallel processing saved in %s\n',strcat(RootPath, filesep, 'JOBS_PARALLEL_auto_preproc_', datestr(now,'yyyy-mm-dd-HH-MM'), '.mat'))
    whos matlabbatch_*
    % Save .mat file with paths to files, job structure, parameters used and
    % file prefix at the end of preprocessing:
    save(strcat(RootPath, filesep, 'JOBS_PARALLEL_auto_preproc_', datestr(now,'yyyy-mm-dd-HH-MM'), '.mat'),'matlabbatch_across','matlabbatch_par1','matlabbatch_par2','matlabbatch_par3','Session','Opts','prefixNIIf');
    
else
    warning('At least one error occured, check within fields of matlabbatch structure') % return errors
    warning('Be aware that some errors (linked to or resulting from the one specified) could occur and not be specified in the structure')
    matlabbatch_par1 = CheckValid;
    CheckValid.CheckValidSub = CheckValidSub; %# MODIFIED 2015-08-31
end

% if ~isfield(CheckValid,'StructuralFolder') && ~isfield(CheckValid,'TooMuchMagnitude') && ~isfield(CheckValid,'TooMuchStructural') && ~isfield(CheckValid,'StructuralFolder') && ~isfield(CheckValid,'StructuralScan') && ~isfield(CheckValid,'TooMuchStructural') && ~isfield(CheckValid,'fMRIdata') && ~isfield(CheckValid,'VolNum') && ~isfield(CheckValid,'FieldMapDefault')
%     % Launch SPM Batch editor / run the batch jobs:
%     spm_jobman(Opts.Mode,matlabbatch);
% else
%     warning('At least one error occured, check within fields of matlabbatch structure') % return errors
%     warning('Be aware that some errors (linked to or resulting from the one specified) could occur and not be specified in the structure')
%     matlabbatch = CheckValid;
% end

end