function data_xls = Adding_other_MRfields(ServerDataFolder,NewOutputXLSFile,OldOutputXLSFile,ProtocolsFile)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, November 18th, 2015

if ~strcmpi(ServerDataFolder(end),filesep)
    ServerDataFolder = [ServerDataFolder,filesep];    
end;

[~,~,PreviousXLS_Table] = xlsread(OldOutputXLSFile,'Data');

if exist('OldOutputXLSFile','var')
     [~,~,PreviousXLS_Table] = xlsread(OldOutputXLSFile,'Data');
     if isnan(PreviousXLS_Table{end,1})
         PreviousXLS_Table(end,:) = [];
     end;
     PreviousSubjPRs   = PreviousXLS_Table(2:end,1);
else
     PreviousSubjPRs = {'DontcarewithValue'};
end;
data_xls = PreviousXLS_Table;  % New Table ...
Nh = size(data_xls,2);
data_xls{1,Nh+1}= 'fMRI'; data_xls{1,Nh+2}= 'DWI'; data_xls{1,Nh+3}= 'MPRAGE'; 
data_xls{1,Nh+4}= 'MPMs'; data_xls{1,Nh+5}= 'MPM_Resolution'; data_xls{1,Nh+6}= 'List of Sequences';

fMRI_protocols = cellstr(get_protocol_names(ProtocolsFile,'__fMRI__','[EPI]')); % protocol name ..
DWI_protocols  = cellstr(get_protocol_names(ProtocolsFile,'__DWI__','[diffusion]')); % protocol name ..
MT_protocols   = cellstr(get_protocol_names(ProtocolsFile,'__MPM__','[MT]')); % protocol name ..
MT_protocols_Resolution  = cellstr(get_protocol_names(ProtocolsFile,'__MPM__','[Resolution]')); % protocol name ..
MPRAGE_protocols   = cellstr(get_protocol_names(ProtocolsFile,'__MPRAGE__','[MPRAGE]')); % protocol name ..

% BlackList = {'deleteit';'Phantom2';'Phantomb2300NODDItest';'PhantomDiffusionTest';'SHIRAISHI';'QAtest';'QAfbirn';'QSMPhantom';'B1test'; ...
%              'MPMPhantom';'Phantom2_water';'IRsequtest';'Evagain';'Gratio';'test_siemens';'QA_FBIRN';'QAFBIRN';'testphase';'TEST_LIQUID'; ...
%              'PMC_MPM';'exv_post-fix-im';'exv_post-fix-im2';'H2O'; 'ACSFcool';'ACSFwarm';'ACSFwarm-h';'exv_post-fix-del'; ...
%              'ExvivoPhantomTesting';'PBS';'DELETEIT';'PR';'`DELETEIT'};
r = 1; % Subjects counter
YesLabel = {'Yes'}; NoLabel = {'No'};

DateFolders = getListofFolders(ServerDataFolder);
for i=1:length(DateFolders)
    InputFolders = getListofFolders([ServerDataFolder,filesep,DateFolders{i}]);
    for j=1:length(InputFolders)
        r = r + 1; disp([num2str(r-1),' -- Collecting Information from Subject : ',InputFolders{j}]);
        Subjs{r-1,1} = InputFolders{j}; %#ok
        Subjs{r-1,2} = [ServerDataFolder,DateFolders{i},filesep,InputFolders{j},filesep]; %#ok        
        if ismember(InputFolders(j),PreviousSubjPRs)
            SubjectFolder = [ServerDataFolder,DateFolders{i},filesep,InputFolders{j}];
            Subj_SessionFolder = getListofFolders(SubjectFolder); 
            Nsession = length(Subj_SessionFolder);
            SubjSequencesList = {};
            for t=1:Nsession
                SubjSequencesList = vertcat(SubjSequencesList,getListofFolders([ServerDataFolder,DateFolders{i},filesep,InputFolders{j},filesep,Subj_SessionFolder{t}]));                
            end;
            SubjSequencesList = unique(SubjSequencesList);
            ExistfMRI = ismember(fMRI_protocols,SubjSequencesList);
            ExistDWI = ismember(DWI_protocols,SubjSequencesList);
            ExistMPRAGE = ismember(MPRAGE_protocols,SubjSequencesList);
            ExistMPM = ismember(MT_protocols,SubjSequencesList);
            if any(ExistMPM)
                MPM_resolutions = unique(MT_protocols_Resolution(ExistMPM));                
                if length(MPM_resolutions)>1
                    ResLabel = MPM_resolutions{1};
                    for ttt=2:length(MPM_resolutions)
                        ResLabel = [ResLabel,', ',MPM_resolutions{ttt}];
                    end;
                else
                    ResLabel = MPM_resolutions{1};
                end;
            else
                ResLabel = 'No';
            end;
            if length(SubjSequencesList)>1
                SequencesLabel = SubjSequencesList{1};
                for ttt=2:length(SubjSequencesList)
                    SequencesLabel = [SequencesLabel,',',SubjSequencesList{ttt}];
                end;
            else
                SequencesLabel = SubjSequencesList{1};
            end;
            %% Filling the new information in the Table ...
            ind = find(ismember(PreviousSubjPRs,InputFolders(j)))+1;
            if any(ExistfMRI)  % fMRI
                data_xls(ind,Nh+1)= YesLabel;
            else
                data_xls(ind,Nh+1)= NoLabel;
            end;
            if any(ExistDWI)  % DWI
                data_xls(ind,Nh+2)= YesLabel;
            else
                data_xls(ind,Nh+2)= NoLabel;
            end;
            if any(ExistMPRAGE)  % MPRAGE
                data_xls(ind,Nh+3)= YesLabel;
            else
                data_xls(ind,Nh+3)= NoLabel;
            end;
             if any(ExistMPM)  % MPMs
                data_xls(ind,Nh+4)= YesLabel;                
            else
                data_xls(ind,Nh+4)= NoLabel;
            end;
            data_xls(ind,Nh+5)= {ResLabel};
            data_xls(ind,Nh+6)= {SequencesLabel};
        end;
    end;
end
[FilePath,NewOutputXLSFile,FileExt] = fileparts(NewOutputXLSFile);
Str_unique = check_clean_IDs(datestr(now));
NewOutputXLSFile = [NewOutputXLSFile,'_',Str_unique];
xlswrite([FilePath,filesep,NewOutputXLSFile,FileExt],data_xls,'Data');

end


%% ======= Internal Functions ======= %%
function IDout = check_clean_IDs(IDin)

IDout= IDin(isstrprop(IDin,'alphanum'));

end