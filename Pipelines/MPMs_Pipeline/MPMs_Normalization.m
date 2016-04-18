function MPMs_Normalization(InputFolder,Template,FWHMsmooth)

%% Anne Ruef, Lester Melie-Garcia
% LREN, CHUV
% Lausanne, February 8th 2016

if strcmp(InputFolder(end),filesep)
    InputFolder = InputFolder(1:end-1);
end;
if ~exist('FWHMsmooth','var')
    FWHMsmooth = 6;
end;
s = which('spm.m');
if  isempty(s)
    disp('Please add SPM toolbox in the path .... ');
    return;
end;

spm_jobman('initcfg');

u_image = pickfiles(InputFolder,{[filesep,'u_'];'.nii'});
GM_image = pickfiles(InputFolder,{[filesep,'c1'];'.nii'});
WM_image = pickfiles(InputFolder,{[filesep,'c2'];'.nii'});
A_MPMs = pickfiles(InputFolder,{'_A.nii'});
R1_MPMs = pickfiles(InputFolder,{'_R1.nii'},{filesep},{[filesep,'hs'];[filesep,'mhs'];[filesep,'B1_'];[filesep,'BiasField']});
R2s_MPMs = pickfiles(InputFolder,{'_R2s.nii'});
MT_MPMs = pickfiles(InputFolder,{'_MT.nii'});

%% Normalizing ...
matlabbatch{1}.spm.tools.VBQ.proc.dartel.mni_norm.template = cellstr(Template);
matlabbatch{1}.spm.tools.VBQ.proc.dartel.mni_norm.multsdata.multsdata_gm = cellstr(GM_image);
matlabbatch{1}.spm.tools.VBQ.proc.dartel.mni_norm.multsdata.multsdata_wm = cellstr(WM_image);
matlabbatch{1}.spm.tools.VBQ.proc.dartel.mni_norm.multsdata.multsdata_f1 = {cellstr(A_MPMs);cellstr(A_MPMs);cellstr(R1_MPMs);cellstr(R2s_MPMs);cellstr(MT_MPMs)};
matlabbatch{1}.spm.tools.VBQ.proc.dartel.mni_norm.multsdata.multsdata_u = cellstr(u_image);
matlabbatch{1}.spm.tools.VBQ.proc.dartel.mni_norm.vox = [NaN NaN NaN];
matlabbatch{1}.spm.tools.VBQ.proc.dartel.mni_norm.bb = [NaN NaN NaN
                                                        NaN NaN NaN];
matlabbatch{1}.spm.tools.VBQ.proc.dartel.mni_norm.fwhm = [FWHMsmooth FWHMsmooth FWHMsmooth];

spm_jobman('run',matlabbatch);
%%  Smoothing ...
clear matlabbatch;

mwc1_Image = pickfiles(InputFolder,{[filesep,'mwc1']});
mwc2_Image = pickfiles(InputFolder,{[filesep,'mwc2']});
matlabbatch{1}.spm.spatial.smooth.data = {mwc1_Image;mwc2_Image};
matlabbatch{1}.spm.spatial.smooth.fwhm = [FWHMsmooth FWHMsmooth FWHMsmooth];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's'; %strcat('s',num2str(FWHMsmooth));

spm_jobman('run',matlabbatch);

end