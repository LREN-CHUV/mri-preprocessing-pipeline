function [outBaseDir] = DWIInit(dwRawFileName, StructuralTemplateFileName, dwParams)
% function [dt6FileName, outBaseDir] = dtiInit([dwRawFileName], [StructuralTemplateFileName], [dwParams])
% 
%   This fucntion will run with the default parameters unless the user
%   passes in dwParams with alternate parameters. This can be done with a
%   call to 'dtiInitParams'. See dtiInitParams.m for default parameters.
% 
% INPUTS:
%   dwRawFileName = Raw dti data in nifti format.
%   StructuralTemplateFileName = PD-weighted anatomical image. By default the diffusion
%                   data are aligned to this image.
%   dwParams      = This structure is generated using dtiInitParams.m It
%                   contains all the parameters necessary for running the 
%                   pipeline. Users should look at the comments there for 
%                   more information. 
%
% 
%% I. Load the diffusion data, set up parameters and directories structure

if notDefined('dwRawFileName') || ~exist(dwRawFileName,'file')
    dwRawFileName = mrvSelectFile('r',{'*.nii.gz';'*.*'},'Select raw DTI nifti file');
    if isempty(dwRawFileName); disp('dtiInit canceled by user.'); return; end
end

% Load the difusion data
disp('Loading raw data...');
dwRaw = niftiRead(dwRawFileName);

% If not defined load default dwparams
if notDefined('dwParams'); 
  dwParams         = dtiInitParams; 
end

% By default all resampled nifti's will be at the same resolution of the input data
dwParams.dwOutMm = dwRaw.pixdim(1:3);


% Initialize the structure containing all directory info and file names
dwDir      = dtiInitDir(dwRawFileName,dwParams);
outBaseDir = dwDir.outBaseDir;
fprintf('dataDir = %s; dims = [%d %d %d %d];\n', dwDir.dataDir, size(dwRaw.data));


% Check whether to do field map correction and that field map is present
listing = dir([dwDir.dataDir '\*grefieldmapping*']);
if dwParams.FieldMapCorrect && size(listing,1)>0
    doFieldMapCorrect=1;
else doFieldMapCorrect=0;
end

% Setup Subject Log file
CreateLog = exist(dwParams.SubjectID,'var') && exist(dwParams.SessionNum,'var') && exist(dwParams.RepeatNum,'var');
if CreateLog == true
    Logfilename=fullfile(dwDir.PipelineBaseDir,'PipelineLog.mat');
    [Subject, Session, Repeat, Date, Time] = InitLogFile(Logfilename,dwParams.SubjectID,dwParams.SessionNum,dwParams.RepeatNum);
    Log = matfile(Logfilename);
end


%% II. Make sure there is a valid phase-encode direction 

if isempty(dwParams.phaseEncodeDir)  ... 
       || (dwParams.phaseEncodeDir<1 ...
       ||  dwParams.phaseEncodeDir>3)
    dwRaw.phase_dim = dtiInitPhaseDim(dwRaw.phase_dim);
else
    dwRaw.phase_dim = dwParams.phaseEncodeDir;
end


%% III. Read Bvecs & Bvals and build if they don't exist

if ~exist(dwDir.bvalsFile,'file') || ~exist(dwDir.bvecsFile,'file')
    [doBvecs, dwParams] = dtiInitBuildBVs(dwDir, dwParams);
else
    doBvecs = false;
end

% Read bvecs and bvals
bvecs = dlmread(dwDir.bvecsFile);
bvals = dlmread(dwDir.bvalsFile);


%% IV. Check for missing data volumes and exclude indicated vols

[doResamp, bvecs, bvals, dwRaw] = dtiInitCheckVols(bvecs, bvals, dwRaw, dwParams);


%% V. Compute mean b=0: used for e-c correction and alignment to structural

% Here we decide if we compute b0. If the user asks to clobber existing
% files, or if the mean b=0 ~exist dtiInitB0 will return a flag that will
% compute it in dtiInit. If clobber is set to ask, then we prompt the user. 
computeB0 = dtiInitB0(dwParams,dwDir);

