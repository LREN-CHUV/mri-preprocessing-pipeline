function EchoCombining(DataFolder,fMRI_SequenceName)

%% Leyla Loued-Khenissi, Vasiliki Liakoni, Lester Melie-Garcia
% LREN, CHUV. 
% Lausanne, November 23rd, 2015

if ~strcmp(DataFolder(end),filesep)
    DataFolder = [DataFolder,filesep];    
end;
InputFolder = [DataFolder,fMRI_SequenceName,filesep];

RepetFolders = getListofFolders(InputFolder,'yes'); % Getting the list of Folders organized ... 
Nf = floor(length(RepetFolders)/3);

for i=1:Nf
    Echo1_List = spm_vol(spm_select('FPListRec',[InputFolder,RepetFolders{3*(i-1)+1}],'.*'));
    Echo2_List = spm_vol(spm_select('FPListRec',[InputFolder,RepetFolders{3*(i-1)+2}],'.*'));
    Echo3_List = spm_vol(spm_select('FPListRec',[InputFolder,RepetFolders{3*(i-1)+3}],'.*'));
    OutputFolder = [DataFolder,fMRI_SequenceName,'_Echocombined',filesep,RepetFolders{3*(i-1)+1},filesep];
    if ~exist(OutputFolder,'dir')
        mkdir(OutputFolder);
    end;
    NEchoes = min([length(Echo1_List),length(Echo2_List),length(Echo3_List)]);
    for k=1:NEchoes
        SaveStruct = Echo1_List(k);
        SaveStruct.fname = [OutputFolder,'comb',spm_str_manip(SaveStruct.fname,'t')];
        spm_write_vol(SaveStruct,squeeze(spm_read_vols(Echo1_List(k))+spm_read_vols(Echo2_List(k))+spm_read_vols(Echo3_List(k))));
    end;
end;

end

