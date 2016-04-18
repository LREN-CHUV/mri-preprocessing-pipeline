function [valid_protocols_EPI,valid_protocols_fieldmap,valid_protocols_anatomic,valid_pmDefaultFile, NDummyScans] = get_fMRI_sequences(InputFolder,ProtocolsFile)

%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, October 25th, 2015

if ~strcmp(InputFolder(end),filesep)
    InputFolder = [InputFolder,filesep];
end;

EPI_protocols = cellstr(get_protocol_names(ProtocolsFile,'__fMRI__','[EPI]')); % protocol name ..
fieldmap_protocols = cellstr(get_protocol_names(ProtocolsFile,'__fMRI__','[fieldmap]')); % protocol name ..
pmDefaultFiles = cellstr(get_protocol_names(ProtocolsFile,'__fMRI__','[pmDefaultFiles]')); % protocol name ..
NDummyScans_all = get_protocol_names(ProtocolsFile,'__fMRI__','[NDummies]'); % protocol name ..
Anatomic_protocols = cellstr(get_protocol_names(ProtocolsFile,'__MPRAGE__','[MPRAGE]')); % protocol name ..

%% For EPI, Fieldmap, FieldMap toolbox Default Files, Number of Dummy scans ...
valid_protocols_EPI = {}; valid_protocols_fieldmap = {}; valid_pmDefaultFile = {}; NDummyScans = [];
for i=1:length(EPI_protocols)
    if exist([InputFolder,EPI_protocols{i}],'dir')&&exist([InputFolder,fieldmap_protocols{i}],'dir')&&exist(pmDefaultFiles{i},'file')
        valid_protocols_EPI = vertcat(valid_protocols_EPI,EPI_protocols{i}); %#ok
        valid_protocols_fieldmap = vertcat(valid_protocols_fieldmap,fieldmap_protocols{i});  %#ok
        NDummyScans = [NDummyScans,str2double(NDummyScans_all(i))]; %#ok
        pmDefaultFile_fullpath = which(pmDefaultFiles{i});
        valid_pmDefaultFile = vertcat(valid_pmDefaultFile,pmDefaultFile_fullpath);  %#ok
    end;
end;
[valid_protocols_EPI,ind] = unique(valid_protocols_EPI,'rows'); %  Taking EPI protocols only once.
valid_protocols_fieldmap = valid_protocols_fieldmap(ind);
valid_pmDefaultFile = valid_pmDefaultFile(ind);
NDummyScans = NDummyScans(ind);
%% For Anatomic Protocols ...
valid_protocols_anatomic = {};
for i=1:length(Anatomic_protocols)
    if exist([InputFolder,Anatomic_protocols{i}],'dir')
        valid_protocols_anatomic = vertcat(valid_protocols_anatomic,Anatomic_protocols{i});  %#ok
    end;
end;
if ~isempty(valid_protocols_anatomic)
    valid_protocols_anatomic = valid_protocols_anatomic(1);
    valid_protocols_anatomic = repmat(valid_protocols_anatomic,length(valid_protocols_EPI),1); % Repeting the same anatomic protocol for all EPI sequences.
end;

end