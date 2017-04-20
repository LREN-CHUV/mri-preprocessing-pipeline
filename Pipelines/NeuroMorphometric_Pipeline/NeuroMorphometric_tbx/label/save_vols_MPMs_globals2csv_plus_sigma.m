function XLS_Table = save_vols_MPMs_globals2csv_plus_sigma(VolumeFile,AtlasFile,MPMFolder,OutputCSVFile,GM_File,WM_File,CSF_File,TableFormat)

%% Input Parameters:
%     VolumeFolder : Folder where volume files (*.txt) were saved during the
%                    NeuroMorphometric Toolbox processing.
%      AtlasFolder : Folder with the Atlases.
%        MPMFolder : Folder with the MPMs. (MT, R2s, R1, PD)
%    OutputCSVFile : Full path of the output CSV file where the volume of anatomical structures for all subjects will be saved.
%       GM_File   : Gray matter tissue classification File (example: c1*.nii file from SPM)
%       WM_File   : White matter tissue classification File (example: c2*.nii file from SPM)
%       CSF_File   : Cerebral Spinal Fluid (CSF) tissue classification File (example: c3*.nii file from SPM)
%      TableFormat: Defines which format the Output Table will be saved. TableFormat = 'csv' : save in CSV format, TableFormat = 'xls': save in Excel SpreadSheet format. 
%                   If this is not defined is asummed Excel format.
%
%% Output Parameters:
%    XLS_Table : Excel spreadsheet with the information of the volume, mean and standard deviation of MPMs per structure plus global measures.
%
%
%% Lester Melie-Garcia
% LREN, Lausanne
% October 7th, 2015

if ~strcmp(MPMFolder(end),filesep)
    MPMFolder = [MPMFolder,filesep];
end;
if ~exist('TableFormat','var')
    if isunix
        TableFormat = 'csv';
    else
        TableFormat = 'xls';
    end;
else
    TableFormat = lower(TableFormat);
end;

[StructNames,SCodes] = getNeuromorphoAtlasInfo;
Table_Header = {'Structure Names','Volume(cm3)','R2* [1/ms]','std R2* [1/ms]','Magnetization Transfer (MT)','std Magnetization Transfer (MT)',...
                                                'Proton Density','std Proton Density','R1 [1000/s]','std R1 [1000/s]','Number of voxels','Volume/TIV'};
Nc = length(Table_Header);
NStruct = length(StructNames);
XLS_Table = cell(NStruct+1,Nc);
XLS_Table(1,:) = Table_Header;
XLS_Table(2:end,1) = StructNames;
SCodes =  cell2mat(SCodes);
Vols_raw = load(VolumeFile); Vols = Vols_raw(SCodes);
XLS_Table(2:end,2) = mat2cell(Vols,ones(size(Vols,1),1));
R2s_Image = pickfiles(MPMFolder(1:end-1),{'_R2s.nii'});
if ~isempty(R2s_Image)
    I_R2s =  spm_read_vols(spm_vol(R2s_Image(1,:)));
end;
MT_Image = pickfiles(MPMFolder(1:end-1),{'_MT.nii'});
if ~isempty(MT_Image)
    I_MT =  spm_read_vols(spm_vol(MT_Image(1,:)));
end;
PD_Image  = pickfiles(MPMFolder(1:end-1),{'_A.nii'});
if ~isempty(PD_Image)
    I_PD =  spm_read_vols(spm_vol(PD_Image(1,:)));
end;
R1_Image = pickfiles(MPMFolder(1:end-1),{'_R1.nii'});
if ~isempty(R1_Image)
    I_R1 =  spm_read_vols(spm_vol(R1_Image(1,:)));
