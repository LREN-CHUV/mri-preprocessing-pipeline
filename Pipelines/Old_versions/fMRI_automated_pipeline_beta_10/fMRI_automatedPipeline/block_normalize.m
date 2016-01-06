function [block prefixNIIf batchNum] = block_normalize(Session, runDartel, prefixNIIs, prefixNIIf, suffixNIIs, batchNum)
% SPM deformations (normalize to MNI) : either DARTEL Flow or Deformations:
% Pullback
%
%--------------------------------------------------------------------------
% INPUTS:
%--------------------------------------------------------------------------
%
% Session : cell of structure containing filepaths by image types, default
% file for EPI image distortion correction (FieldMap) if B0 maps are present,
% resolution of EPI runs (detected from folder name)
%
% runDartel : scalar, if DARTEL create template has been performed
% previously (in order to use the correct job (see main description above))
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
% 2014-07-07, @LREN, Renaud Marquis & Sandrine Muller, refacto
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
        Field{L,k} = strcat(p, filesep, prefixNIIs, n, suffixNIIs, '.nii'); % get either flow fields either deformation fields
        
        if runDartel == 1
            block_temp{L,k}.spm.util.defs.comp{1}.dartel.flowfield = Field(L,k); %for flow fields
            block_temp{L,k}.spm.util.defs.comp{1}.dartel.times = [1 0];
            block_temp{L,k}.spm.util.defs.comp{1}.dartel.K = 6;
            [p n e] = fileparts(Session{1,k}.Struct{:}); % !!!! needed to set p again because SPM leaves the Template in the folder of the first subject!
            block_temp{L,k}.spm.util.defs.comp{1}.dartel.template = {strcat(p, filesep, 'Template_6.nii')};
        else
            block_temp{L,k}.spm.util.defs.comp{1}.def = Field(L,k); %for deformation fields
        end
        
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
        
        if iscellstr(ToNorm)
            
            block_temp{L,k}.spm.util.defs.out{1}.pull.fnames = ToNorm;
            block_temp{L,k}.spm.util.defs.out{1}.pull.savedir.savesrc = 1;
            block_temp{L,k}.spm.util.defs.out{1}.pull.interp = 4;
            block_temp{L,k}.spm.util.defs.out{1}.pull.mask = 1;
            block_temp{L,k}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
            
        else % if potentially multiple EPI sessions (...but only one resolution (or multiple sessions for multiple resolutions...!!!
            
            for g = 1:size(Session{L,k}.EPI,2);
                block_temp{L,k}.spm.util.defs.out{g}.pull.fnames = ToNorm{g};
                block_temp{L,k}.spm.util.defs.out{g}.pull.savedir.savesrc = 1;
                block_temp{L,k}.spm.util.defs.out{g}.pull.interp = 4;
                block_temp{L,k}.spm.util.defs.out{g}.pull.mask = 1;
                block_temp{L,k}.spm.util.defs.out{g}.pull.fwhm = [0 0 0];
            end
            
        end
    end
end

if size(Session,2) ~= 0 && size(Session,1) ~= 0
    block_temp = block_temp(~cellfun(@isempty,block_temp)); % in case some subjects have multiple resolutions and some others not
else
    block_temp = [];
end

block = reshape(block_temp,1,size(block_temp,1)*size(block_temp,2));
% batchNum = batchNum+1; % Not here (done outside the function)
prefixNIIf = ['w' prefixNIIf];

end