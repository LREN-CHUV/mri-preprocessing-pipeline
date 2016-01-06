function NODDI_FitWrapper(dwDir,doMask)

%% Check that input data has multiple shells with minimum of 15 samples

bval=dwDir.dwPreprocessedbvals;
load_bvals=dlmread(bval);
n_low=nnz(find(load_bvals<1200 & load_bvals>500));
n_high=nnz(find(load_bvals>1800));

if n_low>15 || n_high>15
    
    %% Organise Workspace Variables
    
    rawDWIdata=dwDir.dwPreprocessedFile;
    bvec=dwDir.dwPreprocessedbvecs;
    outputdir=[dwDir.subjectDir '\NODDI'];
    TPMfilename=fullfile(dwDir.PipelineBaseDir,'templates','nwTPM_corr.nii');
    
    if ~exist(outputdir,'dir')
        mkdir(outputdir)
    end
    % cd(outputdir);
    
    [~, filename] = fileparts(rawDWIdata);
    splitrawname = strsplit(filename,'.');
    mnb0name=[char(splitrawname(1)) '_mnb0.nii'];
    maskname=[char(splitrawname(1)) '_mnb0_mask.nii'];
    
    if ~exist([outputdir '\' maskname],'file') || doMask==1
        CreateMeanB0(rawDWIdata, bval, [outputdir '\' mnb0name]);
        gunzip([outputdir '\*.gz'])
        pause(2)
        brain_mask([outputdir '\' mnb0name],[outputdir '\' maskname],TPMfilename);
    end
    
    NODDI_roi=[outputdir '\' char(splitrawname(1)) '_NODDI_roi.mat'];
    FittedParams=[outputdir '\' char(splitrawname(1)) '_FittedParams.mat'];
    
    %% Ensure that the mask does not include any voxels with zero intensity
    
    DWI_nii=niftiRead(rawDWIdata);
    mask_nii=niftiRead([outputdir '\' maskname]);
    
    ZeroIntensityVoxels=zeros(size(DWI_nii.data));
    ZeroIntensityVoxels(DWI_nii.data==0)=1;
    ZeroIntensityVoxels=max(ZeroIntensityVoxels,[],4);
    
    ZeroVoxinMask=zeros(size(DWI_nii.data));
    ZeroVoxinMask(ZeroIntensityVoxels==1 & mask_nii.data>0)=1;
    
    newMask=mask_nii.data;
    newMask(newMask>0)=1;
    newMask(ZeroVoxinMask==1)=0;
    
    if(numel(mask_nii.pixdim)>3), TR = mask_nii.pixdim(4);
    else                       TR = 1;
    end
    
    dtiWriteNiftiWrapper(newMask, mask_nii.qto_xyz, [outputdir '\' maskname], 1, 'NODDI Corrected Mask: exclusion of DWI voxels with 0 intensity', [],[],[],[], TR);
    gunzip([outputdir '\' maskname '.gz'])
    pause(2)
    
    %% Setup data for NODDI processing
    
    CreateROI(rawDWIdata, [outputdir '\' maskname], NODDI_roi);
    
    protocol = FSL2Protocol(bval, bvec);
    
    noddi = MakeModel('WatsonSHStickTortIsoV_B0');
    
    %% Begin NODDI parameter batch fitting
    
    batch_fitting(NODDI_roi, protocol, noddi, FittedParams);
    
    %% Save parameters as volumetric maps
    
    SaveParamsAsNIfTI(FittedParams, NODDI_roi, [outputdir '\' maskname], [outputdir '\' char(splitrawname(1))]);
    
    else disp('Skipping NODDI parameter fitting')
    
end

if n_low<15
    disp('Too few points on lower shell (<15)')
end

if n_high<15
    disp('Too few points on higher shell (<15)')
end