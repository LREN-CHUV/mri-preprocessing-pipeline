function [Input_tck, Output_tdi, mrtrixParams] = tckmap(Input_tck, Output_tdi, voxel_size, mrtrixParams)

% This will create output maps summarising the tractography data e.g. TDI.
% IMPORTANT: mrtrix/bin *must* be in the global path
%
% Input_tck = Full path to the previously computed tck file
% Output_tdi = Full path to output track map (.nii) file
% voxel_size = Voxel size for binning of track data
% mrtrixParams = Parameters to be used for processing
%
% NOTE: If inputs are left blank ('') then defaults will be used or the
%       user will be ask to select appropriate files.
%
% Additional options can be configured within the mrtrixParams structure
%
% (C) D Slater, LREN 17/12/2014

%% Check that input variables are correct

% Calculated .tck file
if ~exist(Input_tck,'file') && ~mrtrixParams.commandsOnly==1
    [FileName,PathName] = uigetfile('.tck','Select the tck data');
    Input_tck=fullfile(PathName,FileName);
end
SIFT_suffix = '';
if exist(Input_tck,'file')
    [pathstr,name,ext] = fileparts(Input_tck);
else [pathstr,name,ext] = fileparts(mrtrixParams.DWIpath);
    if mrtrixParams.doSIFT == true
        SIFT_suffix = '_SIFT';
    end
end
if ~isempty(strfind(mrtrixParams.DWIpath,'.gz'))
    C = strsplit(name,'.');
    name = C{1};
end

% Track density imaging (tdi) output
if isempty(Output_tdi)
    if mrtrixParams.doSIFT2 == true
        SIFT_suffix = 'SIFT2';
    end
    if mrtrixParams.do_DEC_tdi == true
        Output_tdiDEC = fullfile(pathstr,[name SIFT_suffix '_' 'DEC' mrtrixParams.tdi_contrast '.nii.gz']);
    end
    Output_tdi=fullfile(pathstr,[name SIFT_suffix '_' mrtrixParams.tdi_contrast '.nii.gz']);
end

% Check/Load settings
if isempty(mrtrixParams) || ~isfield(mrtrixParams,'lmax')
    mrtrixParams = default_mrtrixParams;
end

% Voxel size for tdi output
if ~isempty(voxel_size)
    mrtrixParams.tdi_voxelsize = voxel_size;
end


%% Build tckmap command

multitread_option = ['-nthreads ' num2str(mrtrixParams.numthreads) ' '];
if mrtrixParams.multithread==false
    multitread_option = '';
end
voxel_option = ['-vox ' num2str(mrtrixParams.tdi_voxelsize) ' '];
if mrtrixParams.do_DEC_tdi==1
    dec_option = '-dec '; else dec_option = '';
end
contrast_option = ['-contrast ' mrtrixParams.tdi_contrast ' '];
if mrtrixParams.precise_tdi==1
    precise_option = '-precise '; else precise_option = '';
end
if mrtrixParams.forceoverwrite==true
    force_option = '-force ';
else force_option = '';
end
if mrtrixParams.doSIFT2
    tck_weights = ['-tck_weights_in ' mrtrixParams.SIFT2_weights ' '];
else tck_weights = '';
end

cat_options = [multitread_option, voxel_option, contrast_option, precise_option force_option tck_weights];
if mrtrixParams.do_DEC_tdi==1
    cat_options2 = [multitread_option, voxel_option, dec_option, contrast_option, precise_option force_option tck_weights];
    DEC_command = ['; tckmap ' cat_options2 Input_tck ' ' Output_tdiDEC];
else DEC_command = '';
end

tckmap_command = ['tckmap ' cat_options Input_tck ' ' Output_tdi DEC_command];
mrtrixParams.commands.tckmap = tckmap_command;


%% Run the tckmap_command outside of matlab

if mrtrixParams.commandsOnly==false;
    [status,cmdout] = unix(tckmap_command,'-echo');
    if ~(status==0)
        disp('There was a problem executing the tckmap operating system command. The command did not complete successfully')
        disp(cmdout)
    end
end