end;
if ~isempty(R2s_Image)||~isempty(MT_Image)||~isempty(PD_Image)||~isempty(R1_Image)
    MPMs_mat = zeros(NStruct,8);
    Nvoxels = cell(NStruct,1);
    Iatlas = spm_read_vols(spm_vol(AtlasFile));
    for i=1:NStruct
        ind = Iatlas==SCodes(i);
        Nvoxels{i} = nnz(double(ind));
        if ~isempty(R2s_Image)
            if Nvoxels{i}~=0
                MPMs_mat(i,1) = mean(I_R2s(ind));
                MPMs_mat(i,2) = std(I_R2s(ind));
            else
                MPMs_mat(i,1) = 0;
                MPMs_mat(i,2) = 0;
            end;
        end;
        if ~isempty(MT_Image)
            if Nvoxels{i}~=0
                MPMs_mat(i,3) = mean(I_MT(ind));
                MPMs_mat(i,4) = std(I_MT(ind));
            else
                MPMs_mat(i,3) = 0;
                MPMs_mat(i,4) = 0;
            end
        end;
        if ~isempty(PD_Image)
            if Nvoxels{i}~=0
                MPMs_mat(i,5) = mean(I_PD(ind));
                MPMs_mat(i,6) = std(I_PD(ind));
            else
                MPMs_mat(i,5) = 0;
                MPMs_mat(i,6) = 0;
            end;
        end;
        if ~isempty(R1_Image)
            if Nvoxels{i}~=0
                MPMs_mat(i,7) = mean(I_R1(ind));
                MPMs_mat(i,8) = std(I_R1(ind));
            else
                MPMs_mat(i,7) = 0;
                MPMs_mat(i,8) = 0;
            end
        end;
    end;
    
    %% Adding Intracraneal Volume
    V_GM = spm_vol(GM_File); voxvol = abs(det(V_GM.mat(1:3,1:3)));
    I_GM =  spm_read_vols(V_GM);
    I_WM =  spm_read_vols(spm_vol(WM_File));
    I_CSF =  spm_read_vols(spm_vol(CSF_File));
    TIV = (I_GM + I_WM + I_CSF)>0.1;
    TIV_Nvox = sum(TIV(:));
    TIV = voxvol*TIV_Nvox/1000; % in cm3
    % ICV_Table = cell(2,1);
    % ICV_Table{1,1} = 'Intracraneal Volume(cm3)';
    % ICV_Table{2,1} = ICV;
    %%
    Vol_Normalized = mat2cell(cell2mat(XLS_Table(2:end,2))./TIV,ones(length(XLS_Table(2:end,2)),1));
    MPMs_mat = mat2cell(MPMs_mat,ones(size(MPMs_mat,1),1),ones(size(MPMs_mat,2),1)); %#ok
    MPMs_mat = horzcat(MPMs_mat,Nvoxels,Vol_Normalized);
    XLS_Table(2:end,3:end) = MPMs_mat;
    
    %% Adding White Matter Stats
    WM_StructNames = getNeuromorphoWhiteMatter;
    WM_Codes = getStructCodes(StructNames,SCodes,WM_StructNames);
    ind_WM_R = Iatlas==WM_Codes{1}; ind_WM_L = Iatlas==WM_Codes{2}; ind_WM_all = or(ind_WM_R,ind_WM_L);
    WM_R_Nvox = sum(ind_WM_R(:)); WM_L_Nvox = sum(ind_WM_L(:)); WM_total_Nvox = WM_R_Nvox + WM_L_Nvox;
    WM_R_Vol = Vols_raw(WM_Codes{1}); WM_L_Vol = Vols_raw(WM_Codes{2}); WM_total_Vol = WM_R_Vol + WM_L_Vol;
    %WM_R_Vol = WM_R_Nvox*voxvol/1000; WM_L_Vol = WM_L_Nvox*voxvol/1000; WM_total_Vol = WM_R_Vol + WM_L_Vol;
    %WM_R_R2s = mean(I_R2s(ind_WM_R)); WM_L_R2s = mean(I_R2s(ind_WM_L));
    WM_total_R2s = mean(I_R2s(ind_WM_all)); WM_total_R2s_std = std(I_R2s(ind_WM_all));
    %WM_R_MT  = mean(I_MT(ind_WM_R)) ; WM_L_MT = mean(I_MT(ind_WM_L))  ;
    WM_total_MT = mean(I_MT(ind_WM_all)); WM_total_MT_std = std(I_MT(ind_WM_all));
    %WM_R_PD  = mean(I_PD(ind_WM_R)) ; WM_L_PD = mean(I_PD(ind_WM_L))  ;
    WM_total_PD = mean(I_PD(ind_WM_all)); WM_total_PD_std = std(I_PD(ind_WM_all));
    %WM_R_R1  = mean(I_R1(ind_WM_R)) ; WM_L_R1 = mean(I_R1(ind_WM_L))  ;
    WM_total_R1 = mean(I_R1(ind_WM_all)); WM_total_R1_std = std(I_R1(ind_WM_all));
    %% Adding Gray Matter Stats
    GM_StructNames = get_GraymatterNeuromorphoAtlasInfo;
    GM_Codes = cell2mat(getStructCodes(StructNames,SCodes,GM_StructNames));
    GM_Codes_R = GM_Codes(1:2:end); GM_Codes_L = GM_Codes(2:2:end);
    ind_GM_R = ismember(Iatlas,GM_Codes_R); ind_GM_L = ismember(Iatlas,GM_Codes_L); ind_GM_all = or(ind_GM_R,ind_GM_L);
    GM_R_Nvox = sum(ind_GM_R(:)); GM_L_Nvox = sum(ind_GM_L(:)); GM_total_Nvox = GM_R_Nvox + GM_L_Nvox;
    GM_R_Vol = sum(Vols_raw(GM_Codes_R)); GM_L_Vol = sum(Vols_raw(GM_Codes_L)); GM_total_Vol = GM_R_Vol + GM_L_Vol;
    %GM_R_Vol = GM_R_Nvox*voxvol/1000; GM_L_Vol = GM_L_Nvox*voxvol/1000; GM_total_Vol = GM_R_Vol + GM_L_Vol;
    GM_R_R2s = mean(I_R2s(ind_GM_R)); GM_L_R2s = mean(I_R2s(ind_GM_L)); GM_total_R2s = mean(I_R2s(ind_GM_all));
    GM_R_R2s_std = std(I_R2s(ind_GM_R)); GM_L_R2s_std = std(I_R2s(ind_GM_L)); GM_total_R2s_std = std(I_R2s(ind_GM_all));
    GM_R_MT  = mean(I_MT(ind_GM_R)) ; GM_L_MT = mean(I_MT(ind_GM_L))  ; GM_total_MT = mean(I_MT(ind_GM_all));
    GM_R_MT_std  = std(I_MT(ind_GM_R)) ; GM_L_MT_std = std(I_MT(ind_GM_L))  ; GM_total_MT_std = std(I_MT(ind_GM_all));
    GM_R_PD  = mean(I_PD(ind_GM_R)) ; GM_L_PD = mean(I_PD(ind_GM_L))  ; GM_total_PD = mean(I_PD(ind_GM_all));
    GM_R_PD_std  = std(I_PD(ind_GM_R)) ; GM_L_PD_std = std(I_PD(ind_GM_L))  ; GM_total_PD_std = std(I_PD(ind_GM_all));
    GM_R_R1  = mean(I_R1(ind_GM_R)) ; GM_L_R1 = mean(I_R1(ind_GM_L))  ; GM_total_R1 = mean(I_R1(ind_GM_all));
    GM_R_R1_std  = std(I_R1(ind_GM_R)) ; GM_L_R1_std = std(I_R1(ind_GM_L))  ; GM_total_R1_std = std(I_R1(ind_GM_all));
    
    GM_total_Vol_norm = GM_total_Vol/TIV; GM_R_Vol_norm = GM_R_Vol/TIV; GM_L_Vol_norm=GM_L_Vol/TIV;
    WM_total_Vol_norm = WM_total_Vol/TIV;
    %% Globals Table
    
    GT = [GM_total_Vol,GM_total_R2s,GM_total_R2s_std,GM_total_MT,GM_total_MT_std,GM_total_PD,GM_total_PD_std,GM_total_R1,GM_total_R1_std,GM_total_Nvox,GM_total_Vol_norm
        GM_R_Vol    ,GM_R_R2s    ,GM_R_R2s_std    ,GM_R_MT    ,GM_R_MT_std    ,GM_R_PD    ,GM_R_PD_std    ,GM_R_R1    ,GM_R_R1_std    ,GM_R_Nvox    ,GM_R_Vol_norm
        GM_L_Vol    ,GM_L_R2s    ,GM_L_R2s_std    ,GM_L_MT    ,GM_L_MT_std    ,GM_L_PD    ,GM_L_PD_std    ,GM_L_R1    ,GM_L_R1_std    ,GM_L_Nvox    ,GM_L_Vol_norm
        WM_total_Vol,WM_total_R2s,WM_total_R2s_std,WM_total_MT,WM_total_MT_std,WM_total_PD,WM_total_PD_std,WM_total_R1,WM_total_R1_std,WM_total_Nvox,WM_total_Vol_norm
        TIV         ,   0        ,   0            ,   0       ,   0           ,   0       ,   0           ,   0       ,   0           ,TIV_Nvox     ,     1            ];
    Globals_Table = cell(size(GT,1)+1,length(Table_Header));
    Globals_Table(1,:) = Table_Header;
    Globals_Table(2:end,1) = {'Total Cerebral Grey Matter';'Right Cerebral Grey Matter';'Left Cerebral Grey Matter';'Total Cerebral White Matter';'Intracraneal'};
    % GT = [GM_total_Vol,GM_total_R2s,GM_total_MT,GM_total_PD,GM_total_R1,GM_total_Nvox
    %       GM_R_Vol    ,GM_R_R2s    ,GM_R_MT    ,GM_R_PD    ,GM_R_R1    ,GM_R_Nvox
    %       GM_L_Vol    ,GM_L_R2s    ,GM_L_MT    ,GM_L_PD    ,GM_L_R1    ,GM_L_Nvox
    %       WM_total_Vol,WM_total_R2s,WM_total_MT,WM_total_PD,WM_total_R1,WM_total_Nvox
    %       WM_R_Vol    ,WM_R_R2s    ,WM_R_MT    ,WM_R_PD    ,WM_R_R1    ,WM_R_Nvox
    %       WM_L_Vol    ,WM_L_R2s    ,WM_L_MT    ,WM_L_PD    ,WM_L_R1    ,WM_L_Nvox];
    Globals_Table(2:end,2:end) = mat2cell(GT,ones(size(GT,1),1),ones(size(GT,2),1)); %#ok
    
    XLS_Table = vertcat(XLS_Table,Globals_Table(2:end,:));  % Table with all MPMs plus structures volumes.
