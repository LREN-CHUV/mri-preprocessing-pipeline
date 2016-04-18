function [outFile,mnB0] = CreateMeanB0(dwRaw, bvals, outFile)
%
% [outFile,mnB0] = dtiRawComputeMeanB0([dwRaw=uigetfile], [bvals=uigetfile], outFile)
%
% Averages b0 volumes in dwRaw (NIFTI format). The b0 volumes are extracted 
% based on bvals==0.
%
% HISTORY:
% 2007.04.23 RFD: wrote it.


% Initialize SPM default params for the coregistration.
estParams        = spm_get_defaults('coreg.estimate');
estParams.params = [0 0 0 0 0 0];% Rigid-body (6-params)


%% Load the raw DW data (in NIFTI format)
if(~exist('dwRaw','var') || isempty(dwRaw))
    [f,p] = uigetfile({'*.nii.gz;*.nii';'*.*'}, 'Select the raw DW NIFTI dataset...');
    if(isnumeric(f)) error('User cancelled.'); end
    dwRaw = fullfile(p,f);
end
if(ischar(dwRaw))
    % dwRaw can be a path to the file or the file itself
    [dataDir,~] = fileparts(dwRaw);
else
    [dataDir,~] = fileparts(dwRaw.fname);
end
%[~,inBaseName,~] = fileparts(inBaseName);
if(isempty(dataDir)), dataDir = pwd; end

if(~exist('bvals','var') || isempty(bvals))
    bvals = fullfile(dataDir,'bvals');
    [f,p] = uigetfile({'*.bvals';'*.*'},'Select the bvals file...',bvals);
    if(isnumeric(f)), disp('User canceled.'); return; end
    bvals = fullfile(p,f);
end
if(~exist('outFile','var') || isempty(outFile))
    outFile = fullfile(dataDir,'b0.nii.gz');
    [f,p] = uigetfile({'*.nii.gz;*.nii';'*.*'},'Save the mean b0 file here...',outFile);
    if(isnumeric(f)), disp('User canceled.'); return; end
    outFile = fullfile(p,f);
end

if(ischar(dwRaw))
    disp(['Loading raw data ' dwRaw '...']);
    dwRaw = niftiRead(dwRaw);
end

if(dwRaw.qform_code>0)
  xformToScanner = dwRaw.qto_xyz;
elseif(dwRaw.sform_code>0)
  xformToScanner = dwRaw.sto_xyz;
else
  error('Requires that dwRaw qform_code>1 OR sform_code>1.');
end

nvols = size(dwRaw.data,4);
dtMm  = dwRaw.pixdim(1:3);

if(ischar(bvals))
    %bvals = dlmread(bvals, ' ');
    bvals = dlmread(bvals);
end
if(size(bvals,2) < nvols)
    error(['bvals: need at least one entry for each of the ' num2str(nvols) ' volumes.']);
elseif(size(bvals,2)>nvols)
    warning('More bvals entries than volumes- clipping...');
    bvals = bvals(:,1:nvols);
end


% Find the indices of the bvals in the nifti image
b0inds = find(bvals==0);

%% Average and save all the b=0 volumes

mnB0 = double(dwRaw.data(:,:,:,b0inds(1)));


mnB0 = mean(mnB0,4);
mnB0(isnan(mnB0)) = 0;
mnB0 = int16(round(mnB0));
dtiWriteNiftiWrapper(mnB0, xformToScanner, outFile, 1, 'Mean of b0 volumes');
if(nargout<1), clear outFile; end
return;
