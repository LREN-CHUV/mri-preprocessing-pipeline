function ScaledImage = ScaleData(Image,ScaleFactor)
% Scale an anatomical image by a specific factor. Particularly useful for
% MT so that it can be used in place of T1w MPRAGE images

nii = niftiRead(Image);
nii.data = nii.data*ScaleFactor;

[pathstr,name,ext] = fileparts(Image);

if(numel(nii.pixdim)>3), TR = nii.pixdim(4);
else                       TR = 1;
end

ScaledImage = [pathstr filesep name '_x' num2str(ScaleFactor) ext];

dtiWriteNiftiWrapper(int16(round(nii.data)), nii.qto_xyz, ScaledImage, 1, ...
    'Scaled image file', [],[],[],[], TR);

gunzip([ScaledImage '.gz'])