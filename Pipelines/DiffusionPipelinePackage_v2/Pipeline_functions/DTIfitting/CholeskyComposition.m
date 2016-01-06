function gamma_vec=CholeskyComposition(p_vec)
% This function will transform a vector in Cholesky space back to the
% original positive-definite space.
% p_vec=

gamma_vec(1,1)=p_vec(1);
gamma_vec(2,1)=p_vec(2)^2;
gamma_vec(3,1)=p_vec(3)^2+p_vec(5)^2;
gamma_vec(4,1)=p_vec(4)^2+p_vec(6)^2+p_vec(7)^2;
gamma_vec(5,1)=p_vec(2)*p_vec(5);
gamma_vec(6,1)=p_vec(3)*p_vec(6)+p_vec(5)*p_vec(7);
gamma_vec(7,1)=p_vec(2)*p_vec(7);