function [Input_FOD, Output_tck, mrtrixParams] = tckgen(Input_FOD, Output_tck, Seed_mask, Brain_mask, mrtrixParams)

% This will perform tractography based on the previously calculated FODs.
% IMPORTANT: mrtrix/bin *must* be in the global path
%
% Input_FOD = Full path to the previously computed FOD file
% Output_tck = Full path to output tractography (.tck) file
% Seed_mask = Seed mask of region to start tractography
% Brain_mask = Brain mask used to terminate fibers leaving the brain
% mrtrixParams = Parameters to be used for processing
%
% NOTE: If inputs are left blank ('') then defaults will be used or the
%       user will be ask to select appropriate files.
%
% Additional options can be configured within the mrtrixParams structure
%
% (C) D Slater, LREN 17/12/2014

%% Check that input variables are correct

% Calculated FOD file
if ~exist(Input_FOD,'file') && (~mrtrixParams.commandsOnly == true || isempty(Input_FOD))
    [FileName,PathName] = uigetfile('.nii','Select the FOD data');
    Input_FOD=fullfile(PathName,FileName);
end
if exist(Input_FOD,'file')
    [pathstr,name,ext] = fileparts(Input_FOD);
else [pathstr,name,ext] = fileparts(mrtrixParams.DWIpath);
    name = [name '_fod'];
end

% Track output
if isempty(Output_tck)
    Output_tck=fullfile(pathstr,[name '.tck']);
end

% Seed mask
if ~exist(Seed_mask,'file')
    [MaskName,MaskPath] = uigetfile([pathstr filesep '*.nii'],'Select the Seed mask');
    Seed_mask=fullfile(MaskPath,MaskName);
end

% Brain mask
if ~exist(Brain_mask,'file')
    [MaskName,MaskPath] = uigetfile([pathstr filesep '*.nii'],'Select the Brain mask');
    Brain_mask=fullfile(MaskPath,MaskName);
end

% Check/Load settings
if isempty(mrtrixParams) || ~isfield(mrtrixParams,'lmax')
    mrtrixParams = default_mrtrixParams;
end


%% Build tckgen command

Seedmask_option = ['-seed_image ' Seed_mask ' '];
Brainmask_option = ['-mask ' Brain_mask ' '];
multitread_option = ['-nthreads ' num2str(mrtrixParams.numthreads) ' '];
if mrtrixParams.multithread==false
    multitread_option = '';
end
algorithm_option = ['-algorithm ' mrtrixParams.TrackChoice ' '];
numtracks_option = ['-number ' num2str(mrtrixParams.numTracks) ' '];
StepSize_option = ['-step ' num2str(mrtrixParams.StepSize) ' '];
if isempty(mrtrixParams.StepSize)
    StepSize_option = '';
end
Angle_option = ['-angle ' num2str(mrtrixParams.Angle) ' '];
if isempty(mrtrixParams.Angle)
    Angle_option = '';
end
maxLength_option = ['-maxlength ' num2str(mrtrixParams.maxLength) ' '];
if isempty(mrtrixParams.maxLength)
    maxLength_option = '';
end
minLength_option = ['-minlength ' num2str(mrtrixParams.minLength) ' '];
if isempty(mrtrixParams.minLength)
    minLength_option = '';
end
cutoff_option = ['-cutoff ' num2str(mrtrixParams.cutoff) ' '];
if isempty(mrtrixParams.cutoff)
    cutoff_option = '';
end
if mrtrixParams.use_rk4==1
    rk4_option = '-rk4 '; else rk4_option = '';
end
if mrtrixParams.downsample==1
    downsample_option = ['-downsample ' num2str(mrtrixParams.downsample_factor) ' ']; else downsample_option = '';
end
if mrtrixParams.doACT==1 && (exist(mrtrixParams.Output5TT,'file') || mrtrixParams.commandsOnly==1)
    ACT_option = ['-act ' mrtrixParams.Output5TT ' ']; else ACT_option = '';
end
if mrtrixParams.doACT==1 && mrtrixParams.backtrack==1 && (exist(mrtrixParams.Output5TT,'file') || mrtrixParams.commandsOnly==1)
    backtract_option = ['-backtrack ']; else backtract_option = '';
end
if mrtrixParams.quietTCK==1 || mrtrixParams.numTracks>10^6
    quiet_option = ['-quiet ']; else quiet_option = '';
end
if mrtrixParams.forceoverwrite==true
    force_option = '-force ';
else force_option = '';
end

cat_options = [Seedmask_option, Brainmask_option, multitread_option, algorithm_option ...
    numtracks_option, StepSize_option, Angle_option, maxLength_option, minLength_option ...
    cutoff_option, rk4_option, downsample_option, ACT_option, backtract_option quiet_option force_option];

tckgen_command = ['tckgen ' cat_options Input_FOD ' ' Output_tck];
mrtrixParams.commands.tckgen = tckgen_command;


%% Run the tckgen_command outside of matlab

if mrtrixParams.commandsOnly==false;
    [status,cmdout] = unix(tckgen_command);
    if ~(status==0)
        disp('There was a problem executing the tckgen operating system command. The command did not complete successfully')
        disp(cmdout)
    end
end



