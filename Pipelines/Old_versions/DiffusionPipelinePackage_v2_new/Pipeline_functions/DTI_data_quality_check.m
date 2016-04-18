function DTI_data_quality_check(residual_map,brain_mask)

residual_nii =niftiRead(residual_map);
res = residual_nii.data;
mask_nii =niftiRead(brain_mask);
mask = mask_nii.data;
[X, Y, Z, V] = size(res);

pathstr = fileparts(residual_map);


for i = 1:V
    
    res_vol = res(:,:,:,i);
    res_vol = res_vol(mask>0);
    
    % Sort residuals in ascending order
    res_vol = sort(res_vol);
    num_vox = length(res_vol);
    
    % Calculate mean residuals per DWI volume
    mn_res(i) = mean(res_vol);
    
    % Calculate 25th and 75th percentile
    res_25th(i) = res_vol(round(num_vox*0.25));
    res_75th(i) = res_vol(round(num_vox*0.75));
    
    
end

xx = 1:V;
yy = mn_res;
L = mn_res - res_25th;
U = res_75th - mn_res;

figure
errorbar(xx,yy,L,U)
xlabel('DWI volume (b0 volumes first)')
ylabel('Residuals (arbitrary units)')
figname = [pathstr filesep 'Residuals_by_DWI.fig'];

saveas(gcf,figname,'fig')
