function fix_MTPDT1_center(InputFolder,SubjID,MTSequence,PDSequence,T1Sequence,B1Sequence,B0Sequence)


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
if ~iscell(B1Sequence)
    B1Sequence = cellstr(B1Sequence);
end;
if ~iscell(B0Sequence)
    B0Sequence = cellstr(B0Sequence);
end;
Sequences = vertcat(MTSequence,PDSequence,T1Sequence);
Sessions = getListofFolders([InputFolder,SubjID]);
Nsess = length(Sessions );
for i=1:Nsess
    Subj_InputFolder = [InputFolder,SubjID,filesep,Sessions{i},filesep];
    Temp_Sequences = getListofFolders(Subj_InputFolder);
    ind = ismember(Sequences,Temp_Sequences);
    Subj_Sequences = Sequences(ind);
    B1B0exist = any(ismember(B1Sequence,Temp_Sequences))&&any(ismember(B0Sequence,Temp_Sequences));
    for j=1:length(Subj_Sequences)
        RepetFolders = getListofFolders([Subj_InputFolder,Subj_Sequences{j}]); % Nseq = length(Sequences);
        for k=1:length(RepetFolders)
            SubjImages = pickfiles([Subj_InputFolder,Subj_Sequences{j},filesep,RepetFolders{k}],{'.nii'});
            fixed_image_center(SubjImages,B1Sequence{1},Subj_InputFolder,B1B0exist);
        end;
    end;
end;

end

%% ======= Internal Functions ======= %%
function fixed_image_center(SubjImages,B1Sequence,Subj_InputFolder,B1B0exist)

if ~strcmpi(Subj_InputFolder(end),filesep)
    Subj_InputFolder = [Subj_InputFolder,filesep];    
end;
N = size(SubjImages,1);
%if ~B1B0exist    
    for i=1:N
        V = spm_vol(deblank(SubjImages(i,:)));
        center_coord = (V.dim)/2;
        MM = V.mat; MM(1:3,4) =  [-center_coord(3),center_coord(1),-center_coord(2)];
        V.mat = MM;
        I = spm_read_vols(V); spm_write_vol(V,I);
    end;
% else
%     B1Folder = [Subj_InputFolder,B1Sequence];
%     RepFolders = getListofFolders(B1Folder);
%     B1Folder = [Subj_InputFolder,B1Sequence,filesep,RepFolders{1}];
%     B1Images = pickfiles(B1Folder,{'.nii'});
%     VB1 = spm_vol(deblank(B1Images(1,:)));
%     for i=1:N
%         V = spm_vol(deblank(SubjImages(i,:)));
%         trans = ((VB1.mat)*[32 32 32 1]')-((V.mat)*[140 108 88 1]');
%         MM = V.mat;
%         MM(1:3,4)=(V.mat(1:3,4)) + trans(1:3);
%         V.mat = MM;
%         I = spm_read_vols(V); spm_write_vol(V,I);
%     end;
% end;
end