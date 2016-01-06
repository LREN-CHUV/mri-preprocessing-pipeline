function [Sessions uniqueRes uniqueResIdx block CheckValid] = prepare_fMRI_session_coregStr2Fun(NIIs_folder,Opts,CheckValid)
% function which prepares files for fMRI preprocessing, looks through
% folder hierarchy, and if necessary adds basics batch to SPM (copy
% folders, move files). If MPMs data are found but no masked MT map, it
% calls get_MPMs_from_converted_data and mask_MT_with_PDw.
%
% Nota bene: file extensions (of fMRI scans) other than .nii or .img formats
% are not detected!
%
%--------------------------------------------------------------------------
% INPUTS:
%--------------------------------------------------------------------------
%
% NIIs_folder : string, subject's folder
%
% Opts : structure containing parametrization of fMRI_automated_pipeline
%
% CheckValid : empty variable filled when errors occur (files not found,
% etc.)
%
%--------------------------------------------------------------------------
% OUTPUTS:
%--------------------------------------------------------------------------
%
% Sessions : structure containing filepaths by image types, default file
% for EPI image distortion correction (FieldMap) if B0 maps are present,
% resolution of EPI runs (detected from folder name)
%
% uniqueRes : cell of strings, all resolutions detected (from folder name)
%
% uniqueResIdx : vector of integers, indexes of resolutions found
%
% block : cell of structures, containing SPM jobs (empty if no jobs needed)
%
% CheckValid : see INPUTS above, will be filled with fields when errors
% occur.
%
%--------------------------------------------------------------------------
% 2014-08-19, @LREN, Renaud Marquis & Sandrine Muller, refacto
%--------------------------------------------------------------------------

%% List folder names (per subject):
FolderNames = detectFolders(NIIs_folder);

%% Detect needed folders and files:

%%%% B0 maps
temp = FilterFolders(FolderNames,'gre_field_mapping_1acq_rl_64ch.*',''); % normally we would use this B0 for EPI image distortion correction
if isempty(temp)
    temp = FilterFolders(FolderNames,'gre_field_mapping_1acq_rl.*','');
end
% temp = FilterFolders(FolderNames,'gre_field_mapping.*','.*mm.*'); % this was used to avoid detecting folders that could have been already preprocessed but is conflicting with protocol names

if isempty(temp) % but in case such a protocol hasn't been acquired, use something looking similar instead
    temp = FilterFolders(FolderNames,'gre_field_mapping.*','.*rl.*'); % but not B0 maps for MPMs!
    if ~isempty(temp)
        warning('B0 maps for 64ch not found, using other B0 maps acquired') % but warn the user!
    end
end

