function mrtrixParams = connectome_map(Input_tck, connectome_output, AnatomicalImage, mrtrixParams)

% This will perform the FreeSurfer cortical surface methods on structural
% image data and extract the connectome matrix based on the standard
% FreeSurfer parcellation.
% IMPORTANT: mrtrix/bin *must* be in the global path
%
% Input_tck = Full path to the previously computed tck file
%
%
% NOTE: If inputs are left blank ('') then defaults will be used or the
%       user will be ask to select appropriate files.
%
% Additional options can be configured within the mrtrixParams structure
%
% (C) D Slater, LREN 30/04/2015

%% Check that input variables are correct

% Check anatomical file exists
if ~exist(AnatomicalImage,'file')
    [FileName,PathName] = uigetfile('.nii','Select the anatomical data');
    AnatomicalImage = fullfile(PathName,FileName);
else [Path, Name, ext] = fileparts(AnatomicalImage);
end

% Calculated .tck file
if ~exist(Input_tck,'file') && ~mrtrixParams.commandsOnly==1
    [FileName,PathName] = uigetfile('.tck','Select the tck data');
    Input_tck=fullfile(PathName,FileName);
end
if isempty(mrtrixParams.qMRIpath)
    mrtrixParams.qMRIpath = uigetdir('','Select the folder for FreeSurfer processing');
end

% Check/Load settings
if isempty(mrtrixParams) || ~isfield(mrtrixParams,'lmax')
    mrtrixParams = default_mrtrixParams;
end

% Find all relevant qMRI maps for connectome weights
qMRI_maps = cellstr(pickfiles(mrtrixParams.qMRIpath,{'.nii'},{'_MT.nii','_FAmap.nii','ficvf.nii'}));



%% Build connectome mapping commands

multitread_option = ['-nthreads ' num2str(mrtrixParams.numthreads) ' '];
if mrtrixParams.multithread==false
    multitread_option = '';
end
if mrtrixParams.forceoverwrite==true
    force_option = '-force ';
else force_option = '';
end

freesurf_command = [mrtrixParams.fsurf_script_path ' ' mrtrixParams.qMRIpath];
scriptloc = [mrtrixParams.mrtrixPATH filesep 'scripts'];

parcellation_output = [mrtrixParams.qMRIpath filesep 'Parcellated_image.nii'];
parcellation_output2 = [mrtrixParams.qMRIpath filesep 'Parcellated_image_fixSGM.nii'];
labelconfig_command = ['labelconfig ' mrtrixParams.qMRIpath '/freesurfer/mri/aparc+aseg.mgz ' mrtrixParams.config_in ' ' parcellation_output ' -lut_freesurfer ' mrtrixParams.LUTpath '; cd ' scriptloc ';  chmod +x ./fs_parc_replace_sgm_first; ./fs_parc_replace_sgm_first ' parcellation_output ' ' AnatomicalImage ' ' mrtrixParams.config_in ' ' parcellation_output2 '; cd ' Path];

connectome_command_number = ['tck2connectome ' multitread_option force_option '-zero_diagonal ' Input_tck ' ' parcellation_output2 ' ' connectome_output '_number.csv'];
connectome_command_length = ['tck2connectome ' multitread_option force_option '-metric meanlength ' '-zero_diagonal ' Input_tck ' ' parcellation_output2 ' ' connectome_output '_length.csv'];

for i=1:length(qMRI_maps)
    k = strfind(qMRI_maps{i}, '_MT.nii');
    maptype = 'MT';
    if isempty(k)
        k = strfind(qMRI_maps{i}, '_FAmap.nii');
        maptype = 'FA';
    end
    if isempty(k)
        k = strfind(qMRI_maps{i}, 'ficvf.nii');
        maptype = 'icvf';
    end
    connectome_commands_scalar{i} = ['tck2connectome ' multitread_option force_option '-metric mean_scalar -image ' qMRI_maps{i} ' -zero_diagonal ' Input_tck ' ' parcellation_output2 ' ' connectome_output '_' maptype '.csv'];
end

mrtrixParams.commands.freesurf = freesurf_command;
mrtrixParams.commands.labelconfig = labelconfig_command;
mrtrixParams.commands.connectome_number = connectome_command_number;
mrtrixParams.commands.connectome_length = connectome_command_length;
mrtrixParams.commands.connectome_scalars = connectome_commands_scalar;

if mrtrixParams.doSIFT2
    connectome_command_SIFT2 = ['tck2connectome ' multitread_option force_option '-zero_diagonal -tck_weights_in ' mrtrixParams.SIFT2_weights ' ' Input_tck ' ' parcellation_output2 ' ' connectome_output '_SIFT2.csv'];
    mrtrixParams.commands.connectome_SIFT2 = connectome_command_SIFT2;
end

%% Run the tckmap_command outside of matlab

if mrtrixParams.commandsOnly==false;
    [status,cmdout] = unix(mrtrixParams.commands.freesurf,'-echo');
    [status,cmdout] = unix(mrtrixParams.commands.labelconfig,'-echo');
    [status,cmdout] = unix(mrtrixParams.commands.connectome_number,'-echo');
    [status,cmdout] = unix(mrtrixParams.commands.connectome_length,'-echo');
    for i=1:length(mrtrixParams.commands.connectome_scalars)
        [status,cmdout] = unix(mrtrixParams.commands.connectome_scalars{i},'-echo');
    end
    if ~(status==0)
        disp('There was a problem executing the tckmap operating system command. The command did not complete successfully')
        disp(cmdout)
    end
end



