function [Sessions,uniqueRes,uniqueResIdx,FileExt] = PrepareFiles(SubjSessionFolder,volnum,dummyscans,grefieldSequenceName,StructSequenceName,EPISequenceName,pmDefaultFile)

% PrepareFiles(SubjSessionFolder,volnum,dummyscans,grefieldSequenceName,StructSequenceName,EPISequenceName, pmDefaultFilePath)
% function which prepares files for fMRI preprocessing
%
% SubjSessionFolder : string, subject's session folder
% grefieldSequenceName : a string containing the sequence name for the grefield mapping
% StructSequenceName : a string containing the sequence name for the Structural images
% EPISequenceName : a string containing the sequence name for fMRI 
% pmDefaultFilePath: string of the full path of the EPI corresponding pm default file
%
%% Sandrine Muller, Renaud Marquis, Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, October 25th, 2015

if ~strcmpi(SubjSessionFolder(end),filesep)
    SubjSessionFolder = [SubjSessionFolder,filesep];
end;

%% === Detecting needed folders and files === %%
%% Phase and Magnitude images of b0 Field maps ...  
Folder_List = getListofFolders([SubjSessionFolder,grefieldSequenceName],'yes'); % gives back sorted Folder list
InSubDir01 = [SubjSessionFolder,grefieldSequenceName,filesep,Folder_List{1}];
InSubDir02 = [SubjSessionFolder,grefieldSequenceName,filesep,Folder_List{2}];
Files_Magnitude = spm_select('FPListRec',InSubDir01,'.*');
Files_Phase     = spm_select('FPListRec',InSubDir02,'.*');

if ~isempty(Files_Phase)
    Sessions.Phase = cellstr(Files_Phase);
else
    disp(' Phase Images missing ...');
    Sessions.Phase = {};
end;
if ~isempty(Files_Magnitude)
    Sessions.Magnitude = cellstr(Files_Magnitude(1,:));
else
    disp(' Magnitude Images missing ...');
    Sessions.Magnitude = {}; 
end;
   
%% Structural Image ...
FolderList = getListofFolders([SubjSessionFolder,StructSequenceName],'yes'); % gives back sorted Folder list
Anatomical_Image = spm_select('FPListRec',[SubjSessionFolder,StructSequenceName,filesep,FolderList{1}],'.*');
Sessions.Struct = cellstr(Anatomical_Image(1,:));

%% Listing EPIs ...
EPI_Folders = getListofFolders([SubjSessionFolder,EPISequenceName],'yes'); % gives back sorted Folder list
for i=1:length(EPI_Folders)    
    Files_EPI = spm_select('FPListRec',[SubjSessionFolder,EPISequenceName,filesep,EPI_Folders{i}],'.*');
    Sessions.EPI{i} = cellstr(Files_EPI);
    Sessions.EPIresolution(i) = {'3mm'};
end;

[~,~,FileExt] = fileparts(Files_EPI(1,:));

%% Checking for incomplete sequences ...
Sessions = build_EPI_sessions(Sessions,volnum);

%% Parameters of EPI acquisition
[uniqueRes, ~, uniqueResIdx] = unique(Sessions.EPIresolution); % uniqueResIdx : define groups of EPI resolutions to preprocess differently
Sessions.PMdefaultfile = cellstr(pmDefaultFile);
Idx3mm = strcmp(Sessions.EPIresolution,'3mm');

%% Removing dummies ...
temp = Sessions.EPI(Idx3mm);% BEWARE : dummy scans only removed for 3mm resolution
if dummyscans ~=0
    Sessions.EPI(Idx3mm) = removeDummies(temp,FileExt,dummyscans);
end

end