if ~isempty(temp)
    %%%% PHASE
    % Deal with directory structure:
    if strcmpi(Opts.DirStructure,'LRENpipeline')
        temp2 = detectFolders(strcat(NIIs_folder,filesep,temp{1})); % warning: only the first will be used if several "gre_field_mapping_1acq_rl_64ch..."
        Pha = detect_nii_img_files(strcat(NIIs_folder,filesep,temp),temp2(2)); % select the files in the Phase folder
    else
        Pha = detect_nii_img_files(NIIs_folder,temp(2)); % select the files in the Phase folder
    end
    % Remove already preprocessed files if existing:
    if any(size(Pha)>1)
        L8 = (length(char(strcat(NIIs_folder,filesep,temp)))+2):(length(char(strcat(NIIs_folder,filesep,temp)))+3);
        L9 = (length(char(strcat(NIIs_folder,filesep,temp)))+2):(length(char(strcat(NIIs_folder,filesep,temp)))+7);
        L10 = (length(char(strcat(NIIs_folder,filesep,temp)))+2):(length(char(strcat(NIIs_folder,filesep,temp)))+8);
        for z = 1:length(Pha) % remove already preprocessed files
            IdxPha(z) = (strcmp(Pha{z,1}(L8),'sc')+strcmp(Pha{z,1}(L9),'fpm_sc')++strcmp(Pha{z,1}(L10),'vdm5_sc'))==0;
        end
        Sessions.Phase = Pha(IdxPha);
    else
        Sessions.Phase = Pha;
    end
    
    %%%% MAGNITUDE
    % Deal with directory structure:
    if strcmpi(Opts.DirStructure,'LRENpipeline')
        temp2 = detectFolders(strcat(NIIs_folder,filesep,temp{1})); % warning: only the first will be used if several "gre_field_mapping_1acq_rl_64ch..."
        Mag = detect_nii_img_files(strcat(NIIs_folder,filesep,temp),temp2(1)); % select the files in the Phase folder
    else
        Mag = detect_nii_img_files(NIIs_folder,temp(1)); % select the files in the Magnitude folder
    end
    % Remove already preprocessed files if existing:
    if any(size(Mag)>1)
        L6 = length(strcat(NIIs_folder,filesep,temp))+2;
        L7 = (length(char(strcat(NIIs_folder,filesep,temp)))+2):(length(char(strcat(NIIs_folder,filesep,temp)))+6);
        L11 = (length(char(strcat(NIIs_folder,filesep,temp)))+2):(length(char(strcat(NIIs_folder,filesep,temp)))+8);
        L12 = (length(char(strcat(NIIs_folder,filesep,temp)))+2):(length(char(strcat(NIIs_folder,filesep,temp)))+3);
        
        MaskedMagFound = 0; % initialize for finding potential masked image (sometimes necessary to do this preliminarily)
        for z = 1:length(Mag) % remove already preprocessed files
            IdxMag(z) = (strcmp(Mag{z,1}(L12),'c3')+strcmp(Mag{z,1}(L12),'c2')+strcmp(Mag{z,1}(L12),'c1')+strcmp(Mag{z,1}(L6),'m')+strcmp(Mag{z,1}(L7),'bmask'))==0; % avoid them
            IdxMaskedMag(z) = strcmp(Mag{z,1}(L11),'masked_')==1; % but check also for this one
            if IdxMaskedMag(z)
                MaskedMagFound = MaskedMagFound+1;
            end
        end
                        
        if MaskedMagFound>1 % multiple images beginning with "masked_"
            TempMagnitude = Mag(IdxMaskedMag);
            Magnitude = TempMagnitude(1); % take the first one
        elseif MaskedMagFound>0 % only one image beginning with "masked_"
            Magnitude = Mag(IdxMaskedMag);
        else % no masked magnitude image
            if Opts.MaskMag == 1 % masking of magnitude enabled
                block = brain_mask(Mag(IdxMag),1);
                Magnitude = spm_file(Mag(IdxMag),'prefix','masked_');
            else % no masking enabled
                Magnitude = Mag(IdxMag); % just rely on the original magnitude data
            end
        end
    else
        Magnitude = Mag;
    end
    Sessions.Magnitude = Magnitude(1); % choose the first magnitude image among the two
    
else % case : no gre field mapping acquired
    Sessions.Phase = {};
    Sessions.Magnitude = {};
end

if isempty(Sessions.Phase) % if no B0 maps found
    if isfield(Opts,'FieldMapDefaults') % if FieldMap default file provided
        warning('FieldMap defaults provided but no B0 maps found, no EPI image distortion correction will be applied');
    else
        warning('Standard B0 maps not found, skipping EPI image distortion correction');
    end
else
    if ~isfield(Opts,'FieldMapDefaults') % if no FieldMap default file provided
        warning('Phase and magnitude data found but no specific FieldMap defaults provided')
        warning('Using LREN default set of default files for FieldMap')
    end
end

