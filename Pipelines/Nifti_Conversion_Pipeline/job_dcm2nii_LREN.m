function job_dcm2nii_LREN(InputDataFolder,OutputFolder,datatype,dcm2niiProgram)

% This function convert the dicom/Philips PAR/REC files to Nifti format using
% dcm2nii tool developed by Chris Rorden.
% Webpage: http://www.mccauslandcenter.sc.edu/mricro/mricron/dcm2nii.html
%
%% Input Parameters
%    InputDataFolder : Folder with dicom/par/rec files.
%    OutputFolder : Folder where the converted files will be saved.
%    datatype: type of data to be converted : DTI, fMRI, T1, ASL.
%    dcm2niiProgram: optional, full path to dcm2nii tool
%
%% Lester Melie-Garcia
% Bern, November 10th, 2013
% Modified from job_dcm2nii.m program : Lausanne June 3th, 2014

if isempty(dcm2niiProgram)
    if isunix
        dcm2niiProgram = which('dcm2nii');
    else
        dcm2niiProgram = which('dcm2nii.exe');
    end;
end;
if exist('InputDataFolder','var')
    if isempty(InputDataFolder)
        InputDataFolder = spm_select([1,Inf],'dir','Loading Dicom Data Folders ....','',dir);
    end;
else
    InputDataFolder = spm_select([1,Inf],'dir','Loading Dicom Data Folders ....','',dir);
end;
if exist('OutputFolder','var')
    if isempty(InputDataFolder)
        OutputFolder = spm_select(1,'dir','Loading Output Folders ....','',dir);
    end;
else
    OutputFolder = spm_select(1,'dir','Loading Output Folders ....','',dir);
end;
if exist('datatype','var')
    if isempty(datatype)
        datatype = 'DTI';
    end;
else
    datatype = 'DTI';
end;
if ~isempty(dcm2niiProgram)
    if ~strcmpi(OutputFolder(end),filesep)
        OutputFolder=[OutputFolder,filesep];
    end;
    %dcm2niiSetup = get_dcm2niiDefaults(InputDataFolder);  OutputFolder
    for j=1:size(InputDataFolder,1)
        dcm2niiSetup = get_dcm2niiDefaults(OutputFolder);
        switch datatype
            case 'DTI'
                dcm2niiSetup.fourD=1;
            case 'fMRI'
                dcm2niiSetup.fourD=1;
            case 'T1'
                dcm2niiSetup.fourD=0;
                dcm2niiSetup.Swizzle4D=1;
            case 'ASL'
                dcm2niiSetup.fourD=0;
        end;
        dcm2niiSetup.OutDir = OutputFolder;
        Dcm2niiIniFile=saveIniFile(dcm2niiSetup);

        ParRec1 = pickfiles(InputDataFolder(j,:),'.rec');
        ParRec2 = pickfiles(InputDataFolder(j,:),'.REC');
        isParRec = (~isempty(ParRec1))||(~isempty(ParRec2));
        if isParRec
            InputDataFolder = '';
            for i=1:size(ParRec1,1)
                InputDataFolder = [InputDataFolder(j,:),' ',ParRec1(i,:)];
            end;
            for i=1:size(ParRec2,1)
                InputDataFolder = [InputDataFolder(j,:),' ',ParRec2(i,:)];
            end;
        end;
        InputDataDir = deblank(InputDataFolder(j,:));
        if strcmp(InputDataDir(end),filesep)
            InputDataDir = InputDataDir(1:end-1);
        end;
        dcm2niiCommand=['"',dcm2niiProgram,'"',' -b ','"',Dcm2niiIniFile,'"',' -o ','"',OutputFolder,'"',' ','"',InputDataDir,'"']; %FileListCmd];
        system(dcm2niiCommand);
        delete(Dcm2niiIniFile);
        toDel_o = dir(fullfile(OutputFolder, strcat('o*.nii')));  %remove extra output images if exists
        toDel_co = dir(fullfile(OutputFolder, strcat('co*.nii'))); %remove extra output images if exists
        toDel = [toDel_o; toDel_co];
        files2Delete = {toDel.name}';
        for del_files = 1:size(files2Delete)
            delete(strcat(OutputFolder,files2Delete{del_files}));
        end
    end;
