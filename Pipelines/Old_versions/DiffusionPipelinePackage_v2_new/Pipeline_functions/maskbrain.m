function maskbrain(brainimage,maskimage,maskedbrainimage)
% Simply takes a data image and mask in the same space and outputs the
% union.

anatmasknii = niftiRead(maskimage);
HARDI_anatnii = niftiRead(brainimage);
HARDI_anatmasked = double(HARDI_anatnii.data).*double(anatmasknii.data);
if(numel(HARDI_anatnii.pixdim)>3), TR = HARDI_anatnii.pixdim(4);
else                       TR = 1;
end
dtiWriteNiftiWrapper(single(HARDI_anatmasked), HARDI_anatnii.qto_xyz, maskedbrainimage, 1, '', [],[],[],[], TR);
if exist([HARDI_anat '.gz'],'file')>0
    gunzip([maskedbrainimage '.gz'])
    delete([maskedbrainimage '.gz'])
end