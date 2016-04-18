function [outBaseDir] = DWIInit(dwRawFileName, StructuralTemplateFileName, dwParams)
% function [dt6FileName, outBaseDir] = dtiInit([dwRawFileName], [StructuralTemplateFileName], [dwParams])
%
%   This fucntion will run with the default parameters unless the user
%   passes in dwParams with alternate parameters. This can be done with a
%   call to 'dtiInitParams'. See dtiInitParams.m for default parameters.
%
% INPUTS:
%   dwRawFileName = Raw dti data in nifti format.
%   StructuralTemplateFileName = Anatomical image (e.g. MT). By default the
%                   diffusion data are aligned to this image.
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
listing = dir([dwDir.dataDir '\*grefieldmap*']);
if dwParams.FieldMapCorrect && size(listing,1)>0
    doFieldMapCorrect=1;
else doFieldMapCorrect=0;
end

% Lookup EPI readout time from list of known sequences
if isempty(dwParams.EPI_readout_time)
    dwParams.EPI_readout_time = EPI_readout_lookup(dwDir.inBaseName);
end
if isempty(dwParams.EPI_readout_time) || dwParams.EPI_readout_time==0
    dwParams.FieldMapCorrect = 0;
end

% Create subject, session, repeat comment if relevant
if isfield(dwParams, 'SubjectID') && isfield(dwParams, 'SessionNum') && isfield(dwParams, 'RepeatNum')
    Subject_comment = ['Subject ID: ' dwParams.SubjectID '; Session No.: ' dwParams.SessionNum '; Repeat No.: ' dwParams.RepeatNum];
else Subject_comment = '';
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
    dwParams.MNIalign = 1;
    useStdXformFlag = true;
    dwParams.anatAlign = false;
elseif notDefined('StructuralTemplateFileName') || ~exist(StructuralTemplateFileName,'file')
    StructuralTemplateFileName = dwDir.mnB0Name;
    disp('The mnb0 template will be used for alignment.');
    dwParams.MNIalign = 0;
    useStdXformFlag = false;
    dwParams.anatAlign = false;
else
    disp('The user defined template will be used for alignment.');
    dwParams.MNIalign = 0;
    useStdXformFlag = false;
    dwParams.anatAlign = true;
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
end


%% VIII. Compute the dwi -> structural alignment

% Based on user selected params decide if we align the raw dwi data to a
% reference image. If the alignment is computed doResamp will be true.
[doAlign, doResamp] = dtiInitAlign(dwParams,dwDir,doResamp);

if dwParams.MNIalign == 0 && ~exist(StructuralTemplateFileName,'file')
    acpcXform = dwRaw.qto_xyz;
    save(dwDir.acpcFile, 'acpcXform');
    
elseif doAlign, dtiRawAlignToT1(dwDir.mnB0Name, StructuralTemplateFileName, dwDir.acpcFile,[],useStdXformFlag); end

if dwParams.MNIalign == 1;
    bb = '';
else
    gunzip([dwDir.mnB0Name '.gz'])
    [~, xyz]=spm_read_vols(spm_vol(dwDir.mnB0Name));
    bb = [min(xyz(1,:)) min(xyz(2,:)) min(xyz(3,:)); max(xyz(1,:)) max(xyz(2,:)) max(xyz(3,:))];
    clear xyz
end


%% IX. Resample the DWIs

% Based on user selected params and doResamp decide if we are resampling
% the raw data. If doSample is true and we have computed an alignment or
% we're clobbering old data we doResampleRaw will be true.
doResampleRaw = dtiInitResample(dwParams, dwDir, doResamp);
if doResampleRaw==0 && (doECC==1 || doAlign==1) % || strcmpi(StructuralTemplateFileName,dwDir.mnB0Name))
    doResampleRaw=1;
end
% Applying the dti-to-structural xform and the eddy-current correction
% xforms. If dwParams.eddyCorrect == 0, dwDir.ecFile will be empty and
% dtiRawResample will only do acpcAlignment.
if doResampleRaw,  dtiRawResample(dwRaw, dwDir.ecFile, dwDir.acpcFile,...
        dwDir.dwAlignedRawFile, dwParams.bsplineInterpFlag,...
        dwParams.dwOutMm,bb);
end


%% X. Reorient and align bvecs

