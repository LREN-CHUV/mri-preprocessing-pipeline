function sortDWIdata(bvals,bvecs,DWIfilename,outname,comment)

if ischar(bvals)
    bvals=dlmread(bvals);
end

if ischar(bvecs)
    bvecs=dlmread(bvecs);
end


dwRaw = niftiRead(DWIfilename);

[bvals, sortinds]=sort(bvals);
bvecs=bvecs(:,sortinds);
dwRaw.data=dwRaw.data(:,:,:,sortinds);

if(numel(dwRaw.pixdim)>3), TR = dwRaw.pixdim(4);
else                       TR = 1;
end

dtiWriteNiftiWrapper(int16(round(dwRaw.data)), dwRaw.qto_xyz, [outname '.nii.gz'], 1, ...
    comment, [],[],[],[], TR);

dlmwrite([outname '.bvals'],bvals,' ');
dlmwrite([outname '.bvecs'],bvecs,' ');