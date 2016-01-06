function dtiFitTensorWrapper(fitmethod,dwDir,voxelsize,doMask)

rawDWIdata=dwDir.dwPreprocessedFile;
bval=dwDir.dwPreprocessedbvals;
bvec=dwDir.dwPreprocessedbvecs;
outputdir=[dwDir.subjectDir '\dti'];
TPMfilename=fullfile(dwDir.PipelineBaseDir,'templates','nwTPM_corr.nii');

if ~exist(outputdir)
    mkdir(outputdir)
end

% Run appropriate tensor fit based on fitmethod (WLLS as default)
if strcmp(fitmethod,'lls') || strcmp(fitmethod,'LLS')
    disp('Initiating LLS tensor estimation...')
    dtiFitTensorLLS(rawDWIdata,bval,bvec,outputdir,voxelsize,doMask,TPMfilename);
    
else if strcmp(fitmethod,'nnls') || strcmp(fitmethod,'NLLS') || ...
            strcmp(fitmethod,'cnnls') || strcmp(fitmethod,'CNLLS')
        disp('Initiating CNLLS tensor estimation...')
        dtiFitTensorCNLLS(rawDWIdata,bval,bvec,outputdir,voxelsize,doMask,TPMfilename);
    else
        disp('Initiating WLLS tensor estimation...')
        dtiFitTensorWLLS(rawDWIdata,bval,bvec,outputdir,voxelsize,doMask,TPMfilename);
    end
end

