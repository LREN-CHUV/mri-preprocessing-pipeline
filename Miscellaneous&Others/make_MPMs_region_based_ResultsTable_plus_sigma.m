function [OutputXLSFileName,Vol_data_xls,R2s_data_xls,MT_data_xls,PD_data_xls,R1_data_xls] = make_MPMs_region_based_ResultsTable_plus_sigma(NeuroMorphoInputFolder,ProtocolsFile,PreviousOutputXLSFileName,OutputXLSFileName,SubjectListFileName)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, January 29th, 2016

if ~strcmp(NeuroMorphoInputFolder(end),filesep)
    NeuroMorphoInputFolder = [NeuroMorphoInputFolder,filesep];
end;
if ~isempty(PreviousOutputXLSFileName)
    [~,~,PrevXLSTable] = xlsread(PreviousOutputXLSFileName,'Volume (cm3)');
    PrevSubjects = PrevXLSTable(2:end,1);
else
    PrevSubjects = {};
end;

MT_protocols   = cellstr(get_protocol_names(ProtocolsFile,'__MPM__','[MT]')); % protocol name ..
MT_protocols_Resolution  = cellstr(get_protocol_names(ProtocolsFile,'__MPM__','[Resolution]')); % protocol Resolutions ...

MorphoFolders = getListofFolders(NeuroMorphoInputFolder);
if exist('SubjectListFileName','var');
    SubjectList = textscan(SubjectListFileName,'%s'); %textread(SubjectListFileName,'%s');
else
    SubjectList = MorphoFolders;
end;

MorphoFolders = MorphoFolders(ismember(MorphoFolders,SubjectList));
MorphoFolders = MorphoFolders(~ismember(MorphoFolders,PrevSubjects));

XLS_FileTag = '_Neuromorphics_Vols_MPMs_global_std_values.xls';
%StructNames = getNeuromorphoAtlasInfo;
SubjXLSFile = pickfiles([NeuroMorphoInputFolder,MorphoFolders{1}],{XLS_FileTag});
SubjXLSFile = SubjXLSFile(1,:);
[~,~,OneTable] = xlsread(deblank(SubjXLSFile),'Data');
StructNames = OneTable(2:end,1);

