function [CNLLS_pvec, CostFunRecord, costfun_change]=MFN_CNLLS_tensor_estimate(W,p0,s,method,max_iter)

% W = design matrix
% p0 = input parameter vector from WLLS estimation
% max_iter = maximum number of iterations to perform before exiting
% method = choice of Levenberg (0) or Marquardt (1) estimation
%
%

%% Setup workspace variables

l=0;

count=0;

e1=1;
e2=1;

flag=true;
stopflag=false;

r=s-exp(W*p0);

S=diag(s);

m=size(s,1);

fm=0.5*(r.'*r);
fm_start=fm;

p=p0;

Jp=zeros(7,7);
Jp(1,1)=1;

P=zeros(7,7);

D=zeros(3,3);

M=eye(7,7);

fp_record=zeros(1,10);

iter=0;


%% Perform Cholesky decomposition on WLLS estimated input parameters p0

D(1,1)=p(2);    D(2,2)=p(3);    D(3,3)=p(4);    D(1,2)=p(5);
D(2,3)=p(6);    D(1,3)=p(7);    D(2,1)=p(5);    D(3,2)=p(6);
D(3,1)=p(7);

U=modified_Cholesky_factorization(D);

p(2)=U(1,1);    p(3)=U(2,2);    p(4)=U(3,3);
p(5)=U(2,1);    p(6)=U(3,2);    p(7)=U(3,1);


%% Main loops for Modified Full Newtom minimissation

while stopflag==0 && ~(l==inf) && iter<=max_iter
    iter=iter+1;
    if flag==true
        % Define Jacobian with respect to parameter vector p
        Jp(2,2)=2*p(2); Jp(3,3)=2*p(3); Jp(4,4)=2*p(4); Jp(5,5)=p(2);
        Jp(6,6)=p(3);   Jp(7,7)=p(2);   Jp(3,5)=2*p(5); Jp(4,6)=2*p(6);
        Jp(4,7)=2*p(7); Jp(5,2)=p(5);   Jp(6,3)=p(6);   Jp(7,2)=p(7);
        
        % Convert current p parameters back into normal space vector
        % gamma
        gamma=CholeskyComposition(p);
        
        % Estimate signal and error terms with current parameters gamma
        se=exp(W*gamma);
        Se=diag(se);
        r=s-se;
        R=S-Se;
        
        % Define summed P matrix for calculation of Dell2f and H
        Psum=0;
        for i=1:m
            P(2,2)=2*W(i,2); P(3,3)=2*W(i,3); P(4,4)=2*W(i,4); P(5,5)=2*W(i,3); P(6,6)=2*W(i,4);
            P(7,7)=2*W(i,4); P(2,5)=W(i,5);   P(2,7)=W(i,7);   P(3,6)=W(i,6);   P(5,2)=W(i,5);
            P(5,7)=W(i,6);   P(6,3)=W(i,6);   P(7,2)=W(i,7);   P(7,5)=W(i,6);
            P=-P;
            Psum=Psum+r(i)*se(i)*P;
        end
        
        Dellf=-Jp.'*W.'*Se*r;
        Dell2f=-Jp.'*W.'*(Se^2-R*Se)*W*Jp+Psum;
        
        % If using Marquardt method define new M
        if method==1
            JpTJp=Jp.'*Jp;
            M(1,1)=JpTJp(1,1); M(2,2)=JpTJp(2,2); M(3,3)=JpTJp(3,3); M(4,4)=JpTJp(4,4);
            M(5,5)=JpTJp(5,5); M(6,6)=JpTJp(6,6); M(7,7)=JpTJp(7,7);
        end
    end
    
    % Evaluate Hessian matrix, H, at p and l
    H=Dell2f+l*M;
    
    
    % Solve for search step vector, d
    d=-inv(H)*Dellf;
    
    % Estimate new objective function fp
    gamma2=CholeskyComposition(p+d);
    r2=s-exp(W*gamma2);
    fp=0.5*(r2.'*r2);
    
    % Assess whether objective function converged to minimum
    if abs(fp-fm)<e1 && -d.'*Dellf<e2 && -d.'*Dellf>=0
        if fp<fm
            p=p+d;
            stopflag=1;
        else
            stopflag=1;
        end
    end
    
    % If the search step vector reduced cost function update p and
    % flag to update H and Dellf. If cost function not reduced increase
    % l by factor 10 until H matrix is found to reduce cost function.
    if fp<fm
        l=0.1*l;
        p=p+d;
        flag=true;
        fm=fp;
    else
        flag=false;
        if l==0
            l=0.0001;
        else
            l=10*l;
        end
    end
    % Record changes to cost function fp
    count=count+1;
    fp_record(count)=fp;
end

fp_end=min(fp_record);
costfun_change=(fp_end-fm_start)/fm_start;

CNLLS_pvec=p;
CostFunRecord=fp_record;