else
    disp('Program dcm2nii not defined in the path ...');
    return;
end;

return;

%% =========   Internal Functions   ========= %%
%% dcm2niiSetup = get_dcm2niiDefaults(InputDataFolder)
function dcm2niiSetup = get_dcm2niiDefaults(OutputFolder)

%% [BOOL]
dcm2niiSetup.DebugMode = 0;
dcm2niiSetup.UntestedFeatures=0;
dcm2niiSetup.UINT16toFLOAT32=1;
dcm2niiSetup.Verbose=0;
dcm2niiSetup.Anonymize=1;
dcm2niiSetup.AnonymizeSourceDICOM=0;
dcm2niiSetup.AppendAcqSeries=1;
dcm2niiSetup.AppendDate=1;
dcm2niiSetup.AppendFilename=0;
dcm2niiSetup.AppendPatientName=0;
dcm2niiSetup.AppendProtocolName=1;
dcm2niiSetup.AutoCrop=0;
dcm2niiSetup.CollapseFolders=1;
dcm2niiSetup.createoutputfolder=0;
dcm2niiSetup.CustomRename=0;
dcm2niiSetup.enablereorient=1;
dcm2niiSetup.OrthoFlipXDim=0;
dcm2niiSetup.EveryFile=1;
dcm2niiSetup.fourD=0;
dcm2niiSetup.Gzip=0;
dcm2niiSetup.ManualNIfTIConv=0;
dcm2niiSetup.PhilipsPrecise=0;
dcm2niiSetup.RecursiveUseNameAppend=0;
dcm2niiSetup.SingleNIIFile=1;
dcm2niiSetup.SPM2=0;
dcm2niiSetup.Stack3DImagesWithSameAcqNum=0;
dcm2niiSetup.Swizzle4D=0;
dcm2niiSetup.UseGE_0021_104F=0;

%% [INT]
dcm2niiSetup.BeginClip=0;
dcm2niiSetup.LastClip=0;
dcm2niiSetup.usePigz=0;
dcm2niiSetup.MaxReorientMatrix=1023;
dcm2niiSetup.MinReorientMatrix=200;
dcm2niiSetup.RecursiveFolderDepth=5;
dcm2niiSetup.OutDirMode=0;
dcm2niiSetup.SiemensDTIUse0019If00181020atleast=15;
dcm2niiSetup.SiemensDTINoAngulationCorrectionIf00181020atleast=1000;
dcm2niiSetup.SiemensDTIStackIf00181020atleast=15;

%% [STR]
dcm2niiSetup.OutDir = OutputFolder;

return; % end function get_dcm2niiDefaults

%% Dcm2niiIniFile = saveIniFile(dcm2niiSetup)
function Dcm2niiIniFile = saveIniFile(dcm2niiSetup)

dcm2niiSetupFileName = 'dcm2niisetupFile.ini';
N = 44;
Text2Save = cell(N,1);

fnames = fieldnames(dcm2niiSetup);
j = 0;
for i=1:N-1
    if i==1
        Text2Save{i}='[BOOL]';
    elseif (i==30)||(i==42)
        Text2Save{i}= ' ';
    elseif i==31
        Text2Save{i}= '[INT]';
    elseif i==43
        Text2Save{i}= '[STR]';
    else
        j = j+1;
        eval(['fieldval=dcm2niiSetup.',fnames{j}]);
        Text2Save{i}=[fnames{j},'=',num2str(fieldval)];
    end;
end;
Text2Save{N}= [fnames{end},'=',dcm2niiSetup.OutDir];

Dcm2niiIniFile = [dcm2niiSetup.OutDir,dcm2niiSetupFileName];

fid = fopen(Dcm2niiIniFile,'w');
for i=1:N
    fprintf(fid,'%s  \r',Text2Save{i});
end;
fclose(fid);

return; % end function saveIniFile
