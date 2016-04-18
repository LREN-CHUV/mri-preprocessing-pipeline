function AMICO_FitWrapper(basedir,datadir,DWIpath,maskpath,schemepath,DTIfitmethod)
% 
% Wrapper function for the AMICO NODDI fitting proceedure. Output will be
% stored within the datadir. Typically the DWI, mask and scheme data will
% also be within the datadir but this is not required.
% 
% basedir = fullpath one folder up from datadir e.g. 'C:\Data\Subject1\'
% datadir = folder name containing DWI, mask and scheme data e.g. 'NODDI\'
% DWIpath = path to the DWI data
% maskpath = path to the mask file
% schemepath = path to the Camino scheme file
% DTIfitmethod = 0 (LLS), 1 (WLLS), 2(CNLLS)

if ~exist(basedir,'dir') || isempty(basedir) || ~exist([basedir filesep datadir],'dir') || isempty(datadir)
    selectdir = uigetdir(pwd,'Please select the DWI data folder:');
    [basedir, datadir] = fileparts(selectdir);
end


% Setup AMICO
AMICO_Setup

% Pre-compute auxiliary matrices to speed-up the computations
AMICO_PrecomputeRotationMatrices(); % NB: this needs to be done only once and for all. If previously run this will be skipped.

% Set the folder containing the data (relative to the data folder).
% This will create a CONFIG structure to keep all the parameters.
AMICO_SetSubject( basedir, datadir);

% Setup correct file paths
CONFIG.dwiFilename    = DWIpath;
CONFIG.maskFilename   = maskpath;
CONFIG.schemeFilename = schemepath;

% Load the dataset in memory
AMICO_LoadData

% Configure AMICO to use the 'NODDI' model
AMICO_SetModel( 'NODDI' );

% Generate the kernels corresponding to the protocol
AMICO_GenerateKernels( false );

% Resample the kernels to match the specific subject's scheme
AMICO_ResampleKernels();

% Load the kernels in memory
KERNELS = AMICO_LoadKernels();

% Begin the AMICO model fitting
AMICO_Fit(DTIfitmethod)

% Delete KERNELS from disk
KERNELSpath = fullfile( CONFIG.OUTPUT_path, sprintf('kernels_%s.mat',CONFIG.kernels.model) );
if exist(KERNELSpath,'file')
    delete(KERNELSpath)
end

% Delete protocol kernels - e.g. the 'common' dir
kernel_folder = fullfile(basedir,'common');
rmdir(kernel_folder,'s')

clear all