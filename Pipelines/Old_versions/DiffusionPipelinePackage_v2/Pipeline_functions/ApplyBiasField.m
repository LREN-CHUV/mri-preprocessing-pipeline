function ApplyBiasField(EPI,BiasField)

% Apply the bias field correction to EPI image using the SPM computed
% BiasField

EPIimage = niftiRead(EPI);
BiasImage = niftiRead(BiasField);

if strcmp('Bias Field Corrected',EPIimage.descrip);
    return
end

V = size(EPIimage.data,4);

newdata = zeros(size(EPIimage.data));

for i = 1:V
    
    newdata(:,:,:,i) = double(EPIimage.data(:,:,:,i)).*double(BiasImage.data);
    
end

if(numel(EPIimage.pixdim)>3), TR = EPIimage.pixdim(4);
else                       TR = 1;
end

dtiWriteNiftiWrapper(int16(round(newdata)), EPIimage.qto_xyz, EPI, 1, ...
    'Bias Field Corrected', [],[],[],[], TR);