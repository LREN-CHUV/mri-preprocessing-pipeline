function [block batchNum] = block_model_spec(Session,ModelFilename,TR,Unit,OutputDir,Multi_Reg,prefixNIIf,batchNum)
% SPM Model specification
%
%--------------------------------------------------------------------------
% INPUTS:
%--------------------------------------------------------------------------
%
% Session : cell of structure containing filepaths by image types, default
% file for EPI image distortion correction (FieldMap) if B0 maps are present,
% resolution of EPI runs (detected from folder name)
%
% ModelFilename : string, relative filename of multiple conditions .mat file
% for model specification (see SPM help)
%
% TR : double, specifying repetition time for the current session
%
% Unit : string, unit for design (can be 'secs' or 'scans')
%
% OutputDir : string, output directory for SPM.mat file containing GLM
%
% Multi_Reg : cell of strings, path and filename to multiple regressors
% (can be .txt file of movement parameters or .mat file of movement
% parameters combined with physiological regressors (see RETROICOR))
%
% prefixNIIf : string, prefix of fMRI scan, added job after job in an
% incremental way
%
% batchNum : scalar, index for current SPM batch
%
%--------------------------------------------------------------------------
% OUTPUTS:
%--------------------------------------------------------------------------
%
% block : structure for SPM job (Model specification here)
%
% batchNum : index for next SPM batch
%
%--------------------------------------------------------------------------
% 2014-08-19, @LREN, Renaud Marquis, refacto
%--------------------------------------------------------------------------

%%% CHEKING NEEDED!

block.spm.stats.fmri_spec.dir = cellstr(OutputDir);
block.spm.stats.fmri_spec.timing.units = Unit;
block.spm.stats.fmri_spec.timing.RT = TR;
block.spm.stats.fmri_spec.timing.fmri_t = 16;
block.spm.stats.fmri_spec.timing.fmri_t0 = 8;
block.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
block.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
block.spm.stats.fmri_spec.volt = 1;
block.spm.stats.fmri_spec.global = 'None';
block.spm.stats.fmri_spec.mthresh = 0.8;
block.spm.stats.fmri_spec.mask = {''};
block.spm.stats.fmri_spec.cvi = 'AR(1)';

for c = 1:size(Session.EPI,2)
    Check(c) = iscellstr(Session.EPI{c});
end

if sum(Check) == size(Session.EPI,2)
    for c = 1:size(Session.EPI,2)
        % Add prefix before filename:
        Im = spm_file(Session.EPI{c},'prefix',prefixNIIf);
        block.spm.stats.fmri_spec.sess(c).scans = Im;
        block.spm.stats.fmri_spec.sess(c).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
        block.spm.stats.fmri_spec.sess(c).regress = struct('name', {}, 'val', {});
        if strcmpi(Opts.DirStructure,'DICOMimport')
            block.spm.stats.fmri_spec.sess(c).multi = {strcat(fileparts(fileparts(Session.EPI{c}{1})), filesep, ModelFilename{c})};
        elseif strcmpi(Opts.DirStructure,'LRENpipeline')
            block.spm.stats.fmri_spec.sess(c).multi = {strcat(fileparts(fileparts(fileparts(Session.EPI{c}{1}))), filesep, ModelFilename{c})};
        else
            error('Cannot recognize directory structure in Opts.DirStructure')
        end
        block.spm.stats.fmri_spec.sess(c).multi_reg = {Multi_Reg{c}};
        block.spm.stats.fmri_spec.sess(c).hpf = 128;
    end
else
    error('Cannot recognize sessions format')
end

block.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{batchNum-1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
block.spm.stats.fmri_est.write_residuals = 0;
block.spm.stats.fmri_est.method.Classical = 1;

batchNum = batchNum+1;

batchNum = batchNum+1;

end