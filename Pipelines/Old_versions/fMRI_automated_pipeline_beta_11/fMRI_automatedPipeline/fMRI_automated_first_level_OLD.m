function matlabbatch = fMRI_automated_first_level(Session,prefixNIIf,Opts)
%--------------------------------------------------------------------------
% Flexible automated pipeline for 1st level analysis of fMRI data using SPM
%--------------------------------------------------------------------------
%
% Prerequisites:
%    -> SPM
%    -> if requested, physio toolbox (RETROICOR)
%    ==> fMRI data are assumed to be already converted and preprocessed
%    (using fMRI_automated_preproc e.g.)
%
%--------------------------------------------------------------------------
% INPUTS:
%--------------------------------------------------------------------------
%
% Session : cell of structure containing all filepaths and session
% information, output of preliminary preprocessing
% (fMRI_automated_preproc). If empty, prompts will appear asking for the
% number of subjects.
%
% prefixNIIf : string, prefix of functional scans before any normalization
% and smoothing (remove "sw" if present in it (e.g. if output of
% fMRI_automated_preproc)).
%
% Opts : see fMRI_automated_preproc. However for this function this argument
% is needed and not optional. Like in fMRI_automated_preproc, it is a
% structure. It can contain any field but the following fields are / can be
% here used:
%
%       - ModelFolderName : cell of strings that specifies folder's
%         name containing ModelFilename. If specified, it must contain \ at
%         the end. If multiple conditions .mat file is at the root of the
%         subject's folder, simply enter ''.
%
%       - ModelFilename : cell of strings specifying paths to .mat file
%         containing details of the experimental paradigm. It must include
%         the following cell arrays (each 1 x n): names, onsets
%         and durations (see SPM help for fMRI model
%         specification, section Multiple conditions for
%         additional information).
%
%       - TR : (cell) repetition time(s) of the EPI sequence(s) in
%         seconds, scalar or 1 x n vector (where n is the
%         number of different resolutions used) when multiple
%         resolutions: look at the structure of Session variable (output of
%         fMRI_automated_preproc (to set up correctly the order of the
%         different TRs (and model filenames, ...)).
%
%       - Unit : string, unit used for the onsets and durations
%         specifying the GLM of the first level analysis, can
%         be 'secs' or 'scans'.
%
%       - FirstLevelMaskingThreshold : scalar, defining threshold for
%         masking during first level analysis (see SPM model specification
%         help) (by default, SPM set it to 0.8).
%
%       - FirstLevelExplicitMask : string, path to mask image for first level
%         analysis (see SPM model specification help) (by default, set to ''
%         by SPM, but can specify a path to an image to replace
%         FirstLevelMaskingThreshold e.g.).
%
%       - WriteResiduals : scalar, defining whether to write residuals of
%         1st level GLM analysis (1 = yes ; 0 = no).
%
%       - Contrasts (optional) : if it exists, specified contrasts for
%         1st level analysis will be computed. Contrasts to be performed
%         will be specified in one or both of the following subfields:
%
%                - F
%                - T
%
%         Each subfield T / F is a cell that must contain
%         the following subfields:
%
%                - name
%                - weights
%
%         Where "name" is a string and "weights" is a scalar, as in the
%         example below:
%
%                 Contrasts.T{1}.weights:  [1 0 0 -1]
%                 Contrasts.T{1}.name:  'a minus d'
%
%       - CorrectPhysioNoise (optional) : if a field called "CorrectPhysioNoise
%         exists in Opts, physiological data are used to apply
%         RETROspective Image-based CORrection of physiological noise in
%         fMRI data, otherwise only movement parameters estimated during
%         realignment are included in the GLM to remove residual
%         artifacts due to head movements.
%         Physio (RETROICOR) toolbox is needed if the field is present.
%         If RETROICOR is requested, the following fields are required
%         within CorrectPhysioNoise :
%
%               - PhysioFilename : cell of string of physiological data
%               filenames
%
%               - PhysioFoldername : cell of string of folder containing
%               physiological datafiles (if at the subject's root folder,
%               specify '').
%
%               - sampling_rate : ... of physiological data (cell of
%                 scalars)
%
%               - TRslice : slice TR (cell of scalars)
%
%               - Nslices : number of slices (per EPI volume) (cell
%                 of scalars)
%
%               - sliceorder : 'descending', 'ascending', or
%                 'interleaved'
%
%               - SliceNum : reference slice (usually half of
%                 Nslices) (cell of scalars)
%
%               - MultipleSessInFile : 1 (if multiple sessions in
%                 (each) physiological datafile) or 0.
%                   name: 'A minus D'
%
%--------------------------------------------------------------------------
% USAGE:
%--------------------------------------------------------------------------
%
% >> Jobs = fMRI_automated_first_level(Session,prefixNIIf,Opts);
%
%--------------------------------------------------------------------------
% OUTPUTS
%--------------------------------------------------------------------------
%
% matlabbatch : cell array of structures containing all informations on the
% jobs for SPM
%
%--------------------------------------------------------------------------
% Renaud Marquis & Sandrine Muller, @LREN, last revised 2014-07-07
%--------------------------------------------------------------------------

% If Session is empty, 
if isempty(Session)
    fprintf('Session structure is empty,\nyou will asked to select\npreprocessed functional scans\n(e.g. smoothed warped realigned EPI volumes)\n(dummy scans also need to be selected\nand will be removed afterwards according\nto what is specified in Opts)...\n')
    Nres = input('Specify the number EPI resolutions in the datasets\n(scalar expected):\n','s');
    Nsub = input('Specify the number of subjects\n(scalar expected):\n','s');
    Nsess = input('Specify the number of runs\n(repetitions of the same EPI protocol)\n(scalar expected):\n','s');
    for c = 1:str2double(Nres)
        Opts.TR{c} = str2double(input('Enter the TR\n(repetition time for 1 EPI volume)\nfor this resolution:\n','s'));
        for r = 1:str2double(Nsub)
            for s = 1:str2double(Nsess)
                Session{r,c}.EPI{s} = cellstr(spm_select(Inf,'image','Select preprocesed functional scans for GLM'));
                prefixNIIf = [];
            end
        end
    end
end

%% Initialize
matlabbatch = {};
batchNum = 1;

%% First-level analyses
for sub = 1:size(Session,1)
    
    % Create folder, specify model and estimate it
    % (remove also dummy scans and apply
    % RETROICOR if requested (inside function)):
    [matlabbatch batchNum] = block_model_spec_est(Session(sub,1:size(Session,2)),Opts,prefixNIIf,matlabbatch,batchNum);
    
end

%% Save and run

save(strcat(pwd, filesep, 'Log_fMRI_automated_first_level_', datestr(now,'yyyy-mm-dd-HH-MM-SS-FFF'), '.mat'),'matlabbatch','Opts');
spm_jobman(Opts.Mode,matlabbatch);

end
