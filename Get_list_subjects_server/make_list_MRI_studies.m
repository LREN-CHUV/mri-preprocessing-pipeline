function data_xls = make_list_MRI_studies(ServerDataFolder,OutputXLSFile)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, July 8th, 2014

if ~strcmpi(ServerDataFolder(end),filesep)
    ServerDataFolder = [ServerDataFolder,filesep];    
end;

data_xls{1,1} = 'Subject ID'; data_xls{1,2} = 'Subject Name'; data_xls{1,3} = 'Age'; 
data_xls{1,4} = 'Birth Date'; data_xls{1,5} = 'Gender'; data_xls{1,6} = 'Study Description'; data_xls{1,7} = 'Study Date';
data_xls{1,8} = 'Subject Folder';
r = 1; % Subjects counter
DateFolders = getListofFolders(ServerDataFolder);
for i=1:length(DateFolders)
    InputFolders = getListofFolders([ServerDataFolder,filesep,DateFolders{i}]);
    for j=1:length(InputFolders)
        r = r + 1; disp([num2str(r-1),' -- Collecting Information from Subject : ',InputFolders{j}]);
        SubjectFolder = [ServerDataFolder,DateFolders{i},filesep,InputFolders{j}];
        Subj_SessionFolder = getListofFolders(SubjectFolder);
        SequenceFolder =  getListofFolders([ServerDataFolder,DateFolders{i},filesep,InputFolders{j},filesep,Subj_SessionFolder{1}]);
        RepFolders = getListofFolders([ServerDataFolder,DateFolders{i},filesep,InputFolders{j},filesep,Subj_SessionFolder{1},filesep,SequenceFolder{1}]);
        TargetFolder = [ServerDataFolder,DateFolders{i},filesep,InputFolders{j},filesep,Subj_SessionFolder{1},filesep,SequenceFolder{1},filesep,RepFolders{1},filesep];
        dicom_files = spm_select('FPListRec',TargetFolder,'.*');
        info = dicominfo(dicom_files(1,:));        
        data_xls{r,1} = info.PatientID; 
        data_xls{r,2} = info.PatientName.FamilyName;
        pAge = info.PatientAge;
        data_xls{r,3} = str2double(pAge(1:end-1));
        xdate = info.PatientBirthDate;
        data_xls{r,4} = [xdate(7:8),'.',xdate(5:6),'.',xdate(1:4)];
        data_xls{r,5} = info.PatientSex;
        data_xls{r,6} = info.StudyDescription;
        xdate = info.StudyDate;
        data_xls{r,7} = [xdate(7:8),'.',xdate(5:6),'.',xdate(1:4)];
        data_xls{r,8} = [ServerDataFolder,DateFolders{i},filesep,InputFolders{j}];
    end;
end

if exist('OutputXLSFile','var')
    if exist(OutputXLSFile,'file')
        delete(OutputXLSFile);
    end;
    xlswrite(OutputXLSFile,data_xls, 'Data');
end;

end