%%%% STRUCTURAL
if isempty(Opts.SpecialTokenStruct) % if no user-defined token
    if Opts.StructMT == 1
        TokenStruct1 = 'mt_al_mtflash'; % the first choice ('mt_al_mtflash3d_v2l_1mm' before but could be 1pt5mm e.g.)
        TokenStruct2 = 'mprage'; % the second choice
        temp = FilterFolders(FolderNames,['\w*' TokenStruct1 '\w*'],''); % temp = FilterFolders(FolderNames,['\w*' TokenStruct1 '\w*'],'.*mm.*'); % this was used to avoid detecting folders that could have been already preprocessed but is conflicting with protocol names
        if isempty(temp) % the first choice structural is not found, try the second choice
            temp = FilterFolders(FolderNames,['\w*' TokenStruct2 '\w*'],'');
            FlagMTfound = 0;
        else
            FlagMTfound = 1;
        end
    elseif Opts.StructMPRAGE == 1
        TokenStruct1 = 'mprage';
        TokenStruct2 = 'mt_al_mtflash';
        temp = FilterFolders(FolderNames,['\w*' TokenStruct1 '\w*'],''); % temp = FilterFolders(FolderNames,['\w*' TokenStruct1 '\w*'],'.*mm.*'); % this was used to avoid detecting folders that could have been already preprocessed but is conflicting with protocol names
        if isempty(temp) % the first choice structural is not found, try the second choice
            temp = FilterFolders(FolderNames,['\w*' TokenStruct2 '\w*'],'');
            FlagMTfound = 1;
        else
            FlagMTfound = 0;
        end
    else
        CheckValid.TooMuchStructural = 'Do not know what structural scan to use for normalization';
        temp = 'not_specified';
    end
else
    temp = FilterFolders(FolderNames,['\w*' Opts.SpecialTokenStruct '\w*'],'');
    FlagMTfound = 0;
end

% Check structural folder exists:
if isempty(temp) % no structural folder found (neither MT nor MPRAGE)
    CheckValid.StructuralFolder = 'Folder with structural scan not found';
    temp = 'not_found';
else % structural folder found
    % To avoid conflicts when multiple folders, choose the first one
    temp = temp{1}; % this needs sometimes to be done, for MPMs when DICOMimport e.g. (the first folder)
end

% Get structural file(s) and check it exists:

% Deal with directory structure:
if strcmpi(Opts.DirStructure,'LRENpipeline')
    temp2 = detectFolders(strcat(NIIs_folder,filesep,temp)); % warning: only the first will be used if several "gre_field_mapping_1acq_rl_64ch..."
    Struct = detect_nii_img_files(strcat(NIIs_folder,filesep,temp),temp2); % select files in structural folder
    if any(cellfun(@isempty,Struct)) % no files in directory
        CheckValid.StructuralScan = 'No structural scan found';
        Struct = {'not_found'};
    end
else
    Struct = detect_nii_img_files(NIIs_folder,temp); % select files in structural folder
    if any(cellfun(@isempty,Struct)) % no files in directory
        CheckValid.StructuralScan = 'No structural scan found';
        Struct = {'not_found'};
    end
end

