function Schemepath = fsl2scheme(bvals,bvecs,outpath)

% Convert fsl format bvals and bvecs to Camino scheme format
% Format used will be the STEJSKALTANNER case where acquisition parameters
% are reverse engineered from the bval and bvec files



% If chars load bvals/bvecs
if ischar(bvals)
    if exist(bvals,'file')
%         bvals = dlmread(bvals);
    else [bvalName,bvalPath] = uigetfile([pwd '*.bval'],'Please select the bval file');
%         bvals = dlmread([bvalPath filesep bvalName]);
    end
end
if ischar(bvecs)
    if exist(bvecs,'file')
%         bvecs = dlmread(bvecs);
    else [bvecName,bvecPath] = uigetfile([pwd '*.bvec'],'Please select the bvec file');
%         bvecs = dlmread([bvecPath filesep bvecName]);
    end
end

protocol = FSL2Protocol(bvals, bvecs);

STEJSKALTANNERscheme = zeros(length(protocol.G),7);
TE = (protocol.delta + protocol.smalldel)*1.2;
STEJSKALTANNERscheme(:,1:3) = protocol.grad_dirs;
STEJSKALTANNERscheme(:,4) = protocol.G;
STEJSKALTANNERscheme(:,5) = protocol.delta;
STEJSKALTANNERscheme(:,6) = protocol.smalldel;
STEJSKALTANNERscheme(:,7) = TE;

Scheme_mtrx = STEJSKALTANNERscheme;
formatSpec = 'VERSION: STEJSKALTANNER\n';

fileID = fopen(outpath,'w');
fprintf(fileID,formatSpec);
fclose(fileID);

dlmwrite(outpath,Scheme_mtrx,'-append','delimiter','\t')

Schemepath = outpath;