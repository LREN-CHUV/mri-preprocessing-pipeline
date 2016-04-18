function Sessions = build_EPI_sessions(Sessions,volnum)

% FUNCTION build_sessions_fromNIIs 
% aims at building the sessions
%
% ---------------------------------INPUTS----------------------------------

% ---------------------------------OUTPUTS---------------------------------


% 14-03-20, Sandrine Muller, @ LREN
% 14-06-25, Renaud Marquis, Sandrine Muller, @LREN, refacto

SessionNum = size(Sessions.EPI,2);

if size(volnum,1)==1 && size(volnum,2)==1 % check it is scalar
    volnum = volnum.*ones(1,SessionNum);
else
    error('Specified minimal number of volumes in EPI sequence is not a scalar');
end

for sess = 1:SessionNum
    EPIsize(sess) = length(Sessions.EPI{:,sess});
end

sessToKeep = EPIsize>=volnum;

Sessions.EPI = Sessions.EPI(sessToKeep);

Sessions.EPIresolution = Sessions.EPIresolution(sessToKeep);

end