function [block batchNum] = block_DARTEL(Session, resolution, prefixNII, batchNum)
% SPM DARTEL create template :
%
%--------------------------------------------------------------------------
% INPUTS:
%--------------------------------------------------------------------------
%
% Session : cell of structure containing filepaths by image types, default
% file for EPI image distortion correction (FieldMap) if B0 maps are present,
% resolution of EPI runs (detected from folder name)
%
% resolution: scalar, resolution to be processed within Session
%
% prefixNII : string, prefix of structural scan, added job after job in an
% incremental way
%
% batchNum : scalar, index for current SPM batch
%
%--------------------------------------------------------------------------
% OUTPUTS:
%--------------------------------------------------------------------------
%
% block : structure for SPM job (DARTEL: create template here)
%
% batchNum : index for next SPM batch
%
%--------------------------------------------------------------------------
% 2014-07-07, @LREN, Renaud Marquis & Sandrine Muller, refacto
%--------------------------------------------------------------------------

for l = 1:size(Session,1)
    [p n e] = fileparts(Session{l,resolution}.Struct{:});
    RC1{l} = regexprep([p filesep 'rc1' prefixNII n '.nii'], ',1', '');
    RC2{l} = regexprep([p filesep 'rc2' prefixNII n '.nii'], ',1', '');
%     RC3{l} = regexprep([p filesep 'rc3' prefixNII n '.nii'], ',1', '');
end

block.spm.tools.dartel.warp.images{1} = RC1'; % RC1 (DARTEL imported tissue class 1 (GM)) images
block.spm.tools.dartel.warp.images{2} = RC2'; % RC2 (DARTEL imported tissue class 2 (WM)) images
% block.spm.tools.dartel.warp.images{3} = RC3'; % RC3 (DARTEL imported tissue class 3 (CSF)) images
block.spm.tools.dartel.warp.settings.template = 'Template';
block.spm.tools.dartel.warp.settings.rform = 0;
block.spm.tools.dartel.warp.settings.param(1).its = 3;
block.spm.tools.dartel.warp.settings.param(1).rparam = [4 2 1e-006];
block.spm.tools.dartel.warp.settings.param(1).K = 0;
block.spm.tools.dartel.warp.settings.param(1).slam = 16;
block.spm.tools.dartel.warp.settings.param(2).its = 3;
block.spm.tools.dartel.warp.settings.param(2).rparam = [2 1 1e-006];
block.spm.tools.dartel.warp.settings.param(2).K = 0;
block.spm.tools.dartel.warp.settings.param(2).slam = 8;
block.spm.tools.dartel.warp.settings.param(3).its = 3;
block.spm.tools.dartel.warp.settings.param(3).rparam = [1 0.5 1e-006];
block.spm.tools.dartel.warp.settings.param(3).K = 1;
block.spm.tools.dartel.warp.settings.param(3).slam = 4;
block.spm.tools.dartel.warp.settings.param(4).its = 3;
block.spm.tools.dartel.warp.settings.param(4).rparam = [0.5 0.25 1e-006];
block.spm.tools.dartel.warp.settings.param(4).K = 2;
block.spm.tools.dartel.warp.settings.param(4).slam = 2;
block.spm.tools.dartel.warp.settings.param(5).its = 3;
block.spm.tools.dartel.warp.settings.param(5).rparam = [0.25 0.125 1e-006];
block.spm.tools.dartel.warp.settings.param(5).K = 4;
block.spm.tools.dartel.warp.settings.param(5).slam = 1;
block.spm.tools.dartel.warp.settings.param(6).its = 3;
block.spm.tools.dartel.warp.settings.param(6).rparam = [0.25 0.125 1e-006];
block.spm.tools.dartel.warp.settings.param(6).K = 6;
block.spm.tools.dartel.warp.settings.param(6).slam = 0.5;
block.spm.tools.dartel.warp.settings.optim.lmreg = 0.01;
block.spm.tools.dartel.warp.settings.optim.cyc = 3;
block.spm.tools.dartel.warp.settings.optim.its = 3;

batchNum = batchNum+1;

end

% % The following doesn't work when EPI with multiple resolutions (doesn't
% know which segment job to refer for depedencies...
% block.spm.tools.dartel.warp.images{1}(1) = cfg_dep('Segment: rc1 Images', substruct('.','val', '{}',{batchNum-1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{1}, '.','rc', '()',{':'}));
% block.spm.tools.dartel.warp.images{2}(1) = cfg_dep('Segment: rc2 Images', substruct('.','val', '{}',{batchNum-1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{2}, '.','rc', '()',{':'}));
% block.spm.tools.dartel.warp.images{3}(1) = cfg_dep('Segment: rc3 Images', substruct('.','val', '{}',{batchNum-1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{3}, '.','rc', '()',{':'}));
