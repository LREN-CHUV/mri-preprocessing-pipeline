function biasCorrect = tbx_cfg_biasCorrect
% SPM Configuration file for toolbox 'Old Segment'
%______________________________________________________________________
% Copyright (C) 2005-2012 Wellcome Trust Centre for Neuroimaging

% $Id: spm_cfg_preproc.m 4900 2012-09-05 14:06:50Z john $

if ~isdeployed, addpath(fullfile(spm('dir'),'toolbox','OldSeg')); end

    % ---------------------------------------------------------------------
    % data files
    % ---------------------------------------------------------------------
    data         = cfg_files;
    data.tag     = 'data';
    data.name    = 'Data';
    data.help    = {'Select scans for bias field correction'};
    data.filter = 'image';
    data.ufilter = '.*';
    data.num     = [1 Inf];

    % ---------------------------------------------------------------------
    % Sessions
    % ---------------------------------------------------------------------
    Sessions         = cfg_repeat;
    Sessions.tag     = 'Sessions';
    Sessions.name    = 'Sessions';
    Sessions.help    = {'Select the session to apply the bias field on.'};
    Sessions.values  = {data};
    Sessions.num     = [1 Inf];

    % ---------------------------------------------------------------------
    % Launch biasCorrect
    % ---------------------------------------------------------------------
    biasCorrect          = cfg_exbranch;
    biasCorrect.tag      = 'biasCorrect';
    biasCorrect.name     = 'Bias correction';
    biasCorrect.val      = {Sessions};
    biasCorrect.help     = {''};
    biasCorrect.modality = {'FMRI' 'PET' 'EEG'};
    biasCorrect.prog     = @biasCorrect_run_results;
    biasCorrect.vout     = @vout;

    
%------------------------------------------------------------------------
function dep = vout(varargin)
% Output file names will be saved in a struct with field .files
dep(1)            = cfg_dep;
dep(1).sname      = 'Bias corrected images';
dep(1).src_output = substruct('.','files');
dep(1).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});
