function Subj_IDs = make_list_MRI_studies_fMRI_dropout(ServerDataFolder,OutputXLSFile)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, November 23rd, 2015

if ~strcmpi(ServerDataFolder(end),filesep)
    ServerDataFolder = [ServerDataFolder,filesep];    
end;

if exist('OutputXLSFile','var')
    data_xls{1,1} = 'Subject ID'; data_xls{1,2} = 'Subject Name'; data_xls{1,3} = 'Age';
    data_xls{1,4} = 'Birth Date'; data_xls{1,5} = 'Gender'; data_xls{1,6} = 'Study Description'; data_xls{1,7} = 'Study Date';
end;
r = 1; % counter
DateFolders = getListofFolders(ServerDataFolder);
ZZZ = {'al_mepi2d_3mm_dropout'};
for i=1:length(DateFolders)
    InputFolders = getListofFolders([ServerDataFolder,filesep,DateFolders{i}]);
    for j=1:length(InputFolders)
        SubjectFolder = [ServerDataFolder,DateFolders{i},filesep,InputFolders{j}];
        Subj_SessionFolder = getListofFolders(SubjectFolder);
        SequenceFolder =  getListofFolders([ServerDataFolder,DateFolders{i},filesep,InputFolders{j},filesep,Subj_SessionFolder{1}]);
        if ismember(ZZZ,SequenceFolder)
            r = r + 1; disp([num2str(r-1),' -- Collecting Information from Subject : ',InputFolders{j}]);
            Subjs{r-1,1} = InputFolders{j}; %#ok
            Subjs{r-1,2} = [ServerDataFolder,DateFolders{i},filesep,InputFolders{j},filesep]; %#ok
            if exist('OutputXLSFile','var')                
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
            end;
        end;
    end;
end

if exist('OutputXLSFile','var')
    if exist(OutputXLSFile,'file')
        delete(OutputXLSFile);
    end;
    xlswrite(OutputXLSFile,data_xls, 'Data');
end;

%% Cleaning the list a little bit ...
ind = ismember(Subjs(:,1),{'deleteit';'140318~1.660';'140505~1.660';'140502~1.660';'exv_post-fix-im';'exv_post-fix-im2';'H2O'; 'ACSFcool';'ACSFwarm';'ACSFwarm-h';'PBS';'exv_post-fix-del'; ...
                              '140318~1.660';'ExvivoPhantomTesting'});

Subjs(ind,:) = [];

[B,I] = unique(Subjs(:,1),'first');
I = sort(I);
Subj_IDs(:,1) = Subjs(sort(I),1);
Subj_IDs(:,2) = Subjs(sort(I),2);

end