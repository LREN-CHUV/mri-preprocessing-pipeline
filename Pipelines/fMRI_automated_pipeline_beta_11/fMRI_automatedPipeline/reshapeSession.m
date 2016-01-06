function [Session block] = reshapeSession(Sessions,Idx,resName,Opts)
% Deal with multi-resolution datasets: make duplicates of folders to allow
% separate preprocessing and redefine filepaths (this is done to prevent
% errors when SPM tries to compute the mean of all fMRI runs by processing
% them altogether during realignment).
%
%--------------------------------------------------------------------------
% INPUTS
%--------------------------------------------------------------------------
%
% Sessions : structure containing filepaths
%
% Idx : scalar, index of EPI resolution to look at
%
% resName : string, resolution to process (detected from folder name)
%
%--------------------------------------------------------------------------
% OUTPUTS
%--------------------------------------------------------------------------
%
% Session : reshaped structured containing filepaths (according to
% resolutions)
%
% block : cell of structures, containing SPM jobs (empty if no jobs needed)
%
%--------------------------------------------------------------------------
% 2014-08-19, @LREN, Renaud Marquis & Sandrine Muller, refacto
%--------------------------------------------------------------------------

Session = Sessions;

%% Select the sessions corresponding to the resolution
Session.EPI = Sessions.EPI(Idx);
Session.EPIresolution = Sessions.EPIresolution(Idx);
if ~isempty(Session.Phase)
    Session.PMdefaultfile = unique(Sessions.PMdefaultfile(Idx));
else
    Session.PMdefaultfile = Sessions.PMdefaultfile;
end

if ~isempty(Session.Phase)
    %% Copy files per resolution
    
    [block{1} block{2} pnewPhase] = duplicateFolders(Session.Phase{1,1},strcat('for_',resName),Opts); % copy Phase
    [block{3} block{4} pnewMagnitude] = duplicateFolders(Session.Magnitude{1,1},strcat('for_',resName),Opts); % copy Magnitude
    
    %% redefine the paths for the sessions grouped by each resolution
    Session.Phase = pnewPhase;
    Magnitude = pnewMagnitude;
    Session.Magnitude = Magnitude(1);
end

if exist('block','var')
    
    Njob = size(block,2);
    [block{Njob+1} block{Njob+2} pnewStruct] = duplicateFolders(Session.Struct{1,1},strcat('for_',resName),Opts); % copy Structural
else
        
    [block{1} block{2} pnewStruct] = duplicateFolders(Session.Struct{1,1},strcat('for_',resName),Opts); % copy Structural
end

Session.Struct = pnewStruct;

end