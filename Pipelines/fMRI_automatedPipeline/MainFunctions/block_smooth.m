function [block prefixNII] = block_smooth(Session, FWHM, prefixNII)
% SPM Smooth (fMRI scans)
%
%--------------------------------------------------------------------------
% INPUTS:
%--------------------------------------------------------------------------
%
% Session : cell of structure containing filepaths by image types, default
% file for EPI image distortion correction (FieldMap) if B0 maps are present,
% resolution of EPI runs (detected from folder name)
%
% FWHM: 1 x 3 array, size of the smoothing kernel in x, y and z directions
%
% prefixNIIf : string, prefix of fMRI scan, added job after job in an
% incremental way
%
% batchNum : scalar, index for current SPM batch
%
%--------------------------------------------------------------------------
% OUTPUTS:
%--------------------------------------------------------------------------
%
% block : structure for SPM job (Smooth here)
%
% prefixNIIf : string, prefix of structural scan, added job after job in an
% incremental way, updated
%
% batchNum : index for next SPM batch
%
%--------------------------------------------------------------------------
% 2014-07-07, @LREN, Renaud Marquis & Sandrine Muller, refacto
%--------------------------------------------------------------------------


for k = 1:size(Session.EPI,2) % for each resolution/session

    for i = 1:length(Session.EPI{1,k})
        [pp nn ee] = fileparts(Session.EPI{1,k}{i,1});
        temp = strrep(char(Session.EPI{1,k}{i,1}),[pp filesep],'');
        Session.EPIout{1,k}{i,1} = [pp filesep prefixNII temp];
    end
    
            block{k}.spm.spatial.smooth.data = Session.EPIout{1,k};
            block{k}.spm.spatial.smooth.fwhm = [FWHM FWHM FWHM];
            block{k}.spm.spatial.smooth.dtype = 0;
            block{k}.spm.spatial.smooth.im = 0;
            block{k}.spm.spatial.smooth.prefix = ['s' num2str(FWHM)];

end


% if size(Session,2) ~= 0 && size(Session,1) ~= 0
%     block = block(~cellfun(@isempty,block)); % in case some subjects have multiple resolutions and some others not
% else
%     block = [];
% end
% 
% block = reshape(block,1,size(block,1)*size(block_,2)*size(block,3));
% % batchNum = batchNum+1; % Not here (done outside the function)
prefixNII = [block{1}.spm.spatial.smooth.prefix prefixNII];

end
