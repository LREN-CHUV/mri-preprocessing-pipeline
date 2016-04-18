function [Nprot,B0_p,B1_p,MT_p,PD_p,T1_p] = get_valid_MPM_Protocols(ProtocolsFile,DataFolder,doUNICORT)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, October 2nd, 2014

if ~strcmpi(DataFolder(end),filesep)
    DataFolder = [DataFolder,filesep];    
end;
if ~exist('doUNICORT','var')
    doUNICORT = false;
end;

B0_p = cellstr(get_protocol_names(ProtocolsFile,'__MPM__','[fieldmap]'));
B1_p = cellstr(get_protocol_names(ProtocolsFile,'__MPM__','[B1]'));
MT_p = cellstr(get_protocol_names(ProtocolsFile,'__MPM__','[MT]'));
PD_p = cellstr(get_protocol_names(ProtocolsFile,'__MPM__','[PD]'));
T1_p = cellstr(get_protocol_names(ProtocolsFile,'__MPM__','[T1]'));

SubjectProtocols = getListofFolders(DataFolder);

if ~doUNICORT
    ind_prot = ismember(PD_p,SubjectProtocols) &  ismember(T1_p,SubjectProtocols) &  ismember(MT_p,SubjectProtocols) & ...
               ismember(B0_p,SubjectProtocols) &  ismember(B1_p,SubjectProtocols);
else
    ind_prot = ismember(PD_p,SubjectProtocols) &  ismember(T1_p,SubjectProtocols) &  ismember(MT_p,SubjectProtocols); 
end;
%temp = [ismember(PD_p,SubjectProtocols),ismember(T1_p,SubjectProtocols),ismember(MT_p,SubjectProtocols),ismember(B0_p,SubjectProtocols),ismember(B1_p,SubjectProtocols)];
    
ind_prot =  find(ind_prot);
if ~isempty(ind_prot)
    if ~doUNICORT
        B0_p = B0_p(ind_prot); B1_p = B1_p(ind_prot);
    end;
    MT_p = MT_p(ind_prot); PD_p = PD_p(ind_prot);
    T1_p = T1_p(ind_prot);
    [~,ind_prot] = unique(MT_p,'first'); % Checking for repeated MT protocols ..
    ind_prot = sort(ind_prot);
    if ~doUNICORT
        B0_p = B0_p(ind_prot); B1_p = B1_p(ind_prot);
    else
        B0_p = cell(length(ind_prot),1); B1_p = cell(length(ind_prot),1);
    end;
    MT_p = MT_p(ind_prot); PD_p = PD_p(ind_prot);
    T1_p = T1_p(ind_prot);
else
    B0_p = {}; B1_p = {}; MT_p = {}; PD_p ={}; T1_p ={};   
end;

Nprot = length(ind_prot);

end