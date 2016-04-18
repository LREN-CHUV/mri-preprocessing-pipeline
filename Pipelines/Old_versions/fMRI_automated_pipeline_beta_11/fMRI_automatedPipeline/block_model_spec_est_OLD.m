function [block batchNum] = block_model_spec_est(Session,Opts,prefixNIIf,block,batchNum)
%--------------------------------------------------------------------------
% SPM Model specification and estimation (removal of dummy scans is also
% done here) (RETROICOR and automatic contrasts (via SPM Contrast Manager)
% are also performed if requested)
%
%--------------------------------------------------------------------------
% INPUTS:
%--------------------------------------------------------------------------
%
% Session : cell of structure containing filepaths by image types, default
% file for EPI image distortion correction (FieldMap) if B0 maps are present,
% resolution of EPI runs (detected from folder name)
%
% Opts : see fMRI_automated_first_level.m (and fMRI_automated_preproc.m), but
%     here are the essential fields within this structure for this part of
%     data processing :
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
% prefixNIIf : string, prefix of fMRI scan, added job after job in an
% incremental way
%
% block : cells of jobs (previous jobs)
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
% 2014-08-28, @LREN, Renaud Marquis, refacto
%--------------------------------------------------------------------------

for Res = 1:length(Session) % ok here because 1 subject at a time, therefore index of resolution)
    
    %%% Create GLM directory
    if length(Session)<2
        if strcmpi(Opts.DirStructure,'DICOMimport')
            SubDir = fileparts(fileparts(Session{Res}.Struct{1}));
            NewDir = 'GLM';
        elseif strcmpi(Opts.DirStructure,'LRENpipeline')
            SubDir = fileparts(fileparts(fileparts(Session{Res}.Struct{1})));
            NewDir = 'GLM';
        else
            error('DirStructure not recognized')
        end
    else
        if strcmpi(Opts.DirStructure,'DICOMimport')
            SubDir = fileparts(fileparts(Session{Res}.Struct{1}));
            NewDir = strcat('GLM_',Session{Res}.EPIresolution{1});
        elseif strcmpi(Opts.DirStructure,'LRENpipeline')
            SubDir = fileparts(fileparts(fileparts(Session{Res}.Struct{1})));
            NewDir = strcat('GLM_',Session{Res}.EPIresolution{1});
        else
            error('DirStructure not recognized')
        end
    end
    OutputDir = strcat(SubDir,filesep,NewDir);
    block{batchNum} = MakeNewDir(SubDir,NewDir);
    
    
    nsess = length(Session{Res}.EPI);

    for sessnum = 1:nsess
        
        %%% Recover txt file with realignment parameters before removal of
        % dummies:
        [p n e] = fileparts(Session{Res}.EPI{sessnum}{1});
        ForMovParamFilename{sessnum} = strcat(p, filesep, 'rp_', n, '.txt');
        
        % Remove first lines of realignment parameter txt file if dummy
        % scans (because too many regressors otherwise):
        if Opts.DummyScans{Res}>0
            MovParam{sessnum} = load(ForMovParamFilename{sessnum});
            R = MovParam{sessnum}(Opts.DummyScans{Res}+1:end,:);
            RP{sessnum} = R;
            MovParam{sessnum} = spm_file(ForMovParamFilename{sessnum},'suffix','_dummies_truncated');
            MovParam{sessnum} = spm_file(MovParam{sessnum},'ext','.mat');
            save(MovParam{sessnum},'R');
        else
            RP{sessnum} = load(ForMovParamFilename{sessnum});
            MovParam{sessnum} = ForMovParamFilename{sessnum};
        end
        
        %%% Exclude dummy scans from GLM:
        if Opts.DummyScans{Res}>0
                        
            % Deal with format of EPI sessions whether it is a cell of strings
            % or a cell of cells of strings:
            if iscellstr(Session{Res}.EPI)
                Session{Res}.EPI = Session{Res}.EPI(Opts.DummyScans{Res}+1:end);
            else
                for c = 1:size(Session{Res}.EPI,2)
                    Check(c) = iscellstr(Session{Res}.EPI{c});
                end
                if sum(Check) == size(Session{Res}.EPI,2)
                    for c = 1:size(Session{Res}.EPI,2)
                        Session{Res}.EPI{c} = Session{Res}.EPI{c}(Opts.DummyScans{Res}+1:end);
                    end
                else
                    error('Cannot recognize sessions format')
                end
            end
            clear temp Temp
            
        end
    end
    
    %%% Perform RETROICOR (if requested)
    for sessnum = 1:nsess
        
        if isfield(Opts,'CorrectPhysioNoise')
            if Opts.CorrectPhysioNoise.MultipleSessInFile
                error('Multiple sessions in physio file not supported yet')
            end
            [Physio{sessnum}] = retroicor(Opts.CorrectPhysioNoise.PhysioPathFilename{Res}{nsess},Opts.CorrectPhysioNoise.sampling_rate,Opts.CorrectPhysioNoise.TRslice{Res}{nsess},Opts.CorrectPhysioNoise.Nslices{Res}{nsess},Opts.CorrectPhysioNoise.sliceorder,Opts.CorrectPhysioNoise.SliceNum{Res}{nsess},nsess,Opts.DummyScans{Res}); % RETROspective Image-based CORrection of physiological noise in fMRI data
            R=cat(2,Physio{sessnum},RP{sessnum});
            R=R-repmat(mean(R),size(Physio{sessnum},1),1);
            Rname = sprintf('%s_RP_session%d.mat',spm_str_manip(Opts.CorrectPhysioNoise.PhysioPathFilename{Res}{nsess},'r'),sessnum);
            save(Rname, 'R');
            MultiReg = R;
        else
            MultiReg{sessnum} = MovParam{sessnum};
        end
    end
    
    %%% MODEL SPECIFICATION
    block{batchNum+1}.spm.stats.fmri_spec.dir = cellstr(OutputDir);
    block{batchNum+1}.spm.stats.fmri_spec.timing.units = Opts.Unit;
    block{batchNum+1}.spm.stats.fmri_spec.timing.RT = Opts.TR{Res};
    block{batchNum+1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    block{batchNum+1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
    block{batchNum+1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    block{batchNum+1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    block{batchNum+1}.spm.stats.fmri_spec.volt = 1;
    block{batchNum+1}.spm.stats.fmri_spec.global = 'None';
    block{batchNum+1}.spm.stats.fmri_spec.mthresh = Opts.FirstLevelMaskingThreshold;
    block{batchNum+1}.spm.stats.fmri_spec.mask = {Opts.FirstLevelExplicitMask};
    block{batchNum+1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    
    for c = 1:size(Session{Res}.EPI,2)
        Check(c) = iscellstr(Session{Res}.EPI{c});
    end
    
    if sum(Check) == size(Session{Res}.EPI,2)
        if size(Session{c}.EPI,2)~=1
            
        for c = 1:size(Session{c}.EPI,2)
            % Add prefix before filename:
            Im = spm_file(Session{Res}.EPI{c},'prefix',prefixNIIf);
            block{batchNum+1}.spm.stats.fmri_spec.sess(c).scans = Im;
            block{batchNum+1}.spm.stats.fmri_spec.sess(c).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
            block{batchNum+1}.spm.stats.fmri_spec.sess(c).regress = struct('name', {}, 'val', {});
            if strcmpi(Opts.DirStructure,'DICOMimport')
                block{batchNum+1}.spm.stats.fmri_spec.sess(c).multi = {strcat(fileparts(fileparts(Session{Res}.EPI{c}{1})), filesep, Opts.ModelFoldername{Res}{c}, Opts.ModelFilename{Res}{c})};
            elseif strcmpi(Opts.DirStructure,'LRENpipeline')
                block{batchNum+1}.spm.stats.fmri_spec.sess(c).multi = {strcat(fileparts(fileparts(fileparts(Session{Res}.EPI{c}{1}))), filesep, Opts.ModelFoldername{Res}{c}, Opts.ModelFilename{Res}{c})};
            else
                error('Cannot recognize directory structure in Opts.DirStructure')
            end
            block{batchNum+1}.spm.stats.fmri_spec.sess(c).multi_reg = {MultiReg{c}};
            block{batchNum+1}.spm.stats.fmri_spec.sess(c).hpf = 128;
        end
        else
            % Add prefix before filename:
            Im = spm_file(Session{Res}.EPI{c},'prefix',prefixNIIf);
            block{batchNum+1}.spm.stats.fmri_spec.sess(c).scans = Im;
            block{batchNum+1}.spm.stats.fmri_spec.sess(c).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
            block{batchNum+1}.spm.stats.fmri_spec.sess(c).regress = struct('name', {}, 'val', {});
            if strcmpi(Opts.DirStructure,'DICOMimport')
                block{batchNum+1}.spm.stats.fmri_spec.sess(c).multi = strcat(fileparts(fileparts(Session{Res}.EPI{c}{1})), filesep, Opts.ModelFoldername{Res}, Opts.ModelFilename{Res}{c});
            elseif strcmpi(Opts.DirStructure,'LRENpipeline')
                block{batchNum+1}.spm.stats.fmri_spec.sess(c).multi = strcat(fileparts(fileparts(fileparts(Session{Res}.EPI{c}{1}))), filesep, Opts.ModelFoldername{Res}{c}, Opts.ModelFilename{Res}{c});
            else
                error('Cannot recognize directory structure in Opts.DirStructure')
            end
            block{batchNum+1}.spm.stats.fmri_spec.sess(c).multi_reg = {MultiReg{c}};
            block{batchNum+1}.spm.stats.fmri_spec.sess(c).hpf = 128;
        end
    else
        error('Cannot recognize sessions format')
    end
    
    %%% MODEL ESTIMATION
    block{batchNum+2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{batchNum+1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    block{batchNum+2}.spm.stats.fmri_est.write_residuals = Opts.WriteResiduals;
    block{batchNum+2}.spm.stats.fmri_est.method.Classical = 1;
    
    
    %%% CONTRAST MANAGER (if requested)
    if isfield(Opts,'Contrasts')
        block{batchNum+3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{batchNum+2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        block{batchNum+3}.spm.stats.con.delete = 0;
        
        if isfield(Opts.Contrasts,'F') && isfield(Opts.Contrasts,'T')
            NumCon = length(Opts.Contrasts.F)+length(Opts.Contrasts.T);
            con = 1;
            for fcon = 1:length(Opts.Contrasts.F)
                block{batchNum+3}.spm.stats.con.consess{con}.fcon.name = Opts.Contrasts.F{fcon}.name;
                block{batchNum+3}.spm.stats.con.consess{con}.fcon.weights = Opts.Contrasts.F{fcon}.weights;
                block{batchNum+3}.spm.stats.con.consess{con}.fcon.sessrep = 'none';
                con = con+1;
            end
            for tcon = 1:length(Opts.Contrasts.T)
                block{batchNum+3}.spm.stats.con.consess{con}.tcon.name = Opts.Contrasts.T{tcon}.name;
                block{batchNum+3}.spm.stats.con.consess{con}.tcon.weights = Opts.Contrasts.T{tcon}.weights;
                block{batchNum+3}.spm.stats.con.consess{con}.tcon.sessrep = 'none';
                con = con+1;
            end
        elseif isfield(Opts.Contrasts,'F')
            NumCon = length(Opts.Contrasts.F);
            con = 1;
            for fcon = 1:length(Opts.Contrasts.F)
                block{batchNum+3}.spm.stats.con.consess{con}.fcon.name = Opts.Contrasts.F{fcon}.name;
                block{batchNum+3}.spm.stats.con.consess{con}.fcon.weights = Opts.Contrasts.F{fcon}.weights;
                block{batchNum+3}.spm.stats.con.consess{con}.fcon.sessrep = 'none';
                con = con+1;
            end
        elseif isfield(Opts.Contrasts,'T')
            NumCon = length(Opts.Contrasts.T);
            con = 1;
            for tcon = 1:length(Opts.Contrasts.T)
                block{batchNum+3}.spm.stats.con.consess{con}.tcon.name = Opts.Contrasts.T{tcon}.name;
                block{batchNum+3}.spm.stats.con.consess{con}.tcon.weights = Opts.Contrasts.T{tcon}.weights;
                block{batchNum+3}.spm.stats.con.consess{con}.tcon.sessrep = 'none';
                con = con+1;
            end
        else
            NumCon = 0;
        end
        
    end
    
    batchNum = batchNum+4;
    
end

end
