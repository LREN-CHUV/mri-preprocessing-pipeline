function [ D, eigVal, eigVec ] = WLLS_FitTensor( s, bMATRIX )

warning('off','all')

% Find datapoints to exclude
Inds = find(s);
s = s(Inds);
bMATRIX = bMATRIX(Inds,:);

% Only use bvals less than 1500 s/mm^2 for DTI fit
bvals = (bMATRIX(:,1)+bMATRIX(:,4)+bMATRIX(:,6));
if max(bvals)>10^6
    bvals = bvals/10^6;
end
Inds = find(bvals<1600);
s = s(Inds);
bMATRIX = bMATRIX(Inds,:);

% Convert AMICO bMATRIX into compatible format for fitting
W=zeros(length(s),7);
W(:,1)=1;
W(:,2)=-bMATRIX(:,1);
W(:,3)=-bMATRIX(:,4);
W(:,4)=-bMATRIX(:,6);
W(:,5)=-bMATRIX(:,2);
W(:,6)=-bMATRIX(:,5);
W(:,7)=-bMATRIX(:,3);

% Define log signal column vector yi=ln(si)
y=log(s);

% Estimate weighted-least-squares tensor fit
S=diag(s);
M=S*W;
t=S*y;

p=pinv(M.'*M)*M.'*t;

% Define diffusion tensor D
D=zeros(3,3);

D(1,1)=p(2,1);  D(1,2)=p(5,1);  D(1,3)=p(7,1);
D(2,1)=D(1,2);  D(2,2)=p(3,1);  D(2,3)=p(6,1);
D(3,1)=D(1,3);  D(3,2)=D(2,3);  D(3,3)=p(4,1);

[ V, L ] = eig(D);
L = diag(L);

% sort eigen values and vectors
[ ~, idx ] = sort( L, 'descend' );
eigVal = L( idx );
eigVec = V( :, idx );

warning('on','all')

