function NODDI_FitWrapper(dwDir,doMask)

%% Check that input data has multiple shells with minimum of 15 samples

bval=dwDir.dwPreprocessedbvals;
load_bvals=dlmread(bval);
n_low=nnz(find(load_bvals<1200 & load_bvals>500));
n_high=nnz(find(load_bvals>1800));

if n_low>15 && n_high>15
    
    %% Organise Workspace Variables
    
    rawDWIdata=dwDir.dwPreprocessedFile;
    bvec=dwDir.dwPreprocessedbvecs;
    outputdir=[dwDir.subjectDir filesep 'NODDI'];
    TPMfilename=fullfile(dwDir.PipelineBaseDir,'templates','nwTPM_corr.nii');
    
    if ~exist(outputdir,'dir')
        mkdir(outputdir)
    end
    % cd(outputdir);
    
    [~, filename] = fileparts(rawDWIdata);
    splitrawname = strsplit(filename,'.');
    mnb0name=[char(splitrawname(1)) '_mnb0.nii'];
    maskname=[char(splitrawname(1)) '_mnb0_mask.nii'];
    
    if ~exist([outputdir filesep maskname],'file') || doMask==1
        CreateMeanB0(rawDWIdata, bval, [outputdir filesep mnb0name]);
        gunzip([outputdir filesep '*.gz'])
        pause(2)
        brain_mask([outputdir filesep mnb0name],[outputdir filesep maskname],TPMfilename);
    end
    
    NODDI_roi=[outputdir filesep char(splitrawname(1)) '_NODDI_roi.mat'];
    FittedParams=[outputdir filesep char(splitrawname(1)) '_FittedParams.mat'];
    
    %% Ensure that the mask does not include any voxels with zero intensity
    
    DWI_nii=niftiRead(rawDWIdata);
    mask_nii=niftiRead([outputdir filesep maskname]);
    
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
    
    dtiWriteNiftiWrapper(newMask, mask_nii.qto_xyz, [outputdir filesep maskname], 1, 'NODDI Corrected Mask: exclusion of DWI voxels with 0 intensity', [],[],[],[], TR);
    gunzip([outputdir filesep maskname '.gz'])
    
    %% Setup data for NODDI processing
    
    CreateROI(rawDWIdata, [outputdir filesep maskname], NODDI_roi);
    
    protocol = FSL2Protocol(bval, bvec);
    
    noddi = MakeModel('WatsonSHStickTortIsoV_B0');
    
    %% Begin NODDI parameter batch fitting
    
    batch_fitting(NODDI_roi, protocol, noddi, FittedParams);
    
    %% Save parameters as volumetric maps
    
    SaveParamsAsNIfTI(FittedParams, NODDI_roi, [outputdir filesep maskname], [outputdir filesep char(splitrawname(1))]);
    
    else disp('Skipping NODDI parameter fitting')
    
end

if n_low<15
    disp('Too few points on lower shell (<15)')
end

if n_high<15
    disp('Too few points on higher shell (<15)')
end