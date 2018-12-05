function repere=calcul_repere_tibia_MH(KJC,Mal_ext,Mal_int,cote)
% KJC est le centre du genou ([xyz])
% Mal est la malléole ([xyz])
% cote : D ou G
milieu_malleole=(Mal_ext+Mal_int)/2;
Y=(KJC-milieu_malleole)/norm(KJC-milieu_malleole);

switch cote
    case 'G'
        X=cross(Mal_int-KJC,Mal_ext-KJC)/norm(cross(Mal_int-KJC,Mal_ext-KJC));
    case 'D'
        X=cross(Mal_ext-KJC,Mal_int-KJC)/norm(cross(Mal_ext-KJC,Mal_int-KJC));
end
Z=cross(X,Y);
O=KJC;

repere=[X',Y',Z',O';0,0,0,1];
end