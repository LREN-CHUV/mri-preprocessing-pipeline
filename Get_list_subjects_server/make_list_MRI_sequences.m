function sequences_list = make_list_MRI_sequences(ServerDataFolder)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, July 8th, 2014

if ~exist('ServerDataFolder','var')
    ServerDataFolder = 'K:\IRMMP16\prisma\2014\';
end;
if ~strcmpi(ServerDataFolder(end),filesep)
    ServerDataFolder = [ServerDataFolder,filesep];    
end;

r = 1; % Subjects counter
DateFolders = getListofFolders(ServerDataFolder);
sequences_list = {};
for i=1:length(DateFolders)
    InputFolders = getListofFolders([ServerDataFolder,filesep,DateFolders{i}]);
    for j=1:length(InputFolders)
        r = r + 1; disp([num2str(r-1),' -- Collecting Information from Subject : ',InputFolders{j}]);
        Subj_SessionFolder = getListofFolders([ServerDataFolder,DateFolders{i},filesep,InputFolders{j}]);
        for k=1:length(Subj_SessionFolder)
            SequenceFolder =  getListofFolders([ServerDataFolder,DateFolders{i},filesep,InputFolders{j},filesep,Subj_SessionFolder{k}]);
            sequences_list = vertcat(sequences_list,SequenceFolder); %#ok
        end;
    end;
end

sequences_list = unique(sequences_list);

end

%% ======= Internal Functions ======= %%
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

