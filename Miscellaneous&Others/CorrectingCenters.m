function CorrectingCenters(MTSubDir,ReferenceImage,Images2CorrectCenterExt)

%% CorrectingCenters(MTSubDir,ReferenceImage,Images2CorrectCenterExt)
%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, April 23rd, 2015

V = spm_vol(ReferenceImage);
M = V.mat;
Images2CorrectCenter = pickfiles(MTSubDir,'',Images2CorrectCenterExt);
Ni = size(Images2CorrectCenter,1);
for i=1:Ni
    V = spm_vol(Images2CorrectCenter(i,:));    
    I = spm_read_vols(V);
    V.mat = M;
    spm_write_vol(V,I);
end

end