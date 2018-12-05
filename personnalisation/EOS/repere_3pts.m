function [ M ] = repere_3pts( P1,P2,P3 )
%creation d'un repère orthonormé à partir de 3 points

X=P2-P1;
X=X/norm(X);

Z=cross(P2-P1,P3-P1);
Z=Z/norm(Z);

Y=cross(Z,X);

M=[X' Y' Z'];


end

