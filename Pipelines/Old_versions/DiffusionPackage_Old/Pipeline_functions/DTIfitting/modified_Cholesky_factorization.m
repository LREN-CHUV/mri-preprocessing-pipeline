function M=modified_Cholesky_factorization(NxN_matrix)

% The function will decompose A=NxN_matrix into Cholesky representation of
% A = L*D*L.' = M*M.' where L is a lower triangular matrix with unit
% diagonal elements and D is a diagonal matrix with positive elements on
% the diagonal. M will be output as a matrix containing the unique diagonal
% and off-diagnonal elements in Cholesky space.
%

% Refer to page 52 of Numerical Optimisation Textbook, Nocedal and Wright,
% 1999.


[n, m]=size(NxN_matrix);

if ~n==m
    disp('Error: input must be a square NxN matrix')
end

A=NxN_matrix;

% Delta set to machine epsilon
em=3*10^-16;

maxDiag=max([A(1,1),A(2,2),A(3,3)]);
maxOffDiag=max([A(2,1),A(3,1),A(3,2)]);

B=max([maxDiag,maxOffDiag/(n^2-1)^0.5,em])^0.5;

c=zeros(n,n);
d=zeros(n,n);
l=eye(n,n);

for j=1:n
    SUM=0;
    if j>1
        for s=1:j-1
            SUM=SUM+d(s,s)*l(j,s)^2;
        end
    end
    
    c(j,j)=A(j,j)-SUM;
    
    for i=j+1:n
        SUM2=0;
        if j>1
            for s=1:j-1
                SUM2=SUM2+d(s,s)*l(i,s)*l(j,s);
            end
        end
        c(i,j)=A(i,j)-SUM2;
    end
    
    theta=0;
    if j<n
        theta=max(abs(c(j+1:n,j)));
    end
    
    d(j,j)=max([abs(c(j,j)),(theta/B)^2,em]);
    
    if j<n
        for i=j+1:n
            l(i,j)=c(i,j)/d(j,j);
        end
    end
end

M=l*d^(1/2);




