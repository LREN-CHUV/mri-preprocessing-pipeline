function [Input_DWI, Output_fod, mrtrixParams] = dwi2fod(Input_DWI, Input_response_file, Output_fod, Input_DWI_mask,mrtrixParams)

% This will perform CSD based on a previously computed response function.
% The output fiber orientation distributions (FODs) can then be used for
% all later tractography (deterministic or probabilistic).
% IMPORTANT: mrtrix/bin *must* be in the global path
%
% Input_DWI = Full path to the prepprocessed HARDI data (high b-value, single shell data)
% Input_response_file = Full path to previously computed response.txt file
% Output_fod = Full path to output FOD
% Input_DWI_mask = Brain mask of the DWI data
% mrtrixParams = Parameters to be used for processing
%
% NOTE: If inputs are left blank ('') then defaults will be used or the
%       user will be ask to select appropriate files.
%
% Additional options can be configured within the mrtrixParams structure
%
% (C) D Slater, LREN 17/12/2014


%% Check that input variables are correct

% Preprocessed DWIs
if ~exist(Input_DWI,'file')
    [FileName,PathName] = uigetfile('.nii','Select the DWI data');
    Input_DWI=fullfile(PathName,FileName);
end
[pathstr,name,ext] = fileparts(Input_DWI);
if ~isempty(strfind(Input_DWI,'.gz'))
    C = strsplit(name,'.');
    name = C{1};
end

% Fiber response input
if ~exist(Input_response_file,'file') && ~mrtrixParams.commandsOnly == true
    [FileName,PathName] = uigetfile([pathstr filesep '*.txt'],'Select the response function file');
    Input_response_file=fullfile(PathName,FileName);
end

% Fiber response output
if isempty(Output_fod)
    Output_fod=fullfile(pathstr,[name '_fod.nii']);
end

% Brain mask
if ~exist(Input_DWI_mask,'file')
    [MaskName,MaskPath] = uigetfile([pathstr filesep '*.nii'],'Select the DWI mask');
    Input_DWI_mask=fullfile(MaskPath,MaskName);
end

% Check/Load settings
if isempty(mrtrixParams) || ~isfield(mrtrixParams,'lmax')
    mrtrixParams = default_mrtrixParams;
end

% bvals/bvecs files
if ~exist(mrtrixParams.fslbvecs,'file')
    mrtrixParams.fslbvecs = fullfile(pathstr,[name '.bvecs']);
    if ~exist(mrtrixParams.fslbvecs,'file')
        [bvecsName,bvecsPath] = uigetfile([pathstr filesep '*.bvecs'],'Select the bvecs');
        mrtrixParams.fslbvecs = fullfile(bvecsPath,bvecsName);
    end
end
if ~exist(mrtrixParams.fslbvals,'file')
    mrtrixParams.fslbvals = fullfile(pathstr,[name '.bvals']);
    if ~exist(mrtrixParams.fslbvals,'file')
        [bvalsName,bvalsPath] = uigetfile([pathstr filesep '*.bvals'],'Select the bvals');
        mrtrixParams.fslbvals = fullfile(bvalsPath,bvalsName);
    end
end

%% Build dwi2fod command

fsl_option = ['-fslgrad ' mrtrixParams.fslbvecs ' ' mrtrixParams.fslbvals ' '];
if mrtrixParams.superresolvedCSD == true
    lmax_option = ['-lmax ' '10' ' ']; else lmax_option = ['-lmax ' num2str(mrtrixParams.lmax) ' '];
end
mask_option = ['-mask ' Input_DWI_mask ' '];
multitread_option = ['-nthreads ' num2str(mrtrixParams.numthreads) ' '];
if mrtrixParams.multithread==false
    multitread_option = '';
end
if mrtrixParams.forceoverwrite==true
    force_option = '-force ';
else force_option = '';
end

cat_options = [fsl_option, lmax_option, mask_option, multitread_option force_option];
dwi2fod_command = ['dwi2fod ' cat_options Input_DWI ' ' Input_response_file ' ' Output_fod];
mrtrixParams.commands.dwi2fod = dwi2fod_command;


%% Run the dwi2fod_command outside of matlab

if mrtrixParams.commandsOnly==false;
    [status,cmdout] = unix(dwi2fod_command,'-echo');
    if ~(status==0)
        disp('There was a problem executing the dwi2fod operating system command. The command did not complete successfully')
        disp(cmdout)
    end
end



