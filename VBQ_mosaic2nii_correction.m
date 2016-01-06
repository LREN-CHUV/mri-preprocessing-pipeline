function VBQ_mosaic2nii_correction(DicomInSubDir,NiiInSubDir)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, June 22nd, 2014

if ~strcmp(DicomInSubDir(end),filesep)
    DicomInSubDir = [DicomInSubDir,filesep];
end;
if ~strcmp(NiiInSubDir(end),filesep)
    NiiInSubDir = [NiiInSubDir,filesep];
end;
DicomFolderNames = getListofFolders(DicomInSubDir);
NiiFolderNames = getListofFolders(NiiInSubDir);
Nrep = length(NiiFolderNames);
if Nrep>0
    for i=1:Nrep
        DicomInputFolder = [DicomInSubDir,DicomFolderNames{i},filesep];
        NiiInputFolder = [NiiInSubDir,NiiFolderNames{i},filesep];
        Correct_VBQ_mosaic(DicomInputFolder,NiiInputFolder);
    end;
else
    Correct_VBQ_mosaic(DicomInSubDir,NiiInSubDir);
end;

end

%%  =====      Internal Functions =====  %%
%% function Correct_VBQ_mosaic(DicomInputFolder,NiiInputFolder)
function Correct_VBQ_mosaic(DicomInputFolder,NiiInputFolder)

% This function was modified from smartdep_convert_mosaic.m function ..

NiiFiles = pickfiles(NiiInputFolder,{'.nii'});
v1tt = spm_vol(NiiFiles(1,:));
Nfiles = size(NiiFiles,1);
[n1,n2,n3] = size(spm_read_vols(v1tt));
if Nfiles>n3
    v = spm_vol(NiiFiles);
    dat = zeros(n1,n2,n3,numel(v));
    for i=1:numel(v)
        dat(:,:,:,i) = spm_read_vols(v(i));
    end;
    dim2 = size(dat);
    dim = [dim2(1:2) dim2(4)];
    
    dicom_files = spm_select('FPListRec',DicomInputFolder,'.*');
    hdr = spm_dicom_headers(dicom_files);
    % ------ %
    analyze_to_dicom = [diag([1 -1 1]) [0 (dim(2)+1) 0]'; 0 0 0 1]; % Flip voxels in y
    patient_to_tal   = diag([-1 -1 1 1]); % Flip mm coords in x and y directions
    
    R  = [reshape(hdr{1}.ImageOrientationPatient,3,2)*diag(hdr{1}.PixelSpacing); 0 0];
    x1 = [1;1;1;1];
    y1 = [hdr{1}.ImagePositionPatient(:); 1];
    
    if length(hdr)>1,
        x2 = [1;1;dim(3); 1];
        y2 = [hdr{end}.ImagePositionPatient(:); 1];
    else
        orient           = reshape(hdr{1}.ImageOrientationPatient,[3 2]);
        orient(:,3)      = null(orient');
        if det(orient)<0, orient(:,3) = -orient(:,3); end;
        if checkfields(hdr{1},'SliceThickness'),
            z = hdr{1}.SliceThickness;
        else
            z = 1;
        end
        x2 = [0;0;1;0];
        y2 = [orient*[0;0;z];0];
    end
    dicom_to_patient = [y1 y2 R]/[x1 x2 eye(4,2)];
    mat = patient_to_tal*dicom_to_patient*analyze_to_dicom;
    % ------
    phx = smartdep_get_numaris4_val(hdr{1}.CSASeriesHeaderInfo, 'MrPhoenixProtocol');
    tok = regexp(phx, 'alTE\[[0-9]+\][ ]*=[ ]*([0-9]+)', 'tokens');
    tim = datevec(hdr{1}.AcquisitionTime/(24*60*60));
    
    for i=1:dim2(3)
        descrip = sprintf('%gT %s %s TR=%gms/TE=%gms/FA=%gdeg %s %d:%d:%.5g Mosaic',...
            hdr{1}.MagneticFieldStrength, hdr{1}.MRAcquisitionType,...
            deblank(hdr{1}.ScanningSequence),...
            hdr{1}.RepetitionTime,str2double(tok{i}) / 1000,hdr{1}.FlipAngle,...
            datestr(hdr{1}.AcquisitionDate),tim(4),tim(5),tim(6));
        dat2 = reshape(dat(:,:,1+dim2(3)-i,:), size(dat,1), size(dat,2), size(dat,4));
        v2 = v(1);
        [path, name] = fileparts(NiiFiles(i,:));
        v2.dim = dim;
        if i<10
            echostr = ['0',num2str(i)];
        end;
        v2.fname = fullfile(path, [name,'-','Echo',echostr,'.nii']);
        v2.mat = mat;
        v2.descrip = descrip;
        spm_write_vol(v2, dat2);
    end
    % Cleaning up
    for i=1:size(NiiFiles,1)
        delete(NiiFiles(i,:));
    end;
end;

end
