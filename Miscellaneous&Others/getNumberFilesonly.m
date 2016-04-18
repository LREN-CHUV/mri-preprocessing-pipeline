function N = getNumberFilesonly(InputFolder)

% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, May 16th, 2014 

FileList = getAllFiles(InputFolder);
N = size(FileList,1);

end

%% ==========  Internal  Functions  ============ %%
function fileList = getAllFiles(InputFolder)

  dirData = dir(InputFolder);      %# Get the data for the current directory
  dirIndex = [dirData.isdir];  %# Find the index for directories
  fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
   if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(InputFolder,x),...  %# Prepend path to files
                       fileList,'UniformOutput',false);
  end
  subDirs = {dirData(dirIndex).name};  %# Get a list of the subdirectories
  validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
                                               %#   that are not '.' or '..'
  for iDir = find(validIndex)                  %# Loop over valid subdirectories
    nextDir = fullfile(InputFolder,subDirs{iDir});    %# Get the subdirectory path
    fileList = [fileList; getAllFiles(nextDir)];  %# Recursively call getAllFiles
  end

end