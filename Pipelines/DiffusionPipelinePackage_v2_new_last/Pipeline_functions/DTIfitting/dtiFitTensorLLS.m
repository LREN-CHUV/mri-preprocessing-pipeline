function dtiFitTensorLLS(rawDWIdata,bval,bvec,outputdir,voxelsize,doMask,TPMfilename)

% This function will fit the diffusion tensor to raw DWI data using a
% simple linear-least squares fitting approach (LLS).
% Maps are saved as nifti files for a variety of key tensor and data
% quality measures.


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

%% Limit tensor estimates to data with b-value<=1500s/mm^2
dtiInds=find(bval<=1500);
bval=bval(1,dtiInds);
bvec=bvec(:,dtiInds);
rawDWIimg=rawDWIimg(:,:,:,dtiInds);
numb0 = length(find(bval==0));


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
dt6 = zeros(XX,YY,ZZ,6);

%% Define design matrix W1 (full b-matrix)
W1=zeros(Vols,7);
W1(:,1)=1;

for i=1:Vols
    
    gx=bvec(1,i);
    gy=bvec(2,i);
    gz=bvec(3,i);
    
    b=bval(1,i);
    
    W1(i,2)=-b*gx^2;
    W1(i,3)=-b*gy^2;
    W1(i,4)=-b*gz^2;
    W1(i,5)=-2*b*gx*gy;
    W1(i,6)=-2*b*gy*gz;
    W1(i,7)=-2*b*gx*gz;
end

%% Heuristic parameters for colour map correction
pE=1; % Colour brightness equalization. on=1, off=0.
pB=0.35; % Reduced blue saturation
LE=0.7; % Colour scaling reference
pC=0.7; % Control parameter. Enabled parameters pC=1. Disabled pC=0
pBETA=1; % <1 emphasises low anisotropy values
BETA=0.4; % Relates luminosity to percieved brightness
GAMMA=1.8; % Gamma correction parameter

%% Estimate tensor parameters for each voxel

for zz=1:ZZ
    for yy=1:YY
        for xx=1:XX
            if brainmask(xx,yy,zz)>0
                
                % Define log signal column vector yi=ln(si)
                s=double(squeeze(rawDWIimg(xx,yy,zz,:)));
                % Set working b-matrix to full b-matrix
                W=W1;
                
                % If voxels with zero intensity exist remove them from the
                % tensor estimation (avoids estimation failures when using
                % the b-spline interpolation method)
                nonzero_inds = find(s>0);
                if length(nonzero_inds) >= (numb0 + 6)
                    
                    W = W(nonzero_inds,:);
                    s = s(nonzero_inds);
                    
                    
                    y=log(s);
                    
                    % Estimate least-squares tensor fit
                    p=pinv(W.'*W)*W.'*y;
                    
                    % Define diffusion tensor D
                    D=zeros(3,3);
                    
                    D(1,1)=p(2,1);  D(1,2)=p(5,1);  D(1,3)=p(7,1);
                    D(2,1)=D(1,2);  D(2,2)=p(3,1);  D(2,3)=p(6,1);
                    D(3,1)=D(1,3);  D(3,2)=D(2,3);  D(3,3)=p(4,1);
                    
                    % Create VistaSoft type dt6 file
                    dt6(xx,yy,zz,:) = [D(1,1) D(2,2) D(3,3) D(1,2) D(1,3) D(2,3)];
                    
                    % Derive diffusion metrics from tensor and make maps
                    [eigVec,eigVal] = eig(D);
                    
                    l1=eigVal(3,3);
                    l2=eigVal(2,2);
                    l3=eigVal(1,1);
                    
                    e1=eigVec(:,3);
                    e2=eigVec(:,2);
                    e3=eigVec(:,1);
                    
                    % Calculate residuals from tensor fit
                    Residuals=abs(y-W*p);
                    Res_vec = zeros(1,Vols);
                    Res_vec(nonzero_inds) = Residuals;
                    ResidualMaps(xx,yy,zz,:)=Res_vec;
                    mnResMap(xx,yy,zz)= mean(Residuals.^2);
                    
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
end

% Make folder for Westin metric maps
if ~exist([outputdir '\WestinMetrics'])
    mkdir([outputdir '\WestinMetrics'])
end

% Make folder for QA maps
if ~exist([outputdir '\Residuals'])
    mkdir([outputdir '\Residuals'])
end

FAcolourmap_nii=make_nii(FAcolourmap,voxelsize,niiorigin,128);
ResidualMaps_nii=make_nii(ResidualMaps,voxelsize,niiorigin,16);
mnResMap_nii=make_nii(mnResMap,voxelsize,niiorigin,16);
CPe3colourmap_nii=make_nii(CPe3colourmap,voxelsize,niiorigin,128);


if(numel(rawDWIdata.pixdim)>3), TR = rawDWIdata.pixdim(4);
else                       TR = 1;
end

dtiWriteNiftiWrapper(MDmap, rawDWIdata.qto_xyz, [outputdir filesep filename '_MDmap.nii'], 1, '', [],[],[],[], TR);
dtiWriteNiftiWrapper(FAmap, rawDWIdata.qto_xyz, [outputdir filesep filename '_FAmap.nii'], 1, '', [],[],[],[], TR);
dtiWriteNiftiWrapper(ADmap, rawDWIdata.qto_xyz, [outputdir filesep filename '_ADmap.nii'], 1, '', [],[],[],[], TR);
dtiWriteNiftiWrapper(RDmap, rawDWIdata.qto_xyz, [outputdir filesep filename '_RDmap.nii'], 1, '', [],[],[],[], TR);
dtiWriteNiftiWrapper(CLmap, rawDWIdata.qto_xyz, [outputdir filesep 'WestinMetrics' filesep filename '_CLmap.nii'], 1, '', [],[],[],[], TR);
dtiWriteNiftiWrapper(CPmap, rawDWIdata.qto_xyz, [outputdir filesep 'WestinMetrics' filesep filename '_CPmap.nii'], 1, '', [],[],[],[], TR);
dtiWriteNiftiWrapper(CSmap, rawDWIdata.qto_xyz, [outputdir filesep 'WestinMetrics' filesep filename '_CSmap.nii'], 1, '', [],[],[],[], TR);
dtiWriteNiftiWrapper(dt6, rawDWIdata.qto_xyz, [outputdir filesep filename '_dt6.nii'], 1, '', [],[],[],[], TR);

save_nii(FAcolourmap_nii,[outputdir filesep filename '_FAcol.nii'])
save_nii(ResidualMaps_nii,[outputdir filesep 'Residuals' filesep filename '_Resmap.nii'])
save_nii(mnResMap_nii,[outputdir filesep 'Residuals' filesep filename '_mnResmap.nii'])
save_nii(CPe3colourmap_nii,[outputdir filesep 'WestinMetrics' filesep filename '_CPe3col.nii'])


dtiWriteNiftiWrapper(rawDWIimg, rawDWIdata.qto_xyz, [outputdir filesep char(splitrawname(1)) '_DTIvols.nii'], 1, 'DWI volumes used for the DTI estimation', [],[],[],[], TR);
dlmwrite([outputdir filesep char(splitrawname(1)) '_DTIvols.bval'],bval);
dlmwrite([outputdir filesep char(splitrawname(1)) '_DTIvols.bvec'],bvec);

DTI_data_quality_check([outputdir filesep 'Residuals' filesep filename '_Resmap.nii'],[outputdir filesep maskname])

delete([outputdir filesep 'c*mnb0.nii'],[outputdir filesep '*seg8.mat'])