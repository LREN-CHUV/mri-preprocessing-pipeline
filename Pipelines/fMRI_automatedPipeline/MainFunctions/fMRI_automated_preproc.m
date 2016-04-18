function fMRI_automated_preproc(Subj_folder,volnum,runDartel,varargin)
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
for sub = 1 :length(NIIs_folder)% all subjects
    
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
            [block2 prefixNII] = block_coregister(Session,prefixNII);
            batchNumber = length([matlabbatch block1 block2]);
            [block3 prefixNII] = block_segment(batchNumber,prefixNII,runDartel);
            matlabbatch = [matlabbatch block0 block1 block2 block3];
            
        end
        
        spm_jobman(Mode,matlabbatch);
        
    end

end


if runDartel==1
%% DARTEL: must wait first preproc before running


%-----------------------------------------------------------------------
    % CREATE DARTEL TEMPLATE
    %-----------------------------------------------------------------------
    
    
    for sub = 1:Nsubjects
        Root = [MainRoot '\' SubPaths{sub} '\'];
        Struct3mm = [Root 'structural_for_3mm'];
        RC1img{sub} = spm_select('ExtFPListRec',Struct3mm,['^rc1r' PrefixStruct '.*' FileExt]);
        RC2img{sub} = spm_select('ExtFPListRec',Struct3mm,['^rc2r' PrefixStruct '.*' FileExt]);
        RC3img{sub} = spm_select('ExtFPListRec',Struct3mm,['^rc3r' PrefixStruct '.*' FileExt]);
    end
    matlabbatch{1}.spm.tools.dartel.warp.images{1} = RC1img;
    matlabbatch{1}.spm.tools.dartel.warp.images{2} = RC2img;
    matlabbatch{1}.spm.tools.dartel.warp.images{3} = RC3img;
    matlabbatch{1}.spm.tools.dartel.warp.settings.template = 'Template';
    matlabbatch{1}.spm.tools.dartel.warp.settings.rform = 0;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).rparam = [4 2 1e-006];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).K = 0;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(1).slam = 16;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).rparam = [2 1 1e-006];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).K = 0;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(2).slam = 8;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).rparam = [1 0.5 1e-006];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).K = 1;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(3).slam = 4;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).rparam = [0.5 0.25 1e-006];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).K = 2;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(4).slam = 2;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).rparam = [0.25 0.125 1e-006];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).K = 4;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(5).slam = 1;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).its = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).rparam = [0.25 0.125 1e-006];
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).K = 6;
    matlabbatch{1}.spm.tools.dartel.warp.settings.param(6).slam = 0.5;
    matlabbatch{1}.spm.tools.dartel.warp.settings.optim.lmreg = 0.01;
    matlabbatch{1}.spm.tools.dartel.warp.settings.optim.cyc = 3;
    matlabbatch{1}.spm.tools.dartel.warp.settings.optim.its = 3;
    
    
    clear matlabbatch RC1img RC2img RC3img


%-----------------------------------------------------------------------
        % NORMALISE TO MNI
        %-----------------------------------------------------------------------
if ~isempty(FieldMapFoldersForFMRI)
            ToUnwarp = cellstr(spm_select('ExtFPListRec',EPI3mmSess,['^bu' PrefixFun '.*' FileExt]));
        else
            ToUnwarp = cellstr(spm_select('ExtFPListRec',EPI3mmSess,['^b' PrefixFun '.*' FileExt]));
        end
        for j = 1:length(ToUnwarp)
            Temp = char(ToUnwarp{j});
            ToNorm{j,1} = Temp(1,1:end-2);
        end
        
        PathFlowField = char(spm_select('ExtFPListRec',Struct3mm,['^u_rc1r' PrefixStruct '.*' FileExt]));
        PathFlowField = PathFlowField(1:end-2);
        
        CoregisteredStructImage = spm_select('ExtFPListRec',Struct3mm,['^r' PrefixStruct '.*' FileExt]);
        CoregisteredStructImage = CoregisteredStructImage(1:end-2);
        ToNorm{end+1}=CoregisteredStructImage;
        
        matlabbatch{1}.spm.tools.dartel.mni_norm.template(1) = cellstr([MainRoot '\' SubPaths{1} '\structural_for_3mm\Template_6.nii']);
        matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj(1).flowfield = cellstr(PathFlowField);
        matlabbatch{1}.spm.tools.dartel.mni_norm.data.subj(sub).images = ToNorm;
        matlabbatch{1}.spm.tools.dartel.mni_norm.vox = [NaN NaN NaN];
        matlabbatch{1}.spm.tools.dartel.mni_norm.bb = [NaN NaN NaN
            NaN NaN NaN];
        matlabbatch{1}.spm.tools.dartel.mni_norm.preserve = 0;
        matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm = [0 0 0];

        
        clear matlabbatch ToUnwarp ToNorm Temp PathFlowField CoregisteredStructImage

%% Preproc second part

[block prefixNII] = block_normalize(Session, prefixNII)
matlabbatch = [matlabbatch block];

end


end