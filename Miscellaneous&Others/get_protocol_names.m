function protocol_names = get_protocol_names(ProtocolsFile,ProcessingSTep,MRIModality)

%% Anne Ruef, Lester Melie-Garcia
% LREN, CHUV.
% Lausanne, May 28th, 2014

if isempty(ProtocolsFile)
    [FileName,FilePath] = uigetfile('*.txt','Loading Protocols File ...');
    ProtocolsFile = [FilePath,FileName];
end;

% fid = fopen(ProtocolsFile);
% C = textscan(fid,'%s');
% fclose(fid);
% C = C{1};

C = Read_protocol_file(ProtocolsFile);
NL = length(C);
protocol_names = '';
ind = find(ismember(C,{ProcessingSTep}));
if isempty(ind)
    disp(['The ',ProcessingSTep,' is not defined in the Protocol file ....']);
    return;
end;

j1 = ind + 1;
while isempty(strfind(C{j1},MRIModality))
    j1 = j1 + 1;
    if j1>NL
        return;
    end;
end;
j2 = j1 + 1;
if (j2<=NL)&&(isempty(strfind(C{j2},'__')))
    while isempty(strfind(C{j2},'['))&&(isempty(strfind(C{j2},'__')))
        j2 = j2 + 1;
    end;
    protocol_names = char(C(j1+1:j2-1));
else
    protocol_names = '';
    disp(['For ',ProcessingSTep,' and ',MRIModality,', protocols do not exist....']);
end;

end

function C = Read_protocol_file(ProtocolsFile)

fid = fopen(ProtocolsFile,'r');
i=0; j=0;
C = {};
while ~feof(fid)
   i = i+1;
   jline = fgetl(fid);
   if ~isempty(deblank(jline))
       j = j + 1;
       C{j} = jline; %#ok<AGROW>
   end;
end;
fclose(fid);

end