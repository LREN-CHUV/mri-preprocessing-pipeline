clear;
SubjFolder = 'D:\Users DATA\Users\lester\AAA_Case_198_Repeated\PR00198_MS120488_the194';
Images = pickfiles(SubjFolder,{filesep});

Ns = size(Images,1);
OldPR = 'PR00198';
NewPR = 'PR00194'; Nchar =  length(OldPR);
for i=1:Ns
    disp(['Renaming File : ',num2str(i),' of ',num2str(Ns)]);
    [FilePath,FileName,FileExt] =  fileparts(Images(i,:));
    ind = strfind(FileName,OldPR);
    if ~isempty(ind)
        NewFileName = FileName;
        NewFileName(ind:ind+Nchar-1)=NewPR;
        NewFile = [FilePath,filesep,NewFileName,FileExt];
        movefile(Images(i,:),NewFile);
    end;
end;