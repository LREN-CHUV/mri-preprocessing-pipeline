function [block prefixNIIf batchNum] = block_norm_to_MNI(Session, prefixNIIs, prefixNIIf, suffixNIIs, batchNum)
% SPM DARTEL normalize to MNI space (warning: this job sometimes leaves
% some empty voxels in the resulting normalized images, check carefully the
% output)
%
%--------------------------------------------------------------------------
% INPUTS:
%--------------------------------------------------------------------------
%
% Session : cell of structure containing filepaths by image types, default
% file for EPI image distortion correction (FieldMap) if B0 maps are present,
% resolution of EPI runs (detected from folder name)
%
% prefixNIIs : string, prefix of structural scan, added job after job in an
% incremental way
%
% prefixNIIf : string, prefix of fMRI scan, added job after job in an
% incremental way
%
% suffixNIIs : string, suffix of structural scan, added job after job in an
% incremental way (e.g. DARTEL adds '_Template')
%
% batchNum : scalar, index for current SPM batch
%
%--------------------------------------------------------------------------
% OUTPUTS:
%--------------------------------------------------------------------------
%
% block : structure for SPM job (Deformations (normalization of fMRI) here)
%
% prefixNIIf : string, prefix of fMRI scan, added job after job in an
% incremental way, updated
%
% batchNum : index for next SPM batch
%
%--------------------------------------------------------------------------
% 2014-08-27, @LREN, Renaud Marquis & Sandrine Muller, refacto
%--------------------------------------------------------------------------

% k : if multiple resolutions, index of resolution to process

if any(any(cellfun(@isempty,Session)))
    Session = Session(~cellfun(@isempty,Session));
    warning('Cannot recognize sessions format for normalisation (some fMRI sessions are probably missing)')
    warning('Trying to vectorize Sessions, please check jobs are correct')
end

for k = 1:size(Session,2) % for each resolution
    for L = 1:size(Session,1) % for each subject
        
        [p n e] = fileparts(Session{L,k}.Struct{:}); %p=path, n= nom, e=extension
        Field{L,k} = strcat(p, filesep, prefixNIIs, n, suffixNIIs, '.nii'); % get flow fields
        
        % Deal with format of EPI sessions whether it is a cell of strings
        % or a cell of cells of strings:
        if iscellstr(Session{L,k}.EPI) %Determine whether input is cell array of strings
            ToNorm = spm_file(Session{L,k}.EPI,'prefix',prefixNIIf);
        else
            for c = 1:size(Session{L,k}.EPI,2)
                Check(c) = iscellstr(Session{L,k}.EPI{c});
            end
            if sum(Check) == size(Session{L,k}.EPI,2)
                for c = 1:size(Session{L,k}.EPI,2)
                    ToNorm{c} = spm_file(Session{L,k}.EPI{c},'prefix',prefixNIIf);
                end
            else
                if iscellstr(Session{L,k}.EPI)
                    ToNorm = spm_file(Session{L,k}.EPI,'prefix',prefixNIIf);
                elseif iscellstr(Session{L,k}.EPI{c})
                    for c = 1:size(Session{L,k}.EPI,2)
                        ToNorm{c} = spm_file(Session{L,k}.EPI{c},'prefix',prefixNIIf);
                    end
                else
                    error('Sorry dude, something went wrong...')
                end
            end
        end
        clear temp Temp
        
        for c = 1:length(ToNorm)
            [p n e] = fileparts(Session{1,k}.Struct{:}); % !!!! needed to set p again because SPM leaves the Template in the folder of the first subject!
            block_temp{L,k,c}.spm.tools.dartel.mni_norm.template(1) = {strcat(p, filesep, 'Template_6.nii')};
            block_temp{L,k,c}.spm.tools.dartel.mni_norm.data.subj(1).flowfield = Field(L,k);
            block_temp{L,k,c}.spm.tools.dartel.mni_norm.data.subj(1).images = ToNorm{c};
            block_temp{L,k,c}.spm.tools.dartel.mni_norm.vox = [NaN NaN NaN];
            block_temp{L,k,c}.spm.tools.dartel.mni_norm.bb = [NaN NaN NaN
                NaN NaN NaN];
            block_temp{L,k,c}.spm.tools.dartel.mni_norm.preserve = 0;
            block_temp{L,k,c}.spm.tools.dartel.mni_norm.fwhm = [0 0 0];
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
prefixNIIf = ['w' prefixNIIf];

end