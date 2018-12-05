function repere=calcul_repere_talus_MH(KJC,AJC,Bas_Mal,cote)
% AJC est le centre de la cheville ([xyz])
% Bas_mal est un struct contenant le point le plus bas de la malléole de chaque malléole (int et ext) ([xyz])
% cote : D ou G

milieu_bas_mal=(Bas_Mal.ext+Bas_Mal.int)/2;

<<<<<<< HEAD
Y1=(KJC-AJC)/norm(KJC-AJC);

switch cote
    case 'D'
        Z=(Bas_Mal.ext-Bas_Mal.int)/norm(Bas_Mal.ext-Bas_Mal.int);
    case 'G'
        Z=(Bas_Mal.int-Bas_Mal.ext)/norm(Bas_Mal.int-Bas_Mal.ext);
end
X=cross(Y1,Z)/norm(cross(Y1,Z));
Y=cross(Z,X);
=======
Y=(KJC-AJC)/norm(KJC-AJC);

switch cote
    case 'G'
        Z=(Bas_Mal.ext-Bas_Mal.int)/norm(Bas_Mal.ext-Bas_Mal.int);
    case 'D'
        Z=(Bas_Mal.int-Bas_Mal.ext)/norm(Bas_Mal.int-Bas_Mal.ext);
end
X=cross(Y,Z)/norm(cross(Y,Z));

>>>>>>> dev_diane_ENSAM
O=milieu_bas_mal;

repere=[X',Y',Z',O';0,0,0,1];
end 