function sortHARDIdata(bvals,bvecs,DWIfilename,outname,comment)

% Function designed to extract and save all DWI data appropriate for HARDI
% model fitting.

if ischar(bvals)
    bvals=dlmread(bvals);
end

if ischar(bvecs)
    bvecs=dlmread(bvecs);
end


dwRaw = niftiRead(DWIfilename);

inds=find(bvals==0 | bvals>=1800);
bvals=bvals(inds);
bvecs=bvecs(:,inds);
dwRaw.data=dwRaw.data(:,:,:,inds);

if(numel(dwRaw.pixdim)>3), TR = dwRaw.pixdim(4);
else                       TR = 1;
end

dtiWriteNiftiWrapper(int16(round(dwRaw.data)), dwRaw.qto_xyz, [outname '.nii.gz'], 1, ...
    comment, [],[],[],[], TR);

dlmwrite([outname '.bvals'],bvals,' ');
dlmwrite([outname '.bvecs'],bvecs,' ');