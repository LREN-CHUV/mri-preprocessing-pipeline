function [Subj_OutputFolder,SubjOutMPMFolder] = Preproc_mpm_maps_rev(SubjectFolder,SubjID,OutputFolder,GlobalMPMFolder,ProtocolsFile,MPM_Template)

%% Anne Ruef, Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, May 21st, 2014

s = which('spm.m');
if  ~isempty(s)
    spm_path = fileparts(s);
else
    disp('Please add SPM toolbox in the path .... ');
    return;
end;
if ~strcmp(SubjectFolder(end),filesep)
    SubjectFolder = [SubjectFolder,filesep];
end;
if ~strcmp(OutputFolder(end),filesep)
    OutputFolder = [OutputFolder,filesep];
end;
if ~strcmp(GlobalMPMFolder(end),filesep)
    GlobalMPMFolder = [GlobalMPMFolder,filesep];
end;
% if ~exist(OutputFolder,'dir')
%     Subj_OutputFolder = [OutputFolder,SubjID,filesep];
%     mkdir(Subj_OutputFolder);    
% end;
if ~exist(OutputFolder,'dir')    
    mkdir(OutputFolder);    
end;
if ~exist(GlobalMPMFolder,'dir')
    mkdir(GlobalMPMFolder);    
end;
if ~exist(ProtocolsFile,'file')    
    disp('Protocol names file does not exist ! Please specify ...'); 
    return;