else
    XLS_Table=XLS_Table(:,1:2); % Taking only name of the structures and volume.
end;

if strcmpi(TableFormat,'xls')
    xlswrite(OutputCSVFile,XLS_Table,'Data');
else
    cell2csv(OutputCSVFile,XLS_Table,','); % Case for TableFormat = 'csv';
end;
%xlswrite(OutputCSVFile,Globals_Table,'Globals');
%xlswrite(OutputCSVFile,ICV_Table,'ICV');

end


%%  ======== Internal Functions ======== %%
function [StructNames,StructCodes] = getNeuromorphoAtlasInfo

StructNames = {'3rd Ventricle'
    '4th Ventricle'
    'Right Accumbens Area'
    'Left Accumbens Area'
    'Right Amygdala'
    'Left Amygdala'
    'Brain Stem'
    'Right Caudate'
    'Left Caudate'
    'Right Cerebellum Exterior'
    'Left Cerebellum Exterior'
    'Right Cerebellum WM'
    'Left Cerebellum WM'
    'Right Cerebral WM'
    'Left Cerebral WM'
    'CSF'
    'Right Hippocampus'
    'Left Hippocampus'
    'Right Inf Lat Vent'
    'Left Inf Lat Vent'
    'Right Lateral Ventricle'
    'Left Lateral Ventricle'
    'Right Pallidum'
    'Left Pallidum'
    'Right Putamen'
    'Left Putamen'
    'Right Thalamus Proper'
    'Left Thalamus Proper'
    'Right Ventral DC'
    'Left Ventral DC'
    'Right vessel'
    'Left vessel'
    'Optic Chiasm'
    'Cerebellar VL I-V'
    'Cerebellar VL VI-VII'
    'Cerebellar VL VIII-X'
    'Left Basal Forebrain'
    'Right Basal Forebrain'
    'Right AcgG'
    'Left ACgG'
    'Right AIns'
    'Left Ains'
    'Right AorG'
    'Left AorG'
    'Right AnG'
    'Left AnG'
    'Right Calc'
    'Left Calc'
    'Right CO'
    'Left CO'
    'Right Cun'
    'Left Cun'
    'Right Ent'
    'Left Ent'
    'Right FO'
    'Left FO'
    'Right FRP'
    'Left FRP'
    'Right FuG'
    'Left FuG'
    'Right Gre'
    'Left Gre'
    'Right IOG'
    'Left IOG'
    'Right ITG'
    'Left ITG'
    'Right LiG'
    'Left LiG'
    'Right LorG'
    'Left LorG'
    'Right McgG'
    'Left McgG'
    'Right MFC'
    'Left MFC'
    'Right MFG'
    'Left MFG'
    'Right MOG'
    'Left MOG'
    'Right MorG'
    'Left MorG'
    'Right MpoG'
    'Left MpoG'
    'Right MprG'
    'Left MprG'
    'Right MSFG'
    'Left MSFG'
    'Right MTG'
    'Left MTG'
    'Right OCP'
    'Left OCP'
    'Right OfuG'
    'Left OfuG'
    'Right OpIFG'
    'Left OpIFG'
    'Right OrIFG'
    'Left OrIFG'
    'Right PcgG'
    'Left PcgG'
    'Right Pcu'
    'Left Pcu'
    'Right PHG'
    'Left PHG'
    'Right Pins'
    'Left Pins'
    'Right PO'
    'Left PO'
    'Right PoG'
    'Left PoG'
    'Right PorG'
    'Left PorG'
    'Right PP'
    'Left PP'
    'Right PrG'
    'Left PrG'
    'Right PT'
    'Left PT'
    'Right SCA'
    'Left SCA'
    'Right SFG'
    'Left SFG'
    'Right SMC'
    'Left SMC'
    'Right SMG'
    'Left SMG'
    'Right SOG'
    'Left SOG'
    'Right SPL'
    'Left SPL'
    'Right STG'
    'Left STG'
    'Right TMP'
    'Left TMP'
    'Right TrIFG'
    'Left TrIFG'
    'Right TTG'
    'Left TTG'};

