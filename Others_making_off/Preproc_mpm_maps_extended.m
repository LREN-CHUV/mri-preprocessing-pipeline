function [Subj_OutputFolder,SubjOutMPMFolder] = Preproc_mpm_maps_extended(SubjectFolder,SubjID,OutputFolder,GlobalMPMFolder,ProtocolsFile,MPM_Template,ServerFolder,doUNICORT)

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
spm_jobman('initcfg');

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
if ~exist('doUNICORT','var')
    doUNICORT =  false;
end;
%% Checking if subject have valid MPMs folders ..
RawSession_Folders = getListofFolders(SubjectFolder);
Ns_t = length(RawSession_Folders);  % Number of sessions ...
Nprot_t = zeros(Ns_t,1);
for i=1:Ns_t
    Nprot_t(i) = get_Number_Prot(ProtocolsFile,[SubjectFolder,RawSession_Folders{i},filesep]); % Number of protocols
end;

%%
if sum(Nprot_t)>0    
    Subj_OutputFolder = [OutputFolder,SubjID,filesep];
    mkdir(Subj_OutputFolder);
    copyfile(SubjectFolder,Subj_OutputFolder);
    Session_Folder = getListofFolders(Subj_OutputFolder);
    Ns = length(Session_Folder);  % Number of sessions ...
    Ini_List_Files = getAllFiles(Subj_OutputFolder);
    for i=1:Ns
        DataFolder = [Subj_OutputFolder,Session_Folder{i},filesep];
        Nprot = get_Number_Prot(ProtocolsFile,DataFolder); % Number of protocols
        for j=1:Nprot  % Number of protocols, i.e : 1.0 mm^3, and 1.5 mm^3
            Nrep = get_Number_Rep(ProtocolsFile,DataFolder,j); % Number of repetitions for each protocol
            for k=1:Nrep
                if ~doUNICORT
                    %%  Field mapping images ...
                    pname = get_section_protocol(ProtocolsFile,'__MPM__','[fieldmap]',DataFolder);
                    if (Nprot>1)&&(length(pname)==1)
                        pname = pname{1};
                    else
                        pname = pname{j};  % protocol name
                    end;
                    Folder_List = getListofFolders([DataFolder,pname],'yes'); % gives back sorted Folder list
                    InSubDir01 = [DataFolder,pname,filesep,Folder_List{2*k-1}];
                    InSubDir02 = [DataFolder,pname,filesep,Folder_List{2*k}];
                    Files01 = spm_select('FPListRec',InSubDir01,'.*');
                    Files02 = spm_select('FPListRec',InSubDir02,'.*');
                    b0_Images = char(Files01,Files02);
                    
                    %%  B1 images ...
                    pname = get_section_protocol(ProtocolsFile,'__MPM__','[B1]',DataFolder); 
                    if (Nprot>1)&&(length(pname)==1)
                        pname = pname{1};
                    else
                        pname = pname{j};  % protocol name
                    end;
                    Folder_List = getListofFolders([DataFolder,pname],'yes');  % gives back sorted Folder list
                    InSubDir01 = [DataFolder,pname,filesep,Folder_List{k}];
                    b1_Images = cellstr(spm_select('FPListRec',InSubDir01,'.*'));
                end;
                %%  MT images ...
                pname = get_section_protocol(ProtocolsFile,'__MPM__','[MT]',DataFolder); pname = pname{j}; % protocol name
                Folder_List = getListofFolders([DataFolder,pname],'yes');  % gives back sorted Folder list
                MTSubDir = [DataFolder,pname,filesep,Folder_List{2*k-1}];
                MT_Images = cellstr(spm_select('FPListRec',MTSubDir,'.*'));
                
                %%  PD images ...
                pname = get_section_protocol(ProtocolsFile,'__MPM__','[PD]',DataFolder); pname = pname{j}; % protocol name
                Folder_List = getListofFolders([DataFolder,pname],'yes');  % gives back sorted Folder list
                InSubDir01 = [DataFolder,pname,filesep,Folder_List{2*k-1}];
                PD_Images = cellstr(spm_select('FPListRec',InSubDir01,'.*'));
                
                %%  T1 images ...
                pname = get_section_protocol(ProtocolsFile,'__MPM__','[T1]',DataFolder); pname = pname{j}; % protocol name
                Folder_List = getListofFolders([DataFolder,pname],'yes');  % gives back sorted Folder list
                InSubDir01 = [DataFolder,pname,filesep,Folder_List{2*k-1}];
                T1_Images = cellstr(spm_select('FPListRec',InSubDir01,'.*'));
                
                %%  Calculating MPMs  ...
                if ~doUNICORT
                    % MPMs computation using the standard way, B0 and B1 images are used this case
                    matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.b1_type = '3D_EPI_v2b';
                    matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.sdata_multi.output.indir = 1;
                    %matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.sdata_multi.output.outdir = cellstr(Subj_OutputFolder);
                    matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.sdata_multi.raw_fld.b0 = cellstr(b0_Images);
                    matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.sdata_multi.raw_fld.b1 = cellstr(b1_Images);
                    matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.sdata_multi.raw_mpm.MT = cellstr(MT_Images);
                    matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.sdata_multi.raw_mpm.PD = cellstr(PD_Images);
                    matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.sdata_multi.raw_mpm.T1 = cellstr(T1_Images);
                    matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_b_img.data_spec.sdata_multi.raw_mpm.pdmask_choice.no_pdmask = 0;
                else
                    % MPMs computation using UNICORT, B0 and B1 images are not necessary in this case
                    matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_unicort.data_spec.subj.output.indir = 1;
                    matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_unicort.data_spec.subj.raw_mpm.MT = cellstr(MT_Images);
                    matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_unicort.data_spec.subj.raw_mpm.PD = cellstr(PD_Images);
                    matlabbatch{1}.spm.tools.VBQ.crt_maps.mp_img_unicort.data_spec.subj.raw_mpm.T1 = cellstr(T1_Images);
                end;
                %% Sending the MPM job ...
                spm_jobman('run',matlabbatch); clear matlabbatch;
                
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
                % Just testing something, adjusting center of the images ...
                %V = spm_vol(char(MT_MaskedImage));
                %center_coord = (V.dim)/2;
                %MM = V.mat; MM(1:3,4) =  [-center_coord(3),center_coord(1),-center_coord(2)];
                %V.mat = MM;
                %I = spm_read_vols(V); spm_write_vol(V,I);
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
    SubjOutMPMFolder = copyFile2Output(GlobalMPMFolder,ProtocolsFile,Subj_OutputFolder,SubjID,doUNICORT);
    Out_List_Files = getAllFiles(Subj_OutputFolder);
    Reorganize_MPM_Files(Subj_OutputFolder,Ini_List_Files,Out_List_Files);
    
    %% Copying Data to server ...
    %copy_data2Server(Subj_OutputFolder,OutputFolder,ServerFolder,SubjID);  % if ServerFolder variable is empty,  Nifti data wont be copy to the server
    %copy_data2Server(SubjOutMPMFolder,GlobalMPMFolder,ServerFolder,SubjID);    % if ServerFolder variable is empty,  Nifti data wont be copy to the server
