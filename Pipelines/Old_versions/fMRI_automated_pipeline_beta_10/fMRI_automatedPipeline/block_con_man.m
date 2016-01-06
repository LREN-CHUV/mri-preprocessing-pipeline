function [block batchNum] = block_con_man(Contrasts,batchNum)
% SPM Contrast manager
%
%--------------------------------------------------------------------------
% INPUTS:
%--------------------------------------------------------------------------
%
% Contrasts: structure containing fields called T, F or
% both, informing batch contrast manger on contrasts to test.
% T and F fields are cells, each containing fields "name" and
% "weights", e.g:
%               weights: [1 0 0 -1]
%               name: 'a minus d'
%
% batchNum : scalar, index for current SPM batch
%
%--------------------------------------------------------------------------
% OUTPUTS:
%--------------------------------------------------------------------------
%
% block : structure for SPM job (Contrast manager here)
%
% batchNum : index for next SPM batch
%
%--------------------------------------------------------------------------
% 2014-08-19, @LREN, Renaud Marquis, refacto
%--------------------------------------------------------------------------

block.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{batchNum-1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
block.spm.stats.con.delete = 0;

if isfield(Contrasts,'F') && isfield(Contrasts,'T')
    NumCon = length(Contrasts.F)+length(Contrasts.T);
elseif isfield(Contrasts,'F')
    NumCon = length(Contrasts.F);
elseif isfield(Contrasts,'T')
    NumCon = length(Contrasts.T);
else
    NumCon = 0;
end

for con = 1:NumCon
    if isfield(Contrasts,'F')
        for fcon = 1:length(Contrasts.F)
            block.spm.stats.con.consess{con}.fcon.name = Contrasts.F{con}.name;
            block.spm.stats.con.consess{con}.fcon.weights = Contrasts.F{con}.weights;
            block.spm.stats.con.consess{con}.fcon.sessrep = 'none';
        end
    end
    if isfield(Contrasts,'T')
        for tcon = 1:length(Contrasts.T)
            block.spm.stats.con.consess{con}.tcon.name = Contrasts.T{con}.name;
            block.spm.stats.con.consess{con}.tcon.weights = Contrasts.T{con}.weights;
            block.spm.stats.con.consess{con}.tcon.sessrep = 'none';
        end
    end
end

batchNum = batchNum+1;

end