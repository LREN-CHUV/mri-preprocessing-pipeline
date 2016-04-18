function fix_MTPDT1_ACPCorigin(InputFolder,SubjID,MTSequence,PDSequence,T1Sequence)


%% Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, July 8th, 2014

if ~strcmpi(InputFolder(end),filesep)
    InputFolder = [InputFolder,filesep];    
end;
if ~iscell(MTSequence)
    MTSequence = cellstr(MTSequence);
end;
if ~iscell(PDSequence)
    PDSequence = cellstr(PDSequence);
end;
if ~iscell(T1Sequence)
    T1Sequence = cellstr(T1Sequence);
end;
Sequences = vertcat(MTSequence,PDSequence,T1Sequence);
Sessions = getListofFolders([InputFolder,SubjID]);
Nsess = length(Sessions );
for i=1:Nsess
    Subj_InputFolder = [InputFolder,SubjID,filesep,Sessions{i},filesep];
    Temp_Sequences = getListofFolders(Subj_InputFolder);
    ind = ismember(Sequences,Temp_Sequences);
    Subj_Sequences = Sequences(ind);
    if ismember(T1Sequence,Subj_Sequences)
        T1RepetFolder = getListofFolders([Subj_InputFolder,char(T1Sequence)]);
        T1image = pickfiles([Subj_InputFolder,char(T1Sequence),filesep,T1RepetFolder{1}],'.nii'); T1image = deblank(T1image(1,:));       
        comm_adjust(1,T1image,'T1',T1image,8,0);
        V = spm_vol(T1image); M = V.mat;
        for j=1:length(Subj_Sequences)            
            RepetFolders = getListofFolders([Subj_InputFolder,Subj_Sequences{j}]); % Nseq = length(Sequences);            
            for k=1:length(RepetFolders)
                SubjImages = pickfiles([Subj_InputFolder,Subj_Sequences{j},filesep,RepetFolders{k}],{'.nii'});
                fixed_image_center(SubjImages,M);
            end;
        end;
    end;
end;

end

%% ======= Internal Functions ======= %%
function fixed_image_center(SubjImages,M)

N = size(SubjImages,1);    
for i=1:N
    V = spm_vol(deblank(SubjImages(i,:)));
    V.mat = M;
    I = spm_read_vols(V); spm_write_vol(V,I);
end;
end