if any(size(Struct)>1) % if several structural scans
    if Opts.FilterAlreadyPreprocessedSMRI == 1 % filtering of already preprocessed files
        L1 = (length(char(strcat(NIIs_folder,filesep,temp)))+2):(length(char(strcat(NIIs_folder,filesep,temp)))+3);
        L2 = (length(char(strcat(NIIs_folder,filesep,temp)))+2):(length(char(strcat(NIIs_folder,filesep,temp)))+4);
        L5 = (length(char(strcat(NIIs_folder,filesep,temp)))+2):(length(char(strcat(NIIs_folder,filesep,temp)))+9);
        L12 = (length(char(strcat(NIIs_folder,filesep,temp)))+2):(length(char(strcat(NIIs_folder,filesep,temp)))+11);
        L13 = (length(char(strcat(NIIs_folder,filesep,temp)))+2):(length(char(strcat(NIIs_folder,filesep,temp)))+6);
        L14 = (length(char(strcat(NIIs_folder,filesep,temp)))+2):(length(char(strcat(NIIs_folder,filesep,temp)))+5);
        if strcmpi(Opts.DirStructure,'LRENpipeline')
            L1 = L1+length(char(temp2))+1;
            L2 = L2+length(char(temp2))+1;
            L5 = L5+length(char(temp2))+1;
            L12 = L12+length(char(temp2))+1;
            L13 = L13+length(char(temp2))+1;
            L14 = L14+length(char(temp2))+1;
        end
        for z = 1:length(Struct) % remove already preprocessed files
            IdxStruct(z) = (strcmp(Struct{z,1}(L13),'swmc6')+strcmp(Struct{z,1}(L13),'swmc5')+strcmp(Struct{z,1}(L13),'swmc4')+strcmp(Struct{z,1}(L13),'swmc3')+strcmp(Struct{z,1}(L13),'swmc2')+strcmp(Struct{z,1}(L13),'swmc1')+strcmp(Struct{z,1}(L14),'wmc6')+strcmp(Struct{z,1}(L14),'wmc5')+strcmp(Struct{z,1}(L14),'wmc4')+strcmp(Struct{z,1}(L14),'wmc3')+strcmp(Struct{z,1}(L14),'wmc2')+strcmp(Struct{z,1}(L14),'wmc1')+strcmp(Struct{z,1}(L12),'BiasField_')+strcmp(Struct{z,1}(L2),'sws')+strcmp(Struct{z,1}(L1),'ws')+strcmp(Struct{z,1}(L1),'ms')+strcmp(Struct{z,1}(L1),'c1')+strcmp(Struct{z,1}(L1),'c2')+strcmp(Struct{z,1}(L1),'c3')+strcmp(Struct{z,1}(L1),'c4')+strcmp(Struct{z,1}(L1),'c5')+strcmp(Struct{z,1}(L2),'iy_')+strcmp(Struct{z,1}(L1),'y_')+strcmp(Struct{z,1}(L1),'u_')+strcmp(Struct{z,1}(L2),'rc1')+strcmp(Struct{z,1}(L2),'rc2')+strcmp(Struct{z,1}(L2),'rc3')+strcmp(Struct{z,1}(L2),'rc4')+strcmp(Struct{z,1}(L2),'rc5')+strcmp(Struct{z,1}(L1),'c6')+strcmp(Struct{z,1}(L1),'rc6')+strcmp(Struct{z,1}(L5),'Template'))==0;
        end
        % above, 'ms' stands for bias corrected structural scan (only 'm' would
        % have been better but can cause problems in some datasets) (same
        % principle applies to other indexes: they are trade-off between
        % avoiding problematic images and commonly seen filenames)
    else
        IdxStruct = ones(1,length(Struct));
    end
    Structural = Struct(IdxStruct);
else
    Structural = Struct;
end



% Check MPM case
if FlagMTfound == 1 % MT folder found
    
    % Check MT map is there
    MT = Structural;
    clear IdxStruct
    for z = 1:length(MT) % check if masked MT map exists
        IdxStruct(z) = (strcmp(MT{z,1}(end-6:end-4),'_MT'));
    end
    MT = MT(IdxStruct);
    %     if isempty(MT) && strcmpi(Opts.DirStructure,'LRENpipeline') % no MT map found & DirStructure is LRENpipeline (=> a daemon is running this function)
    %         error('NO MT MAP FOUND ==> CHECK sMRI pipeline HAS BEEN LAUNCHED FIRST')
    %     elseif isempty(MT) % no MT map found
    if isempty(MT) % no MT map found
        if exist('block','var')
            Njob = size(block,2);
            [temp_block MT1st] = get_MPMs_from_converted_data(NIIs_folder,FolderNames,Opts);
            if ischar(temp_block)
                CheckValid.MPMdataOK = temp_block;
            else
                for nnj = 1:size(temp_block,2);
                    block{Njob+nnj} = temp_block{nnj}; % here get_MPMs_from_converted_data can output multiple jobs, therefore a loop is used to transfer jobs...
                end
            end
        else
            [temp_block MT1st] = get_MPMs_from_converted_data(NIIs_folder,FolderNames,Opts);
            if ischar(temp_block)
                CheckValid.MPMdataOK = temp_block;
            else
                block = temp_block;
            end
        end
        MT = {spm_file(MT1st,'suffix','_MT')};
        PDw = {spm_file(MT1st,'suffix','_PDw')};
    end
    
    % Check masked MT map is there
    MaskedMT = Structural;
    clear IdxStruct
    for z = 1:length(MaskedMT) % check if masked MT map exists
        IdxStruct(z) = (strcmp(MaskedMT{z,1}(end-8:end-4),'_MT_m'));
    end
    MaskedMT = MaskedMT(IdxStruct);
    
    if ~isempty(MaskedMT) % but not masked MT map
        Structural = MaskedMT;
    else