% If computeB0 comes back true, do the (mean b=0) computation 
if computeB0, dtiRawComputeMeanB0(dwRaw, bvals, dwDir.mnB0Name); end


%% VI. Select the anatomy file

% Can customise this section such that the script looks up previous
% anatomical data for the subject on the database - need Ferath input on
% database structure

% Check for the case that the user wants to align to MNI instead of PD.
if exist('StructuralTemplateFileName','var') && strcmpi(StructuralTemplateFileName,'MNI')
%     StructuralTemplateFileName = dwDir.mnB0Name;
%     disp('The mnb0 template will be used for alignment.');
    StructuralTemplateFileName = fullfile(dwDir.PipelineBaseDir,'templates','MNI_EPI.nii.gz');
    disp('The MNI EPI template will be used for alignment.');
end

if notDefined('StructuralTemplateFileName') || ~exist(StructuralTemplateFileName,'file')
    StructuralTemplateFileName = dwDir.mnB0Name;
    disp('The mnb0 template will be used for alignment.');
end
fprintf('StructuralTemplateFileName = %s;\n', StructuralTemplateFileName);


%% VII. Eddy current correction

% Based on user selected params decide if we do eddy current correction 
% and resampling. If the ecc is done doResamp will be true.
[doECC, doResamp] = dtiInitEddyCC(dwParams,dwDir,doResamp);

% If doECC comes back true do the eddy current correction
if doECC
dtiRawRohdeEstimateEddyMotion(dwRaw, dwDir.mnB0Name, bvals, dwDir.ecFile,...
                              dwParams.eddyCorrect==1);
      if CreateLog == true
            eval([Log '.' Subject '.' Session '.' Repeat '.' Date '.' Time '.EC_corrected = 1;']);
      end
end


%% VIII. Compute the dwi -> structural alignment

% Based on user selected params decide if we align the raw dwi data to a
% reference image. If the alignment is computed doResamp will be true.
[doAlign, doResamp] = dtiInitAlign(dwParams,dwDir,doResamp);

if doAlign, dtiRawAlignToT1(dwDir.mnB0Name, StructuralTemplateFileName, dwDir.acpcFile); end


%% IX. Resample the DWIs

% Based on user selected params and doResamp decide if we are resampling
% the raw data. If doSample is true and we have computed an alignment or
% we're clobbering old data we doResampleRaw will be true. 
doResampleRaw = dtiInitResample(dwParams, dwDir, doResamp);
if doResampleRaw==0 && (doECC==1 || doAlign==1)
    doResampleRaw=1;
end
% Applying the dti-to-structural xform and the eddy-current correction
% xforms. If dwParams.eddyCorrect == 0, dwDir.ecFile will be empty and
% dtiRawResample will only do acpcAlignment.
if doResampleRaw,  dtiRawResample(dwRaw, dwDir.ecFile, dwDir.acpcFile,...
                   dwDir.dwAlignedRawFile, dwParams.bsplineInterpFlag,...
                   dwParams.dwOutMm);
end


%% X. Reorient and align bvecs 

% Check to see if bvecs should be reoriented and reorient if necessary. If
% the conditions are met then the bvecs are reoriented and the aligned
% bvals file is saved from bvals.
dtiInitReorientBvecs(dwParams, dwDir, doResamp, doBvecs, bvecs, bvals);


%% XI. Load aligned raw data and clear unaligned raw data

dwRawAligned = niftiRead(dwDir.dwAlignedRawFile);
bvecs = dlmread(dwDir.alignedBvecsFile);
bvals = dlmread(dwDir.alignedBvalsFile);
clear dwRaw;  


%% XII. Reorder Raw data by b-value. Perform same reorder to bval/bvec.
% Create mnb0 image of EC-corrected data

