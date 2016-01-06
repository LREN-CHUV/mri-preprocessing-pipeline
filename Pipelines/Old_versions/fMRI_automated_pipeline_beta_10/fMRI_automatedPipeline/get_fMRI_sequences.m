function [valid_protocols_fMRI,valid_protocols_fieldmap] = get_fMRI_sequences(InputFolder,ProtocolsFile)

%% Renauld Marquis, Sandrine Muller, Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, May 5th, 2015

if ~strcmp(InputFolder(end),filesep)
    InputFolder = [InputFolder,filesep];
end;

fMRI_protocols = cellstr(get_protocol_names(ProtocolsFile,'__fMRI__','[epi]')); % protocol name ..
fieldmap_protocols = cellstr(get_protocol_names(ProtocolsFile,'__fMRI__','[fieldmap]')); % protocol name ..

valid_protocols_diff = {}; valid_protocols_fieldmap = {};
for i=1:length(fMRI_protocols)
    if exist([InputFolder,fMRI_protocols{i}],'dir')&&exist([InputFolder,fieldmap_protocols{i}],'dir')
        valid_protocols_fMRI = vertcat(valid_protocols_diff,fMRI_protocols{i}); 
        valid_protocols_fieldmap = vertcat(valid_protocols_fieldmap,fieldmap_protocols{i});  %#ok
    end;
end;

end