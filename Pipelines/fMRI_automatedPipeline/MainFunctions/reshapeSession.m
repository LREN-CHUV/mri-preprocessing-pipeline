function Session = reshapeSession(Sessions,Idx,resName,FileExt)

Session = Sessions;

%% Select the sessions corresponding to the resolution
Session.EPI = Sessions.EPI(Idx);
Session.EPIresolution = Sessions.EPIresolution(Idx);
Session.PMdefaultfile = Sessions.PMdefaultfile(Idx(1));

if ~isempty(Sessions.Phase)
    %% Copy files per resolution
    pnewPhase = duplicateFolders(Session.Phase{1,1},resName); % copy Phase
    pnewMagnitude = duplicateFolders(Session.Magnitude{1,1},resName);% copy Magnitude
    
    %% redefine the paths for the sessions grouped by each resolution
    Session.Phase = cellstr(spm_select('ExtFPList',pnewPhase,FileExt));
    Magnitude = cellstr(spm_select('ExtFPList',pnewMagnitude,FileExt));
    Session.Magnitude = Magnitude(1);
end

pnewStruct = duplicateFolders(Session.Struct{1,1},resName);% copy Structural
Session.Struct = cellstr(spm_select('ExtFPList',pnewStruct,FileExt));

end