%         if strcmpi(Opts.DirStructure,'DICOMimport')
            if exist('block','var')
                Njob = size(block,2);
                block{Njob+1} = mask_MT_with_PDw(MT{1},PDw{1},Opts.Threshold_masking_MT_with_PDw);
            else
                block{1} = mask_MT_with_PDw(MT{1},PDw{1},Opts.Threshold_masking_MT_with_PDw);
            end
            Structural = spm_file(MT,'prefix','masked_'); % the prefix will be different from what we are looking for at the beginning, but then we know if fMRI or sMRI did this job
%         else
%             error('NO MASKED MT MAP FOUND ==> CHECK sMRI pipeline HAS BEEN LAUNCHED FIRST')
%         end
    end
end

% Make a new folder for structural file and copy structural scan in it (to
% avoid conflicts with sMRI preprocessing(s):
if exist('block','var')
    Njob = size(block,2);
else
    Njob = 0;
end
if strcmpi(Opts.DirStructure,'LRENpipeline')
    [deleteit ops] = fileparts(fileparts(fileparts(Structural{1})));
    block{Njob+1} = MakeNewDir(fileparts(fileparts(fileparts(Structural{1}))),strcat(ops,'_for_fMRI'));
    block{Njob+2} = MakeNewDir(strcat(fileparts(fileparts(fileparts(Structural{1}))),filesep,strcat(ops,'_for_fMRI')),'coreg_struct');
    [block{Njob+3} Structural] = CopyTo(Structural,strcat(strcat(fileparts(fileparts(fileparts(Structural{1}))),filesep,strcat(ops,'_for_fMRI')),filesep,'coreg_struct'));
else
    [deleteit ops] = fileparts(fileparts(Structural{1}));
    block{Njob+1} = MakeNewDir(fileparts(fileparts(Structural{1})),strcat(ops,'_for_fMRI'));
    [block{Njob+2} Structural] = CopyTo(Structural,strcat(fileparts(fileparts(Structural{1})),filesep,strcat(ops,'_for_fMRI')));
end

if any(size(Structural(~cellfun(@isempty,Structural)))>1) % if still several structural scans
    CheckValid.TooMuchStructural = 'Do not know which structural scan to use';
    Sessions.Struct = 'unable_to_choose_between_multiple_files';
else
    Sessions.Struct = Structural(~cellfun(@isempty,Structural));
end

%% List EPIs and avoid potentially pre-existing processed files:
temp = FilterFolders(FolderNames,['\w*' Opts.TokenEPI '\w*'],'');

% Here LRENpipeline directory structure helps to distinguish between
% repetitions of the same MR sequence, where scans can be realigned
% altogether, and multiple runs using different MR sequences, where scans
% cannot probably be realigned altogether (a very common reason to get fMRI
% using multiple types of EPI sequence is when one wants to manipulate
% resolution, e.g. to sample a brain region at different resolutions). Then
% see " Sessions.EPI = Sessions.EPI(~cellfun(@isempty,Sessions.EPI)); " (around
% line 389).

% Deal with directory structure:
if strcmpi(Opts.DirStructure,'DICOMimport')
    if ~isempty(temp)
        for i = 1:length(temp)
            [f FileExt] = detect_nii_img_files(NIIs_folder,temp{i}); % select the files in the functional folder
            if Opts.FilterAlreadyPreprocessedFMRI == 1
                % remove already preprocessed files:
                L3 = length(strcat(NIIs_folder,filesep,temp{i}))+2;
                L4 = (length(char(strcat(NIIs_folder,filesep,temp{i})))+2):(length(char(strcat(NIIs_folder,filesep,temp{i})))+5);
                for j = 1:length(f)
                    idx(j) = (strcmp(f{j,1}(L3),'s')+strcmp(f{j,1}(L3),'w')+strcmp(f{j,1}(L3),'b')+strcmp(f{j,1}(L3),'u')+strcmp(f{j,1}(L3),'B')+strcmp(f{j,1}(L3),'r')+strcmp(f{j,1}(L3),'c')+strcmp(f{j,1}(L4),'mean'))==0;
                    % idx(j) =
                    % (strcmp(f{j,1}(L),'s')+strcmp(f{j,1}(L),'w')+strcmp(f{j,1}(L),'b')+strcmp(f{j,1}(L),'u')+strcmp(f{j,1}(L),'rp')+strcmp(f{j,1}(L),'B')+strcmp(f{j,1}(L),'c'))==0;
                    % % last line caused some troubles with some datasets and is therefore
                    % commented
                end
            else
                idx = ones(1,length(f));
            end
            Sessions.EPI{i} = f(idx);
            if Opts.DetectResolution == 1
                %%% Find Resolution
                temp3 = Sessions.EPI{1,i}{1,1};
                [p n e] = fileparts(temp3);
                [p n e] = fileparts(p);
                s2 = regexp(n, '_', 'split');
                Sessions.EPIresolution(i) = s2(~cellfun(@isempty,regexpi(s2,'.*mm')));
                TempSequence1 = strtrim(regexprep(n,strcat('_',s2{end}),''));
                TempSequence2 = strtrim(regexprep(TempSequence1,strcat('_','Mag'),''));
                TempSequence3 = strtrim(regexprep(TempSequence2,strcat('_','CombinedCoils'),''));
                Sequence(i) = {strtrim(regexprep(TempSequence3,'Echo00',''))};
            else
                Sessions.EPIresolution(i) = {'undefined'};
                SeqSplit = regexp(temp{i},'_','split');
                if ~isempty(str2double(SeqSplit{end})) && length(SeqSplit{end})==4
                    Sequence(i) = {temp{i}(1:(end-(length(SeqSplit{end})+1)))};
                else
                    Sequence(i) = {temp{i}};
                end
            end
            clear idx
        end
    else
        Sessions.EPI = {};
        Sessions.EPIresolution = {};
        Sequence = {};
        FileExt = '';
    end
else
    if ~isempty(temp)
        for i = 1:length(temp)
            % ==> get repetitions of the same EPI sequence:
            RepRun = detectFolders(strcat(NIIs_folder,filesep,temp{i}));
            for k = 1:length(RepRun)
                % ==> get files for a particular repetition of a particular
                % sequence:
                [f FileExt] = detect_nii_img_files(NIIs_folder,strcat(temp{i},filesep,RepRun{k})); % select the files in the Structural folder
                % remove already preprocessed files:
                L3 = length(strcat(NIIs_folder,filesep,temp{i}))+2;
                L4 = (length(char(strcat(NIIs_folder,filesep,temp{i})))+2):(length(char(strcat(NIIs_folder,filesep,temp{i})))+5);
                for j = 1:length(f)
                    idx(j) = (strcmp(f{j,1}(L3),'s')+strcmp(f{j,1}(L3),'w')+strcmp(f{j,1}(L3),'b')+strcmp(f{j,1}(L3),'u')+strcmp(f{j,1}(L3),'B')+strcmp(f{j,1}(L4),'mean'))==0;
                    % idx(j) =
                    % (strcmp(f{j,1}(L),'s')+strcmp(f{j,1}(L),'w')+strcmp(f{j,1}(L),'b')+strcmp(f{j,1}(L),'u')+strcmp(f{j,1}(L),'rp')+strcmp(f{j,1}(L),'B')+strcmp(f{j,1}(L),'c'))==0;
                    % % last line caused some troubles with some datasets and is therefore
                    % commented
                end
                % store in column the different protocols and in rows the
                % different repetitions of the same protocol:
                Sessions.EPI{k,i} = f(idx);
                if Opts.DetectResolution == 1
                    %%% Find Resolution
                    temp3 = Sessions.EPI{k,i}{1,1};
                    [p n e] = fileparts(temp3);
                    [p n e] = fileparts(fileparts(p));
                    s2 = regexp(n, '_', 'split');
                    Sessions.EPIresolution(k,i) = s2(~cellfun(@isempty,regexpi(s2,'.*mm')));
                    Sequence(k,i) = {n};
                else
                    Sessions.EPIresolution(k,i) = {'undefined'};
                    SeqSplit = regexp(temp{i},'_','split');
                    if ~isempty(str2double(SeqSplit{end})) && length(SeqSplit{end})==4
                        Sequence(k,i) = {temp{i}(1:(end-(length(SeqSplit{end})+1)))};
                    else
                        Sequence(k,i) = {temp{i}};
                    end
                end
                clear idx
            end
        end
    else
        Sessions.EPI = {};
        Sessions.EPIresolution = {};
        Sequence = {};
        FileExt = '';
    end
end

% Vectorize sessions (repetitions x protocol types) and remove those empty
% (there could be e.g. 2 runs for 1.5mm and 1 run for 2mm):
if size(Sessions.EPI,1)>size(Sessions.EPI,2)
    Sessions.EPI = Sessions.EPI(~cellfun(@isempty,Sessions.EPI))';
else
    Sessions.EPI = Sessions.EPI(~cellfun(@isempty,Sessions.EPI));
end

%% Check for incomplete sequences
[Sessions CheckValid] = build_EPI_sessions(Sessions,Opts.MinVolNum,CheckValid); % (NB: EVEN IF NORMALLY INCOMPLETE SEQUENCES ARE NOT SENT TO FROM SCANNER TO SERVER)

%% Parameters of EPI acquisition

L = length(Sessions.EPIresolution);
[uniqueRes, m1, uniqueResIdx] = unique(Sessions.EPIresolution); % uniqueResIdx : define groups of EPI resolutions to preprocess differently (otherwise computing of mean for realign will fail)
[p n e] = fileparts(which('fMRI_automated_preproc'));
if ~isempty(Sessions.Phase) % if B0 maps were acquired
    if ~isfield(Opts,'FieldMapDefaults')
        for pm = 1:length(Sequence)
            Sessions.PMdefaultfile{pm} = strcat(p,filesep,'FieldMap_defaults',filesep,'pm_defaults_Prisma_',Sequence{pm},e);
        end
    else
        if any(size(Opts.FieldMapDefaults))
            Sessions.PMdefaultfile = Opts.FieldMapDefaults;
        else
            Sessions.PMdefaultfile = cellstr(repmat(Opts.FieldMapDefaults,L,1));
        end
    end
    
    % Check whether default file for EPI image distortion correction exists:
    if ~isempty(Sessions.PMdefaultfile) % if Default file for FieldMap not set to null ("{}")
        for pm = 1:length(Sessions.PMdefaultfile)
            if exist(Sessions.PMdefaultfile{pm},'file')~=2 % check if the file exists
                CheckValid.FieldMapDefault = 'Default parameters file for EPI image distortion correction not found';
            end
        end
    end
else
    Sessions.PMdefaultfile = {'No B0 maps found, no EPI image distortion correction'};
end

if ~exist('block','var')
    block = [];
end

%% Remove dummies : removed, end user has to deal with it at modelisation step
% if Opts.DetectResolution == 1
%     temp = Sessions.EPI(Idx3mm); % BEWARE : dummy scans only removed for 3mm resolution in this case
%     if Opts.DummyScans ~=0 && ~isempty(temp)
%         Sessions.EPI(Idx3mm) = removeDummies(temp,FileExt,Opts.DummyScans);
%     end
% else
%     if Opts.DummyScans ~=0 && ~isempty(Sessions.EPI)
%         Sessions.EPI = removeDummies(Sessions.EPI,FileExt,Opts.DummyScans);
%     end
% end

end