end;
end

%% ==========  Internal Functions ==========
function Nprot = get_Number_Prot(ProtocolsFile,DataFolder)

[~,Np_MT] = get_section_protocol(ProtocolsFile,'__MPM__','[MT]',DataFolder);
[~,Np_PD] = get_section_protocol(ProtocolsFile,'__MPM__','[PD]',DataFolder);
[~,Np_T1] = get_section_protocol(ProtocolsFile,'__MPM__','[T1]',DataFolder);
Nprot = min([Np_MT,Np_PD,Np_T1]);

end
%% Nrep = get_Number_Rep(ProtocolsFile,DataFolder,j)
function Nrep = get_Number_Rep(ProtocolsFile,DataFolder,j)
% Note: MT, PD, T1 protocols have two folders per repetition, the 1st have magnitude images, the 2nd phase images.
cprotocol = get_section_protocol(ProtocolsFile,'__MPM__','[MT]',DataFolder);
Nr_MT = length(getListofFolders([DataFolder,cprotocol{j}]));
cprotocol = get_section_protocol(ProtocolsFile,'__MPM__','[PD]',DataFolder);
Nr_PD = length(getListofFolders([DataFolder,cprotocol{j}]));
cprotocol = get_section_protocol(ProtocolsFile,'__MPM__','[T1]',DataFolder);
Nr_T1 = length(getListofFolders([DataFolder,cprotocol{j}]));
if (Nr_MT==1)||(Nr_PD==1)||(Nr_T1==1)
    Nrep = 1;
