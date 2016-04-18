function [cprotocol,Np] = get_section_protocol(ProtocolsFile,ProcessingSTep,MRIModality,DataFolder)

pname = get_protocol_names(ProtocolsFile,ProcessingSTep,MRIModality); % protocol name ..
pname = cellstr(pname);
subj_protocols = getListofFolders(DataFolder);
%ind = ismember(pname,subj_protocols);
%cprotocol = pname(ind);
[~,~,ipname] = intersect(subj_protocols,pname);
cprotocol = pname(sort(ipname));
Np = length(cprotocol);
%cprotocol = char(pname(ind));
%Np = size(cprotocol,1);

end