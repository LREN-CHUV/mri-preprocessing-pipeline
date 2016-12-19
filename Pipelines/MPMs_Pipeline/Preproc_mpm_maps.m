function [isDone, Subj_OutputFolder] = Preproc_mpm_maps(InputFolder, SubjID, LocalOutputFolder, ProtocolsFile, PipelineParmsConfigFile, ServerFolder)

% This function computes the Multiparametric Maps (MPMs)(R2*, R1, MT, PD) and brain segmentation in different tissue maps.All computation was programmed based on the LREN database structure. The
% MPMs are calculated locally in 'OutputFolder' and finally copied to 'ServerFolder'.
%% Input Parameters:
%  InputFolder: Global folder where the subject data folder (identified by SubjID) will be placed. Based on LREN database, this folder contains Nifti data located in the server.
%  SubjID: Identifier of the subject (Subject's Folder name).
%  LocalOutputFolder: Local Folder where all MPMs belonging to several subjects will be saved.
%  ProtocolsFile: File that provides the list of protocols needed for MPMs computation. (for instance: Protocols_definition.txt)
%  PipelineParmsConfigFile : File defining parameters of the MPM pipeline:
%                               MPM_Template: Template used for segmentation step;
%                               doUNICORT: Flag variable to indicate if UNICORT approach is used to compute the MPMs.
%  ServerFolder: Folder located in the Server, where the final MPMs files will be saved where all users have access.
%
%% Output Parameters:
%  Subj_OutputFolder: Subject Folder located and defined by OutputFolder input variable (see Input Parameters).
%   isDone : isDone >= 1 : Subject finished without errors.
%            isDone = 0 :  No processing perform on that subject.
%            isDone = -1 : Subject finished with errors.
%
%% Anne Ruef, Lester Melie-Garcia
% LREN, CHUV.
% Lausanne, May 21st, 2014
% Modified: January 28th, 2016
% This is an improvement of 'Preproc_mpm_maps_extended_fixed.m'
% Code formatted using http://base-n.de/matlab/code_beautifier.html

try
    s = which('spm.m');
    if isempty(s)
        disp('Please add SPM toolbox in the path .... ');
          return;
    end;
    if ~ strcmp(InputFolder(end), filesep)
        InputFolder = [InputFolder, filesep];
    end;
    SubjectFolder = [InputFolder, SubjID, filesep];

    if ~ strcmp(LocalOutputFolder(end), filesep)
        LocalOutputFolder = [LocalOutputFolder, filesep];
    end;

    [MPM_Template, doUNICORT] = Read_Preproc_mpm_maps_config(PipelineParmsConfigFile); % Reading parameters needed for MPMs computation.

    spm_jobman('initcfg');

    if ~ exist(LocalOutputFolder, 'dir')
        mkdir(LocalOutputFolder);
    end;
    if ~ exist(ProtocolsFile, 'file')
        disp('Protocol names file does not exist ! Please specify ...');
          isDone = 0;
        return;
    end;
    if ~ exist('doUNICORT', 'var')
        doUNICORT = false;
    end;
    %% Checking if subject have valid MPMs folders ..
    RawSession_Folders = getListofFolders(SubjectFolder);
    Ns_t = length(RawSession_Folders); % Number of sessions ...
    Nprot_t = zeros(Ns_t, 1);
    for i = 1:Ns_t
        Nprot_t(i) = get_valid_MPM_Protocols(ProtocolsFile, [SubjectFolder, RawSession_Folders{i}, filesep], doUNICORT); % Number of protocols
    end;

    Niter = 8; % Number of iterations for commissure adjustment ...
    Images2CorrectCenterExt = {'_A.nii'; '_MT.nii'; '_MTR.nii'; '_MTR_synt.nii'; '_MTRdiff.nii'; '_MTw.nii'; '_PDw.nii'; '_R1.nii'; '_R1_m.nii'; '_R2s.nii'; '_T1w.nii'; '_MTforA.nii'};
    %%
    Ns = 0;
    if sum(Nprot_t) > 0
        Subj_OutputFolder = [LocalOutputFolder, SubjID, filesep];
        mkdir(Subj_OutputFolder);
        copyfile(SubjectFolder, Subj_OutputFolder);
        Session_Folder = getListofFolders(Subj_OutputFolder);
        Ns = length(Session_Folder); % Number of sessions ...
        Ini_List_Files = getAllFiles(Subj_OutputFolder);
        for i = 1:Ns
            DataFolder = [Subj_OutputFolder, Session_Folder{i}, filesep];
            [Nprot, B0_p, B1_p, MT_p, PD_p, T1_p] = get_valid_MPM_Protocols(ProtocolsFile, DataFolder, doUNICORT); % Valid Protocols and Number of protocols
            for j = 1:Nprot % Number of protocols, i.e : 1.0 mm^3, and 1.5 mm^3
                Nrep = get_Number_Rep_ext(MT_p{j}, PD_p{j}, T1_p{j}, DataFolder); % Number of repetitions for each protocol
                for k = 1:Nrep
                    if ~ doUNICORT
                        %%  Field mapping images ...
                        Folder_List = getListofFolders([DataFolder, B0_p{j}], 'yes'); % gives back sorted Folder list
                        InSubDir01 = [DataFolder, B0_p{j}, filesep, Folder_List{2 * k - 1}];
                        InSubDir02 = [DataFolder, B0_p{j}, filesep, Folder_List{2 * k}];
                        Files01 = spm_select('FPListRec', InSubDir01, '.*');
                        Files02 = spm_select('FPListRec', InSubDir02, '.*');
                        b0_Images = char(Files01, Files02);

                        %%  B1 images ...
                        Folder_List = getListofFolders([DataFolder, B1_p{j}], 'yes'); % gives back sorted Folder list
                        InSubDir01 = [DataFolder, B1_p{j}, filesep, Folder_List{k}];
                        b1_Images = cellstr(spm_select('FPListRec', InSubDir01, '.*'));
                    else
                        b0_Images = ''; b1_Images = '';
                    end;
                    %%  MT images ...
                    Folder_List = getListofFolders([DataFolder, MT_p{j}], 'yes'); % gives back sorted Folder list
                    MTSubDir = [DataFolder, MT_p{j}, filesep, Folder_List{2 * k - 1}];
                    MT_Images = cellstr(spm_select('FPListRec', MTSubDir, '.*'));

                    %%  PD images ...
                    Folder_List = getListofFolders([DataFolder, PD_p{j}], 'yes'); % gives back sorted Folder list
                    InSubDir01 = [DataFolder, PD_p{j}, filesep, Folder_List{2 * k - 1}];
                    PD_Images = cellstr(spm_select('FPListRec', InSubDir01, '.*'));

                    %%  T1 images ...
                    Folder_List = getListofFolders([DataFolder, T1_p{j}], 'yes'); % gives back sorted Folder list
                    InSubDir01 = [DataFolder, T1_p{j}, filesep, Folder_List{2 * k - 1}];
                    T1_Images = cellstr(spm_select('FPListRec', InSubDir01, '.*'));

                    %%  Calculating MPMs  ...
                    doMPM = ~ (isempty(MT_Images) || isempty(PD_Images) || isempty(T1_Images)); % Checking that we dont have empty folders to compute MPMs.
                    if doMPM
                        MPMs_computation(MT_Images, PD_Images, T1_Images, doUNICORT, b0_Images, b1_Images);

                        %% Masking  MT map
                        MaskImage = pickfiles(MTSubDir, '_PDw.nii');
                        if ~ doUNICORT
                            Images2Mask = pickfiles(MTSubDir, '', {'_MT.nii'; '_R1.nii'});
                        else
                            % For unicort case ...
                            [MaskFilePath, MaskFileName, MaskFileExt] = fileparts(MaskImage);
                            Images2Mask_MT = [MaskFilePath, filesep, MaskFileName(1:end - 3), 'MT', MaskFileExt];
                            Images2Mask_R1 = [MaskFilePath, filesep, 'mh', MaskFileName(1:end - 3), 'R1', MaskFileExt];
                            Images2Mask = char(Images2Mask_MT, Images2Mask_R1);
                        end;
                        thresh_mask = 100; suffix = '_m';
                        MaskedImages = Mask_images(Images2Mask, MaskImage, thresh_mask, suffix);
                        MT_MaskedImage = MaskedImages(1);
                        comm_adjust(1, MT_MaskedImage{1}, 'T1', MT_MaskedImage{1}, Niter, 0); % Commissure adjustment to find a rigth image center and have good segmentation.
                        CorrectingCenters(MTSubDir, MT_MaskedImage{1}, Images2CorrectCenterExt); % Correcting new center to the rest of the images.
                        %% Segmenting MT masked image ...
                        MPMs_Segmentation(MT_MaskedImage{1}, MPM_Template);
                    end;
                end;
            end;
        end;
        %% Reorganizing the Outputs ...
        %SubjOutMPMFolder = copyFile2Output(GlobalMPMFolder,ProtocolsFile,Subj_OutputFolder,SubjID,doUNICORT);
        Out_List_Files = getAllFiles(Subj_OutputFolder);
        Reorganize_MPM_Files(Subj_OutputFolder, Ini_List_Files, Out_List_Files);

        %% Copying Data to server ...
        copy_data2Server(Subj_OutputFolder, LocalOutputFolder, ServerFolder, SubjID); % if ServerFolder variable is empty,  Nifti data wont be copy to the server
        %copy_data2Server(SubjOutMPMFolder,GlobalMPMFolder,ServerFolder,SubjID);        % if ServerFolder variable is empty,  Nifti data wont be copy to the server
    end;
    isDone = Ns;
catch ME
    warning(ME.message);
    for printStack = 1:length(ME.stack)
        disp(ME.stack(printStack).file);
        disp(ME.stack(printStack).line);
    end
    isDone = - 1;
end;
end

%% ==========  Internal Functions ==========
%% Nprot = get_Number_Prot(ProtocolsFile,DataFolder)
function Nprot = get_Number_Prot(ProtocolsFile, DataFolder)

[~, Np_MT] = get_section_protocol(ProtocolsFile, '__MPM__', '[MT]', DataFolder);
[~, Np_PD] = get_section_protocol(ProtocolsFile, '__MPM__', '[PD]', DataFolder);
[~, Np_T1] = get_section_protocol(ProtocolsFile, '__MPM__', '[T1]', DataFolder);
Nprot = min([Np_MT, Np_PD, Np_T1]);

end
%% Nrep = get_Number_Rep(ProtocolsFile,DataFolder,j)
function Nrep = get_Number_Rep(ProtocolsFile, DataFolder, j)
% Note: MT, PD, T1 protocols have two folders per repetition, the 1st have magnitude images, the 2nd phase images.
cprotocol = get_section_protocol(ProtocolsFile, '__MPM__', '[MT]', DataFolder);
Nr_MT = length(getListofFolders([DataFolder, cprotocol{j}]));
cprotocol = get_section_protocol(ProtocolsFile, '__MPM__', '[PD]', DataFolder);
Nr_PD = length(getListofFolders([DataFolder, cprotocol{j}]));
cprotocol = get_section_protocol(ProtocolsFile, '__MPM__', '[T1]', DataFolder);
Nr_T1 = length(getListofFolders([DataFolder, cprotocol{j}]));
if (Nr_MT == 1) || (Nr_PD == 1) || (Nr_T1 == 1)
    Nrep = 1;
else
    Nrep = floor(min([Nr_MT, Nr_PD, Nr_T1] / 2));
end;

end

%% Nrep = get_Number_Rep_ext(ProtocolsFile,DataFolder,j)
function Nrep = get_Number_Rep_ext(MT_p, PD_p, T1_p, DataFolder)
% Note: MT, PD, T1 protocols have two folders per repetition, the 1st have magnitude images, the 2nd phase images.
Nr_MT = length(getListofFolders([DataFolder, MT_p]));
Nr_PD = length(getListofFolders([DataFolder, PD_p]));
Nr_T1 = length(getListofFolders([DataFolder, T1_p]));
if (Nr_MT == 1) || (Nr_PD == 1) || (Nr_T1 == 1)
    Nrep = 1;
else
    Nrep = floor(min([Nr_MT, Nr_PD, Nr_T1] / 2));
end;

end
%% [cprotocol,Np] = get_section_protocol(ProtocolsFile,ProcessingSTep,MRIModality,DataFolder)
function [cprotocol, Np] = get_section_protocol(ProtocolsFile, ProcessingSTep, MRIModality, DataFolder)

pname = get_protocol_names(ProtocolsFile, ProcessingSTep, MRIModality); % protocol name ..
pname = cellstr(pname);
subj_protocols = getListofFolders(DataFolder);
%ind = ismember(pname,subj_protocols);
%cprotocol = pname(ind);
[~, ~, ipname] = intersect(subj_protocols, pname);
cprotocol = pname(sort(ipname));
Np = length(cprotocol);
%cprotocol = char(pname(ind));
%Np = size(cprotocol,1);

end

%% Reorganize_MPM_Files(Subj_OutputFolder,Ini_List_Files,Out_List_Files)
function Reorganize_MPM_Files(Subj_OutputFolder, Ini_List_Files, Out_List_Files)

Files2Delete = intersect(Out_List_Files, Ini_List_Files);
for i = 1:length(Files2Delete)
    delete(Files2Delete{i});
end;
sizeTree = folderSizeTree(Subj_OutputFolder);
mem = cell2mat(sizeTree.size); % Folders size ..
flevel = cell2mat(sizeTree.level); % Folders level ...
ind = find((flevel == 2) & (mem == 0));
for i = 1:length(ind)
    rmdir(sizeTree.name{ind(i)}, 's'); % Removing empty folders ...
end;
sizeTree = folderSizeTree(Subj_OutputFolder);
mem = cell2mat(sizeTree.size); % Folders size ..
flevel = cell2mat(sizeTree.level); % Folders level ...
ind = find((flevel == 3) & (mem == 0));
for i = 1:length(ind)
    rmdir(sizeTree.name{ind(i)}, 's'); % Removing de remaining empty folders ...
end;

end

%% SubjOutMPMFolder = copyFile2Output(OutputFolderName,ProtocolsFile,Subj_OutputFolder,SubjID)
function SubjOutMPMFolder = copyFile2Output(GlobalMPMFolder, ProtocolsFile, Subj_OutputFolder, SubjID, doUNICORT)

SubjOutMPMFolder = [GlobalMPMFolder, SubjID, filesep];
mkdir(SubjOutMPMFolder);
Session_Folder = getListofFolders(Subj_OutputFolder);
Ns = length(Session_Folder); % Number of sessions ...
Files2Save = cellstr(get_protocol_names(ProtocolsFile, '__MPMOutputs__', '[Files]'));
Nf = length(Files2Save);
for i = 1:Ns
    DataFolder = [Subj_OutputFolder, Session_Folder{i}, filesep];
    Nprot = get_Number_Prot(ProtocolsFile, DataFolder); % Number of protocols
    if i < 10
        Session = ['0', num2str(i)];
    end;
    for j = 1:Nprot
        Nrep = get_Number_Rep(ProtocolsFile, DataFolder, j); % Number of repetitions for each protocol
        for k = 1:Nrep
            pname = get_section_protocol(ProtocolsFile, '__MPM__', '[MT]', DataFolder); pname = pname{j}; % protocol name
            Folder_List = getListofFolders([DataFolder, pname]);
            MTSubDir = [DataFolder, pname, filesep, Folder_List{2 * k - 1}];
            Ref_Image = pickfiles(MTSubDir, '_PDw.nii');
            if k < 10
                Repet = ['0', num2str(k)];
            end;
            for t = 1:Nf
                if ~ doUNICORT
                    Files2copy = deblank(pickfiles(MTSubDir, Files2Save{t}));
                else
                    [Ref_ImageFilePath, Ref_ImageFileName] = fileparts(Ref_Image);
                    if strcmp(Files2Save{t}, '_R1.nii')
                        Files2copy = [Ref_ImageFilePath, filesep, 'mh', Ref_ImageFileName(1:end - 4), Files2Save{t}];
                    else
                        Files2copy = [Ref_ImageFilePath, filesep, Ref_ImageFileName(1:end - 4), Files2Save{t}];
                    end;
                    if ~ exist(Files2copy, 'file')
                        Files2copy = '';
                    end;
                end;
                if ~ isempty(Files2copy)
                    new_Name = [SubjID, '_', pname, '_ses_', Session, '_rep_', Repet, Files2Save{t}];
                    copyfile(Files2copy, [SubjOutMPMFolder, new_Name]);
                end;
            end;
        end;
    end;
end;

end

%% function copy_data2Server(InputFolder)
function copy_data2Server(SubjInputFolder, InputFolder, ServerFolder, SubjID)

if ~ isempty(ServerFolder)
    if ~ exist(ServerFolder, 'dir')
        mkdir(ServerFolder);
    end;
    if ~ strcmpi(ServerFolder(end), filesep)
        ServerFolder = [ServerFolder, filesep];
    end;
    if ~ strcmpi(InputFolder(end), filesep)
        InputFolder = [InputFolder, filesep];
    end;
    ind = strfind(InputFolder, filesep);
    ServerFolderName = InputFolder(ind(end - 1) + 1:ind(end) - 1);
    SubjOutputServerFolder = [ServerFolder, ServerFolderName, filesep, SubjID];
    if ~ exist(SubjOutputServerFolder, 'dir')
        mkdir(SubjOutputServerFolder);
    end;
    copyfile(SubjInputFolder, SubjOutputServerFolder);
end;

end
