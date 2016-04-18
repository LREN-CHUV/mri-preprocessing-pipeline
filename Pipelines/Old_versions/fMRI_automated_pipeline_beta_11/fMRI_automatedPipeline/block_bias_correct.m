function [block prefixNII batchNum] = block_bias_correct(Session,RegisterToMean,prefixNII,batchNum)
% SPM bias correction (based on Antoine's Lutti code and SPM bias
% correction toolbox for SPM by Sandrine Muller)
%
%--------------------------------------------------------------------------
% INPUTS:
%--------------------------------------------------------------------------
%
% Session : cell of structure containing filepaths by image types, default
% file for EPI image distortion correction (FieldMap) if B0 maps are present,
% resolution of EPI runs (detected from folder name)
%
% RegisterToMean : scalar, 1 if fMRI scans were realigned to the mean
% (two-pass procedure) or to the first
%
% prefixNII : string, prefix of MR scans, added job after job in an
% incremental way
%
% batchNum : scalar, index for current SPM batch
%
%--------------------------------------------------------------------------
% OUTPUTS:
%--------------------------------------------------------------------------
%
% block : structure for SPM job (Bias correct here)
%
% prefixNII : string, prefix of MR scans, added job after job in an
% incremental way, updated
%
% batchNum : index for next SPM batch
%
%--------------------------------------------------------------------------
% 2014-07-07, @LREN, Renaud Marquis & Sandrine Muller, refacto
%--------------------------------------------------------------------------

for i = 1:length(Session.EPI)
    for f = 1:length(Session.EPI{i})
        [p n e] = fileparts(Session.EPI{i}{f});
        ToBiasCorrect{f} = strcat(p, filesep, prefixNII, n, e);
    end
    block.spm.tools.biasCorrect.data{i} = ToBiasCorrect';
    clear ToBiasCorrect;
end
batchLength = length(block.spm.tools.biasCorrect.data);
[p n e] = fileparts(Session.EPI{1}{1}); % get filename of first file
if RegisterToMean == 1
    if isempty(Session.Phase)
        block.spm.tools.biasCorrect.data{batchLength+1} = {strcat(p, filesep, 'mean', n, e)}; % no prefix here, because reslice adds prefix to all files except the mean
    else
        block.spm.tools.biasCorrect.data{batchLength+1} = {strcat(p, filesep, 'meanu', n, e)}; % no prefix here, because reslice adds prefix to all files except the mean
    end
else
    block.spm.tools.biasCorrect.data{batchLength+1} = {strcat(p, filesep, prefixNII, n, e)};
end

% block.spm.tools.biasCorrect.data{batchLength+1}(1) = cfg_dep('Realign & Unwarp: Unwarped Mean Image', substruct('.','val', '{}',{batchNum-1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','meanuwr'));

prefixNII = ['b' prefixNII];

batchNum = batchNum+1;

end