StructCodes = {4;11;23;30;31;32;35;36;37;38;39;40;41;44;45;46;47;48;49;50;51;52;55;56;57;58;59;60;61;62;63;64;69;71; ...
               72;73;75;76;100;101;102;103;104;105;106;107;108;109;112;113;114;115;116;117;118;119;120;121;122;123;  ...
               124;125;128;129;132;133;134;135;136;137;138;139;140;141;142;143;144;145;146;147;148;149;150;151;152;  ...
               153;154;155;156;157;160;161;162;163;164;165;166;167;168;169;170;171;172;173;174;175;176;177;178;179;  ...
               180;181;182;183;184;185;186;187;190;191;192;193;194;195;196;197;198;199;200;201;202;203;204;205;206;207};
end

%%
function StructNames = getNeuromorphoWhiteMatter

StructNames = {'Right Cerebral WM';'Left Cerebral WM'};
    
end

%% 
function StructCodes = getStructCodes(FullStructNames,FullStructCodes,InputStructNames)

N = length(InputStructNames);
StructCodes = cell(N,1);
for i=1:N
    StructCodes{i} = FullStructCodes(ismember(FullStructNames,InputStructNames(i))); 
end;

end
%%
function StructNames = get_GraymatterNeuromorphoAtlasInfo

StructNames = {'Right Accumbens Area'
    'Left Accumbens Area'
    'Right Amygdala'
    'Left Amygdala'
    'Right Caudate'
    'Left Caudate'
    'Right Hippocampus'
    'Left Hippocampus'
    'Right Pallidum'
    'Left Pallidum'
    'Right Putamen'
    'Left Putamen'
    'Right Thalamus Proper'
    'Left Thalamus Proper'
    'Right Ventral DC'
    'Left Ventral DC'
    'Left Basal Forebrain'
    'Right Basal Forebrain'
    'Right AcgG'
    'Left ACgG'
    'Right AIns'
    'Left Ains'
    'Right AorG'
    'Left AorG'
    'Right AnG'
    'Left AnG'
    'Right Calc'
    'Left Calc'
    'Right CO'
    'Left CO'
    'Right Cun'
    'Left Cun'
    'Right Ent'
    'Left Ent'
    'Right FO'
    'Left FO'
    'Right FRP'
    'Left FRP'
    'Right FuG'
    'Left FuG'
    'Right Gre'
    'Left Gre'
    'Right IOG'
    'Left IOG'
    'Right ITG'
    'Left ITG'
    'Right LiG'
    'Left LiG'
    'Right LorG'
    'Left LorG'
    'Right McgG'
    'Left McgG'
    'Right MFC'
    'Left MFC'
    'Right MFG'
    'Left MFG'
    'Right MOG'
    'Left MOG'
    'Right MorG'
    'Left MorG'
    'Right MpoG'
    'Left MpoG'
    'Right MprG'
    'Left MprG'
    'Right MSFG'
    'Left MSFG'
    'Right MTG'
    'Left MTG'
    'Right OCP'
    'Left OCP'
    'Right OfuG'
    'Left OfuG'
    'Right OpIFG'
    'Left OpIFG'
    'Right OrIFG'
    'Left OrIFG'
    'Right PcgG'
    'Left PcgG'
    'Right Pcu'
    'Left Pcu'
    'Right PHG'
    'Left PHG'
    'Right Pins'
    'Left Pins'
    'Right PO'
    'Left PO'
    'Right PoG'
    'Left PoG'
    'Right PorG'
    'Left PorG'
    'Right PP'
    'Left PP'
    'Right PrG'
    'Left PrG'
    'Right PT'
    'Left PT'
    'Right SCA'
    'Left SCA'
    'Right SFG'
    'Left SFG'
    'Right SMC'
    'Left SMC'
    'Right SMG'
    'Left SMG'
    'Right SOG'
    'Left SOG'
    'Right SPL'
    'Left SPL'
    'Right STG'
    'Left STG'
    'Right TMP'
    'Left TMP'
    'Right TrIFG'
    'Left TrIFG'
    'Right TTG'
    'Left TTG'};
