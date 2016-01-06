function block = brain_mask( filenames, mask_input )
%-----------------------------------------------------------------------
% BRAIN_MASK
%-----------------------------------------------------------------------
% This function extract c1, c2 and c3, compute a mask using them, and mask
% the original image using the mask to output skull stripped version of the
% original image (if mask_input = 1).
%
% USAGE:
% brain_mask( filenames, mask_input )
%
%-----------------------------------------------------------------------
% INPUTS
%-----------------------------------------------------------------------
%
% filenames : array of strings (output of spm_select), filenames of all
% input images (to compute the mask from (and eventually mask afterwards)),
% e.g. using spm_select function :
%                                   spm_select(Inf,'image')
%
% or like this if you have a cell array "Cell" of strings :
%                                   char(Cell)
%
% mask_input : scalar, 1 (mask the original input image with the mask
% computed using the three tissue classes) or 0 (just create the mask,
% don't mask the image that has been used to create it)
%
%-----------------------------------------------------------------------
% OUTPUTS
%-----------------------------------------------------------------------
%
% -> mask computed (original file with the prefix "mask_")
%
% -> if mask_input == 1, original input image(s) masked using the mask,
% with the prefix "masked_".
%
%-----------------------------------------------------------------------

S = size(filenames,1);

Images = cellstr(filenames);

f = 1:S;
g = (f*3)-2;

for f = 1:S
    
    [pathstr,name,ext] = fileparts(Images{f});
    
    block{g(f)}.spm.spatial.preproc.channel.vols = cellstr(Images{f});
    block{g(f)}.spm.spatial.preproc.channel.biasreg = 0.001;
    block{g(f)}.spm.spatial.preproc.channel.biasfwhm = 60;
    block{g(f)}.spm.spatial.preproc.channel.write = [0 0];
    
    [p n e] = fileparts(which('spm'));
    
    block{g(f)}.spm.spatial.preproc.tissue(1).tpm = {strcat(p, filesep, 'tpm\TPM.nii,1')};
    block{g(f)}.spm.spatial.preproc.tissue(1).ngaus = 1;
    block{g(f)}.spm.spatial.preproc.tissue(1).native = [1 0];
    block{g(f)}.spm.spatial.preproc.tissue(1).warped = [0 0];
    block{g(f)}.spm.spatial.preproc.tissue(2).tpm = {strcat(p, filesep, 'tpm\TPM.nii,2')};
    block{g(f)}.spm.spatial.preproc.tissue(2).ngaus = 1;
    block{g(f)}.spm.spatial.preproc.tissue(2).native = [1 0];
    block{g(f)}.spm.spatial.preproc.tissue(2).warped = [0 0];
    block{g(f)}.spm.spatial.preproc.tissue(3).tpm = {strcat(p, filesep, 'tpm\TPM.nii,3')};
    block{g(f)}.spm.spatial.preproc.tissue(3).ngaus = 2;
    block{g(f)}.spm.spatial.preproc.tissue(3).native = [1 0];
    block{g(f)}.spm.spatial.preproc.tissue(3).warped = [0 0];
    block{g(f)}.spm.spatial.preproc.tissue(4).tpm = {strcat(p, filesep, 'tpm\TPM.nii,4')};
    block{g(f)}.spm.spatial.preproc.tissue(4).ngaus = 3;
    block{g(f)}.spm.spatial.preproc.tissue(4).native = [0 0];
    block{g(f)}.spm.spatial.preproc.tissue(4).warped = [0 0];
    block{g(f)}.spm.spatial.preproc.tissue(5).tpm = {strcat(p, filesep, 'tpm\TPM.nii,5')};
    block{g(f)}.spm.spatial.preproc.tissue(5).ngaus = 4;
    block{g(f)}.spm.spatial.preproc.tissue(5).native = [0 0];
    block{g(f)}.spm.spatial.preproc.tissue(5).warped = [0 0];
    block{g(f)}.spm.spatial.preproc.tissue(6).tpm = {strcat(p, filesep, 'tpm\TPM.nii,6')};
    block{g(f)}.spm.spatial.preproc.tissue(6).ngaus = 2;
    block{g(f)}.spm.spatial.preproc.tissue(6).native = [0 0];
    block{g(f)}.spm.spatial.preproc.tissue(6).warped = [0 0];
    block{g(f)}.spm.spatial.preproc.warp.mrf = 1;
    block{g(f)}.spm.spatial.preproc.warp.cleanup = 1;
    block{g(f)}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    block{g(f)}.spm.spatial.preproc.warp.affreg = 'mni';
    block{g(f)}.spm.spatial.preproc.warp.fwhm = 0;
    block{g(f)}.spm.spatial.preproc.warp.samp = 3;
    block{g(f)}.spm.spatial.preproc.warp.write = [0 0];
    block{g(f)+1}.spm.util.imcalc.input(1) = cfg_dep('Segment: c1 Images', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{1}, '.','c', '()',{':'}));
    block{g(f)+1}.spm.util.imcalc.input(2) = cfg_dep('Segment: c2 Images', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{2}, '.','c', '()',{':'}));
    block{g(f)+1}.spm.util.imcalc.input(3) = cfg_dep('Segment: c3 Images', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{3}, '.','c', '()',{':'}));
    block{g(f)+1}.spm.util.imcalc.output = strcat('mask_', name, ext);
    block{g(f)+1}.spm.util.imcalc.outdir = {pathstr};
    block{g(f)+1}.spm.util.imcalc.expression = '(i1+i2+i3)>0'; % very liberal, to avoid masking too much
    block{g(f)+1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    block{g(f)+1}.spm.util.imcalc.options.dmtx = 0;
    block{g(f)+1}.spm.util.imcalc.options.mask = 0;
    block{g(f)+1}.spm.util.imcalc.options.interp = 1;
    block{g(f)+1}.spm.util.imcalc.options.dtype = 4;
            
    if mask_input == 1
        [block{g(f)+2}] = mask_with_brain_mask(strcat('masked_',name,ext), strcat('mask_', name, ext), Images{f});
    end
    
end

end

function [block] = mask_with_brain_mask(outputfilename, maskfilename, filename)

[pathstr,name,ext] = fileparts(filename);
mask_for_masking = strcat(pathstr,filesep,maskfilename);

block.spm.util.imcalc.input(1) = {filename};
block.spm.util.imcalc.input(2) = {mask_for_masking};
block.spm.util.imcalc.output = outputfilename;
block.spm.util.imcalc.outdir = {pathstr};
block.spm.util.imcalc.expression = 'i2.*i1';
block.spm.util.imcalc.var = struct('name', {}, 'value', {});
block.spm.util.imcalc.options.dmtx = 0;
block.spm.util.imcalc.options.mask = 0;
block.spm.util.imcalc.options.interp = 1;
block.spm.util.imcalc.options.dtype = 4;

end
