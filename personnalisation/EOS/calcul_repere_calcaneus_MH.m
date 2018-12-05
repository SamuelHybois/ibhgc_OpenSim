function repere=calcul_repere_calcaneus_MH(axe_henke)
X=axe_henke;
Z=[0 0 1];
Y=cross(Z,X);
repere=[X',Y',Z',[0;0;0];0,0,0,1];

end