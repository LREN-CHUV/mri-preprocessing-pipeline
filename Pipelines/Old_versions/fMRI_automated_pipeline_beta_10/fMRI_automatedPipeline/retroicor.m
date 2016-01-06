% physio_script.m
% Script that calls physio routines to construct physiological regressors
% acquired using Spike or BIOPAC system
% The main routine to create the physio regressors is make_physio_regressors
%
% USAGE:
%
% [R oR] = physio_script(physiofile,rpfile,nslices,ndummies,sliceTR,...
%               nsessions,slicenum,sliceorder,samplingrate,nvols)
%
%_______________________________________________________________________
% INPUTS:
%
% physiofile : string, absolute path to physiological data file
%
% rpfile : string, absolute path to realignment parameters file
%
% nslices : scalar, number of effective * slices per volume
%           * (beware of oversampling (PAT) in 3D EPI sequences)
%
% ndummies : scalar, number of dummy scans
%
% sliceTR : scalar, slice TR in seconds
%
% nsessions : scalar, number of sessions per physiological data file
% (currently multiple sessions has not been tested for LREN recordings using
% BIOPAC system)
%
% slicenum : scalar, reference slice, typically half the number of slices
% (nslices)
%
% sliceorder : string, order of acquisition of slices. Can be 'ascending'
% (by default, if input is empty), 'descending' or 'interleaved'.
%
% samplingrate : scalar, sampling rate in Hz of acquired physiological data
%
% nvols : number of EPI volumes acquired in the experimental run
%
%_______________________________________________________________________
% OUTPUTS:
%
% R : 20 x nvols regressors, including physiological regressors and
% movement parameters
%
% oR : 14 x nvols regressors, including physiological regressors only
%
% The routine also saves 6 .mat files, with different suffixes:
%
%       - "cardiac_session" : 6 x nvols matrix, only the cardiac regressors
%
%       - "cardiacqrs_session" : same but with cardiacqrs
%
%       - "respire_session" : same but also with the respiratory regressors
%
%       - "rvt_session" : same but with respiratory volume and heart rate
%
%       - "R_session" : 14 x nvols matrix, only the physiological regressors
%
%       - "RP_session" : 20 x nvols matrix, physiological regressors
%       concatenated with realignment parameters
%_______________________________________________________________________
%
% Example:
% 
% retroicor('C:\DATA\physio_file3.mat',...
%  'C:\DATA\rp_fPR00151-101231-00001-00001-1.txt',52,0,52e-3,1,26,
%  'ascending',1250,263)
%
%_______________________________________________________________________
% Refs and Background reading:
% 
% The implementation of this toolbox is described in:
% Hutton et al, 2011, NeuroImage.
% 
% The methods are based on the following:
% Glover et al, 2000, MRM, (44) 162-167 
% Josephs et al, 1997, ISMRM, p1682
% Birn et al, 2006, NeuroImage, (31) 1536-1548
%
%________________________________________________________
% (c) Wellcome Trust Centre for NeuroImaging (2010)

% Chloe Hutton
% $Id: physio_script.m $

%--------------------------------------------------------------------------
% Renaud Marquis @ LREN, refacto
%--------------------------------------------------------------------------

function [R oR] = retroicor(physiofile,rpfile,nslices,ndummies,sliceTR,nsessions,slicenum,sliceorder,samplingrate,nvols)

TRms=sliceTR*1e3; % TR but in ms

% The above slice number can be determined from
% data converted to nifti format. By default, slices
% will be numbered from bottom to top but the acquisition
% order can be ascending, descending or interleaved.
% If slice order is descending or interleaved, the slice number
% must be adjusted to represent the time at which the slice of
% interest was acquired:
if isempty(sliceorder)
    sliceorder='ascending'; % Ascending by default.
end
slicenum=get_slicenum(slicenum,nslices,sliceorder);

RP=load(rpfile);

