function dtiFitTensorCNLLS(rawDWIdata,bval,bvec,outputdir,voxelsize,doMask,TPMfilename)

% ,dobootstrap,nboots)

% This function will fit the diffusion tensor to raw DWI data using a
% constrained non-linear least squares fitting approach (CNLLS).
% Maps are saved as nifti files for a variety of key tensor and data
% quality measures.

% Fitting preceedure described by Koay, Chapter 16, Diffusion MRI, 2011.


%% Prepare data

% If inputs are file locations then load data
if ischar(rawDWIdata)
    rawfilename=rawDWIdata;
    rawDWIdata=niftiRead(rawDWIdata);
    rawDWIimg=rawDWIdata.data;
end
if ischar(bval)
    bval = dlmread(bval);
end
if ischar(bvec)
    bvec = dlmread(bvec);
end

[~, filename] = fileparts(rawfilename);
splitrawname = strsplit(filename,'.');
mnb0name=[char(splitrawname(1)) '_mnb0.nii'];
maskname=[char(splitrawname(1)) '_mnb0_mask.nii'];

% Create default nii structure for 3d maps
niiorigin=[rawDWIdata.qoffset_x rawDWIdata.qoffset_y rawDWIdata.qoffset_z];


%% Use SPM batch function 'brain_mask' to define mask from average b0

