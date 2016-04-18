function MPRAGE_synth(InputDataFolder,SubjectID)

%% Simulation of MP-RAGE
% Author: Sara Lorio
% Modified: Lester Melie Garcia, May 8th, 2015
% It was modified to be run in parallel in cluster enviorement

if ~strcmpi(InputDataFolder(end),filesep)
    InputDataFolder = [InputDataFolder,filesep];    
end;

SubjInputFolder = [InputDataFolder,SubjectID] ; 
%MR parameters
R1_Image = pickfiles(SubjInputFolder,{'_R1.nii'});
R2_Image = pickfiles(SubjInputFolder,{'_R2s.nii'});
PD_Image =  pickfiles(SubjInputFolder,{'_A.nii'});
R1struct = spm_vol(R1_Image);
R2sstruct = spm_vol(R2_Image);
PDstruct = spm_vol(PD_Image);

%Acquisition parameters
% MPRAGE parameter settings. See Tardif CL et al NI 2009. 
 TI = 960;
 TR = 2420;
 TE = 4.19;
 ES = 9.9;
 tau = 176*ES;
 TD = TR-TI-tau;
 alpha = 9;

 if (length(R1struct)==length(R2sstruct))&&(length(R1struct)==length(PDstruct))&&(length(R2sstruct)==length(PDstruct))
     %% MP-RAGE with R1, PD, R2*
     for i=1:length(R1struct)
         Vsave = spm_vol(R1struct(i));
         
         R1 = spm_read_vols(R1struct(i));
         R2s = spm_read_vols(R2sstruct(i));
         PD = spm_read_vols(PDstruct(i));
         
         T1=1./R1*1e6;%T1 in ms
         T1s=(1./T1-1/ES*log(cosd(alpha))).^(-1);
         E1= exp(-(TI-tau/2)./T1); E2=exp(-TD./T1);E3=exp(-tau./T1s);E4=exp(-tau/(2.*T1s));
         
         Ssynth=PD.*sind(alpha).*exp(-TE.*R2s).*(E4.*(1-2*E1+E1.*E2)./(1+E1.*E2.*E3)+T1s./T1.*(1+E1.*E2.*E3-E4-E4.*E2.*E1)./(1+E3.*E2.*E1));
         Vsave.fname = fullfile(spm_str_manip(Vsave.fname,'h'),[SubjectID,'_T1PDR2s_MPRAGE.nii']);
         
         %Vsave.fname =fullfile(spm_str_manip(P,'h'),'SynthMPRAGE.nii');%Vsave path set to path of the data for saving of the processed phase data
         spm_write_vol(Vsave,Ssynth);
         clear Ssynth
     end
 end;

end

%% MP-RAGE with R1, PD
% for i=1:length(R1struct)
%     Vsave = spm_vol(R1struct(i));
% 
%     R1 = spm_read_vols(R1struct(i));
%     PD = spm_read_vols(PDstruct(i));
% 
%     T1=1./R1*1e6;%T1 in ms
%     T1s=(1./T1-1/ES*log(cosd(alpha))).^(-1);
%     E1= exp(-(TI-tau/2)./T1); E2=exp(-TD./T1);E3=exp(-tau./T1s);E4=exp(-tau/(2.*T1s));
% 
%     Ssynth=PD.*sind(alpha).*(E4.*(1-2*E1+E1.*E2)./(1+E1.*E2.*E3)+T1s./T1.*(1+E1.*E2.*E3-E4-E4.*E2.*E1)./(1+E3.*E2.*E1));
%     Vsave.fname = fullfile(spm_str_manip(Vsave.fname,'h'),'T1PD_MPRAGE.nii');
% 
%     %Vsave.fname =fullfile(spm_str_manip(P,'h'),'SynthMPRAGE.nii');%Vsave path set to path of the data for saving of the processed phase data
%     spm_write_vol(Vsave,Ssynth);
%     clear Ssynth
% 
% end
% 
% 
% %% MP-RAGE with R1,R2*
% for i=1:length(R1struct)
%     Vsave = spm_vol(R1struct(i));
% 
%     R1 = spm_read_vols(R1struct(i));
%     R2s = spm_read_vols(R2sstruct(i));
% 
%     T1=1./R1*1e6;%T1 in ms
%     T1s=(1./T1-1/ES*log(cosd(alpha))).^(-1);
%     E1= exp(-(TI-tau/2)./T1); E2=exp(-TD./T1);E3=exp(-tau./T1s);E4=exp(-tau/(2.*T1s));
% 
%     Ssynth = sind(alpha).*exp(-TE.*R2s).*(E4.*(1-2*E1+E1.*E2)./(1+E1.*E2.*E3)+T1s./T1.*(1+E1.*E2.*E3-E4-E4.*E2.*E1)./(1+E3.*E2.*E1));
%     Vsave.fname = fullfile(spm_str_manip(Vsave.fname,'h'),'T1R2s_MPRAGE.nii');
% 
%     %Vsave.fname =fullfile(spm_str_manip(P,'h'),'SynthMPRAGE.nii');%Vsave path set to path of the data for saving of the processed phase data
%     spm_write_vol(Vsave,Ssynth);
%         clear Ssynth
% 
% end
% 
% 
% %% MP-RAGE with R1
% for i=1:length(R1struct)
%     Vsave = spm_vol(R1struct(i));
% 
%     R1 = spm_read_vols(R1struct(i));
%     R2 = spm_read_vols(R2sstruct(i));
%     PD = spm_read_vols(PDstruct(i));
% 
%     T1=1./R1*1e6;%T1 in ms
%     T1s=(1./T1-1/ES*log(cosd(alpha))).^(-1);
%     E1= exp(-(TI-tau/2)./T1); E2=exp(-TD./T1);E3=exp(-tau./T1s);E4=exp(-tau/(2.*T1s));
% 
%     Ssynth = sind(alpha).*(E4.*(1-2*E1+E1.*E2)./(1+E1.*E2.*E3)+T1s./T1.*(1+E1.*E2.*E3-E4-E4.*E2.*E1)./(1+E3.*E2.*E1));
%     Vsave.fname = fullfile(spm_str_manip(Vsave.fname,'h'),'T1_MPRAGE.nii');
% 
%     %Vsave.fname =fullfile(spm_str_manip(P,'h'),'SynthMPRAGE.nii');%Vsave path set to path of the data for saving of the processed phase data
%     spm_write_vol(Vsave,Ssynth);
%         clear Ssynth
% 
% end
