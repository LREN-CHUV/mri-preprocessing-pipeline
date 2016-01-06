function Subj_IDs = make_list_MRI_studies02(ServerDataFolder,NewOutputXLSFile,OldOutputXLSFile)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, September 30th, 2014

if ~strcmpi(ServerDataFolder(end),filesep)
    ServerDataFolder = [ServerDataFolder,filesep];    
end;

if exist('NewOutputXLSFile','var')
    data_xls{1,1} = 'Subject ID'; data_xls{1,2} = 'Subject Name'; data_xls{1,3} = 'Age';
    data_xls{1,4} = 'Birth Date'; data_xls{1,5} = 'Gender'; data_xls{1,6} = 'Study Description'; data_xls{1,7} = 'Study Date';
    data_xls{1,8} = 'Control (C) / Patient=non Control (P) / Incidental Finding (IC)'; data_xls{1,9} = 'visual check: MPM';
    data_xls{1,10} = 'R2s';data_xls{1,11} = 'R1_m'; data_xls{1,12} = 'PD'; data_xls{1,13} = 'MT_m';data_xls{1,14} = 'c1';
    data_xls{1,15}=  'comments'; data_xls{1,16}= 'Neuropsychological Test (Y/N)'; %data_xls(1,17:22)= cell(1,6);
end;

if exist('OldOutputXLSFile','var')
     [~,~,PreviousXLS_Table] = xlsread(OldOutputXLSFile,'Data');
     if isnan(PreviousXLS_Table{end,1})
         PreviousXLS_Table(end,:) = [];
     end;
     PreviousSubjPRs   = PreviousXLS_Table(2:end,1);
else
     PreviousSubjPRs = {'DontcarewithValue'};
end;

BlackList = {'deleteit';'Phantom2';'Phantomb2300NODDItest';'PhantomDiffusionTest';'SHIRAISHI';'QAtest';'QAfbirn';'QSMPhantom';'B1test'; ...
             'MPMPhantom';'Phantom2_water';'IRsequtest';'Evagain';'Gratio';'test_siemens';'QA_FBIRN';'QAFBIRN';'testphase';'TEST_LIQUID'; ...
             'PMC_MPM';'exv_post-fix-im';'exv_post-fix-im2';'H2O'; 'ACSFcool';'ACSFwarm';'ACSFwarm-h';'exv_post-fix-del'; ...
             'ExvivoPhantomTesting';'PBS';'DELETEIT';'PR';'`DELETEIT'};
r = 1; % Subjects counter
nr = 1; % New Subjects counter
DateFolders = getListofFolders(ServerDataFolder);
for i=1:length(DateFolders)
    InputFolders = getListofFolders([ServerDataFolder,filesep,DateFolders{i}]);
    for j=1:length(InputFolders)
        r = r + 1; disp([num2str(r-1),' -- Collecting Information from Subject : ',InputFolders{j}]);
        Subjs{r-1,1} = InputFolders{j}; %#ok
        Subjs{r-1,2} = [ServerDataFolder,DateFolders{i},filesep,InputFolders{j},filesep]; %#ok        
        if exist('NewOutputXLSFile','var')&&not(ismember(InputFolders(j),PreviousSubjPRs))&&not(ismember(InputFolders(j),BlackList))
            nr = nr + 1;
            SubjectFolder = [ServerDataFolder,DateFolders{i},filesep,InputFolders{j}];
            Subj_SessionFolder = getListofFolders(SubjectFolder);
            SequenceFolder =  getListofFolders([ServerDataFolder,DateFolders{i},filesep,InputFolders{j},filesep,Subj_SessionFolder{1}]);
            RepFolders = getListofFolders([ServerDataFolder,DateFolders{i},filesep,InputFolders{j},filesep,Subj_SessionFolder{1},filesep,SequenceFolder{1}]);
            TargetFolder = [ServerDataFolder,DateFolders{i},filesep,InputFolders{j},filesep,Subj_SessionFolder{1},filesep,SequenceFolder{1},filesep,RepFolders{1},filesep];
            dicom_files = spm_select('FPListRec',TargetFolder,'.*');
            info = dicominfo(dicom_files(1,:));
            data_xls{nr,1} = info.PatientID;
            data_xls{nr,2} = info.PatientName.FamilyName;
            pAge = info.PatientAge;
            data_xls{nr,3} = str2double(pAge(1:end-1));
            xdate = info.PatientBirthDate;
            data_xls{nr,4} = [xdate(7:8),'.',xdate(5:6),'.',xdate(1:4)];
            data_xls{nr,5} = info.PatientSex;
            data_xls{nr,6} = info.StudyDescription;
            xdate = info.StudyDate;
            data_xls{nr,7} = [xdate(7:8),'.',xdate(5:6),'.',xdate(1:4)];
        end;
    end;
end
if nr>1
    disp('New Subjects found: ');
end;
for i=2:nr
    disp(data_xls{i,1});
end;

if exist('NewOutputXLSFile','var')&&not(exist('OldOutputXLSFile','var'))
    xlswrite(NewOutputXLSFile,data_xls, 'Data');
end;

         
if exist('NewOutputXLSFile','var')&&exist('OldOutputXLSFile','var')
     [~,~,PreviousXLS_Table] = xlsread(OldOutputXLSFile,'Data');
     if isnan(PreviousXLS_Table{end,1})
         PreviousXLS_Table(end,:) = [];
     end;
     SubjPRs   = PreviousXLS_Table(2:end,1);
     SubjNames = PreviousXLS_Table(2:end,2);
     NewSubjPRs = data_xls(2:end,1);
     %ind_out = find(ismember(NewSubjPRs,BlackList)) + 1;
     %data_xls(ind_out,:) = [];
     %NewSubjPRs = data_xls(2:end,1);
     NewSubjNames  = data_xls(2:end,2);
     ind = find(not(ismember(NewSubjNames,SubjNames)).*not(ismember(NewSubjPRs,SubjPRs)));
     Table2Add = data_xls(ind+1,:);
     NewXLSTable = vertcat(PreviousXLS_Table,Table2Add);
     [FilePath,NewOutputXLSFile,FileExt] = fileparts(NewOutputXLSFile);
     Str_unique = check_clean_IDs(datestr(now));
     NewOutputXLSFile = [NewOutputXLSFile,'_',Str_unique];
     xlswrite([FilePath,filesep,NewOutputXLSFile,FileExt],NewXLSTable,'Data');
end;

if exist('OutputXLSFile','var')
    if exist(OutputXLSFile,'file')
        delete(OutputXLSFile);
    end;
    xlswrite(OutputXLSFile,data_xls, 'Data');
end;

%% Cleaning the list a little bit ...
% ind = ismember(Subjs(:,1),{'deleteit';'140318~1.660';'140505~1.660';'140502~1.660';'exv_post-fix-im';'exv_post-fix-im2';'H2O'; 'ACSFcool';'ACSFwarm';'ACSFwarm-h';'PBS';'exv_post-fix-del'; ...
%                               '140318~1.660';'ExvivoPhantomTesting'});

ind = ismember(Subjs(:,1),BlackList);
Subjs(ind,:) = [];

[B,I] = unique(Subjs(:,1),'first');
I = sort(I);
Subj_IDs(:,1) = Subjs(sort(I),1);
Subj_IDs(:,2) = Subjs(sort(I),2);

end

%% ======= Internal Functions ======= %%
function IDout = check_clean_IDs(IDin)

IDout= IDin(isstrprop(IDin,'alphanum'));

end