end;
Subj_OutputFolder = [OutputFolder,SubjID,filesep];
mkdir(Subj_OutputFolder);
copyfile(SubjectFolder,Subj_OutputFolder);
Session_Folder = getListofFolders(Subj_OutputFolder);
Ns = length(Session_Folder);  % Number of sessions ...
Ini_List_Files = getAllFiles(Subj_OutputFolder);
for i=1:Ns
    DataFolder = [Subj_OutputFolder,Session_Folder{i},filesep];
    [B0_p,B1_p,MT_p,PD_p,T1_p,Nprot] = get_valid_MPM_Protocols(ProtocolsFile,DataFolder);
    for j=1:Nprot  % Number of protocols, i.e : 1.0 mm^3, and 1.5 mm^3
        Nrep = get_Number_Rep(ProtocolsFile,DataFolder,j); % Number of repetitions for each protocol
        for k=1:Nrep
            %%  Field mapping images ...
            Folder_List = getListofFolders([DataFolder,B0_p{j}],'yes'); % gives back sorted Folder list
            InSubDir01 = [DataFolder,B0_p{j},filesep,Folder_List{2*k-1}];
            InSubDir02 = [DataFolder,B0_p{j},filesep,Folder_List{2*k}];
            Files01 = spm_select('FPListRec',InSubDir01,'.*');
            Files02 = spm_select('FPListRec',InSubDir02,'.*');
            b0_Images = char(Files01,Files02);
            
            %%  B1 images ...
            Folder_List = getListofFolders([DataFolder,B1_p{j}],'yes');  % gives back sorted Folder list
            InSubDir01 = [DataFolder,B1_p{j},filesep,Folder_List{k}];
            b1_Images = cellstr(spm_select('FPListRec',InSubDir01,'.*'));
            
            %%  MT images ...
            Folder_List = getListofFolders([DataFolder,MT_p{j}],'yes');  % gives back sorted Folder list
            MTSubDir = [DataFolder,MT_p{j},filesep,Folder_List{2*k-1}];
            MT_Images = cellstr(spm_select('FPListRec',MTSubDir,'.*'));
            
            %%  PD images ...
            Folder_List = getListofFolders([DataFolder,PD_p{j}],'yes');  % gives back sorted Folder list
            InSubDir01 = [DataFolder,PD_p{j},filesep,Folder_List{2*k-1}];
            PD_Images = cellstr(spm_select('FPListRec',InSubDir01,'.*'));
            
            %%  T1 images ...
            Folder_List = getListofFolders([DataFolder,T1_p{j}],'yes');  % gives back sorted Folder list
            InSubDir01 = [DataFolder,T1_p{j},filesep,Folder_List{2*k-1}];
            T1_Images = cellstr(spm_select('FPListRec',InSubDir01,'.*'));
            
            %%  Calculating MPMs  ...
            matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.b1_type = '3D_EPI_v2b';
            matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.sdata_multi.output.indir = 1;
            %matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.sdata_multi.output.outdir = cellstr(Subj_OutputFolder);
            matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.sdata_multi.raw_fld.b0 = cellstr(b0_Images);
            matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.sdata_multi.raw_fld.b1 = cellstr(b1_Images);
            matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.sdata_multi.raw_mpm.MT = cellstr(MT_Images);
            matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.sdata_multi.raw_mpm.PD = cellstr(PD_Images);
            matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.sdata_multi.raw_mpm.T1 = cellstr(T1_Images);
            matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.sdata_multi.raw_mpm.pdmask_choice.no_pdmask = 0;
            %% Sending the MPM job ...
            spm_jobman('run',matlabbatch); clear matlabbatch;
            
            %% Masking  MT map
            Images2Mask =  pickfiles(MTSubDir,'',{'_MT.nii';'_R1.nii'});
            MaskImage =  pickfiles(MTSubDir,'_PDw.nii');
            thresh_mask = 100; suffix = '_m';
            MaskedImages = Mask_images(Images2Mask,MaskImage,thresh_mask,suffix);
            MT_MaskedImage = MaskedImages(1);
            %% Segmenting MT masked image ...
            matlabbatch{1}.spm.spatial.preproc.channel.vols(1) = cellstr(MT_MaskedImage);
            matlabbatch{1}.spm.spatial.preproc.channel.biasreg = 0.001; 
            matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60; 
            matlabbatch{1}.spm.spatial.preproc.channel.write = [0 0]; 
            matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm = {[spm_path,filesep,'tpm',filesep,MPM_Template,',1']};
            matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus = 2; 
            matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 1]; 
            matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0]; 
            matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm = {[spm_path,filesep,'tpm',filesep,MPM_Template,',2']}; 
            matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus = 2; 
            matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 1]; 
            matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0]; %#ok<*AGROW>
            matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm = {[spm_path,filesep,'tpm',filesep,MPM_Template,',3']};
            matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus = 2;
            matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm = {[spm_path,filesep,'tpm',filesep,MPM_Template,',4']};
            matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus = 3;
            matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [0 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm = {[spm_path,filesep,'tpm',filesep,MPM_Template,',5']};
            matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus = 4;
            matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [0 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm = {[spm_path,filesep,'tpm',filesep,MPM_Template,',6']};
            matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus = 2;
            matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
            matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
            matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
            matlabbatch{1}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
            matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
            matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
            matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
            matlabbatch{1}.spm.spatial.preproc.warp.write = [1 1];
            %% Sending the segmentation job ...
            spm_jobman('run',matlabbatch); clear matlabbatch;
        end;        
    end;    
end;
%% Reorganizing the Outputs ...
SubjOutMPMFolder = copyFile2Output(GlobalMPMFolder,ProtocolsFile,Subj_OutputFolder,SubjID);
Out_List_Files = getAllFiles(Subj_OutputFolder);
Reorganize_MPM_Files(Subj_OutputFolder,Ini_List_Files,Out_List_Files);

end

%% ==========  Internal Functions ==========
%% Nrep = get_Number_Rep(ProtocolsFile,DataFolder,j)
function Nrep = get_Number_Rep(ProtocolsFile,DataFolder,j)
% Note: MT, PD, T1 protocols have two folders per repetition, the 1st have magnitude images, the 2nd phase images.
[~,~,MT_p,PD_p,T1_p] = get_valid_MPM_Protocols(ProtocolsFile,DataFolder);

Nr_MT = length(getListofFolders([DataFolder,MT_p{j}]));
Nr_PD = length(getListofFolders([DataFolder,PD_p{j}]));
Nr_T1 = length(getListofFolders([DataFolder,T1_p{j}]));
Nrep = min([Nr_MT,Nr_PD,Nr_T1]/2);

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
ind = find((flevel==2)&(mem==0));
for i=1:length(ind)
    rmdir(sizeTree.name{ind(i)},'s');  % Removing empty folders ...
end;
sizeTree = folderSizeTree(Subj_OutputFolder);
mem = cell2mat(sizeTree.size); % Folders size ..
flevel = cell2mat(sizeTree.level); % Folders level ...
ind = find((flevel==3)&(mem==0));
for i=1:length(ind)
    rmdir(sizeTree.name{ind(i)},'s');  % Removing de remaining empty folders ...
end;

end

%% SubjOutMPMFolder = copyFile2Output(OutputFolderName,ProtocolsFile,Subj_OutputFolder,SubjID)
function SubjOutMPMFolder = copyFile2Output(GlobalMPMFolder,ProtocolsFile,Subj_OutputFolder,SubjID)

SubjOutMPMFolder = [GlobalMPMFolder,SubjID,filesep];
mkdir(SubjOutMPMFolder);
Session_Folder = getListofFolders(Subj_OutputFolder);
Ns = length(Session_Folder);  % Number of sessions ...
Files2Save = cellstr(get_protocol_names(ProtocolsFile,'__MPMOutputs__','[Files]'));
Nf = length(Files2Save);
for i=1:Ns
    DataFolder = [Subj_OutputFolder,Session_Folder{i},filesep];
    [~,~,MT_p,~,~,Nprot] = get_valid_MPM_Protocols(ProtocolsFile,DataFolder); % Number of protocols
    if i<10
        Session = ['0',num2str(i)];
    end;
    for j=1:Nprot
        Nrep = get_Number_Rep(ProtocolsFile,DataFolder,j); % Number of repetitions for each protocol
        for k=1:Nrep
            Folder_List = getListofFolders([DataFolder,MT_p{j}]);
            MTSubDir = [DataFolder,MT_p{j},filesep,Folder_List{2*k-1}];            
            if k<10
                Repet = ['0',num2str(k)];
            end;
            for t=1:Nf
                Files2copy = deblank(pickfiles(MTSubDir,Files2Save{t}));
                if ~isempty(Files2copy)                   
                    new_Name = [SubjID,'_',MT_p{j},'_ses_',Session,'_rep_',Repet,Files2Save{t}];
                    copyfile(Files2copy,[SubjOutMPMFolder,new_Name]);
                end;
            end;
        end;
    end;
end;

end

