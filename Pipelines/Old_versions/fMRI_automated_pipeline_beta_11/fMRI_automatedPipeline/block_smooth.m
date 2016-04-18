function [block prefixNIIf batchNum] = block_smooth(Session, FWHM, prefixNIIf, batchNum)
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

if any(any(cellfun(@isempty,Session)))
    Session = Session(~cellfun(@isempty,Session));
    warning('Cannot recognize sessions format for normalisation (some fMRI sessions are probably missing)')
    warning('Trying to vectorize Sessions, please check jobs are correct')
end

for k = 1:size(Session,2) % for each resolution
    for L = 1:size(Session,1) % for each subject
        
        % Deal with format of EPI sessions whether it is a cell of strings
        % or a cell of cells of strings:
        if iscellstr(Session{L,k}.EPI)
            ToSmooth = spm_file(Session{L,k}.EPI,'prefix',prefixNIIf);
        else
            for c = 1:size(Session{L,k}.EPI,2)
                Check(c) = iscellstr(Session{L,k}.EPI{c});
            end
            if sum(Check) == size(Session{L,k}.EPI,2)
                for c = 1:size(Session{L,k}.EPI,2)
                    ToSmooth{c} = spm_file(Session{L,k}.EPI{c},'prefix',prefixNIIf);
                end
            else
                if iscellstr(Session{L,k}.EPI)
                    ToSmooth = spm_file(Session{L,k}.EPI,'prefix',prefixNIIf);
                elseif iscellstr(Session{L,k}.EPI{c})
                    for c = 1:size(Session{L,k}.EPI,2)
                        ToSmooth{c} = spm_file(Session{L,k}.EPI{c},'prefix',prefixNIIf);
                    end
                else
                    error('Sorry dude, something went wrong...')
                end
            end
        end
        clear temp Temp
        
        for c = 1:length(ToSmooth)
            block_temp{L,k,c}.spm.spatial.smooth.data = ToSmooth{c};
            block_temp{L,k,c}.spm.spatial.smooth.fwhm = FWHM;
            block_temp{L,k,c}.spm.spatial.smooth.dtype = 0;
            block_temp{L,k,c}.spm.spatial.smooth.im = 0;
            block_temp{L,k,c}.spm.spatial.smooth.prefix = 's';
        end
        
    end
end

if size(Session,2) ~= 0 && size(Session,1) ~= 0
    block_temp = block_temp(~cellfun(@isempty,block_temp)); % in case some subjects have multiple resolutions and some others not
else
    block_temp = [];
end

block = reshape(block_temp,1,size(block_temp,1)*size(block_temp,2)*size(block_temp,3));
% batchNum = batchNum+1; % Not here (done outside the function)
prefixNIIf = ['s' prefixNIIf];

end