end


%% function filesf = pickfiles(directory0,filtand,filtor)
function filesf = pickfiles(directory0,filtand,filtor)

filesf = '';
if iscell(directory0), directory0 = strvcat(directory0{:}); end
for d = 1:size(directory0,1),
    directory = deblank(directory0(d,:));
    if iscell(filtand), filtand = strvcat(filtand{:}); end
    if nargin == 3 && iscell(filtor),
        filtor = strvcat(filtor{:}); end
    files = get_all(directory); ind = [];
    for file = 1:size(files,1),
        for i = 1:size(filtand,1)
            chkand(i) = ~isempty(findstr(deblank(files(file,:)),...
                [deblank(filtand(i,:))]));
        end
        if nargin == 3,
            for i = 1:size(filtor,1)
                chkor(i) = ~isempty(findstr(deblank(files(file,:)),...
                    [deblank(filtor(i,:))]));
            end
        else, chkor = true;
        end
        if all([all(chkand) any(chkor)]), ind = [ind file]; end
    end
    filesf = strvcat(filesf,files(ind,:));
end
end

%% function files = get_all(directory)
function files = get_all(directory)

% Pick all files in a folder
% Pedro A Valdes-Hernandez 

directory = deblank(directory);
list = dirall(directory);
for i = 1:length(list),
    if ~list(i).isdir, 
        files{i} = list(i).name;
    end
