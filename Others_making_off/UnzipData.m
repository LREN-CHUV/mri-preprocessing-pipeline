function UnzipData(InputFolder,OutPutFolder)

%% Lester Melie-Garcia
% LREN, Lausanne 
% February 13st, 2015

if strcmp(InputFolder(end),filesep)
    InputFolder = InputFolder(1:end-1);
end;

ZipFiles = pickfiles(InputFolder,'.zip');
NFiles = size(ZipFiles,1);
for i=432:NFiles
    if i~=16
        [~,FileName] = fileparts(ZipFiles(i,:));
        disp(['Unziping Data: ',FileName,' , ',num2str(i),' of ',num2str(NFiles)]);
        unzip(ZipFiles(i,:),OutPutFolder);
    end;
end;

disp('Unziping Process  DONE !!');

end
