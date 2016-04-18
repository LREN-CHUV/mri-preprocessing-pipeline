
% Top-level automated preprocessing of fMRI data using Parallel Computing
% Toolbox :

%% CHECK
% Available memory on machine :
memory
% Number of cores :
NbCores = feature('numCores');
fprintf('This machine has %d cores\n',NbCores)

% On our cluster, the number of cores should be 12, but check it
if NbCores ~= 12
    warning('Check number of cores on cluster carefully, should normally be 12')
end

% Check maximal number of workers allowed on the machine :
c = parcluster('local'); % build the 'local' cluster object
nw = c.NumWorkers;        % get the number of workers
fprintf('Maximal number of workers : %d\n',nw);

%% INITIALIZE
% Number of subjects to process :
Nsub = 70;
% add path to SPM and fMRI pipeline :
addpath 'D:\Users DATA\Users\Renaud\spm12b'
addpath 'D:\Users DATA\Users\Renaud\fMRI_automated_pipeline'
spm_jobman('initcfg');
% Create jobs : CHECK fmri_pipeline_config.txt BEFOREHAND !! (or check Opts)
RootPath = 'D:\Users DATA\Users\Renaud\PD';
[matlabbatch_par1 matlabbatch_across matlabbatch_par2 matlabbatch_par3 Session Opts prefixNIIf] = fMRI_automated_preproc_parallel(RootPath,'');

%% PROCESS JOBS IN PARALLEL
if matlabpool('size') == 0 % checking to see if my pool is already open
    matlabpool open 12 % eventually replace "12" by the actual number of cores on the machine
end

% Realign (and unwarp), bias-correct, coregister, and segment
parfor sub = 1:Nsub
    spm_jobman('run',matlabbatch_par1{sub});
end

% DARTEL (if asked)
if ~isa(matlabbatch_across,'char')
    spm_jobman('run',matlabbatch_across);
end

% Normalize
parfor sub = 1:Nsub
    spm_jobman('run',matlabbatch_par2{sub});
end

% Smooth
parfor sub = 1:Nsub
    spm_jobman('run',matlabbatch_par3{sub});
end

%% INITIALIZE
matlabbatch_1st = fMRI_automated_first_level_parallel(Session,prefixNIIf,Opts);

%% PROCESS JOBS IN PARALLEL
parfor sub = 1:Nsub
    spm_jobman('run',matlabbatch_1st{sub});
end

% close workers
matlabpool close

