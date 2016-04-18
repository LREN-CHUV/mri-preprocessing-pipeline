function [Anatomic_Image,Anatomic_Protocol,Anatomic_Protocol_Path] = getValid_Anatomic_Image(MPMDataFolder,MPRAGEFolder,ProtocolsFile,SubjectID)

%% Lester Melie Garcia
%  LREN, CHUV
%  Lausanne April 16th 2015

if ~strcmp(MPMDataFolder(end),filesep)
    MPMDataFolder = [MPMDataFolder,filesep];
end;
if ~strcmp(MPRAGEFolder(end),filesep)
    MPRAGEFolder = [MPRAGEFolder,filesep];
end;

SubjMPMDataFolder = [MPMDataFolder,SubjectID,filesep];
SubjMPRAGEDataFolder = [MPRAGEFolder,SubjectID,filesep];

Anatomic_Image = ''; Anatomic_Protocol= ''; Anatomic_Protocol_Path = '';
if exist(SubjMPMDataFolder,'dir')
   [Anatomic_Image,Anatomic_Protocol,Anatomic_Protocol_Path] = getAnatSeqFolder(SubjMPMDataFolder,ProtocolsFile,'MPM');
end;
if isempty(Anatomic_Image)&&exist(SubjMPRAGEDataFolder,'dir')
   [Anatomic_Image,Anatomic_Protocol,Anatomic_Protocol_Path] = getAnatSeqFolder(SubjMPRAGEDataFolder,ProtocolsFile,'MPRAGE');   
end;

end
%%  ======  Internal Functions 
function [Anatomic_Image,Protocol,Protocol_Path] = getAnatSeqFolder(SubjAnatomicDataFolder,ProtocolsFile,Modality)

if strcmpi(Modality,'MPM')
    IModality = '__MPM__';
    ISection = '[MT]';
end;
if strcmpi(Modality,'MPRAGE')
    IModality = '__MPRAGE__';
    ISection = '[MPRAGE]';
end;

SessionFolders = getListofFolders(SubjAnatomicDataFolder);
Ns =  length(SessionFolders);
Protocol = {}; Protocol_Path = {};
for i=1:Ns
    Session = SessionFolders{i};
    [Subj_Protocols,Nm] = get_section_protocol(ProtocolsFile,IModality,ISection,[SubjAnatomicDataFolder,Session]);
    if Nm~=0
        Protocol = vertcat(Protocol,Subj_Protocols); %#ok
        Np = length(Subj_Protocols);
        Subj_Protocol_Path = cell(Np,1);
        for j=1:Np
            Subj_Protocol_Path{j} = [SubjAnatomicDataFolder,Session,filesep,Subj_Protocols{j}];
        end;
        Protocol_Path = vertcat(Protocol_Path,Subj_Protocol_Path); %#ok
    end;
end;

Np = length(Protocol);

if Np~=0
    if strcmpi(Modality,'MPM')
        Label4Search = '1mm';
        ind = [];
        for i=1:Np
            j = strfind(Protocol{i},Label4Search);
            if ~isempty(j)
                ind = [ind,i]; %#ok
            end;
        end;
        if isempty(ind)
            Label4Search = '1pt5mm';
            for i=1:Np
                j = strfind(Protocol{i},Label4Search);
            end;
            if ~isempty(j)
                ind = [ind,i];
            end;
        end;
        if ~isempty(ind)
            Protocol_Path = Protocol_Path(ind(1));
            Protocol = Protocol(ind(1));
            Anatomic_Image = pickfiles(Protocol_Path,{'_MT_m.nii';[filesep,'sPR']});
        else
            Anatomic_Image = '';
        end;
    end;
    if strcmpi(Modality,'MPRAGE')
        Anatomic_Image = pickfiles(Protocol_Path(1),{'.nii'});
    end;
    if ~isempty(Anatomic_Image)
        Anatomic_Image = Anatomic_Image(1,:);  % Taking the first image, in case we have more than one because there are more than one repetition.
    end;
else
    Anatomic_Image = '';
end;
   
end