% Check to see if bvecs should be reoriented and reorient if necessary. If
% the conditions are met then the bvecs are reoriented and the aligned
% bvals file is saved from bvals.
BvecsRotated = dtiInitReorientBvecs(dwParams, dwDir, doResamp, doBvecs, bvecs, bvals);


%% XI. Load aligned raw data and clear unaligned raw data

% dwRawAligned = niftiRead(dwDir.dwAlignedRawFile);
bvecs = dlmread(dwDir.alignedBvecsFile);
% On prisma data the x-gradients need to be inverted
if BvecsRotated
    bvecs(1,:) = bvecs(1,:)*-1;
end
bvals = dlmread(dwDir.alignedBvalsFile);
clear dwRaw;


%% XII. Reorder Raw data by b-value. Perform same reorder to bval/bvec.
% Create mnb0 image of EC-corrected data

if doResampleRaw
    
    sortDWIdata(bvals,bvecs,dwDir.dwAlignedRawFile,dwDir.outBaseDir,Subject_comment)
    
    dwRawAligned = niftiRead(dwDir.dwAlignedRawFile);
    bvecs = dlmread(dwDir.alignedBvecsFile);
    bvals = dlmread(dwDir.alignedBvalsFile);
    
    aligned_mnb0name=[dwDir.outBaseDir '_mnb0.nii'];
    dtiRawComputeMeanB0(dwRawAligned, bvals, aligned_mnb0name);
    gunzip([dwDir.outBaseDir '*.gz']);
    pause(2);
    dwDir.dwAlignedRawFile = [dwDir.outBaseDir '.nii'];
    clear dwRawAligned
end

%% XIII Apply b0 field map correction

if doFieldMapCorrect && exist(dwDir.dwAlignedRawFile,'file')>0 && doResampleRaw==1
    disp('Initiating field map correction...');
    dwDir.dwUnwarpedRawFile=DTI_DistCorr(dwDir.dataDir,dwDir.dataDir,dwDir.dwAlignedRawFile,dwParams.EPI_readout_time, dwParams.Phase_Trav_BLIP_DIR, Subject_comment);
    
    splitrawname = strsplit(dwDir.dwUnwarpedRawFile,'.');
    newbval = [char(splitrawname(1)) '.bval'];
    newbvec = [char(splitrawname(1)) '.bvec'];
    dlmwrite(newbval,bvals,' ');
    dlmwrite(newbvec,bvecs,' ');
    
    %     Can also delete aligned but not unwarped nifti, bval and bvec files
    delete([dwDir.outBaseDir '.bvals'],[dwDir.outBaseDir '.bvecs'],...
        [dwDir.outBaseDir '.nii*'])
    
    
else if doResampleRaw==1
        disp('Skipping field map correction...');
    end
end

%% XIV Setup location of preprocessed files for model fitting

if exist([dwDir.outBaseDir '_unwarped.nii'],'file')>0
    dwDir.dwPreprocessedFile=[dwDir.outBaseDir '_unwarped.nii'];
    dwDir.dwPreprocessedbvals=[dwDir.outBaseDir '_unwarped.bval'];
    dwDir.dwPreprocessedbvecs=[dwDir.outBaseDir '_unwarped.bvec'];
    dwDir.dwPreprocessedBaseDir=[dwDir.outBaseDir '_unwarped'];
else if exist([dwDir.outBaseDir '_unwarped.nii.gz'],'file')>0
        gunzip([dwDir.outBaseDir '_unwarped.nii.gz'])
        dwDir.dwPreprocessedFile=[dwDir.outBaseDir '_unwarped.nii'];
        dwDir.dwPreprocessedbvals=[dwDir.outBaseDir '_unwarped.bval'];
        dwDir.dwPreprocessedbvecs=[dwDir.outBaseDir '_unwarped.bvec'];
        dwDir.dwPreprocessedBaseDir=[dwDir.outBaseDir '_unwarped'];
    else
        dwDir.dwPreprocessedFile=[dwDir.outBaseDir '.nii'];
        dwDir.dwPreprocessedbvals=dwDir.alignedBvalsFile;
        dwDir.dwPreprocessedbvecs=dwDir.alignedBvecsFile;
        dwDir.dwPreprocessedBaseDir=[dwDir.outBaseDir];
    end
