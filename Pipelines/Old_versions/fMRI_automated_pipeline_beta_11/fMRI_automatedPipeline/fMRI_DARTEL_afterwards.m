function [matlabbatch Session Opts prefixNIIf] = fMRI_DARTEL_afterwards(RootPath, SubjectID, Opts, Session, prefixNIIf)
%--------------------------------------------------------------------------
% Run DARTEL on a fMRI dataset which has been already preprocessed, then
% normalize and smooth the result (overwrite!)
%--------------------------------------------------------------------------
%
% Prerequisites:
%    -> SPM
%    -> bias correct toolbox (Sandrine, based on Antoine's code))
%    -> converted files (NifTi format (.nii or .img & .hdr file extension))
%    -> DARTEL imported tissue classes (rc1, rc2 and rc3 images) from segmentation
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
% Opts : see fMRI_automated_preproc. However for this function this argument
% is needed and not optional.
%
% Session : cell of structure containing all filepaths and session
% information, output of preliminary preprocessing (fMRI_automated_preproc)
%
% prefixNIIf : string, prefix of functional scans before any normalization
% and smoothing (remove "sw" if present in it!)
%
%--------------------------------------------------------------------------
% USAGE:
%--------------------------------------------------------------------------
%
% >> fMRI_automated_preproc(RootPath, SubjectID, Opts, Session, prefixNIIf);
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
% Renaud Marquis & Sandrine Muller, @LREN, refacto, last revised 2014-08-27
%--------------------------------------------------------------------------

%% Initialization

batchNum = 1; % initialize
matlabbatch = {}; % initialize
CheckValid = [];

%% DARTEL

if sum(sum(cellfun(@isempty,Session))) % if only some (this will appear if not all subjects have same runs), return error
    CheckValid.PartialMultiRes = 'Only some subjects with fMRI at multiple resolutions: cannot deal with such a case';
    warning('Only some subjects with fMRI at multiple resolutions: cannot deal with such a case')
    if strcmpi(SubjectID,'')
        save(strcat(RootPath, filesep, 'WARNING_fMRI_automated_preproc_', datestr(now,'yyyy-mm-dd-HH-MM-SS-FFF'), '.mat'),'CheckValid');
    else
        save(strcat(char(Subj_folder), filesep, 'WARNING_fMRI_automated_preproc_', datestr(now,'yyyy-mm-dd-HH-MM-SS-FFF'), '.mat'),'CheckValid');
    end
else
    for k = 1:size(Session,2) % for each resolution
        [matlabbatch{batchNum} batchNum] = block_DARTEL(Session, k, '', batchNum);
    end
%     below: "u" for flow fields, but "rc1" because DARTEL-imported
%     gray matter tissue class (output of block_segment) used for
%     block_DARTEL. And flow fields also have a suffix ("Template").
    prefixNIIs = ['u_rc1']; % done outside here to prevent replication of prefixing when multiple resolution
    suffixNIIs = ['_Template'];
end

%% Second part of preprocessing: normalize and smooth

%%%% Normalize to MNI space: (block_norm_to_MNI (using DARTEL) can be
%%%% problematic sometimes)...
% [block prefixNIIf batchNum] = block_norm_to_MNI(Session, prefixNIIs, prefixNIIf, suffixNIIs, batchNum);
%%%% Normalize
[block prefixNIIf batchNum] = block_normalize(Session, Opts.RunDARTEL, prefixNIIs, prefixNIIf, suffixNIIs, batchNum);

for b = 1:size(block,2)
    matlabbatch{batchNum-1+b} = block{b}; % because output of block_normalize contains multiple jobs when multiple subjects
end

batchNum=batchNum+b; % set batch number of next part of preprocessing
clear block

%%% Smooth
[block prefixNIIf batchNum] = block_smooth(Session, Opts.FWHM, prefixNIIf, batchNum);
for b = 1:size(block,2)
    matlabbatch{batchNum-1+b} = block{b}; % because output of block_normalize contains multiple jobs when multiple subjects
end
batchNum=batchNum+b;
clear block

%% SAVE AND RUN

% Save .mat file with paths to files, job structure, parameters used and
% file prefix at the end of preprocessing:
if strcmpi(SubjectID,'')
    save(strcat(RootPath, filesep, 'Log_fMRI_DARTEL_afterwards_', datestr(now,'yyyy-mm-dd-HH-MM-SS-FFF'), '.mat'),'matlabbatch','Session','Opts','prefixNIIf');
else
    save(strcat(char(Subj_folder), filesep, 'Log_fMRI_DARTEL_afterwards_', datestr(now,'yyyy-mm-dd-HH-MM-SS-FFF'), '.mat'),'matlabbatch','Session','Opts','prefixNIIf');
end

% Check whether errors occured or not and run batch (or return errors):
if ~isfield(CheckValid,'DARTEL')
    % Launch SPM Batch editor / run the batch jobs:
    spm_jobman(Opts.Mode,matlabbatch);
    
else
    warning('At least one error occured, check within fields of matlabbatch structure') % return errors
    warning('Be aware that some errors (linked to or resulting from the one specified) could occur and not be specified in the structure')
    matlabbatch = CheckValid;
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