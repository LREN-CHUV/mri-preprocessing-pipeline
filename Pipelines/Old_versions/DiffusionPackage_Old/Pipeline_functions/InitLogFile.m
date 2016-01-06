function [Subject, Session, Repeat, Date, Time] = InitLogFile(LogPath,SubjectID,SessionNum,RepeatNum)

DateNumber = num2str(now);
DayTime = strsplit(DateNumber,'.');
DateNumber = DayTime{1};
TimeNumber = DayTime{2};

if exist(LogPath,'file')
    load(LogPath)
end

Subject = genvarname(SubjectID);
Session = genvarname(['Session' num2str(SessionNum)]);
Repeat  = genvarname(['Repeat' num2str(RepeatNum)]);
Date    = genvarname(['Date' DateNumber]);
Time    = genvarname(['Time' TimeNumber]);

eval([Subject '.' Session '.' Repeat '.' Date '.' Time '.EC_corrected = 0;']);
eval([Subject '.' Session '.' Repeat '.' Date '.' Time '.FieldMap_corrected = 0;']);
eval([Subject '.' Session '.' Repeat '.' Date '.' Time '.MNI_transformed = 0;']);
eval([Subject '.' Session '.' Repeat '.' Date '.' Time '.DTIfitting = 0;']);
eval([Subject '.' Session '.' Repeat '.' Date '.' Time '.NODDIfitting = 0;']);
eval([Subject '.' Session '.' Repeat '.' Date '.' Time '.HARDIpath = [];']);
eval([Subject '.' Session '.' Repeat '.' Date '.' Time '.HARDIfitting = 0;']);
eval([Subject '.' Session '.' Repeat '.' Date '.' Time '.PreprocessedPath = [];']);
eval([Subject '.' Session '.' Repeat '.' Date '.' Time '.DKIfitting = 0;']);

clear SubjectID SessionNum RepeatNum DateNumber DayTime DateNumber ...
        TimeNumber Subject Session Repeat Date

save(LogPath)

end;