function repere=calcul_repere_femur_MH(Cond_ext,Cond_int,FH,cote)
% FH est le centre de la tête fémorale ([xyz])
% Cond est le centre du condyle ([xyz])
% cote : D ou G
milieu_condyle=(Cond_ext+Cond_int)/2;
Y=(FH-milieu_condyle)/norm(FH-milieu_condyle);

switch cote
    case 'G'
        X=cross(Cond_int-FH,Cond_ext-FH)/norm(cross(Cond_int-FH,Cond_ext-FH));
    case 'D'
        X=cross(Cond_ext-FH,Cond_int-FH)/norm(cross(Cond_ext-FH,Cond_int-FH));
end
Z=cross(X,Y);
O=FH;

repere=[X',Y',Z',O';0,0,0,1];
end