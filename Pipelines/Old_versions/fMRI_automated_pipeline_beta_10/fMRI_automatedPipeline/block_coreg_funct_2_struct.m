function [block prefixNIIf batchNum] = block_coreg_funct_2_struct(Session,RegisterToMean,prefixNIIf,batchNum)
% 2014-07-07, @LREN, Renaud Marquis & Sandrine Muller, refacto
% 2014-07-07, @LREN, Renaud Marquis, refacto

%%% Coregister functional to structural

[p n e] = fileparts(Session.EPI{1}{1});
if RegisterToMean == 1
    if isempty(Session.Phase)
        block.spm.spatial.coreg.estimate.source = {strcat(p, filesep, 'bmean', n, e)}; % bias correction done anyway, but no prefix after mean (see block_bias_correct.m)
    else
        block.spm.spatial.coreg.estimate.source = {strcat(p, filesep, 'bmeanu', n, e)}; % bias correction done anyway, but no prefix after mean (see block_bias_correct.m)
    end
elseif RegisterToMean == 0
    block.spm.spatial.coreg.estimate.source = {strcat(p, filesep, prefixNIIf, n, e)};
else
    error('Unknown case for RegisterToMean')
end

block.spm.spatial.coreg.estimate.ref = Session.Struct; % here the reference is the struct

for i = 1:length(Session.EPI)
    for f = 1:length(Session.EPI{i})
        [p n e] = fileparts(Session.EPI{i}{f});
        Temp{f} = strcat(p, filesep, prefixNIIf, n, e);
    end
    ToCoreg{i} = Temp';
    clear Temp;
end

if iscellstr(ToCoreg)
    block.spm.spatial.coreg.estimate.other = ToCoreg;
else
    for sess = 1:length(ToCoreg)
        L = length(ToCoreg{sess});
        for F = 1:L
            temp{F,sess} = ToCoreg{sess}{F};
        end
    end
    KeepAligned = reshape(temp,size(temp,1)*size(temp,2),1);
    KeepAligned = KeepAligned(~cellfun(@isempty,KeepAligned));
    if RegisterToMean == 0
        KeepAligned = KeepAligned{2:end}; % prevent to coregister twice the first scan in case the first scan has been chosen for realignment (and therefore as source for coregistration, see above)
    end
    block.spm.spatial.coreg.estimate.other = KeepAligned;
end

block.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
block.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
block.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
block.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

prefixNIIf = ['' prefixNIIf];

batchNum = batchNum+1;

end