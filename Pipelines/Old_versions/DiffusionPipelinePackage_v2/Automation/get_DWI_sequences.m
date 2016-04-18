function [valid_protocols_diff,valid_protocols_fieldmap] = get_DWI_sequences(InputFolder,ProtocolsFile)

%% David Slater, Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, July 10th, 2014

if ~strcmp(InputFolder(end),filesep)
    InputFolder = [InputFolder,filesep];
end;

diffusion_protocols = cellstr(get_protocol_names(ProtocolsFile,'__DWI__','[diffusion]')); % protocol name ..
fieldmap_protocols = cellstr(get_protocol_names(ProtocolsFile,'__DWI__','[fieldmap]')); % protocol name ..

valid_protocols_diff = {}; valid_protocols_fieldmap = {};
for i=1:length(diffusion_protocols)
    if exist([InputFolder,diffusion_protocols{i}],'dir')&&exist([InputFolder,fieldmap_protocols{i}],'dir')
        valid_protocols_diff = vertcat(valid_protocols_diff,diffusion_protocols{i}); %#ok
        valid_protocols_fieldmap = vertcat(valid_protocols_fieldmap,fieldmap_protocols{i});  %#ok
    end;
end;

end