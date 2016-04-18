function SPM_segmentation_pipeline_newTPM_AC_PC_align_new(ServerFolder,SubjectID,TemplateImage,WhichImage)

% In this program is saved previous segmentation files using old tpm, run segmentation with the new tpm and fixing the center to guarantee the segmentation working.
%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, April 23rd, 2015

s = which('spm.m');
if  isempty(s)
    disp('Please add SPM toolbox in the path .... ');
    return;
end;
if ~strcmp(ServerFolder(end),filesep)
    ServerFolder = [ServerFolder,filesep];
end;
if ~exist('WhichImage','var')
    WhichImage = '_MT_m.nii';
else
    if isempty(WhichImage)
        WhichImage = '_MT_m.nii';
    end;
end;

OldSegmentationFolder = 'Old_Segmentation';
SujectServerFolder = [ServerFolder,SubjectID];
Niter = 8; % Number of iterations for commissure adjustment ...
Images2CorrectCenterExt = {'_A.nii';'_MT.nii';'_MTR.nii';'_MTR_synt.nii';'_MTRdiff.nii';'_MTw.nii';'_PDw.nii';'_R1.nii';'_R1_m.nii';'_R2s.nii';'_T1w.nii'};
if exist(SujectServerFolder,'dir')
    Image2Segment = pickfiles(SujectServerFolder,{WhichImage},{filesep},{'c1s';'c2s';'c3s';'iy_s';'_seg8.mat';'y_s'});
    Ni = size(Image2Segment,1);
    for i=1:Ni
        FileFolder = fileparts(Image2Segment(i,:));
        mkdir(FileFolder,OldSegmentationFolder);
        Images2Move = pickfiles(FileFolder,{filesep},{'c1s';'c2s';'c3s';'iy_s';'_seg8.mat';'y_s'});
        Nf = size(Images2Move,1);
        for k=1:Nf
            movefile(Images2Move(k,:),[FileFolder,filesep,OldSegmentationFolder]);
        end;
        comm_adjust(1,Image2Segment(i,:),'T1',Image2Segment(i,:),Niter,0); % Commissure adjustment to find a rigth image center and have good segmentation.
        CorrectingCenters(FileFolder,Image2Segment(i,:),Images2CorrectCenterExt);  % Correcting new center to the rest of the images.
        MPMs_Segmentation(Image2Segment(i,:),TemplateImage);  
    end;
end

end
