function copyFolders(SourceFolder,TargetFolder,SubjIDs)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, March 22nd, 2016

if ~strcmp(SourceFolder(end),filesep)
     SourceFolder = [SourceFolder,filesep];
end;
if ~strcmp(TargetFolder(end),filesep)
     TargetFolder = [TargetFolder,filesep];
end;
if exist('SubjIDs','var')
    if ~iscell(SubjIDs)
        SubjIDs = textread(SubjIDs,'%s'); %#ok
    end;
    Ns = length(SubjIDs);    
    for i=1:Ns
        disp(['Copying Subject : ',SubjIDs{i},'--> ',num2str(i),' of ',num2str(Ns)]);
        Subj_SourceFolder = [SourceFolder,SubjIDs{i}];
        Subj_TargetSubFolder = [TargetFolder,SubjIDs{i}];
        if ~exist(Subj_TargetSubFolder,'dir')
            mkdir(Subj_TargetSubFolder);
        end;
        if exist(Subj_SourceFolder,'dir')&&exist(Subj_TargetSubFolder,'dir')
            copyfile(Subj_SourceFolder,Subj_TargetSubFolder);
        end;
    end;
else
    if exist(SourceFolder,'dir')&&exist(TargetFolder,'dir')
        copyfile(SourceFolder,TargetFolder);
    end; 
end;

end