if doResampleRaw
    
    sortDWIdata(bvals,bvecs,dwDir.dwAlignedRawFile,dwDir.outBaseDir,'Eddy Corrected')
    
    dwRawAligned = niftiRead(dwDir.dwAlignedRawFile);
    bvecs = dlmread(dwDir.alignedBvecsFile);
    bvals = dlmread(dwDir.alignedBvalsFile);
    
    aligned_mnb0name=[dwDir.outBaseDir '_mnb0.nii'];
    dtiRawComputeMeanB0(dwRawAligned, bvals, aligned_mnb0name);
    gunzip([dwDir.outBaseDir '*.gz']);
    pause(2);
end

%% XIII Apply b0 field map correction

if doFieldMapCorrect && exist(dwDir.dwAlignedRawFile,'file')>0 && doResampleRaw==1
    disp('Initiating field map correction...');
    dwDir.dwUnwarpedRawFile=DTI_DistCorr(dwDir.dataDir,dwDir.dataDir,dwDir.dwAlignedRawFile);
    
    splitrawname = strsplit(dwDir.dwUnwarpedRawFile,'.');
    newbval = [char(splitrawname(1)) '.bval'];
    newbvec = [char(splitrawname(1)) '.bvec'];
    dlmwrite(newbval,bvals,' ');
    dlmwrite(newbvec,bvecs,' ');
    
    %     Can also delete aligned but not unwarped nifti, bval and bvec files
    delete([dwDir.outBaseDir '.bvals'],[dwDir.outBaseDir '.bvecs'],...
        [dwDir.outBaseDir '.nii*'],[dwDir.outBaseDir '_mnb0*'])
    
    if CreateLog == true
        eval([Log '.' Subject '.' Session '.' Repeat '.' Date '.' Time '.FieldMap_corrected = 1;']);
    end
    
else if doResampleRaw==1
        disp('Skipping field map correction...');
    end
end

%% XIV Setup location of preprocessed files for model fitting

if exist([dwDir.outBaseDir '_unwarped.nii'],'file')>0
    dwDir.dwPreprocessedFile=[dwDir.outBaseDir '_unwarped.nii'];
    dwDir.dwPreprocessedbvals=[dwDir.outBaseDir '_unwarped.bval'];
    dwDir.dwPreprocessedbvecs=[dwDir.outBaseDir '_unwarped.bvec'];
else if exist([dwDir.outBaseDir '_unwarped.nii.gz'],'file')>0
        gunzip([dwDir.outBaseDir '_unwarped.nii.gz'])
        dwDir.dwPreprocessedFile=[dwDir.outBaseDir '_unwarped.nii'];
        dwDir.dwPreprocessedbvals=[dwDir.outBaseDir '_unwarped.bval'];
        dwDir.dwPreprocessedbvecs=[dwDir.outBaseDir '_unwarped.bvec'];
    else
        dwDir.dwPreprocessedFile=dwDir.dwAlignedRawFile;
        dwDir.dwPreprocessedbvals=dwDir.alignedBvalsFile;
        dwDir.dwPreprocessedbvecs=dwDir.alignedBvecsFile;
    end
end

doMask=doResampleRaw;

%% XV. Tensor Fitting

if dwParams.fitDTI==1
    dtiFitTensorWrapper(dwParams.fitMethod,dwDir,dwParams.dwOutMm,doMask)
end


%% XVI. Fit NODDI model to multi shell data

if dwParams.fitNODDI==1
    NODDI_FitWrapper(dwDir,doMask)
end

%% XVII. Prepare data for HARDI model fitting

dwDir.HARDIdir=[dwDir.subjectDir '\HARDI'];

if ~exist(dwDir.HARDIdir,'dir');
    mkdir(dwDir.HARDIdir);
end

sortHARDIdata(dwDir.dwPreprocessedbvals,dwDir.dwPreprocessedbvecs,dwDir.dwPreprocessedFile,[dwDir.HARDIdir '\' dwDir.outBaseName '_HARDI'],'HARDI high b-value data')






