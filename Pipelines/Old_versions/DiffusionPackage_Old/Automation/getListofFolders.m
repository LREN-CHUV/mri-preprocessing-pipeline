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
return;