end
[~, dwDir.preprocBaseName] = fileparts(dwDir.dwPreprocessedBaseDir);
dwDir.outBaseName = dwDir.preprocBaseName;
doMask=doResampleRaw;

%% XV. Create mask, b0 data and apply bias field correction for model fitting

b0name = [dwDir.dwPreprocessedBaseDir '_mnb0.nii'];
b0maskname = [dwDir.dwPreprocessedBaseDir '_mnb0_mask.nii'];
TPMfilename=fullfile(dwDir.PipelineBaseDir,'templates','nwTPM_corr.nii');

if ~exist(b0maskname,'file') || doResampleRaw==1
    CreateMeanB0(dwDir.dwPreprocessedFile, dwDir.dwPreprocessedbvals, b0name);
    gunzip([dwDir.dwPreprocessedBaseDir '*.gz'])
    [b0maskname, biasout] = brain_mask(b0name,b0maskname,TPMfilename,1);
    
    %     Apply the bias field correction to the mnb0 then to the corrected
    %     DWIs
    ApplyBiasField(b0name,biasout)
    ApplyBiasField(dwDir.dwPreprocessedFile,biasout)
    gunzip([dwDir.dwPreprocessedBaseDir '*.gz'])
    
    if dwParams.anatAlign
        [anatpath, anatname] = fileparts(StructuralTemplateFileName);
        anatmask = [anatpath filesep anatname '_mask.nii'];
        brain_mask(StructuralTemplateFileName,anatmask,TPMfilename,1);
%         maskbrain(StructuralTemplateFileName,anatmask,StructuralTemplateFileName)
    end
    
    
    % Co-register unwarped data to template without reslicing
    if doFieldMapCorrect && doResampleRaw==1
        coreg_DWIdata(StructuralTemplateFileName,b0name,dwDir.dwPreprocessedFile,Subject_comment)
    end
    
    % Create more robust mask from anatomical data
    if dwParams.anatAlign
        reslice_image(b0name,anatmask,b0maskname)
    end
end


%% XV. Tensor Fitting

if dwParams.fitDTI==1
    dtiMask = [dwDir.subjectDir filesep 'dti' filesep dwDir.outBaseName '_mnb0_mask.nii'];
    if exist(b0maskname,'file')>0
        if ~exist([dwDir.subjectDir filesep 'dti'],'dir')
            mkdir([dwDir.subjectDir filesep 'dti'])
        end
        copyfile(b0maskname,dtiMask);
        doMask =0;
    end
    dtiFitTensorWrapper(dwParams.fitMethod,dwDir,dwParams.dwOutMm,doMask)
end


%% XVI. Fit NODDI model to multi shell data

if dwParams.fitNODDI==1 && nnz(bvals>1800)>5
    %     Setup files and directory for NODDI fitting
    NODDIMask = [dwDir.subjectDir filesep 'NODDI' filesep dwDir.outBaseName '_mnb0_mask.nii'];
    if exist(b0maskname,'file')>0
        if ~exist([dwDir.subjectDir filesep 'NODDI'],'dir')
            mkdir([dwDir.subjectDir filesep 'NODDI'])
        end
        copyfile(b0maskname,NODDIMask);
        doMask =0;
    else doMask =1;
    end
    
    %     Choose NODDI fit method
    if dwParams.useAMICO == 0;
        disp('Starting original NODDI fit proceedure')
        NODDI_FitWrapper(dwDir,doMask)
        
    else
        disp('Starting AMICO NODDI fit proceedure')
        [basedir, datadir] = fileparts([dwDir.subjectDir filesep 'NODDI']);
        Schemepath = [dwDir.subjectDir filesep 'NODDI' filesep dwDir.outBaseName '.scheme'];
        fsl2scheme(dwDir.dwPreprocessedbvals,dwDir.dwPreprocessedbvecs,Schemepath);
        AMICO_FitWrapper(basedir,datadir,dwDir.dwPreprocessedFile,NODDIMask,Schemepath,dwParams.AMICOfitmethod)
        if exist([dwDir.subjectDir filesep 'common'],'dir')
            rmdir([dwDir.subjectDir filesep 'common'],'s')
        end
        fitparams = pickfiles([dwDir.subjectDir filesep 'NODDI'],{'FIT_parameters.nii'});
        extract_AMICO(dwDir,fitparams)
        gunzip([dwDir.subjectDir filesep 'NODDI' filesep '*.gz'])
    end