Table_Header = {'Subject ID','Repetition','Resolution'};
Table_Header = horzcat(Table_Header,StructNames'); %,'Volume(cm3)','R2* [1/ms]','Magnetization Transfer (MT)','Proton Density','R1 [1000/s]','Number of voxels','Volume/TIV'};

Ns = length(MorphoFolders); Nh = length(Table_Header);
Vol_data_xls = cell(Ns+1,Nh); 
R2s_data_xls = cell(Ns+1,Nh); R2s_std_data_xls = cell(Ns+1,Nh);
MT_data_xls  = cell(Ns+1,Nh); MT_std_data_xls  = cell(Ns+1,Nh); 
PD_data_xls  = cell(Ns+1,Nh); PD_std_data_xls  = cell(Ns+1,Nh);
R1_data_xls  = cell(Ns+1,Nh); R1_std_data_xls  = cell(Ns+1,Nh);
Nvox_data_xls = cell(Ns+1,Nh); Vol_norm_data_xls = cell(Ns+1,Nh); 
% Adding Header
Vol_data_xls(1,:)=Table_Header; 
R2s_data_xls(1,:)=Table_Header; R2s_std_data_xls(1,:)=Table_Header;
MT_data_xls(1,:)=Table_Header;  MT_std_data_xls(1,:)=Table_Header; 
PD_data_xls(1,:)=Table_Header;  PD_std_data_xls(1,:)=Table_Header;
R1_data_xls(1,:)=Table_Header;  R1_std_data_xls(1,:)=Table_Header;
Nvox_data_xls(1,:)=Table_Header; Vol_norm_data_xls(1,:)=Table_Header; 
s = 1;
for i=1:Ns
    disp(['Subject : ',num2str(i),' of ',num2str(Ns)]);
    SubjFolder = [NeuroMorphoInputFolder,MorphoFolders{i},filesep];
    Session_Folder = getListofFolders(SubjFolder);
    Nse = length(Session_Folder);  % Number of sessions ...
    Nxls = size(pickfiles(SubjFolder,{XLS_FileTag}),1);  % Number of excel files (*.xls)
    SubjVols = cell(Nxls,Nh); 
    SubjR2s = cell(Nxls,Nh); SubjR2s_std = cell(Nxls,Nh);
    SubjMT   = cell(Nxls,Nh); SubjMT_std  = cell(Nxls,Nh); 
    SubjPD = cell(Nxls,Nh);  SubjPD_std = cell(Nxls,Nh);
    SubjR1 = cell(Nxls,Nh);  SubjR1_std = cell(Nxls,Nh);
    SubjNvox = cell(Nxls,Nh);SubjVols_norm = cell(Nxls,Nh);
    c = 0; 
    for j=1:Nse
        SequencesFolder = [SubjFolder,Session_Folder{j},filesep];
        Sequences = getListofFolders(SequencesFolder);
        Np = length(Sequences); % Number of protocols
        for k=1:Np
            SubjProtocolsFolder = [SequencesFolder,Sequences{k},filesep];
            RepetitionFolders = getListofFolders(SubjProtocolsFolder);
            MPM_resol = unique(MT_protocols_Resolution(ismember(MT_protocols,Sequences{k})));
            Nr = length(RepetitionFolders); % Repetition Folders
            for t=1:Nr
                SubjRepetitionFolder = [SubjProtocolsFolder,RepetitionFolders{t}];
                SubjXLSFile = pickfiles(SubjRepetitionFolder,{XLS_FileTag});
                [~,~,OneTable] = xlsread(deblank(SubjXLSFile),'Data'); OneTable = OneTable(2:end,:);                
                c =  c + 1;
                SubjVols(c,1) = MorphoFolders(i); SubjVols(c,2) = {c}; SubjVols(c,3) = MPM_resol;
                SubjVols(c,4:end) = OneTable(:,2)';
                SubjR2s(c,1) = MorphoFolders(i); SubjR2s(c,2) = {c}; SubjR2s(c,3) = MPM_resol;
                SubjR2s(c,4:end) = OneTable(:,3)';
                SubjR2s_std(c,1) = MorphoFolders(i); SubjR2s_std(c,2) = {c}; SubjR2s_std(c,3) = MPM_resol;
                SubjR2s_std(c,4:end) = OneTable(:,4)';                
                SubjMT(c,1) = MorphoFolders(i); SubjMT(c,2) = {c}; SubjMT(c,3) = MPM_resol;
                SubjMT(c,4:end) = OneTable(:,5)';
                SubjMT_std(c,1) = MorphoFolders(i); SubjMT_std(c,2) = {c}; SubjMT_std(c,3) = MPM_resol;
                SubjMT_std(c,4:end) = OneTable(:,6)';           
                SubjPD(c,1) = MorphoFolders(i); SubjPD(c,2) = {c}; SubjPD(c,3) = MPM_resol;
                SubjPD(c,4:end) = OneTable(:,7)';
                SubjPD_std(c,1) = MorphoFolders(i); SubjPD_std(c,2) = {c}; SubjPD_std(c,3) = MPM_resol;
                SubjPD_std(c,4:end) = OneTable(:,8)';               
                SubjR1(c,1) = MorphoFolders(i); SubjR1(c,2) = {c}; SubjR1(c,3) = MPM_resol;
                SubjR1(c,4:end) = OneTable(:,9)';
                SubjR1_std(c,1) = MorphoFolders(i); SubjR1_std(c,2) = {c}; SubjR1_std(c,3) = MPM_resol;
                SubjR1_std(c,4:end) = OneTable(:,10)';             
                SubjNvox(c,1) = MorphoFolders(i); SubjNvox(c,2) = {c}; SubjNvox(c,3) = MPM_resol;
                SubjNvox(c,4:end) = OneTable(:,11)';                 
                SubjVols_norm(c,1) = MorphoFolders(i); SubjVols_norm(c,2) = {c}; SubjVols_norm(c,3) = MPM_resol;
                SubjVols_norm(c,4:end) = OneTable(:,12)';               
            end;
        end;
    end;
    Vol_data_xls(s+1:s+Nxls,:) = SubjVols; 
    R2s_data_xls(s+1:s+Nxls,:) = SubjR2s;  R2s_std_data_xls(s+1:s+Nxls,:) = SubjR2s_std;
    MT_data_xls(s+1:s+Nxls,:) = SubjMT;    MT_std_data_xls(s+1:s+Nxls,:) = SubjMT_std;
    PD_data_xls(s+1:s+Nxls,:) = SubjPD;    PD_std_data_xls(s+1:s+Nxls,:) = SubjPD_std;
    R1_data_xls(s+1:s+Nxls,:)= SubjR1;     R1_std_data_xls(s+1:s+Nxls,:)= SubjR1_std;
    PD_data_xls(s+1:s+Nxls,:) = SubjPD;    PD_std_data_xls(s+1:s+Nxls,:) = SubjPD_std;
    Nvox_data_xls(s+1:s+Nxls,:)= SubjNvox; Vol_norm_data_xls(s+1:s+Nxls,:)= SubjVols_norm;
    s = s + Nxls;
end;

if ~isempty(PreviousOutputXLSFileName)    
    [~,~,PrevXLSTable] = xlsread(PreviousOutputXLSFileName,'Volume (cm3)');
    Vol_data_xls = vertcat(PrevXLSTable,Vol_data_xls(2:end,:));
    [~,~,PrevXLSTable] = xlsread(PreviousOutputXLSFileName,'R2s (ms^-1)');
    R2s_data_xls = vertcat(PrevXLSTable,R2s_data_xls(2:end,:));
    [~,~,PrevXLSTable] = xlsread(PreviousOutputXLSFileName,'std R2s (ms^-1)');
    R2s_std_data_xls = vertcat(PrevXLSTable,R2s_std_data_xls(2:end,:));
    [~,~,PrevXLSTable] = xlsread(PreviousOutputXLSFileName,'Magnetization Transfer(MT)');
    MT_data_xls = vertcat(PrevXLSTable,MT_data_xls(2:end,:));
    [~,~,PrevXLSTable] = xlsread(PreviousOutputXLSFileName,'std Magnetization Transfer(MT)');
    MT_std_data_xls = vertcat(PrevXLSTable,MT_std_data_xls(2:end,:));    
    [~,~,PrevXLSTable] = xlsread(PreviousOutputXLSFileName,'Proton Density');
    PD_data_xls = vertcat(PrevXLSTable,PD_data_xls(2:end,:));
    [~,~,PrevXLSTable] = xlsread(PreviousOutputXLSFileName,'std Proton Density');
    PD_std_data_xls = vertcat(PrevXLSTable,PD_std_data_xls(2:end,:));    
    [~,~,PrevXLSTable] = xlsread(PreviousOutputXLSFileName,'R1 (ms^-1)');
    R1_data_xls = vertcat(PrevXLSTable,R1_data_xls(2:end,:));
    [~,~,PrevXLSTable] = xlsread(PreviousOutputXLSFileName,'std R1 (ms^-1)');
    R1_std_data_xls = vertcat(PrevXLSTable,R1_std_data_xls(2:end,:));    
    [~,~,PrevXLSTable] = xlsread(PreviousOutputXLSFileName,'Number of voxels');
    Nvox_data_xls = vertcat(PrevXLSTable,Nvox_data_xls(2:end,:));    
    [~,~,PrevXLSTable] = xlsread(PreviousOutputXLSFileName,'Volume Normalized');
    Vol_norm_data_xls = vertcat(PrevXLSTable,Vol_norm_data_xls(2:end,:));    
end;

Str_unique = check_clean_IDs(datestr(now));
[FilePath,FileName,FileExt] = fileparts(OutputXLSFileName);

OutputXLSFileName = [FilePath,filesep,[FileName,'_',Str_unique],FileExt];

xlswrite(OutputXLSFileName,Vol_data_xls,'Volume (cm3)');
xlswrite(OutputXLSFileName,R2s_data_xls,'R2s (ms^-1)');
xlswrite(OutputXLSFileName,R2s_std_data_xls,'std R2s (ms^-1)');
xlswrite(OutputXLSFileName,MT_data_xls,'Magnetization Transfer(MT)');
xlswrite(OutputXLSFileName,MT_std_data_xls,'std Magnetization Transfer(MT)');
xlswrite(OutputXLSFileName,PD_data_xls,'Proton Density');
xlswrite(OutputXLSFileName,PD_std_data_xls,'std Proton Density');
xlswrite(OutputXLSFileName,R1_data_xls,'R1 (ms^-1)');
xlswrite(OutputXLSFileName,R1_std_data_xls,'std R1 (ms^-1)');
xlswrite(OutputXLSFileName,Nvox_data_xls,'Number of voxels');
xlswrite(OutputXLSFileName,Vol_norm_data_xls,'Volume Normalized');

end


%% ======= Internal Functions ======= %%
function IDout = check_clean_IDs(IDin)

IDout= IDin(isstrprop(IDin,'alphanum'));

end