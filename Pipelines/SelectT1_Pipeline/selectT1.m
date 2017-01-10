function success = selectT1(InputFolder,OutputFolder,SubjectID,ProtocolsFile)

success = -1;

%% output
if  ~exist(OutputFolder,'dir')
    mkdir(OutputFolder);
end;
if ~strcmp(OutputFolder(end),filesep)
    OutputFolder = [OutputFolder,filesep];
end;

%% valid protocols (the ones we keep)
T1_protocol = cellstr(get_protocol_names(ProtocolsFile,'__Dicom2Nifti__','[T1]'));

SessionFolders = getListofFolders([InputFolder,filesep,SubjectID]);
Ns = length(SessionFolders);  % Number of sessions ...
for sf = 1:Ns
    DataFolder = [InputFolder,filesep,SubjectID,filesep,SessionFolders{sf},filesep];
    ProtocolFolders = getListofFolders(DataFolder);
    if ~isempty(ProtocolFolders)
        for i=1:length(ProtocolFolders)
            which_prot = which_protocol(ProtocolFolders{i},T1_protocol);
            switch which_prot
                case {'T1'}
                    InputProtocolFolder = [DataFolder,filesep,ProtocolFolders{i}];
                    OutputProtocolFolder = [OutputFolder,SubjectID,filesep,SessionFolders{sf},filesep,ProtocolFolders{i}];
                    if exist(OutputProtocolFolder,'dir')
                        warning('output protocol folder already exists');
                    else
                        mkdir(OutputProtocolFolder);
                    end
                    copyfile(InputProtocolFolder,OutputProtocolFolder);
            end
        end
    end
end

success = 1;

end


%% function which_prot = which_protocol(FolderName,T1_protocol)
function which_prot = which_protocol(FolderName,T1_protocol)

if ismember(FolderName,T1_protocol)
    which_prot = 'T1';
else
    which_prot = 'other';
end;

end
