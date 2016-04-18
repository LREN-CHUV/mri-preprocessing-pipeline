function OutputMaskedImages = Mask_images(Images2Mask,MaskImage,thresh_mask,suffix)

%% Input Parameters
%   Images2Mask: Images to mask using MaskImage
%   MaskImage : The Mask image.
%   thresh_mask: Threshold used in MaskImage for obtaining the final mask.
%   suffix: Suffix used for saving the output Masked image. 
%
%% Output Parameters
%   OutputMaskedImages: Full path of the masked images.
%
%% Anne Ruef, Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, May 28th, 2014

if ~exist('thresh_mask','var')
    thresh_mask = 100;  % Set for VBQ case, using MT.nii as image to mask, and PDw.nii used for masking.
end;
if ~exist('suffix','var')
    suffix = '_m';
end

Ns = size(Images2Mask,1);

V = spm_vol(MaskImage);
Y = spm_read_vols(V);
Y = Y > thresh_mask;

OutputMaskedImages = cell(Ns,1);
for i=1:Ns    
    V = spm_vol(deblank(Images2Mask(i,:)));
    I2mask = spm_read_vols(V);    
    Iout = I2mask.* Y;
    [FilePath,FileName,FileExt] = fileparts(V.fname);
    V.fname = [FilePath,filesep,FileName,suffix,FileExt];    
    spm_write_vol(V,Iout);
    OutputMaskedImages{i} =  V.fname;
end

end