% The channel numbers must be assigned as they have been in spike.
% Unused channels should be set to empty using [];
% The channel numbers can be checked using the routines 
% show_channels and check_channels as demonstrated below.
% Once the channels have been set correctly, they should
% stay the same when using spike with the same set-up and
% configuration file.

if strcmp(physiofile(end-3:end),'.mat') == 1
    % show_channels(physiofile);
    %%% line above commented !!
    scanner_channel=3;
    cardiacTTL_channel=1;
    cardiacQRS_channel=[];
    resp_channel=2;
    % check_channels(physiofile,scanner_channel,cardiacTTL_channel,cardiacQRS_channel,resp_channel);
    %%% line above commented !!
else
    show_channels(physiofile);
    scanner_channel=1;
    cardiacTTL_channel=2;
    cardiacQRS_channel=[];
    resp_channel=4;
    check_channels(physiofile,scanner_channel,cardiacTTL_channel,cardiacQRS_channel,resp_channel);
end

% Call the main routine for calculating physio regressors
% NB - currently the cardiacqrs calculation is disabled.
[cardiac,cardiacqrs,respire,rvt]=make_physio_regressors(physiofile,nslices,ndummies,sliceTR,samplingrate, nvols,...
                slicenum,nsessions,scanner_channel,cardiacTTL_channel,cardiacQRS_channel,resp_channel);               
   
% Save a record of parameters used for the regressors
%eval(['save ' spm_str_manip(physiofile,'r') '_physioparams physiofile nslices ndummies TRms slicenum nsessions']);
filename=[spm_str_manip(physiofile,'r'), '_physioparams'];
save(filename, 'physiofile', 'nslices', 'ndummies', 'TRms','slicenum','nsessions','sliceorder');

% Save a record of parameters used for the regressors
%eval(['save ' spm_str_manip(physiofile,'r') '_physioparams physiofile nslices ndummies TRms slicenum nsessions']);
filename=[spm_str_manip(physiofile,'r'), '_physioparams'];
save(filename, 'physiofile', 'nslices', 'ndummies', 'TRms','slicenum','nsessions','sliceorder');

% For each session, put regressors in a matrix called R.
% Each individual set of regressors are saved and also all regressors are saved with the name 'physiofile_R_session%d'. 
% These files can be loaded into an SPM design matrix using the 'Multiple Regressors' option.
% NB motion parameters can also be concatenated with the physio regressors 
% and saved as a set of regressors called R (see below for example)

for sessnum=1:nsessions
   R=[];
   if ~isempty(cardiac{sessnum}) & ~isempty(cardiac{sessnum})
      cardiac_sess = cardiac{sessnum};
      filename = sprintf('%s_cardiac_session%d',spm_str_manip(physiofile,'r'),sessnum);
      save(filename, 'cardiac_sess');    
      R=cat(2,R,cardiac{sessnum}(:,1:6));
   end
   if ~isempty(cardiacqrs{sessnum}) & ~isempty(cardiacqrs{sessnum})
      cardiacqrs_sess = cardiacqrs{sessnum};
      filename = sprintf('%s_cardiacqrs_session%d',spm_str_manip(physiofile,'r'),sessnum); 
      save(filename, 'cardiacqrs_sess');
      R=cat(2,R,cardiacqrs{sessnum}(:,1:6));
   end
   if ~isempty(respire) & ~isempty(respire{sessnum})
      respire_sess = respire{sessnum};
      filename = sprintf('%s_respire_session%d',spm_str_manip(physiofile,'r'),sessnum); 
      save(filename, 'respire_sess');
      R=cat(2,R,respire{sessnum}(:,1:6));
   end
   if ~isempty(rvt) & ~isempty(rvt{sessnum})
      rvt_sess = rvt{sessnum};
      filename = sprintf('%s_rvt_session%d',spm_str_manip(physiofile,'r'),sessnum); 
      save(filename,'rvt_sess');
      R=cat(2,R,rvt{sessnum}(:,1:size(rvt{sessnum},2)));
   end
   nfiles=size(R,1);
   % Save R for all physio only 
   if nfiles>0
      oR=R;
      Rname = sprintf('%s_R_session%d',spm_str_manip(physiofile,'r'),sessnum);
      R=R-repmat(mean(R),nfiles,1);
      save(Rname, 'R');
   end
