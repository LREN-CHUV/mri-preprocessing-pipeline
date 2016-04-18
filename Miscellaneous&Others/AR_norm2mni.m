function AR_norm2mni(u_img,template,type,preserve,smooth)

%%%%%%%%%%%%%%%%%%%%%%%
%
% function that normalise volume and MPM images
% a priori assumption: the flow fields should be in the same folder as your
% images
% u_img = flow fields images
% template = template image (6th)
% type = if your dealing with volume data only choose 'class'
% type = if you are dealing with VBQ images choose 'VBQ_new'
% type = if you are dealing with VBQ images nomalised with existing
% template choose 'VBQ_exist'
% preserve = if you want to preserve concentration choose 0, if you want to
% preserve amount choose 1
% smooth = choose your gaussian kernel
% example AR_norm2mni('path\u_rc1_XXX.nii','path\Template_6.nii','VBQ',[0 1],6)
% 
%%%%%%%%%%%%%%%%%%%%%%%


if strfind(type,'class')
    
    clear matlabbatch
    matlabbatch{1}.spm.tools.dartel.mni_norm.template = template;
    matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.flowfields = {u_img};
    matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.images = gm_wm;
    matlabbatch{1}.spm.tools.dartel.mni_norm.vox = [NaN NaN NaN];
    matlabbatch{1}.spm.tools.dartel.mni_norm.bb = [NaN NaN NaN
                                               NaN NaN NaN];
    matlabbatch{1}.spm.tools.dartel.mni_norm.preserve = preserve;
    matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm = [smooth smooth smooth];
  spm_jobman('run',matlabbatch);
    
elseif strfind(type,'VBQ_new')
    
        clear matlabbatch

        [flow_path,flow_img,flow_ext]=fileparts(u_img);
        [temp_path,temp_img,temp_ext]=fileparts(template);
        
        matlabbatch{1}.spm.tools.VBQ.proc.dartel.mni_norm.template = {template};
        matlabbatch{1}.spm.tools.VBQ.proc.dartel.mni_norm.multsdata.multsdata_gm = {strcat(flow_path,'\c1',flow_img(6:end-size(temp_img,2)+1),'.nii')};
        matlabbatch{1}.spm.tools.VBQ.proc.dartel.mni_norm.multsdata.multsdata_wm = {strcat(flow_path,'\c2',flow_img(6:end-size(temp_img,2)+1),'.nii')};
        matlabbatch{1}.spm.tools.VBQ.proc.dartel.mni_norm.multsdata.multsdata_f1 = {
                                                                                    {strcat(flow_path,'\',flow_img(6:end-(size(temp_img,2)+4)),'_A.nii')}
                                                                                    {strcat(flow_path,'\',flow_img(6:end-(size(temp_img,2)+4)),'_R1.nii')}
                                                                                    {strcat(flow_path,'\',flow_img(6:end-(size(temp_img,2)+4)),'_R2s.nii')}
                                                                                    {strcat(flow_path,'\',flow_img(6:end-(size(temp_img,2)+4)),'_MT.nii')}
                                                                                    }';
        matlabbatch{1}.spm.tools.VBQ.proc.dartel.mni_norm.multsdata.multsdata_u = cellstr(u_img);
        matlabbatch{1}.spm.tools.VBQ.proc.dartel.mni_norm.vox = [NaN NaN NaN];
        matlabbatch{1}.spm.tools.VBQ.proc.dartel.mni_norm.bb = [NaN NaN NaN
                                                                NaN NaN NaN];
        matlabbatch{1}.spm.tools.VBQ.proc.dartel.mni_norm.fwhm = [smooth smooth smooth];
        spm_jobman('run',matlabbatch);
        clear matlabbatch
       
            
        matlabbatch{1}.spm.spatial.smooth.data = {
                                          strcat(flow_path,'\mwc1',flow_img(6:end-size(temp_img,2)+1),'.nii')
                                          strcat(flow_path,'\mwc2',flow_img(6:end-size(temp_img,2)+1),'.nii')
                                          };
        matlabbatch{1}.spm.spatial.smooth.fwhm = [smooth smooth smooth];
        matlabbatch{1}.spm.spatial.smooth.dtype = 0;
        matlabbatch{1}.spm.spatial.smooth.im = 0;
        matlabbatch{1}.spm.spatial.smooth.prefix = strcat('s',num2str(smooth));        
        spm_jobman('run',matlabbatch);
        
elseif strfind(type,'VBQ_exist')
    
        clear matlabbatch

        [flow_path,flow_img,flow_ext]=fileparts(u_img);
        [temp_path,temp_img,temp_ext]=fileparts(template);
        
        matlabbatch{1}.spm.tools.VBQ.proc.dartel.mni_norm.template = {template};
        matlabbatch{1}.spm.tools.VBQ.proc.dartel.mni_norm.multsdata.multsdata_gm = {strcat(flow_path,'\c1',flow_img(6:end),'.nii')};
        matlabbatch{1}.spm.tools.VBQ.proc.dartel.mni_norm.multsdata.multsdata_wm = {strcat(flow_path,'\c2',flow_img(6:end),'.nii')};
        matlabbatch{1}.spm.tools.VBQ.proc.dartel.mni_norm.multsdata.multsdata_f1 = {
                                                                                    {strcat(flow_path,'\',flow_img(6:end-5),'_A.nii')}
                                                                                    {strcat(flow_path,'\',flow_img(6:end-5),'_R1.nii')}
                                                                                    {strcat(flow_path,'\',flow_img(6:end-5),'_R2s.nii')}
                                                                                    {strcat(flow_path,'\',flow_img(6:end-5),'_MT.nii')}
                                                                                    }';
        matlabbatch{1}.spm.tools.VBQ.proc.dartel.mni_norm.multsdata.multsdata_u = cellstr(u_img);
        matlabbatch{1}.spm.tools.VBQ.proc.dartel.mni_norm.vox = [NaN NaN NaN];
        matlabbatch{1}.spm.tools.VBQ.proc.dartel.mni_norm.bb = [NaN NaN NaN
                                                                NaN NaN NaN];
        matlabbatch{1}.spm.tools.VBQ.proc.dartel.mni_norm.fwhm = [smooth smooth smooth];
        spm_jobman('run',matlabbatch);
        clear matlabbatch
       
            
        matlabbatch{1}.spm.spatial.smooth.data = {
                                          strcat(flow_path,'\mwc1',flow_img(6:end),'.nii')
                                          strcat(flow_path,'\mwc2',flow_img(6:end),'.nii')
                                          };
        matlabbatch{1}.spm.spatial.smooth.fwhm = [smooth smooth smooth];
        matlabbatch{1}.spm.spatial.smooth.dtype = 0;
        matlabbatch{1}.spm.spatial.smooth.im = 0;
        matlabbatch{1}.spm.spatial.smooth.prefix = strcat('s',num2str(smooth));        
        spm_jobman('run',matlabbatch);

end