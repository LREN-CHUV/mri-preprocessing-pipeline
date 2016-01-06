function block = mask_MT_with_PDw(MTimg, PDwImg, varargin)
% Mask MT map with PD-weighted map
%
% Creates a new MT map that is identical to the original MT map except that
% all voxels where the corresponding PD-weighted map are set to 0
%
% Optional argument (3rd) sets the threshold (by default >100)
%
% Renaud Marquis @ LREN, 2014-08-18

if nargin < 2
    MTimg = spm_select(1,'image','Select the MT map',{},pwd);
    PDwImg = spm_select(1,'image','Select the PDw map',{},pwd);
end

if nargin < 3
    threshold = 100;
else
    threshold = varargin{1};
end

% PDwImg = cellstr(spm_select('ExtFPListRec',[Root,'\MPMs'],strcat('^*PDw.nii')));
% MTimg = cellstr(spm_select('ExtFPListRec',[Root,'\MPMs'],strcat('^*MT.nii')));

% check whether filepath is specified using spm_select, cellstr of
% spm_select, or cell of cell of strings for PDw...
if ~isstr(PDwImg) && ~iscellstr(PDwImg)
    PDwImg = PDwImg{:};
elseif ~isstr(PDwImg) && iscellstr(PDwImg)
    % OK
elseif isstr(PDwImg)
    PDwImg = {PDwImg};
else
    error('Cannot detect format of path to file')
end

% ...same with MT
if ~isstr(MTimg) && ~iscellstr(MTimg)
    MTimg = MTimg{:};
elseif ~isstr(MTimg) && iscellstr(MTimg)
    % OK
elseif isstr(MTimg)
    MTimg = {MTimg};
else
    error('Cannot detect format of path to file')
end

Files = [PDwImg;MTimg];

[p n e] = fileparts(MTimg{:});

e = regexprep(e,',1','');

block.spm.util.imcalc.input = Files;
block.spm.util.imcalc.output = strcat(p,filesep,'masked_',n,e);
block.spm.util.imcalc.outdir = {fileparts(Files{1,:})};
block.spm.util.imcalc.expression = strcat('(i1>', threshold, ').*i2');
block.spm.util.imcalc.var = struct('name', {}, 'value', {});
block.spm.util.imcalc.options.dmtx = 0;
block.spm.util.imcalc.options.mask = 0;
block.spm.util.imcalc.options.interp = 1;
block.spm.util.imcalc.options.dtype = 4;

end