function BatchPreProc(Diffusion_dir,RawIdentifier,AnatIdentifier,doParallel,dwParams)
% Diffusion_dir = base path to folder with all subjects for preprocessing
% RawIdentifier = cell array of identifiers which uniquely specifies raw
%   data files. e.g. {'_data.nii', 'raw'}
% AnatIdentifier = cell array of identifiers which uniquely specifies
%   anatomical image files. e.g. {'MPRAGE','.nii', 'raw'}. The anatomical
%   image file should be stored with the raw data file
% doParallel = if true open matlab pool to process in parallel
% dwParams = structure containing preprocessing parameters. Initialise
%   default options using: dwParams = dtiInitParams


%% Setup Variables

% Find all Raw files for preprocessing
AllRAW = cellstr(pickfiles(Diffusion_dir,RawIdentifier));


%% Loop processing over subjects

if ~(doParallel==1)
    % In Series
    for i = 1:size(AllRAW,1)
        
        rawdir = fileparts(AllRAW{i});
        StructuralTemplateFileName = cellstr(pickfiles(rawdir,AnatIdentifier));
        DWIInit(AllRAW{i}, StructuralTemplateFileName{1}, dwParams)
        
    end
else
    % In Parallel
    if matlabpool('size')==0
        matlabpool open;
    end
    parfor i = 1:size(AllRAW,1)
        
        rawdir = fileparts(AllRAW{i});
        StructuralTemplateFileName = cellstr(pickfiles(rawdir,AnatIdentifier));
        DWIInit(AllRAW{i}, StructuralTemplateFileName{1}, dwParams)
        
    end
    matlabpool close;
end


