function Nbytes = getNbytes(InputFolder)

  dirData = dir(InputFolder);      %# Get the data for the current directory
  dirIndex = [dirData.isdir];  %# Find the index for directories
  Nbytes = sum([dirData(~dirIndex).bytes]); %/1024;
  subDirs = {dirData(dirIndex).name};  %# Get a list of the subdirectories
  validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
                                               %#   that are not '.' or '..'
  for iDir = find(validIndex)                  %# Loop over valid subdirectories
    nextDir = fullfile(InputFolder,subDirs{iDir});    %# Get the subdirectory path
    %Nbytes = [Nbytes getNbytes(nextDir)];  %# Recursively call getAllFiles
    Nbytes = Nbytes + getNbytes(nextDir); 
  end

end