else
    Nrep = floor(min([Nr_MT,Nr_PD,Nr_T1]/2));
end;

end
%% [cprotocol,Np] = get_section_protocol(ProtocolsFile,ProcessingSTep,MRIModality,DataFolder)
function [cprotocol,Np] = get_section_protocol(ProtocolsFile,ProcessingSTep,MRIModality,DataFolder)

pname = get_protocol_names(ProtocolsFile,ProcessingSTep,MRIModality); % protocol name ..
pname = cellstr(pname);
subj_protocols = getListofFolders(DataFolder);
%ind = ismember(pname,subj_protocols);
%cprotocol = pname(ind);
[~,~,ipname] = intersect(subj_protocols,pname);
cprotocol = pname(sort(ipname));
Np = length(cprotocol);
%cprotocol = char(pname(ind));
%Np = size(cprotocol,1);

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
function SubjOutMPMFolder = copyFile2Output(GlobalMPMFolder,ProtocolsFile,Subj_OutputFolder,SubjID,doUNICORT)

SubjOutMPMFolder = [GlobalMPMFolder,SubjID,filesep];
mkdir(SubjOutMPMFolder);
Session_Folder = getListofFolders(Subj_OutputFolder);
Ns = length(Session_Folder);  % Number of sessions ...
Files2Save = cellstr(get_protocol_names(ProtocolsFile,'__MPMOutputs__','[Files]'));
Nf = length(Files2Save);
for i=1:Ns
    DataFolder = [Subj_OutputFolder,Session_Folder{i},filesep];
    Nprot = get_Number_Prot(ProtocolsFile,DataFolder); % Number of protocols
    if i<10
        Session = ['0',num2str(i)];
    end;
    for j=1:Nprot
        Nrep = get_Number_Rep(ProtocolsFile,DataFolder,j); % Number of repetitions for each protocol
        for k=1:Nrep
            pname = get_section_protocol(ProtocolsFile,'__MPM__','[MT]',DataFolder); pname = pname{j}; % protocol name
            Folder_List = getListofFolders([DataFolder,pname]);
            MTSubDir = [DataFolder,pname,filesep,Folder_List{2*k-1}];
            Ref_Image =  pickfiles(MTSubDir,'_PDw.nii');
            if k<10
                Repet = ['0',num2str(k)];
            end;
            for t=1:Nf
                if ~doUNICORT
                    Files2copy = deblank(pickfiles(MTSubDir,Files2Save{t}));
                else                    
                    [Ref_ImageFilePath,Ref_ImageFileName] = fileparts(Ref_Image);
                    if strcmp(Files2Save{t},'_R1.nii')
                        Files2copy = [Ref_ImageFilePath,filesep,'mh',Ref_ImageFileName(1:end-4),Files2Save{t}];
                    else
                        Files2copy = [Ref_ImageFilePath,filesep,Ref_ImageFileName(1:end-4),Files2Save{t}];
                    end;
                    if ~exist(Files2copy,'file')
                        Files2copy = '';
                    end;
                end;                                
                if ~isempty(Files2copy)
                    new_Name = [SubjID,'_',pname,'_ses_',Session,'_rep_',Repet,Files2Save{t}];
                    copyfile(Files2copy,[SubjOutMPMFolder,new_Name]);
                end;
            end;
        end;
    end;
end;

end

%% function copy_data2Server(InputFolder)
function copy_data2Server(SubjInputFolder,InputFolder,ServerFolder,SubjID)

if ~isempty(ServerFolder)
    if ~exist(ServerFolder,'dir')
        mkdir(ServerFolder);
    end;
    if ~strcmpi(ServerFolder(end),filesep)
        ServerFolder = [ServerFolder,filesep];
    end;
    if ~strcmpi(InputFolder(end),filesep)
        InputFolder = [InputFolder,filesep];
    end;
    ind = strfind(InputFolder,filesep);
    ServerFolderName = InputFolder(ind(end-1)+1:ind(end)-1);
    SubjOutputServerFolder = [ServerFolder,ServerFolderName,filesep,SubjID];
    if ~exist(SubjOutputServerFolder ,'dir')
        mkdir(SubjOutputServerFolder);
    end;
    copyfile(SubjInputFolder,SubjOutputServerFolder);
end;

end

