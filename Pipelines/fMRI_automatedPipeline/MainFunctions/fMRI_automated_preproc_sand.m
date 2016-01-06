function fMRI_automated_preproc_sand(Subj_folder,volnum,runDartel,varargin)
% function needed:
% getAllFiles

%FUNCTION prefix = fMRIpreproc_auto(NIIs_folder)
% aims at doing all the preprocessing of the fMRI data
%------------------------------INPUTS--------------------------------------
% NIIs_folder : s of the name of the folder containing all sequences
% volnum : scalar, minimal number of volumes per session
% runDartel: 1 if true (apply DARTEL), 0 otherwise
% varargin: OPTIONAL : 
% {1} Mode: a string ('interactive' or 'run') to see or not the job in the
% GUI before running it
% {2} dummyscans : number of dummy files (for 3mm resolution EPI only)
%-------------------------------OUTPUTS------------------------------------
% create a number of files relative to spm preprocessing
% prefix : prefix of the files created
%
% USAGE : prefix = fMRIpreproc_auto('C:\TEMP\DL060989',[240 240 110 110],5);
% 14-03-21, @LREN, Sandrine Muller
% 14-06-27, @LREN, Sandrine Muller, Renaud Marquis, refacto

% % % % % 
% % % % % Subj_folder ='C:\TEMP\testfMRIauto';dummyscans = 5;Mode = 'interactive';volnum=100; runDartel = 1;


%% Initialization
prefixNII = [];

if nargin>2
    if length(varargin)>2
        error('Improper number of dummy scans');
    elseif length(varargin)==1
        Mode = varargin{1};
    else
        Mode = varargin{1};
        dummyscans = varargin{2};
    end
else
    Mode = 'run';
    dummyscans = 0;
end

%% Files and folders gestion

% by default, if no fieldmap no VDM etc.

%%% List folder names (per subject):
temp = detectFolders(Subj_folder);
% NIIs_folder = strcat(repmat(cellstr(Subj_folder),length(temp),1),filesep,temp);
NIIs_folder = {Subj_folder}; % edited 15.09.29, Sandrine
for sub = 1 %:length(NIIs_folder)% all subjects
    
    [Sessions uniqueRes uniqueResIdx FileExt] = PrepareFiles(NIIs_folder{sub,1},volnum,dummyscans);


    %% Preproc first part
    for res = 1:length(uniqueRes)
        if length(uniqueRes)>1
            
            Session = reshapeSession(Sessions,uniqueResIdx == res,uniqueRes{res},FileExt); % Session relative to the resolution
            
            if ~isempty(Session.Phase)
                matlabbatch{1} = block_VDM(Session);
            else
                matlabbatch = {};
            end
            
            [block0 prefixNII] = block_realign_unwarp(Session, '');
            [block1 prefixNII] = block_BiasCorrect(Session,prefixNII);
            tempprefix = prefixNII;
            [block2 prefixNII] = block_coregister(Session,prefixNII);
            batchNumber = length([matlabbatch block1 block2]);
            [block3 prefixNII] = block_segment(batchNumber,prefixNII,runDartel);
            matlabbatch = [matlabbatch block0 block1 block2 block3];
            
        else
            
            Session = Sessions;
            
            if ~isempty(Session.Phase)
                matlabbatch{1} = block_VDM(Session);
            else
                matlabbatch = {};
            end
            
            [block0 prefixNII] = block_realign_unwarp(Session, '');
            [block1 prefixNII] = block_BiasCorrect(Session,prefixNII);
            tempprefix = prefixNII;
            [block2 prefixNII] = block_coregister(Session,prefixNII);
            batchNumber = length([matlabbatch block1 block2]);
            [block3 prefixNII] = block_segment(batchNumber,prefixNII,runDartel);
            matlabbatch = [matlabbatch block0 block1 block2 block3];
            
        end
%         
%         spm_jobman(Mode,matlabbatch);
        
    end

end


%% Preproc second part

[block prefixNII] = block_normalize(Session,length(matlabbatch), 'bu');
matlabbatch = [matlabbatch block];
spm_jobman(Mode,matlabbatch);

end