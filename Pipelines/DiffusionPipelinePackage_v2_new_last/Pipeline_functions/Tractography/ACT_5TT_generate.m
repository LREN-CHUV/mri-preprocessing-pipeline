function [AnatomicalImage, Output5TT, mrtrixParams] = ACT_5TT_generate(AnatomicalImage,Output5TT,mrtrixParams)
% This will call the act_anat_prepare_fsl script for 5TT segmentation

%% Setup variables

% Check anatomical file exists
if ~exist(AnatomicalImage,'file')
    [FileName,PathName] = uigetfile('.nii','Select the anatomical data');
    AnatomicalImage = fullfile(PathName,FileName);
else [PathName, FileName, ext] = fileparts(AnatomicalImage);
end

if ~isempty(strfind(AnatomicalImage, '_MT.nii')) && isempty(strfind(AnatomicalImage, 'x1000'))
    % If using the MT image scale by x1000
    AnatomicalImage = ScaleData(AnatomicalImage,1000);
end

% Set output for 5TT file
if isempty(Output5TT)
    [pathstr,name] = fileparts(AnatomicalImage);
    Output5TT = [pathstr filesep name '_5TT.nii.gz'];
end


%% Build ACT_5TT command

scriptloc = [mrtrixParams.mrtrixPATH filesep 'scripts'];

ACT_5TT_command = ['cd ' scriptloc ';  chmod +x ./act_anat_prepare_fsl; ./act_anat_prepare_fsl ' AnatomicalImage ' ' Output5TT '; ' 'cd ' PathName];
mrtrixParams.commands.ACT_5TT = ACT_5TT_command;

%% Run the ACT_5TT command outside of matlab

if mrtrixParams.commandsOnly==false;
    [status,cmdout] = unix(ACT_5TT_command,'-echo');
    if ~(status==0)
        disp('There was a problem executing the ACT_5TT operating system command. The command did not complete successfully')
        disp(cmdout)
    end
end

mrtrixParams.Output5TT = Output5TT;