function [Sessions uniqueRes uniqueResIdx FileExt] = PrepareFiles(NIIs_folder,volnum,dummyscans,seqNamegrefield,seqNameStruct,seqNameEPI, pmDefaultFilePath)
% function which prepares files for fMRI preprocessing
%
% NIIs_folder : string, subject's folder
% seqNamegrefield: a string containing the sequence name for the grefield mapping
% seqNameStruct: a string containing the sequence name for the Structural scan
% seqNameEPI : a string containing the sequence name for the fMRI 
% pmDefaultFilePath: string of the path of the EPI corresponding pm default file


fprintf('Prepare preprocessing session config .mat... \n');


%% List folder names (per subject):
% FolderNames = detectFolders(NIIs_folder);
[ff,dd] = spm_select('ExtFPListRec',NIIs_folder,'.nii');
FolderNames = cellstr(dd);
clear ff dd;

%% Detect needed folders and files:
%%%% PHASE
temp = FilterFolders(FolderNames,[seqNamegrefield '.*']);

if ~isempty(temp)
    Sessions.Phase = DetectFiles(NIIs_folder,temp{3}); % select the files in the Phase folder
    
    %%%% MAGNITUDE
    Magnitude = DetectFiles(NIIs_folder,temp{2}); % select the files in the Magnitude folder
    Sessions.Magnitude = Magnitude(1);
    clear temp;
    
else % case : no gre field mapping acquired
    Sessions.Phase = {};
    Sessions.Magnitude = {};
end

%%%% STRUCTURAL
temp = FilterFolders(FolderNames,seqNameStruct);

Struct = DetectFiles(NIIs_folder,[temp{end}]); % select the files in the Structural folder, by default take the last sequence of MPRAGE 
Sessions.Struct = Struct(1); % in case several structural scans, take only the first

clear temp;

%% List EPIs and avoid potentially pre-existing processed files:
temp = FilterFolders(FolderNames,seqNameEPI);
% if dummies folders do not count them:
for j = 1:length(temp)
    [pp nn ee] = fileparts(temp{j,1});
    idx(j) = ~strcmp(nn,'dummies');
end
idx(1) = 0;
temp = temp(idx);
clear idx;
for i = 1:length(temp)
    [f FileExt] = DetectFiles(NIIs_folder,temp{i}); % select the files in the Structural folder
    
    % to remove already preprocessed files:
    L = length(strcat(NIIs_folder,filesep,temp{i}))+2;
    for j = 1:length(f)
        [pp nn ee] = fileparts(f{j,1});
        idx(j) = (strcmp(nn(1),'s')+strcmp(nn(1),'w')+strcmp(nn(1),'b')+strcmp(nn(1),'u')+strcmp(nn(1),'rp')+strcmp(nn(1),'B')+strcmp(nn(1),'c'))==0;
    end
    Sessions.EPI{i} = f(idx);
    
    %%% Find Resolution
    temp3 = Sessions.EPI{1,i}{1,1};
    [p n e] = fileparts(temp3);
    [p n e] = fileparts(p);
    [p n e] = fileparts(p);
    s2 = regexp(n, '_', 'split');
    Sessions.EPIresolution(i) = s2(~cellfun(@isempty,regexpi(s2,'.*mm')));
    clear idx temp2 temp3 s2 p n e;
    
end



%% Check for incomplete sequences:
Sessions = build_EPI_sessions(Sessions,volnum);


%% Parameters of EPI acquisition
L = length(Sessions.EPIresolution);
[uniqueRes, m1, uniqueResIdx] = unique(Sessions.EPIresolution); % uniqueResIdx : define groups of EPI resolutions to preprocess differently
[p n e] = fileparts(which('fMRI_automated_preproc')); 
Sessions.PMdefaultfile = cellstr(pmDefaultFilePath);
Idx3mm = strcmp(Sessions.EPIresolution,'3mm');

%% Remove dummies :
temp = Sessions.EPI(Idx3mm);% BEWARE : dummy scans only removed for 3mm resolution
if dummyscans ~=0
    Sessions.EPI(Idx3mm) = removeDummies(temp,FileExt,dummyscans);
end



end