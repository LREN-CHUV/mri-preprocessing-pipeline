function commandspath = mrtrix_wrapper(Input_DWI,Input_DWI_mask,Anatomical_Image,BaseDirPath,mrtrixParams)
% This function will create the required commands to perform constrained
% spherical deconvolution (CSD) tractography. The basic processing
% proceedures will provide output files that can the be used for specific
% user defined probabilistic tractography applications.
%
% Input_DWI = The preprocessed DWI data to be used for tractography
% Input_DWI_mask = A mask file for the DWI data
% Anatomical_Image = An anatomical T1w MPRAGE or MT dataset (note: if using
%       an MT image it should be names myanatomicalimage_MT.nii
% BaseDirPath = The base directory above your subject directory. In
%       otherwords, the folder from which data will be copied to HPC1.
% mrtrixParams = The parameters used for the tractography pipeline. If
%       these are empty then the default_mrtrixParams function will be called.
%
% (C) D Slater, LREN 22/12/2014
%

%% A. Setup variables

% Preprocessed DWIs
if ~exist(Input_DWI,'file')
    [FileName,PathName] = uigetfile('.nii','Select the DWI data');
    Input_DWI=fullfile(PathName,FileName);
end
[pathstr,name,ext] = fileparts(Input_DWI);
HARDI_path = pathstr;

% Brain mask
if ~exist(Input_DWI_mask,'file')
    [MaskName,MaskPath] = uigetfile([pathstr filesep '*.nii'],'Select the DWI mask');
    Input_DWI_mask=fullfile(MaskPath,MaskName);
end

% Check/Load settings
if isempty(mrtrixParams) || ~isfield(mrtrixParams,'lmax')
    mrtrixParams = default_mrtrixParams;
end

% Set the DWI path within the mrtrixParams structure
mrtrixParams.DWIpath = Input_DWI;

% Check is anatomical image is supplied and if it is MT or T1
if isempty(Anatomical_Image) || ~exist(Anatomical_Image,'file')
    mrtrixParams.doACT = false;
elseif ~isempty(strfind(Anatomical_Image, '_MT')) && isempty(strfind(Anatomical_Image, 'x1000'))
    % If using the MT image scale by x1000
    Anatomical_Image = ScaleData(Anatomical_Image,1000);
    disp('Using an MT template scaled by x1000')
    disp('------------------------------------')
    copyfile(Anatomical_Image,mrtrixParams.qMRIpath)
end

%% I. dwi2response
% This function is used to estimate the high FA (>0.7) voxels within a
% dataset. These are then used to estimate the fiber response function used
% to deconvolve the DWI signal and crossing fiber bundles.

[Input_DWI, Output_response_file, mrtrixParams] = dwi2response(Input_DWI, '', Input_DWI_mask,mrtrixParams);

if ~mrtrixParams.commandsOnly==true
    disp('--------------------------')
    disp('dwi2response has completed')
    disp(['Response file saved as: ' Output_response_file])
else
    disp('--------------------------')
    disp('dwi2response commands have been calculated')
end


%% II. dwi2fod
% The Output_response_file from dwi2response is now used to estimate the
% fiber orientation distribution (FOD) at each voxel. This contains the
% crossing fiber information which can be later used for tractography.

Input_response_file = Output_response_file;

[~, Output_fod, mrtrixParams] = dwi2fod(Input_DWI, Input_response_file, '', Input_DWI_mask,mrtrixParams);

if ~mrtrixParams.commandsOnly==true
    disp('--------------------------')
    disp('dwi2fod has completed')
    disp(['FOD estimates saved as: ' Output_fod])
else
    disp('--------------------------')
    disp('dwi2fod commands have been calculated')
end

%% III. ACT 5TT segmentation
% Here the provided anatomical image will be used to create the 5 tissue
% type segmentation (5TT). This is done via a call script to FSL.

[Anatomical_Image, Output5TT, mrtrixParams] = ACT_5TT_generate(Anatomical_Image,'',mrtrixParams);

if ~mrtrixParams.commandsOnly==true
    disp('--------------------------')
    disp('5TT generation has completed')
    disp(['5TT file saved as: ' Output5TT])
else
    disp('--------------------------')
    disp('5TT generation commands have been calculated')
end


%% IV. tckgen
% This is the tractography section of preprocessing. By default this will
% run whole brain CSD probabilistic tractography. A number of additional
% settings can be changed in the mrtrixParams structure.

Input_FOD = Output_fod;
Brain_mask = Input_DWI_mask;
Seed_mask = Brain_mask;

[~, Output_tck, mrtrixParams] = tckgen(Input_FOD, '', Seed_mask, Brain_mask, mrtrixParams);

if ~mrtrixParams.commandsOnly==true
    disp('--------------------------')
    disp('tckgen has completed')
    disp(['Tractography file saved as: ' Output_tck])
else
    disp('--------------------------')
    disp('tckgen commands have been calculated')
end

%% V. SIFT
% Dense tractograms can be filtered using the SIFT algorithm.

if mrtrixParams.doSIFT ==1 || mrtrixParams.doSIFT2
    Input_tck = Output_tck;
    [Output_tck, mrtrixParams] = tcksift(Input_tck, Input_FOD, '', mrtrixParams);
end


%% VI. tckmap
% Tractography output will be used to generate a super-resolution tract
% density image (TDI). Additional settings can be configured in the
% mrtrixParams structure.

Input_tck = Output_tck;

[~, Output_tdi, mrtrixParams] = tckmap(Input_tck, '', '', mrtrixParams);

if ~mrtrixParams.commandsOnly==true
    disp('--------------------------')
    disp('tckmap has completed')
    disp(['Track density image (TDI) file saved as: ' Output_tdi])
else
    disp('--------------------------')
    disp('tckmap commands have been calculated')
end

%% VII. Connectome mapping
% This section uses freesurfer segmentations to map the connectome.

connectome_dir = [HARDI_path filesep 'connectome'];
if ~exist(connectome_dir,'dir');
    mkdir(connectome_dir);
end

CC = strsplit(name,'.');
connectome_output = [connectome_dir filesep CC{1} '_connectome'];

mrtrixParams = connectome_map(Input_tck, connectome_output, Anatomical_Image, mrtrixParams);

if ~mrtrixParams.commandsOnly==true
    disp('--------------------------')
    disp('tck2connectome has completed')
    disp(['Connectome matrices saved to: ' connectome_dir])
else
    disp('--------------------------')
    disp('tck2connectome commands have been calculated')
end

disp('--------------------------')
disp('------------------------------------')

%% B. Save computed mrtrix commands as a .sh file for running on HPC clusters

if isempty(mrtrixParams.SubjectName)
    SubPrefix = '';
else SubPrefix = [mrtrixParams.SubjectName '_'];
end

% commandspath = [pathstr filesep SubPrefix 'mrtrix_commands.sh'];
commandsprefix = [pathstr filesep SubPrefix];

% if exist(commandspath,'file')
%     delete(commandspath)
% end

% save_commands(commandspath, BaseDirPath, mrtrixParams)
save_commandsv2(commandsprefix, BaseDirPath, mrtrixParams)

