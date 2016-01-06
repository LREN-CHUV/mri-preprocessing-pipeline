function [Sessions CheckValid] = build_EPI_sessions(Sessions,volnum,CheckValid)
% Discard folders containing not enough fMRI scans (they are probably
% incomplete runs)
%
%--------------------------------------------------------------------------
% INPUTS
%--------------------------------------------------------------------------
%
% Sessions : structure containing filepaths
%
% volnum : scalar, threshold indicating minimal number of volumes to find
% in the fMRI run
%
% CheckValid : empty variable filled when errors occur (files not found,
% etc.)
%
%--------------------------------------------------------------------------
% OUTPUTS
%--------------------------------------------------------------------------
%
% Sessions : structure containing filepaths, updated
%
% CheckValid : see INPUTS above, will be filled with fields when errors
% occur.
%
%--------------------------------------------------------------------------
% 2014-08-19, @LREN, Renaud Marquis & Sandrine Muller, refacto
%--------------------------------------------------------------------------

if isfield(Sessions,'EPI')
    SessionNum = size(Sessions.EPI,2);
else
    CheckValid.fMRIdata = 'fMRI data not found';
end

if size(volnum,1)==1 && size(volnum,2)==1 % check it is scalar
    volnum = volnum.*ones(1,SessionNum);
else
    CheckValid.VolNum = 'Specified minimal number of volumes in EPI sequence is not a scalar';
end

if SessionNum ~= 0
    for sess = 1:SessionNum
        for sess2 = 1:size(Sessions.EPI,1) % in LRENpipeline case this is necessary
            EPIsize(sess2,sess) = length(Sessions.EPI{sess2,sess});
        end
    end
else
    EPIsize = 0;
end

sessToKeep = EPIsize>volnum;

Sessions.EPI = Sessions.EPI(sessToKeep);

end