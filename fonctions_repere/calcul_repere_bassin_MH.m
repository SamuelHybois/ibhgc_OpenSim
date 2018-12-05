function repere=calcul_repere_bassin_MH(FH_D,FH_G,PS)
% FH est le centre de la t�te f�morale ([xyz])
% PS est le centre du plateau sacr� ([xyz])
Z=(FH_D-FH_G)/norm(FH_D-FH_G);
X=cross(PS-FH_G,Z)/norm(cross(PS-FH_G,Z));
Y=cross(Z,X);
O=(FH_D+FH_G)/2;
repere=[X',Y',Z',O';0,0,0,1];
end