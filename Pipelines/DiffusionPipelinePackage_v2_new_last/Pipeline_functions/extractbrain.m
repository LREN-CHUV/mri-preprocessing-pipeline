function extractbrain(anatomicalimage,newmaskedimage)


[path name] = fileparts(anatomicalimage);
TPMfilename = [fileparts(which('spm')) '/tpm/TPM.nii'];
maskpath = [path filesep name '_mask.nii'];

brain_mask(anatomicalimage,maskpath,TPMfilename,0);

[status,cmdout] = unix(['maskfilter ' maskpath ' dilate ' maskpath ' -npass 5 -force'],'-echo');

anatnii = niftiRead(anatomicalimage);
masknii = niftiRead(maskpath);

maskedanat = double(anatnii.data).*double(masknii.data);

if(numel(anatnii.pixdim)>3), TR = anatnii.pixdim(4);
else                       TR = 1;
end

dtiWriteNiftiWrapper(int16(maskedanat), anatnii.qto_xyz, newmaskedimage, 1, '', [],[],[],[], TR);
gunzip([newmaskedimage '*.gz'])

delete(maskpath)