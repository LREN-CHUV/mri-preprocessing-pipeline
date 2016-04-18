function compute_MPMs_foreingData(SubjectFolder,SubjID,OutputFolder,MTSubDirLabel,PDSubDirLabel,T1SubDirLabel,MPM_Template,doUNICORT)

%% Lester Melie Garcia
% LREN, CHUV
% February 4th 2016

s = which('spm.m');
if isempty(s)
    disp('Please add SPM toolbox in the path .... ');
    return;
end;
if ~strcmp(SubjectFolder(end),filesep)
    SubjectFolder = [SubjectFolder,filesep];
end;
if ~strcmp(OutputFolder(end),filesep)
    OutputFolder = [OutputFolder,filesep];
end;

spm_jobman('initcfg');

Subj_OutputFolder = [OutputFolder,SubjID,filesep];
mkdir(Subj_OutputFolder);
copyfile(SubjectFolder,Subj_OutputFolder);

MTSubDir = get_FolderName(Subj_OutputFolder,MTSubDirLabel);
PDSubDir = get_FolderName(Subj_OutputFolder,PDSubDirLabel);
T1SubDir = get_FolderName(Subj_OutputFolder,T1SubDirLabel);

MT_Images = cellstr(spm_select('FPListRec',MTSubDir,'.*'));
PD_Images = cellstr(spm_select('FPListRec',PDSubDir,'.*'));
T1_Images = cellstr(spm_select('FPListRec',T1SubDir,'.*'));

Ini_List_Files = getAllFiles(Subj_OutputFolder);

disp('Computing MPMs ...');
MPMs_computation(MT_Images,PD_Images,T1_Images,doUNICORT);
%% Masking  MT map
MaskImage =  pickfiles(MTSubDir,'_PDw.nii');
if ~doUNICORT
    Images2Mask =  pickfiles(MTSubDir,'',{'_MT.nii';'_R1.nii'});
else
    % For unicort case ...
    [MaskFilePath,MaskFileName,MaskFileExt] = fileparts(MaskImage);
    Images2Mask_MT = [MaskFilePath,filesep,MaskFileName(1:end-3),'MT',MaskFileExt];
    Images2Mask_R1 = [MaskFilePath,filesep,'mh',MaskFileName(1:end-3),'R1',MaskFileExt];
    Images2Mask = char(Images2Mask_MT,Images2Mask_R1);
end;

thresh_mask = 100; suffix = '_m';
MaskedImages = Mask_images(Images2Mask,MaskImage,thresh_mask,suffix);
MT_MaskedImage = MaskedImages(1);
Niter = 8; % Number of iterations for commissure adjustment ...
Images2CorrectCenterExt = {'_A.nii';'_MT.nii';'_MTR.nii';'_MTR_synt.nii';'_MTRdiff.nii';'_MTw.nii';'_PDw.nii';'_R1.nii';'_R1_m.nii';'_R2s.nii';'_T1w.nii';'_MTforA.nii'};

comm_adjust(1,MT_MaskedImage{1},'T1',MT_MaskedImage{1},Niter,0); % Commissure adjustment to find a rigth image center and have good segmentation.
CorrectingCenters(MTSubDir,MT_MaskedImage{1},Images2CorrectCenterExt);  % Correcting new center to the rest of the images.

disp('Segmenting ...');
MPMs_Segmentation(MT_MaskedImage{1},MPM_Template);
Out_List_Files = getAllFiles(Subj_OutputFolder);
Reorganize_MPM_Files(Subj_OutputFolder,Ini_List_Files,Out_List_Files);

end

%% ==========  Internal Functions ==========
%% OutputFolder = get_FolderName(InputFolder,FolderLabel)
function OutputFolder = get_FolderName(InputFolder,FolderLabel)

if strcmp(InputFolder(end),filesep)
    InputFolder = InputFolder(1:end-1);
end;

Files = pickfiles(InputFolder,{[FolderLabel,filesep]});
OutputFolder = fileparts(Files(1,:));

% if ~strcmp(OutputFolder(end),filesep)
%     OutputFolder = [OutputFolder,filesep];
% end;

end

%% Reorganize_MPM_Files(Subj_OutputFolder,Ini_List_Files,Out_List_Files)
function Reorganize_MPM_Files(Subj_OutputFolder,Ini_List_Files,Out_List_Files)

Files2Delete = intersect(Out_List_Files,Ini_List_Files);
for i=1:length(Files2Delete)
    delete(Files2Delete{i});
end;
sizeTree = folderSizeTree(Subj_OutputFolder);
mem = cell2mat(sizeTree.size); % Folders size ..
flevel = cell2mat(sizeTree.level); % Folders level ...
ind = find((flevel==1)&(mem==0));
for i=1:length(ind)
    rmdir(sizeTree.name{ind(i)},'s');  % Removing empty folders ...
end;
sizeTree = folderSizeTree(Subj_OutputFolder);
mem = cell2mat(sizeTree.size); % Folders size ..
flevel = cell2mat(sizeTree.level); % Folders level ...
ind = find((flevel==2)&(mem==0));
for i=1:length(ind)
    rmdir(sizeTree.name{ind(i)},'s');  % Removing de remaining empty folders ...
end;

end
