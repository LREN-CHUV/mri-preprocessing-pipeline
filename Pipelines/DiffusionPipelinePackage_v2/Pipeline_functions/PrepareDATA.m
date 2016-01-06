function [im, newMask] = PrepareDATA(dwiData,maskname)

[pathstr, name, ext] = fileparts(dwiData);

DWI_nii=niftiRead(dwiData);

mask_nii=niftiRead(maskname);


im = DWI_nii.data;
DWI_nii.data = [];

[X, Y, Z, V] = size(im);
mask4D = uint8(zeros(size(im)));

for i=1:V
    mask4D(:,:,:,i) = uint8(mask_nii.data);
end

Inds = find((im(:)<1).*(mask4D(:)==1));

[x1,y1,z1,v1] = ind2sub([X, Y, Z, V],Inds);

for i = 1:length(Inds)
    
    x = x1(i);
    y = y1(i);
    z = z1(i);
    v = v1(i);
    
    if x>1 && x<X && y>1 && y<Y && z>1 && z<Z
        N(1)=im(x-1,y-1,z-1);  N(2)=im(x,y-1,z-1);  N(3)=im(x+1,y-1,z-1);  N(4)=im(x-1,y,z-1);  N(5)=im(x,y,z-1);  N(6)=im(x+1,y,z-1);  N(7)=im(x-1,y+1,z-1);  N(8)=im(x,y+1,z-1);  N(9)=im(x+1,y+1,z-1);
        N(10)=im(x-1,y-1,z);   N(11)=im(x,y-1,z);   N(12)=im(x+1,y-1,z);   N(13)=im(x-1,y,z);                      N(14)=im(x+1,y,z);   N(15)=im(x-1,y+1,z);   N(16)=im(x,y+1,z);   N(17)=im(x+1,y+1,z-1);
        N(18)=im(x-1,y-1,z+1); N(19)=im(x,y-1,z+1); N(20)=im(x+1,y-1,z+1); N(21)=im(x-1,y,z+1); N(22)=im(x,y,z+1); N(23)=im(x+1,y,z+1); N(24)=im(x-1,y+1,z+1); N(25)=im(x,y+1,z+1); N(26)=im(x+1,y+1,z+1);
        im(x,y,z,v)= mean(N(:));
    end
    
end

ZeroIntensityVoxels=zeros(size(im));
ZeroIntensityVoxels(im==0)=1;
ZeroIntensityVoxels=max(ZeroIntensityVoxels,[],4);

ZeroVoxinMask=zeros(size(im));
ZeroVoxinMask(ZeroIntensityVoxels==1 & mask_nii.data>0)=1;

newMask=mask_nii.data;
newMask(newMask>0)=1;
newMask(ZeroVoxinMask==1)=0;

if(numel(DWI_nii.pixdim)>3), TR = DWI_nii.pixdim(4);
else                       TR = 1;
end

dtiWriteNiftiWrapper(newMask, mask_nii.qto_xyz, maskname, 1, 'NODDI Corrected Mask: exclusion of DWI voxels with 0 intensity', [],[],[],[], TR);
dtiWriteNiftiWrapper(im, DWI_nii.qto_xyz, dwiData, 1, 'Zero Voxel intensity corrected data', [],[],[],[], TR);
gunzip([maskname '.gz']);
gunzip([pathstr filesep name '*.gz']);
pause(2)