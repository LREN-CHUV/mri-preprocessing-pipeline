function EchoCombine
% this function combines the multiple echoes of an fMRI time-series. The
% echo combination is done using a simple summation. 
% All image volumes for each echo number have to be entered together. 


Echo1 = spm_vol(spm_select(Inf,'image','Select 1st echo images',[],[],'^f.*\-01.(img|nii)$'));
Echo2 = spm_vol(spm_select(Inf,'image','Select 2nd echo images',[],[],'^f.*\-02.(img|nii)$'));
Echo3 = spm_vol(spm_select(Inf,'image','Select 3nd echo images',[],[],'^f.*\-03.(img|nii)$'));
% spm_select('FPList',Params.SegmentationTarget,'^WB.*.(img|nii)$')%automatic
% loading of nifti echo files

for runcounter=1:size(spm_read_vols(Echo1),4)
    SaveStruct=Echo1(runcounter);
    SaveStruct.fname=fullfile(spm_str_manip(SaveStruct.fname,'h'),['comb' spm_str_manip(SaveStruct.fname,'t')]);
    spm_write_vol(SaveStruct,squeeze(spm_read_vols(Echo1(runcounter))+spm_read_vols(Echo2(runcounter))+spm_read_vols(Echo3(runcounter))));
end

end
 