%    If required, also concatenate with motion params, e.g.
if size(RP,1) ~= size(oR,1)
    R=cat(2,oR,RP(ndummies+1:end,:)); % in this case the dummy scans were not removed before realignment and the realignment parameters contain ndummies additional lines
else
    R=cat(2,oR,RP);
end
  
  R=R-repmat(mean(R),nfiles,1);
  Rname = sprintf('%s_RP_session%d',spm_str_manip(physiofile,'r'),sessnum);
  save(Rname, 'R');   
end

% % Add necessary folders to path
% [spm_path,name]=fileparts(which('spm'));
% physiopath=sprintf('%s%s%s',spm_path,filesep,'toolbox',filesep,'physio');
% addpath(physiopath);
% sonpath=sprintf('%s%s%s%s%s',spm_path,filesep,'toolbox',filesep,'physio',filesep,'son');
% addpath(sonpath);

% if nargin<7
    % Add name of physio file
%     physiofile='physio_example.smr';
%     rpfile='rp_fMQ0613-0007-00001-000001-01.txt';

% FIL test
%     physiofile='C:\DATA\Software\Physio_example\PhysiologicalData\Physio3D.smr';
%     rpfile='C:\DATA\Software\Physio_example\PhysiologicalData\rp_bfMT01629-0004-00001-000001-01.txt';
%     
%     % Input values that must be defined correctly for specific acquisition
%     nslices=40;  % Number of slices in volume
%     ndummies=0;  % Number of scans excluded from analysis
%     TR=80e-3;       % Slice TR in secs
%     nsessions=1; % Number of scanning sessions in the file
%     slicenum=20; 
%     RespSampling=[];

% LREN test
% physiofile='C:\DATA\physio.mat';
%     rpfile='C:\DATA\rp_fPR00235-0002-00006-000006-01.txt';
%     
%     % Input values that must be defined correctly for specific acquisition
%     nslices=49;  % Number of slices in volume
%     ndummies=5;  % Number of scans excluded from analysis
%     TR=66e-3;       % Slice TR in secs
%     nsessions=1; % Number of scanning sessions in the file
%     slicenum=25; % Slice number to time-lock regressors to
%     
%     RespSampling=1250;
%     nvols = 125;
    
    % RM test:
%     TRvol = [1.98 4.032 2.704]; % 3mm, 1.5mm, 2mm
%     nsessions = 1; % Number of scanning sessions in the file
%     sliceorder='descending';

%     % 3mm
%     physiofile='C:\DATA\physio_file1.mat';
%     rpfile='C:\DATA\rp_fPR00151-094615-00006-00006-1.txt';
%     
%     nslices = 30;
%     TR = 66e-3;
%     slicenum = 15;
%     ndummies = 5;
%     RespSampling=2000;
%     nvols = 364; % not 359, this is the number of volumes without dummies!!!
%     
%     % 1.5mm
%     physiofile='C:\DATA\physio_file2.mat';
%     rpfile='C:\DATA\rp_fPR00151-095933-00001-00001-1.txt';
%     
%     nslices = 64;
%     TR = 63e-3;
%     slicenum = 32;
%     ndummies = 0;
%     RespSampling=2000;
%     nvols = 176;

%     % 2mm
%     physiofile='C:\DATA\physio_file3.mat';
%     rpfile='C:\DATA\rp_fPR00151-101231-00001-00001-1.txt';
%     
%     nslices = 52;
%     sliceTR = 52e-3;
%     slicenum = 26;
%     ndummies = 0;
%     
%     samplingrate=2000;
%     nvols = 263;
    
% end