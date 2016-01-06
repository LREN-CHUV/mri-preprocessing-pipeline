function [Input_DWI, Output_response_file, mrtrixParams] = dwi2response(Input_DWI, Output_response_file, Input_DWI_mask,mrtrixParams)

% This function estimates the CSD response function for a preprocessed DWI
% dataset. The response function is used to estimate the DWI signal from a
% single coherent fiber bundle. This can then be used to 'deconvolve'
% signals in more complex white matter in order to resolve crossing fiber
% bundles.
% IMPORTANT: mrtrix/bin *must* be in the global path
%
% Input_DWI = Full path to the prepprocessed HARDI data (high b-value, single shell data)
% Output_response_file = Full path to save the response.txt file
% Input_DWI_mask = Brain mask of the DWI data
% mrtrixParams = Parameters to be used for processing
%
% NOTE: If inputs are left blank ('') then defaults will be used or the
%       user will be ask to select appropriate files.
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

% Fiber response output
if ~exist(Output_response_file,'file') || isempty(Output_response_file)
    if isempty(mrtrixParams.SubjectName)
        SubPrefix = '';
    else SubPrefix = [mrtrixParams.SubjectName '_'];
    end
    Output_response_file=fullfile(pathstr,[SubPrefix 'Response.txt']);
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
        [bvecsName,bvecsPath] = uigetfile([pathstr filesep '*.bvec*'],'Select the bvecs');
        mrtrixParams.fslbvecs = fullfile(bvecsPath,bvecsName);
    end
end
if ~exist(mrtrixParams.fslbvals,'file')
    mrtrixParams.fslbvals = fullfile(pathstr,[name '.bvals']);
    if ~exist(mrtrixParams.fslbvals,'file')
        [bvalsName,bvalsPath] = uigetfile([pathstr filesep '*.bval*'],'Select the bvals');
        mrtrixParams.fslbvals = fullfile(bvalsPath,bvalsName);
    end
end


%% Build mrtrix dwi2response command

fsl_option = ['-fslgrad ' mrtrixParams.fslbvecs ' ' mrtrixParams.fslbvals ' '];
lmax_option = ['-lmax ' num2str(mrtrixParams.lmax) ' '];
mask_option = ['-mask ' Input_DWI_mask ' '];
sf_option = '';
if mrtrixParams.saveResponsemask == true
    if isempty(mrtrixParams.Resposemaskpath)
        mrtrixParams.Resposemaskpath = fullfile(pathstr,[name '_responsemask.nii']);
    end
    sf_option = ['-sf ' mrtrixParams.Resposemaskpath ' '];
end
multitread_option = ['-nthreads ' num2str(mrtrixParams.numthreads) ' '];
if mrtrixParams.multithread==false
    multitread_option = '';
end
if mrtrixParams.forceoverwrite==true
    force_option = '-force ';
else force_option = '';
end

cat_options = [fsl_option lmax_option mask_option sf_option multitread_option force_option];

dwi2response_command = ['dwi2response ' cat_options Input_DWI ' ' Output_response_file];
mrtrixParams.commands.dwi2response = dwi2response_command;

%% Run the dwi2response_command outside of matlab
if mrtrixParams.commandsOnly==false;
    [jobstatus,cmdout] = unix(dwi2response_command,'-echo');
    if ~(jobstatus==0)
        disp('There was a problem executing the dwi2response operating system command. The command did not complete successfully')
        disp(cmdout)
        
    end
end