end

%% XVII. Prepare data for HARDI model fitting

if nnz(bvals>1500)>29
    % Create HARDI directory for all tractogrphy processing
    dwDir.HARDIdir=[dwDir.subjectDir filesep 'HARDI'];
    if ~exist(dwDir.HARDIdir,'dir');
        mkdir(dwDir.HARDIdir);
    end
    sortHARDIdata(dwDir.dwPreprocessedbvals,dwDir.dwPreprocessedbvecs,dwDir.dwPreprocessedFile,[dwDir.HARDIdir filesep dwDir.outBaseName '_HARDI'],'HARDI high b-value data')
    
    % Find MT file in subject directory. If no MT try MT_m (masked)
    MTfile = cellstr(pickfiles(fullfile(dwDir.subjectDir,'raw'),{'_MT_m.nii'},{'.'},{'.gz'}));
    if exist(MTfile{1},'file')
        StructuralTemplateFileName = MTfile{1};
    else MTfile = cellstr(pickfiles(fullfile(dwDir.subjectDir,'raw'),{'_MT.nii'},{'.'},{'.gz'}));
        if exist(MTfile{1},'file')
            StructuralTemplateFileName = MTfile{1};
        end
    end
    
    % If PDw also exists then mask structural to be sure
    PDw = cellstr(pickfiles(fullfile(dwDir.subjectDir),{'_PDw.nii'},{'.'},{'.gz','mask','BiasField'}));
    if ~isempty(PDw{1})
        
        structnii = niftiRead(StructuralTemplateFileName);
        PDnii = niftiRead(PDw{1});
        
        structnii.data(PDnii.data<=100) = 0;
        structnii.data(structnii.data<0) = 0;
        
        if(numel(structnii.pixdim)>3), TR = structnii.pixdim(4);
        else                       TR = 1;
        end
        
        dtiWriteNiftiWrapper(single(structnii.data), structnii.qto_xyz, StructuralTemplateFileName, 1, '', [],[],[],[], TR);
        [~,~,ext] = fileparts(StructuralTemplateFileName);
        if strfind(ext,'gz')
            gunzip(StructuralTemplateFileName)
        else
            gunzip([StructuralTemplateFileName '*gz'])
        end
    end
    
    [~, anat_name, anat_ext] = fileparts(StructuralTemplateFileName);
    
    HARDI_DWIs = [dwDir.HARDIdir filesep dwDir.outBaseName '_HARDI.nii.gz'];
    HARDI_mask = [dwDir.HARDIdir filesep dwDir.outBaseName '_mask.nii'];
    HARDI_anat = [dwDir.HARDIdir filesep anat_name anat_ext];
    
    % Copy anatomy file and mask
    if ~exist(HARDI_mask,'file')
        copyfile(b0maskname,HARDI_mask);
    end
    if ~exist(HARDI_anat,'file')
        copyfile(StructuralTemplateFileName,HARDI_anat);
    end
    
    if ~isfield(dwParams.mrtrixParams,'lmax')
        dwParams.mrtrixParams = default_mrtrixParams;
    end
    
    dwDir.fsurfdir=[dwDir.subjectDir filesep 'qMRI'];
    if dwParams.mrtrixParams.connectome==1
        % Create folder for all FreeSurfer surface processing
        dwDir = freesurf_setup(dwDir);
    end
    
    if isfield(dwParams,'SubjectID') && ~isempty(dwParams.SubjectID)
        pathsplit = strsplit(dwDir.subjectDir,[filesep dwParams.SubjectID]);
        BaseDirPath = pathsplit{1};
        SubjectName = dwParams.SubjectID;
    else
        % Sets the path which will be different on the HPC system
        pathsplit = strsplit(dwDir.subjectDir,[filesep 'PR0']);
        BaseDirPath = pathsplit{1};
        SubjectName = '';
    end
    
    
    dwParams.mrtrixParams.SubjectName = SubjectName;
    dwParams.mrtrixParams.qMRIpath = dwDir.fsurfdir;
    
    mrtrix_wrapper(HARDI_DWIs,HARDI_mask,HARDI_anat,BaseDirPath,dwParams.mrtrixParams)
    
end

