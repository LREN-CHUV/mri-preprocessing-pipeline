function isReady = is_ready4MPMs(SubjectFolder,ProtocolsFile,doUNICORT)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, January 21st, 2015

if ~strcmpi(SubjectFolder(end),filesep)
    SubjectFolder = [SubjectFolder,filesep];    
end;
RawSession_Folders = getListofFolders(SubjectFolder);
Ns_t = length(RawSession_Folders);  % Number of sessions ...
Nprot_t = zeros(Ns_t,1);
for i=1:Ns_t
    Nprot_t(i) = get_valid_MPM_Protocols(ProtocolsFile,[SubjectFolder,RawSession_Folders{i},filesep],doUNICORT); % Number of protocols
end;

isReady = sum(Nprot_t)>0;

end