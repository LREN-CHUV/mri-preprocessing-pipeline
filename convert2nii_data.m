InputFolder = 'D:\Users DATA\Users\lester\VBQ_Dicom_Data\';
OutputFolder = 'D:\Users DATA\Users\lester\DataNifti_New\';
if ~strcmp(OutputFolder(end),filesep)
    OutputFolder = [OutputFolder,filesep];
end;
if ~strcmp(InputFolder(end),filesep)
    InputFolder = [InputFolder,filesep];
end;
if ~exist(OutputFolder,'dir')
    mkdir(OutputFolder);
end;

ProtocolsFile = 'D:\Users DATA\Users\lester\Automatic_Computation\Protocols_definition.txt';
spm_jobman('initcfg');
SubjectFolders = getListofFolders(InputFolder);
Ns = length(SubjectFolders);  % Number of subjects ...
H = waitbar(0,'Converting Data to nifti format  ... ','Resize','on','Position',[233.25 237.75 273 50.25],'Resize','off'); StringNs = num2str(Ns);
for i=1:Ns
    waitbar(i/Ns,H, ['Converting Data to nifti format...  '  num2str(i) ' of ' StringNs]);   
    SubjectFolder = [InputFolder,SubjectFolders{i},filesep];
    DCM2NII_VBQ_rev(SubjectFolder,SubjectFolders{i},OutputFolder,ProtocolsFile);
end;

close(H);