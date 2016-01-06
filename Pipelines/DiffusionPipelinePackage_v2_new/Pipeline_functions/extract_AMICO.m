function extract_AMICO(dwDir,fitparams)

AMICOnii =niftiRead(fitparams(1,:));

icvf = squeeze(AMICOnii.data(:,:,:,1));

ISO = squeeze(AMICOnii.data(:,:,:,2));

ODI = squeeze(AMICOnii.data(:,:,:,3));

outputdir = [dwDir.subjectDir filesep 'NODDI'];

if(numel(AMICOnii.pixdim)>3), TR = AMICOnii.pixdim(4);
    else                       TR = 1;
end

dtiWriteNiftiWrapper(icvf, AMICOnii.qto_xyz, [outputdir filesep dwDir.inBaseName '_ficvf.nii'], 1, '', [],[],[],[], TR);
dtiWriteNiftiWrapper(ODI, AMICOnii.qto_xyz, [outputdir filesep dwDir.inBaseName '_fiso.nii'], 1, '', [],[],[],[], TR);
dtiWriteNiftiWrapper(ISO, AMICOnii.qto_xyz, [outputdir filesep dwDir.inBaseName '_odi.nii'], 1, '', [],[],[],[], TR);

