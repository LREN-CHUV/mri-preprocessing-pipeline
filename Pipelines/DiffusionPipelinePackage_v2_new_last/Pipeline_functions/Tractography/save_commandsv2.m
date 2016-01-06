function save_commandsv2(commandsprefix, BaseDirPath, mrtrixParams)

% First replace all references to current basedir with references to new
% HPC basedir
mrtrixParams.commands.dwi2response = strrep(mrtrixParams.commands.dwi2response, BaseDirPath, mrtrixParams.HPCdirPATH);
mrtrixParams.commands.dwi2response = strrep(mrtrixParams.commands.dwi2response, '\', '/');

mrtrixParams.commands.dwi2fod = strrep(mrtrixParams.commands.dwi2fod, BaseDirPath, mrtrixParams.HPCdirPATH);
mrtrixParams.commands.dwi2fod = strrep(mrtrixParams.commands.dwi2fod, '\', '/');

if mrtrixParams.doACT == true
    mrtrixParams.commands.ACT_5TT = strrep(mrtrixParams.commands.ACT_5TT, BaseDirPath, mrtrixParams.HPCdirPATH);
    mrtrixParams.commands.ACT_5TT = strrep(mrtrixParams.commands.ACT_5TT, '\', '/');
end

mrtrixParams.commands.tckgen = strrep(mrtrixParams.commands.tckgen, BaseDirPath, mrtrixParams.HPCdirPATH);
mrtrixParams.commands.tckgen = strrep(mrtrixParams.commands.tckgen, '\', '/');

if mrtrixParams.doACT == true && mrtrixParams.doSIFT == true
    mrtrixParams.commands.tcksift = strrep(mrtrixParams.commands.tcksift, BaseDirPath, mrtrixParams.HPCdirPATH);
    mrtrixParams.commands.tcksift = strrep(mrtrixParams.commands.tcksift, '\', '/');
end

mrtrixParams.commands.tckmap = strrep(mrtrixParams.commands.tckmap, BaseDirPath, mrtrixParams.HPCdirPATH);
mrtrixParams.commands.tckmap = strrep(mrtrixParams.commands.tckmap, '\', '/');

if mrtrixParams.connectome == true
    mrtrixParams.commands.freesurf = strrep(mrtrixParams.commands.freesurf, BaseDirPath, mrtrixParams.HPCdirPATH);
    mrtrixParams.commands.freesurf = strrep(mrtrixParams.commands.freesurf, '\', '/');
    
    mrtrixParams.commands.labelconfig = strrep(mrtrixParams.commands.labelconfig, BaseDirPath, mrtrixParams.HPCdirPATH);
    mrtrixParams.commands.labelconfig = strrep(mrtrixParams.commands.labelconfig, '\', '/');
    
    mrtrixParams.commands.connectome_number = strrep(mrtrixParams.commands.connectome_number, BaseDirPath, mrtrixParams.HPCdirPATH);
    mrtrixParams.commands.connectome_number = strrep(mrtrixParams.commands.connectome_number, '\', '/');
    
    mrtrixParams.commands.connectome_length = strrep(mrtrixParams.commands.connectome_length, BaseDirPath, mrtrixParams.HPCdirPATH);
    mrtrixParams.commands.connectome_length = strrep(mrtrixParams.commands.connectome_length, '\', '/');
    
    for i = 1:length(mrtrixParams.commands.connectome_scalars)
        mrtrixParams.commands.connectome_scalars{i} = strrep(mrtrixParams.commands.connectome_scalars{i}, BaseDirPath, mrtrixParams.HPCdirPATH);
        mrtrixParams.commands.connectome_scalars{i} = strrep(mrtrixParams.commands.connectome_scalars{i}, '\', '/');
    end
    
    if mrtrixParams.doSIFT2 == true
        mrtrixParams.commands.connectome_SIFT2 = strrep(mrtrixParams.commands.connectome_SIFT2, BaseDirPath, mrtrixParams.HPCdirPATH);
        mrtrixParams.commands.connectome_SIFT2 = strrep(mrtrixParams.commands.connectome_SIFT2, '\', '/');
    end
end

%% Save commands to .sh files

% Do segmentation and tractography setup commands first
commandspath = [commandsprefix 'mrtrix_setup.sh'];
if exist(commandspath,'file')
    delete(commandspath)
end

fileID = fopen(commandspath, 'w');

fprintf(fileID, '#!/bin/bash \n\n');
fprintf(fileID, '# Use this script to run tractography processing on HPC1 \n# Please ensure that the data is saved on HPC1 in the location that the script expects \n\n');
fprintf(fileID, '# Anatomical image segmentation and diffusion setup will be performed \n# Please check segmentation quality then run mrtrix_tract.sh script \n\n');
fprintf(fileID, ['# These commands were generated on: ' datestr(date,1) ' \n\n\n']);

if mrtrixParams.doACT == true
    fprintf(fileID, '# Create the 5TT segmentation required for ACT \n');
    fprintf(fileID, [mrtrixParams.commands.ACT_5TT '\n\n']);
end

if mrtrixParams.connectome == true
    fprintf(fileID, '# Run FreeSurfer parcellation \n');
    fprintf(fileID, [mrtrixParams.commands.freesurf '\n\n']);
    
    fprintf(fileID, '# Configure parcellated image into mrTrix format \n');
    fprintf(fileID, [mrtrixParams.commands.labelconfig '\n\n']);
    
end

fprintf(fileID, '# Generate the CSD response function \n');
fprintf(fileID, [mrtrixParams.commands.dwi2response '\n\n']);

fprintf(fileID, '# Estimate the CSD spherical harmonics \n');
fprintf(fileID, [mrtrixParams.commands.dwi2fod '\n\n']);

fclose(fileID);


% Now save tractography commands
commandspath = [commandsprefix 'mrtrix_tracts.sh'];
if exist(commandspath,'file')
    delete(commandspath)
end

fileID = fopen(commandspath, 'w');

fprintf(fileID, '#!/bin/bash \n\n');
fprintf(fileID, '# Use this script to run tractography processing on HPC1 \n# Please ensure that the data is saved on HPC1 in the location that the script expects \n\n');
fprintf(fileID, '# Tractography processing and summaries will be performed \n# Run this after mrtrix_setup.sh has been successful and segmentation quality checked \n\n');
fprintf(fileID, ['# These commands were generated on: ' datestr(date,1) ' \n\n\n']);

fprintf(fileID, '# Generate the tractography streamlines \n');
fprintf(fileID, [mrtrixParams.commands.tckgen '\n\n']);

if mrtrixParams.doACT == true && mrtrixParams.doSIFT == true
    fprintf(fileID, '# Filter tractogram using SIFT \n');
    fprintf(fileID, [mrtrixParams.commands.tcksift '\n\n']);
end

fprintf(fileID, '# Output TDI summary maps \n');
fprintf(fileID, [mrtrixParams.commands.tckmap '\n\n']);

if mrtrixParams.connectome == true
    
    fprintf(fileID, '# Create connectome matrix (number of streamlines) \n');
    fprintf(fileID, [mrtrixParams.commands.connectome_number '\n\n']);
    
    fprintf(fileID, '# Create connectome matrix (length of streamlines) \n');
    fprintf(fileID, [mrtrixParams.commands.connectome_length '\n\n']);
    
    fprintf(fileID, '# Create connectome matrices (scalars) \n');
    for i=1:length(mrtrixParams.commands.connectome_scalars)
        fprintf(fileID, [mrtrixParams.commands.connectome_scalars{i} '\n']);
    end
    
    if mrtrixParams.doSIFT2 == true
        fprintf(fileID, '\n# Create connectome matrix (SIFT2 weights) \n');
        fprintf(fileID, [mrtrixParams.commands.connectome_SIFT2 '\n\n']);
    end
end

fclose(fileID);


%% Old script format containing all commands

% fileID = fopen(commandspath, 'w');
% 
% fprintf(fileID, '#!/bin/bash \n\n');
% fprintf(fileID, '# Use this script to run tractography processing on HPC1 \n# Please ensure that the data is saved on HPC1 in the location that the script expects \n\n');
% fprintf(fileID, ['# These commands were generated on: ' datestr(date,1) ' \n\n\n']);
% 
% fprintf(fileID, '# Generate the CSD response function \n');
% fprintf(fileID, [mrtrixParams.commands.dwi2response '\n\n']);
% 
% fprintf(fileID, '# Estimate the CSD spherical harmonics \n');
% fprintf(fileID, [mrtrixParams.commands.dwi2fod '\n\n']);
% 
% if mrtrixParams.doACT == true
%     fprintf(fileID, '# Create the 5TT segmentation required for ACT \n');
%     fprintf(fileID, [mrtrixParams.commands.ACT_5TT '\n\n']);
% end
% 
% fprintf(fileID, '# Generate the tractography streamlines \n');
% fprintf(fileID, [mrtrixParams.commands.tckgen '\n\n']);
% 
% if mrtrixParams.doACT == true && mrtrixParams.doSIFT == true
%     fprintf(fileID, '# Filter tractogram using SIFT \n');
%     fprintf(fileID, [mrtrixParams.commands.tcksift '\n\n']);
% end
% 
% fprintf(fileID, '# Output TDI summary maps \n');
% fprintf(fileID, [mrtrixParams.commands.tckmap '\n\n']);
% 
% if mrtrixParams.connectome == true
%     fprintf(fileID, '# Run FreeSurfer parcellation \n');
%     fprintf(fileID, [mrtrixParams.commands.freesurf '\n\n']);
%     
%     fprintf(fileID, '# Configure parcellated image into mrTrix format \n');
%     fprintf(fileID, [mrtrixParams.commands.labelconfig '\n\n']);
%     
%     fprintf(fileID, '# Create connectome matrix (number of streamlines) \n');
%     fprintf(fileID, [mrtrixParams.commands.connectome_number '\n\n']);
%     
%     fprintf(fileID, '# Create connectome matrix (length of streamlines) \n');
%     fprintf(fileID, [mrtrixParams.commands.connectome_length '\n\n']);
%     
%     fprintf(fileID, '# Create connectome matrices (scalars) \n');
%     for i=1:length(mrtrixParams.commands.connectome_scalars)
%         fprintf(fileID, [mrtrixParams.commands.connectome_scalars{i} '\n']);
%     end
%     
%     if mrtrixParams.doSIFT2 == true
%         fprintf(fileID, '\n# Create connectome matrix (SIFT2 weights) \n');
%         fprintf(fileID, [mrtrixParams.commands.connectome_SIFT2 '\n\n']);
%     end
% end
% 
% fclose(fileID);
