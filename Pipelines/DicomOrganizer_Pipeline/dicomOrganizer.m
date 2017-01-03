function success = dicomOrganizer(InputFolder,OutputFolder,SubjectID,DataStructure)

% Input Parameters:
%    InputFolder  :  General Folder with disorganized data. Each subfolder in this Folder will contain from one subject.
%    OutputFolder :  Folder where the organized data will be saved.
%
%% Lester Melie-Garcia
% LREN, CHUV.
% Lausanne, October 10th, 2014

success = -1;

s = which('Dicomymizer.jar');
if  ~isempty(s)
    JAVA_Library_path = fileparts(s);
else
    disp('Please add JAVA Library : Dicomymizer.jar  in the path .... ');
    return;
end;

if ~strcmpi(JAVA_Library_path(end),filesep)
    JAVA_Library_path = [JAVA_Library_path,filesep];
end;

javaaddpath(JAVA_Library_path);

if ~strcmpi(InputFolder(end),filesep)
    InputFolder = [InputFolder,filesep];
end;

if ~exist('DataStructure','var')
    DataStructure = 'PatientID:StudyID:ProtocolName:SeriesNumber';
end

SubjectFolder = [InputFolder, SubjectID, filesep];

Dicom_organizer_one_subject(SubjectFolder,OutputFolder,DataStructure,JAVA_Library_path);

success = 1;

end

%% ========= Internal Functions ========= %%

function Dicom_organizer_one_subject(SubjectInputFolder,OutputFolder,DataStructure,JAVA_Library_path)

%% Lester Melie-Garcia
% LREN, CHUV.
% Lausanne, October 10th, 2014

CommandLine = ['java -jar ',JAVA_Library_path,'Dicomymizer.jar anonymizer -sv -nc -pst -i ',SubjectInputFolder,' -o ',OutputFolder,' -h ', DataStructure ];
system(CommandLine);

end

%%
function FolderNames = getListofFolders(InputFolder,sortflag)


%% Lester Melie-Garcia
% LREN, CHUV.
% Lausanne, May 16th, 2014

DirList = dir(InputFolder);
dirindex = [DirList.isdir];
DirList = DirList(dirindex);
FolderNames = {DirList.name}';
FolderNames = setdiff(FolderNames,{'.';'..'});

if exist('sortflag','var')
    if ~isempty(sortflag)
        if ~any(isnan(str2double(FolderNames)))
            x = str2num(char(FolderNames)); %#ok
            [x,ind] = sort(x); %#ok
            FolderNames = FolderNames(ind);
        else
            Ns = length(FolderNames);
            tz = cell(Ns,1);
            for i=1:Ns
                ind = min(strfind(FolderNames{i},'_'));
                tz{i} = FolderNames{i}(1:ind-1);
            end;
            if ~isempty(str2num(char(tz))) %#ok
                x = str2num(char(tz)); %#ok
                [x,ind] = sort(x); %#ok
                FolderNames = FolderNames(ind);
            end;
        end;
    end;
end;

end
