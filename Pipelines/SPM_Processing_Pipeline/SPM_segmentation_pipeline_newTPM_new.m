function SPM_segmentation_pipeline_newTPM_new(ServerFolder,SubjectID,TemplateImage,WhichImage)

% In this program is saved previous segmentation files using old tpm, and run segmentation with the new tpm.
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

OldSegmentationFolder = 'Old_Segmentation_nwTPM_SL_template';
SujectServerFolder = [ServerFolder,SubjectID];
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
        MPMs_Segmentation(Image2Segment(i,:),TemplateImage); 
    end;
end

end