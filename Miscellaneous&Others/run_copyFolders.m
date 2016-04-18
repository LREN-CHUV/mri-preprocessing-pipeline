% MPMFolder = 'M:\CRN\LREN\SHARE\VBQ_Output_All\MPMs_All\';
% %OutPutFolder = 'M:\CRN\LREN\USERS_BACKUP\aruef\NCCR\MapCompB0B1\maps_comp_16032016\MPMs_All\';
% OutPutFolder = 'D:\Users DATA\Users\lester\ZZZ_ZZZ\Test\';
% 
% 
% SubjIDs = textread('D:\Users DATA\Users\lester\PR4Unicort.txt','%s');
% Ns = length(SubjIDs);
% 
% for i=1:Ns
%     disp(['Copying Subject : ',SubjIDs{i},'--> ',num2str(i),' of ',num2str(Ns)]);
%     SourceFolder = [MPMFolder,SubjIDs{i}];
%     TargetFolder = [OutPutFolder,SubjIDs{i}];
%     mkdir(TargetFolder);
%     copyfile(SourceFolder,TargetFolder);
% end;

MPMFolder = 'M:\CRN\LREN\SHARE\ZZZ_Neuromorphics_Atlasing\';
OutPutFolder = 'M:\CRN\LREN\USERS_BACKUP\aruef\NCCR\MapCompB0B1\Neuromorphics_Atlasing_maps_comp_16032016\Neuromorphics_maps_comp_16032016\';

copyFolders(MPMFolder,OutPutFolder,'D:\Users DATA\Users\lester\PR4Unicort.txt');