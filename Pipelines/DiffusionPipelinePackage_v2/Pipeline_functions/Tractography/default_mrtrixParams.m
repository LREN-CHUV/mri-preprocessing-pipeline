function mrtrixParams = default_mrtrixParams
% 
% Initialise the default parameters for mrtrix processing
% 
% (C) D Slater, LREN 17/12/2014


mrtrixParams.mrtrixPATH = '/data/lren/program/mrtrix3'; % Path to mrtrix. By default the HPC1 location.
mrtrixParams.HPCdirPATH = '/data/lren/Diff_Tractography'; % If saving commands only this is assumed to be the basedir for copied /Subject/HARDI folders on HPC system
mrtrixParams.DWIpath = '';              % This will be autmatically set and used in later processing stages
mrtrixParams.SubjectName = '';          % Subject identifier. If provided certain files will prefix this string.
mrtrixParams.forceoverwrite = 1;        % If true overwrite existing files **Need to include this in command creation**
mrtrixParams.lmax = 8;                  % Maximum harmonic order (lmax). lmax=8 requires 45 directions; lmax=10 requires 66 directions
mrtrixParams.fslbvecs = '';             % Path to fsl bvecs
mrtrixParams.fslbvals = '';             % Path to fsl bvals
mrtrixParams.saveResponsemask = true;   % If true the voxel mask used to create the response function will be saved
mrtrixParams.Resposemaskpath = '';      % Option to specify the reponse mask output path
mrtrixParams.commandsOnly = true;      % If true then commands will be created but not run by matlab
mrtrixParams.commands = '';             % mrtrix commands will be generated as each stage is run.
mrtrixParams.superresolvedCSD = true;   % If true FoDs will be computed with a higher spherical harmonic order than the data natively supports.
mrtrixParams.multithread = false;        % If true will use multi core parallel processing
mrtrixParams.numthreads = 1;            % Number of cores (threads) to use in parallel processing
mrtrixParams.TrackChoice = 'iFOD2';     % FACT, iFOD1, iFOD2, Nulldist, SD_Stream, Seedtest, Tensor_Det, Tensor_Prob (default: iFOD2).
mrtrixParams.numTracks = 20E6;         % Number of tracks added to output file before stopping tracking
mrtrixParams.quietTCK = true;           % If true do not display tracking output
mrtrixParams.StepSize = '';             % Tractography algorithm step size (in mm). If blank default mrtrix settings are used
mrtrixParams.Angle = '';                % Tractography algorithm angular threshold. If blank default mrtrix settings are used
mrtrixParams.maxLength = 400;           % Maximum allowed length of tracks in output (in mm)
mrtrixParams.minLength = 2;            % Minimum allowed length of tracks in output (in mm)
mrtrixParams.cutoff = '';               % Min. FA or FOD threshold for tracking. If blank default mrtrix settings are used
mrtrixParams.use_rk4 = false;           % If true use 4th order Runge-Kuta algorithm for tracking
mrtrixParams.downsample = true;        % If true fiber tracts are downsampled to save disk space
mrtrixParams.downsample_factor = 2;     % The factor by which streamlines should be down sampled to reduce tck file size
mrtrixParams.tdi_voxelsize = 0.7;       % Output voxel size for track density imaging (tdi)
mrtrixParams.do_DEC_tdi = true;         % If true the tdi map will have DEC colour encoding
mrtrixParams.tdi_contrast = 'tdi';      % Define the desired form of contrast for the output image. Options are: tdi, length, invlength, scalar_map, scalar_map_count, fod_amp, curvature (default: tdi)
mrtrixParams.precise_tdi = true;       % If true a more precise mapping stategy is used which takes account of fiber length through each voxel
mrtrixParams.doACT = true;              % If true ACT framework will be used. If no anatomical image is supplied ACT processes will be skipped
mrtrixParams.Output5TT = '';            % Empty as default. Created by the wrapper after 5TT generation
mrtrixParams.backtrack = true;         % If true rejected fibers will back-track and re-run until they find an accepted trajectory
mrtrixParams.doSIFT = true;             % When true SIFT tractogram filtering will be performed
mrtrixParams.term_number = ...
    round(mrtrixParams.numTracks/2);   % Tract termination value for SIFT. By default 90% of fibers will be filtered
mrtrixParams.doSIFT2 = true;            % Run the SIFT2 algorithm on .tck data. If SIFT previously performed use it's output
mrtrixParams.connectome = true;         % If true freesurfer segmentation will be performed and connectome matrix calculated
mrtrixParams.fsurf_script_path = '/data/lren/DSLATER/my_submit_lren_MPM.sh'; % Path to the freesurfer processing script
mrtrixParams.qMRIpath = '';             % Path to folder containing all qMRI maps for FreeSurfer processing
mrtrixParams.config_in = '/data/lren/program/mrtrix3/fs_default.txt'; %The MRtrix connectome configuration file path
mrtrixParams.LUTpath = '/data/lren/program/freesurfer/FreeSurferColorLUT.txt'; % Path to FreeSurfer look up table file
mrtrixParams.useHPC = 1;                % If using HPC1 set true
mrtrixParams.HPCscratch = '/scratch';   % HPC1 scratch path where large .tck files can be written for local nodes.
mrtrixParams.b2000CanonicalResponse = '/data/lren/program/mrtrix3/CanonicalResponse_200subj_290kVox_b2000.txt';
mrtrixParams.b3000CanonicalResponse = '/data/lren/program/mrtrix3/CanonicalResponse_100subj_14kVox_b3000.txt';

