function maskbrain(anat,mask,maskedanat)
% Simple function which finds the union between anat and mask, both of
% which should be in the same space and alignment.

anatnii = niftiRead(anat);
masknii = niftiRead(mask);

maskeddata = double(anatnii.data).*double(masknii.data);

if(numel(anatnii.pixdim)>3), TR = anatnii.pixdim(4);
else                       TR = 1;
end

dtiWriteNiftiWrapper(single(maskeddata), anatnii.qto_xyz, maskedanat, 1, '', [],[],[],[], TR);

pause(2)

if exist([maskedanat '.gz'],'file')>0
    gunzip([maskedanat '.gz'])
    delete([maskedanat '.gz'])
end