end
if ~isempty(list)
    files = strvcat(files{:});
else files = []; end
end

%% function list = dirall(folder,level)
function list = dirall(folder,level)

list = dir(folder); list([1 2]) = [];
for i = 1:length(list), 
    list(i).name = sprintf('%s%s%s',folder,filesep,list(i).name);
end
if nargin == 2 && level == 1, return; end
for i = 1:length(list),
    if list(i).isdir,
        switch nargin
            case 1
                newlist = dirall(list(i).name);
            case 2
                newlist = dirall(list(i).name,level-1);
        end
        list = [list; newlist];
    end
end
end

%% function cell2csv(fileName, cellArray, separator, excelYear, decimal)
function cell2csv(fileName, cellArray, separator, excelYear, decimal)
% % Writes cell array content into a *.csv file.
% % 
% % CELL2CSV(fileName, cellArray[, separator, excelYear, decimal])
% %
% % fileName     = Name of the file to save. [ e.g. 'text.csv' ]
% % cellArray    = Name of the Cell Array where the data is in
% % 
% % optional:
% % separator    = sign separating the values (default = ',')
% % excelYear    = depending on the Excel version, the cells are put into
% %                quotes before they are written to the file. The separator
% %                is set to semicolon (;)  (default = 1997 which does not change separator to semicolon ;)
% % decimal      = defines the decimal separator (default = '.')
% %
% %         by Sylvain Fiedler, KA, 2004
% % updated by Sylvain Fiedler, Metz, 06
% % fixed the logical-bug, Kaiserslautern, 06/2008, S.Fiedler
% % added the choice of decimal separator, 11/2010, S.Fiedler
% % modfiedy and optimized by Jerry Zhu, June, 2014, jerryzhujian9@gmail.com
% % now works with empty cells, numeric, char, string, row vector, and logical cells. 
% % row vector such as [1 2 3] will be separated by two spaces, that is "1  2  3"
% % One array can contain all of them, but only one value per cell.
% % 2x times faster than Sylvain's codes (8.8s vs. 17.2s):
% % tic;C={'te','tm';5,[1,2];true,{}};C=repmat(C,[10000,1]);cell2csv([datestr(now,'MMSS') '.csv'],C);toc;