if ~exist([outputdir '\' maskname],'file') || doMask==1
    CreateMeanB0(rawDWIdata, bval, [outputdir '\' mnb0name]);
    gunzip([outputdir '\*.gz'])
    pause(2)
    brain_mask([outputdir '\' mnb0name],[outputdir '\' maskname],TPMfilename);
end
brainmask=[outputdir '\' maskname];
brainmask=niftiRead(brainmask);
brainmask=brainmask.data;
brainmask(brainmask>0)=1;
numVox=sum(sum(sum(brainmask)));

%% Limit tensor estimates to data with b-value<=1500s/mm^2
dtiInds=find(bval<=1500);
bval=bval(1,dtiInds);
bvec=bvec(:,dtiInds);
rawDWIimg=rawDWIimg(:,:,:,dtiInds);


%% Define future map variables

[XX, YY, ZZ, Vols]=size(rawDWIimg);

MDmap=zeros(XX,YY,ZZ);
FAmap=zeros(XX,YY,ZZ);
ADmap=zeros(XX,YY,ZZ);
RDmap=zeros(XX,YY,ZZ);
CLmap=zeros(XX,YY,ZZ);
CPmap=zeros(XX,YY,ZZ);
CSmap=zeros(XX,YY,ZZ);
FAcolourmap=zeros(XX,YY,ZZ,3);
ResidualMaps=zeros(XX,YY,ZZ,Vols);
mnResMap=zeros(XX,YY,ZZ);
CPe3colourmap=zeros(XX,YY,ZZ,3);
costfun_changemap=zeros(XX,YY,ZZ);
count=0;
percent_complete=0;

%% Define design matrix W
W=zeros(Vols,7);
W(:,1)=1;

for i=1:Vols
    
    gx=bvec(1,i);
    gy=bvec(2,i);
    gz=bvec(3,i);
    
    b=bval(1,i);
    
    W(i,2)=-b*gx^2;
    W(i,3)=-b*gy^2;
    W(i,4)=-b*gz^2;
    W(i,5)=-2*b*gx*gy;
    W(i,6)=-2*b*gy*gz;
    W(i,7)=-2*b*gx*gz;
end

%% Heuristic parameters for colour map correction
pE=1; % Colour brightness equalization. on=1, off=0.
pB=0.3; % Reduced blue saturation
LE=0.7; % Colour scaling reference
pC=1; % Control parameter. Enabled parameters pC=1. Disabled pC=0
pBETA=1; % <1 emphasises low anisotropy values
BETA=0.5; % Relates luminosity to percieved brightness
GAMMA=1.5; % Gamma correction parameter

%% Estimate tensor parameters for each voxel
fprintf(1,'Estimating tensors. Percent complete:  %d',percent_complete);
for zz=1:ZZ
    percent_complete=round(count/numVox*100);
    if percent_complete==100
        fprintf(1,'\b\b\b%d',percent_complete);
    else if percent_complete>=10
            fprintf(1,'\b\b%d',percent_complete);
        else
            fprintf(1,'\b%d',percent_complete);
        end
    end
    for yy=1:YY
        for xx=1:XX
            if min(squeeze(rawDWIimg(xx,yy,zz,:)))>0 && brainmask(xx,yy,zz)>0
                count=count+1;
                
                % Define log signal column vector yi=ln(si)
                s=double(squeeze(rawDWIimg(xx,yy,zz,:)));
                y=log(s);
                
                % Estimate weighted-least-squares tensor fit
                S=diag(s);
                M=S*W;
                t=S*y;
                
                p=pinv(M.'*M)*M.'*t;
                
                % Use WLLS estimate of p as input vector to CNLLS
                % estimation
                [CNLLS_pvec, ~, costfun_change]=MFN_CNLLS_tensor_estimate(W,p,s,1,100);
                
                % Convert back into positive definite Dij space using
                % Cholesky composition
                p=CholeskyComposition(CNLLS_pvec);
                
                % Define diffusion tensor D
                D=zeros(3,3);   
                
                D(1,1)=p(2,1);  D(1,2)=p(5,1);  D(1,3)=p(7,1);
                D(2,1)=D(1,2);  D(2,2)=p(3,1);  D(2,3)=p(6,1);
                D(3,1)=D(1,3);  D(3,2)=D(2,3);  D(3,3)=p(4,1);
                
                % Derive diffusion metrics from tensor and make maps
                [eigVec,eigVal] = eig(D);
                
                l1=eigVal(3,3);
                l2=eigVal(2,2);
                l3=eigVal(1,1);
                
                e1=eigVec(:,3);
                e2=eigVec(:,2);
                e3=eigVec(:,1);
                
                % Calculate residuals from tensor fit
                Residuals=y-W*p;
                ResidualMaps(xx,yy,zz,:)=Residuals;
                mnResMap(xx,yy,zz)= mean(Residuals.^2);
                costfun_changemap(xx,yy,zz)=costfun_change;
                
                % Create MD, FA, AD and RD maps
                MD=(l1+l2+l3)/3;
                MDmap(xx,yy,zz)=MD;
                Var_eigs=((l1-MD)^2+(l2-MD)^2+(l3-MD)^2)/3;
                FA=(3/2^0.5)*Var_eigs^0.5/(l1^2+l2^2+l3^2)^0.5;
                FAmap(xx,yy,zz)=FA;
                AD=l1;
                ADmap(xx,yy,zz)=AD;
                RD=(l2+l3)/2;
                RDmap(xx,yy,zz)=RD;
                
                % Define Westin metrics(linear=CL, planar=CP, spherical=CS)
                % and create maps
                CL=(l1-l2)/l1;
                CP=(l2-l3)/l1;
                CS=l3/l1;
                CLmap(xx,yy,zz)=CL;
                CPmap(xx,yy,zz)=CP;
                CSmap(xx,yy,zz)=CS;
                
                RI=abs(e3(1,1));    GI=abs(e3(2,1));    BI=abs(e3(3,1));
                
                bb=BI/(RI+GI+BI);
                CB=max([(3/2)*pB*(bb-1/3)*pC, 0]);
                
                RS=CB*BI+(1-CB)*RI;
                GS=CB*BI+(1-CB)*GI;
                BS=BI;
                
                c1=1/3-pE/25;   c2=1/3+pE/4;    c3=1-c1-c2;
                
                FL=min([(c1*RS+c2*GS+c3*BS)/(LE^(1/BETA)), 1]);
                LM=max([RS,GS,BS]);
                LF=pC*FL+(1-pC)*LM;
                
                fR=255*(abs(CP)^pBETA*RS/LF)^(1/GAMMA);
                fG=255*(abs(CP)^pBETA*GS/LF)^(1/GAMMA);
                fB=255*(abs(CP)^pBETA*BS/LF)^(1/GAMMA);

                CPe3colourmap(xx,yy,zz,1)=fR;
                CPe3colourmap(xx,yy,zz,2)=fG;
                CPe3colourmap(xx,yy,zz,3)=fB;
                
                % Create directionally encoded colour (DEC) maps
                RI=abs(e1(1,1));    GI=abs(e1(2,1));    BI=abs(e1(3,1));
                
                bb=BI/(RI+GI+BI);
                CB=max([(3/2)*pB*(bb-1/3)*pC, 0]);
                
                RS=CB*BI+(1-CB)*RI;
                GS=CB*BI+(1-CB)*GI;
                BS=BI;
                
                c1=1/3-pE/25;   c2=1/3+pE/4;    c3=1-c1-c2;
                
                FL=min([(c1*RS+c2*GS+c3*BS)/(LE^(1/BETA)), 1]);
                LM=max([RS,GS,BS]);
                LF=pC*FL+(1-pC)*LM;
                
                fR=255*(FA^pBETA*RS/LF)^(1/GAMMA);
                fG=255*(FA^pBETA*GS/LF)^(1/GAMMA);
                fB=255*(FA^pBETA*BS/LF)^(1/GAMMA);
                
                FAcolourmap(xx,yy,zz,1)=fR;
                FAcolourmap(xx,yy,zz,2)=fG;
                FAcolourmap(xx,yy,zz,3)=fB;
                
                % Perform residual bootstrap nboots times if
                % dobootstrap=true
%                 if dobootstrap
%                     for n=1:nboots
%                         
%                         
%                         
%                     end
%                 end
                
                
            end
        end
    end
end

fprintf(1,'\b\b 100 \n');
fprintf(1,'Finished CNLLS tensor estimation \n');

% Make folder for Westin metric maps
if ~exist([outputdir '\WestinMetrics'])
    mkdir([outputdir '\WestinMetrics'])
end

% Make folder for QA maps
if ~exist([outputdir '\Residuals'])
    mkdir([outputdir '\Residuals'])
end

MDmap_nii=make_nii(MDmap,voxelsize,niiorigin,16);
FAmap_nii=make_nii(FAmap,voxelsize,niiorigin,16);
ADmap_nii=make_nii(ADmap,voxelsize,niiorigin,16);
RDmap_nii=make_nii(RDmap,voxelsize,niiorigin,16);
CLmap_nii=make_nii(CLmap,voxelsize,niiorigin,16);
CPmap_nii=make_nii(CPmap,voxelsize,niiorigin,16);
CSmap_nii=make_nii(CSmap,voxelsize,niiorigin,16);
FAcolourmap_nii=make_nii(FAcolourmap,voxelsize,niiorigin,128);
ResidualMaps_nii=make_nii(ResidualMaps,voxelsize,niiorigin,16);
mnResMap_nii=make_nii(mnResMap,voxelsize,niiorigin,16);
costfun_changemap_nii=make_nii(costfun_changemap,voxelsize,niiorigin,16);
CPe3colourmap_nii=make_nii(CPe3colourmap,voxelsize,niiorigin,128);


save_nii(MDmap_nii,[outputdir '\' filename '_MDmap.nii'])
save_nii(FAmap_nii,[outputdir '\' filename '_FAmap.nii'])
save_nii(ADmap_nii,[outputdir '\' filename '_ADmap.nii'])
save_nii(RDmap_nii,[outputdir '\' filename '_RDmap.nii'])
save_nii(CLmap_nii,[outputdir '\WestinMetrics\' filename '_CLmap.nii'])
save_nii(CPmap_nii,[outputdir '\WestinMetrics\' filename '_CPmap.nii'])
save_nii(CSmap_nii,[outputdir '\WestinMetrics\' filename '_CSmap.nii'])
save_nii(FAcolourmap_nii,[outputdir '\' filename '_FAcol.nii'])
save_nii(ResidualMaps_nii,[outputdir '\Residuals\' filename '_Resmap.nii'])
save_nii(costfun_changemap_nii,[outputdir '\Residuals\' filename '_CostfunChange.nii'])
save_nii(mnResMap_nii,[outputdir '\Residuals\' filename '_mnResmap.nii'])
save_nii(CPe3colourmap_nii,[outputdir '\WestinMetrics\' filename '_CPe3col.nii'])

if(numel(rawDWIdata.pixdim)>3), TR = rawDWIdata.pixdim(4);
    else                       TR = 1;
end
    
dtiWriteNiftiWrapper(rawDWIimg, rawDWIdata.qto_xyz, [outputdir '\' char(splitrawname(1)) '_DTIvols.nii'], 1, 'DWI volumes used for the DTI estimation', [],[],[],[], TR);
dlmwrite([outputdir '\' char(splitrawname(1)) '_DTIvols.bval'],bval);
dlmwrite([outputdir '\' char(splitrawname(1)) '_DTIvols.bvec'],bvec);

delete([outputdir '\c*mnb0.nii'],[outputdir '\*seg8.mat'])

