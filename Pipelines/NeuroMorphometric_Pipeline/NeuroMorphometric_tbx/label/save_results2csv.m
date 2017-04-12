function save_results2csv(VolumeFolder,OutputCSVFile)

%% Input Parameters:
%     VolumeFolder : Folder where volume files (*.txt) were saved during the
%                    NeuroMorphometric Toolbox processing.
%     OutputCSVFile : Full path of the output CSV file where the volume of anatomical structures for all subjects will be saved.
%
%% Lester Melie-Garcia
% LREN, Lausanne
% June 11th, 2015

if ~strcmp(VolumeFolder(end),filesep)
    VolumeFolder = [VolumeFolder,filesep];
end;

VolumeFiles = pickfiles(VolumeFolder(1:end-1),{'.txt'});
Ns = size(VolumeFiles,1);
[StructNames,SCodes] = getNeuromorphoAtlasInfo;
Table_Header = StructNames';
Table_Header = horzcat({'IDs'},Table_Header);
NStruct = length(StructNames);
XLS_Table = cell(Ns+1,NStruct+1);
XLS_Table(1,:) = Table_Header;
SCodes =  cell2mat(SCodes);
for i=1:Ns
    [~,FileName] = fileparts(VolumeFiles(i,:));
    Vols = load(VolumeFiles(i,:)); Vols = Vols(SCodes)';
    Vols = mat2cell(Vols,1,ones(1,NStruct)); %#ok
    XLS_Table{i+1,1} = FileName;
    XLS_Table(i+1,2:end) = Vols;
end;

cell2csv(OutputCSVFile, XLS_Table,',');

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