%% Checking for optional Variables
if ~exist('separator', 'var')
    separator = ',';
end

if ~exist('excelYear', 'var')
    excelYear = 1997;
end

if ~exist('decimal', 'var')
    decimal = '.';
end

%% Setting separator for newer excelYears
if excelYear > 2000
    separator = ';';
end

% convert cell
cellArray = cellfun(@StringX, cellArray, 'UniformOutput', false);

%% Write file
datei = fopen(fileName, 'w');
[nrows,ncols] = size(cellArray);
for row = 1:nrows
    fprintf(datei,[sprintf(['%s' separator],cellArray{row,1:ncols-1}) cellArray{row,ncols} '\n']);
end    
% Closing file
fclose(datei);

% sub-function
function x = StringX(x)
    % If zero, then empty cell
    [nrx,ncx] = size(x);
    isrowx = (nrx==1)&&(ncx>=1);
    if isempty(x)
        x = '';
    % If numeric -> String, e.g. 1, [1 2]
    elseif isnumeric(x) && isrow(x)
        x = num2str(x);
        if decimal ~= '.'
            x = strrep(x, '.', decimal);
        end
    % If logical -> 'true' or 'false'
    elseif islogical(x)
        if x == 1
            x = 'TRUE';
        else
            x = 'FALSE';
        end
    % If matrix array -> a1 a2 a3. e.g. [1 2 3]
    % also catch string or char here
    %elseif (isrowx) && ~iscell(x)
    elseif isrow(x) && ~iscell(x)
        x = num2str(x);
    % everthing else, such as [1;2], {1}
    else
        x = 'NA';
    end

    % If newer version of Excel -> Quotes 4 Strings
    if excelYear > 2000
        x = ['"' x '"'];
    end
end % end sub-function
end % end function