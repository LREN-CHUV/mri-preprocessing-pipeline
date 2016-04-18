function FileList2 = removeDummies(FileList,FileExt,dummyscans)
% function which removes a dummy scans number (dummyscans) from a EPI
% session (FileList) with FileExt extensions.
%

for sess = 1:length(FileList)
    % folder creation:
    [p n e] = fileparts(FileList{1,sess}{1,1});
    dummyFolderName = strcat(p,filesep,'dummies');
    if ~exist(dummyFolderName)
        mkdir(dummyFolderName);
        
        % move files in dummies folder:
        dummyFiles = strrep(FileList{1,sess}(1:dummyscans,1),p,strcat(p,filesep,'dummies'));
        cellfun(@movefile,FileList{1,sess}(1:dummyscans,1),dummyFiles);
        FileList2{1,sess} = FileList{1,sess}(dummyscans+1:end,1);
        
    else % check if dunmmies already discarded
        
        if isdir(spm_select('ExtFPList',dummyFolderName,['.*' FileExt])) % dummy folder exists and empty, remove dummies
            
            % move files in dummies folder:
            dummyFiles = strrep(FileList{1,sess}(1:dummyscans,1),p,strcat(p,filesep,'dummies'));
            cellfun(@movefile,FileList{1,sess}(1:dummyscans,1),dummyFiles);
            FileList2{1,sess} = FileList{1,sess}(dummyscans+1:end,1);
        
        elseif dummyscans ~= length(cellstr(spm_select('ExtFPList',dummyFolderName,['.*' FileExt]))) 
            
            error('Dummy scans previously discarded and not equal to the number of dummies specified.');
            
        else
            FileList2{1,sess} = FileList{1,sess};
        end
        
    end
end

end