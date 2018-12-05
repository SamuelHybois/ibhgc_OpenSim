function [reperes,points,rayons]=extraction_reperes_joint_center_EOS_Minf(dir_regions,rep_wrl)
%% Lecture des fichiers DDR
File_regions_Femur = 'FemurD_v3.ddr';
Reg_fem = lire_fichier_ddr(fullfile(dir_regions, File_regions_Femur));
Regions_Femur=RegtyI2tyII(Reg_fem,'Polygones');

File_regions_Bassin = 'MG_Bassin_Homme.ddr';
Reg_bassin = lire_fichier_ddr(fullfile(dir_regions, File_regions_Bassin));
Regions_Bassin=RegtyI2tyII(Reg_bassin,'Polygones');

File_regions_Tibia = 'Tibia_CS.ddr';
Reg_Tibia= lire_fichier_ddr(fullfile(dir_regions, File_regions_Tibia ));
Regions_Tibia=RegtyI2tyII(Reg_Tibia,'Polygones');

File_regions_Fibula = 'Fibula_CS.ddr';
Reg_Fibula= lire_fichier_ddr(fullfile(dir_regions, File_regions_Fibula ));
Regions_Fibula=RegtyI2tyII(Reg_Fibula,'Polygones');

%% Lecture des fichiers wrl
% Fémurs
FemurG = lire_fichier_vrml(fullfile(rep_wrl,'FemurG.wrl'));
FemurD = lire_fichier_vrml(fullfile(rep_wrl,'FemurD.wrl'));
% Bassin
Bassin = lire_fichier_vrml(fullfile(rep_wrl,'Bassin.wrl'));
% Tibias
TibiaD = lire_fichier_vrml(fullfile(rep_wrl,'TibiaD.wrl'));
TibiaG = lire_fichier_vrml(fullfile(rep_wrl,'TibiaG.wrl'));
% Fibulas
PeroneD = lire_fichier_vrml(fullfile(rep_wrl,'PeroneD.wrl'));
PeroneG = lire_fichier_vrml(fullfile(rep_wrl,'PeroneG.wrl'));

%% Identification des points d'interet
% Tete femorale
Tetefemorale_G = ISOLE_SURF_MAILLAGE('Polygones',Regions_Femur.TeteFemorale.Polygones,FemurG);
FH_G = sphere_moindres_carres(Tetefemorale_G.Noeuds);
HJC_G = FH_G.Centre;
Tetefemorale_D = ISOLE_SURF_MAILLAGE('Polygones',Regions_Femur.TeteFemorale.Polygones,FemurD);
FH_D = sphere_moindres_carres(Tetefemorale_D.Noeuds);
HJC_D = FH_D.Centre;

% Plateau sacre
PlateauSacre = ISOLE_SURF_MAILLAGE('Polygones',Regions_Bassin.Plateau_Sacrum.Polygones,Bassin);
Centre_PS = barycentre(PlateauSacre.Noeuds);

% Condyles femoraux
% Gauche
% condyle_Externe
CondyleExterne_G = ISOLE_SURF_MAILLAGE('Polygones',Regions_Femur.CondyleExt.Polygones,FemurG);
CondExt_G = sphere_moindres_carres(CondyleExterne_G.Noeuds);
CondExt_G_rayon=CondExt_G.Rayon;
CondExt_G=CondExt_G.Centre;

% condyle_Interne
CondyleInterne_G = ISOLE_SURF_MAILLAGE('Polygones',Regions_Femur.CondyleInt.Polygones,FemurG);
CondInt_G = sphere_moindres_carres(CondyleInterne_G.Noeuds);
CondInt_G_rayon=CondInt_G.Rayon;
CondInt_G=CondInt_G.Centre;

KJC_G = (CondExt_G + CondInt_G)/2;

% Droite
% condyle_Externe
CondyleExterne_D = ISOLE_SURF_MAILLAGE('Polygones',Regions_Femur.CondyleExt.Polygones,FemurD);
CondExt_D = sphere_moindres_carres(CondyleExterne_D.Noeuds);
CondExt_D_rayon=CondExt_D.Rayon;
CondExt_D=CondExt_D.Centre;

% condyle_Interne
CondyleInterne_D = ISOLE_SURF_MAILLAGE('Polygones',Regions_Femur.CondyleInt.Polygones,FemurD);
CondInt_D = sphere_moindres_carres(CondyleInterne_D.Noeuds);
CondInt_D_rayon=CondInt_D.Rayon;
CondInt_D=CondInt_D.Centre;

KJC_D = (CondExt_D + CondInt_D)/2;

% tibia et Fibula
% tibia et fibula gauche
Malleole_Int_G = ISOLE_SURF_MAILLAGE('Polygones',Regions_Tibia.Malleole_Int_complete.Polygones,TibiaG);
<<<<<<< HEAD
Centre_Malleole_int_G = barycentre(Malleole_Int_G.Noeuds);
=======
Centre_Mallelole_int_G = barycentre(Malleole_Int_G.Noeuds);
>>>>>>> dev_diane_ENSAM
[~,I_bas_int_G]=min(Malleole_Int_G.Noeuds(:,3));
Bas_Malleole_G.int=Malleole_Int_G.Noeuds(I_bas_int_G,:);

Malleole_Ext_G = ISOLE_SURF_MAILLAGE('Polygones',Regions_Fibula.Malleole_laterale_complete.Polygones,PeroneG);
<<<<<<< HEAD
Centre_Malleole_ext_G = barycentre(Malleole_Ext_G.Noeuds);
[~,I_bas_ext_G]=min(Malleole_Ext_G.Noeuds(:,3));
Bas_Malleole_G.ext=Malleole_Ext_G.Noeuds(I_bas_ext_G,:);
=======
Centre_Mallelole_ext_G = barycentre(Malleole_Ext_G.Noeuds);
[~,I_bas_ext_G]=min(Malleole_Ext_G.Noeuds(:,3));
Bas_Malleole_G.ext=Malleole_Ext_G.Noeuds(I_bas_ext_G,:);

AJC_G = (Centre_Mallelole_int_G + Centre_Mallelole_ext_G)/2;
>>>>>>> dev_diane_ENSAM

AJC_G = (Centre_Malleole_int_G + Centre_Malleole_ext_G)/2;
decalage_malleole_G_R0=Centre_Malleole_ext_G-Centre_Malleole_int_G;

% tibia et fibula droit
Malleole_Int_D = ISOLE_SURF_MAILLAGE('Polygones',Regions_Tibia.Malleole_Int_complete.Polygones,TibiaD);
<<<<<<< HEAD
Centre_Malleole_int_D = barycentre(Malleole_Int_D.Noeuds);
=======
Centre_Mallelole_int_D = barycentre(Malleole_Int_D.Noeuds);
>>>>>>> dev_diane_ENSAM
[~,I_bas_int_D]=min(Malleole_Int_D.Noeuds(:,3));
Bas_Malleole_D.int=Malleole_Int_D.Noeuds(I_bas_int_D,:);

Malleole_Ext_D = ISOLE_SURF_MAILLAGE('Polygones',Regions_Fibula.Malleole_laterale_complete.Polygones,PeroneD);
<<<<<<< HEAD
Centre_Malleole_ext_D = barycentre(Malleole_Ext_D.Noeuds);
[~,I_bas_ext_D]=min(Malleole_Ext_D.Noeuds(:,3));
Bas_Malleole_D.ext=Malleole_Ext_D.Noeuds(I_bas_ext_D,:);

AJC_D = (Centre_Malleole_int_D + Centre_Malleole_ext_D)/2;
decalage_malleole_D_R0=Centre_Malleole_ext_D-Centre_Malleole_int_D;
=======
Centre_Mallelole_ext_D = barycentre(Malleole_Ext_D.Noeuds);
[~,I_bas_ext_D]=min(Malleole_Ext_D.Noeuds(:,3));
Bas_Malleole_D.ext=Malleole_Ext_D.Noeuds(I_bas_ext_D,:);
>>>>>>> dev_diane_ENSAM


%% Calcul des repères segment
% Bassin
M_R0_Rb=calcul_repere_bassin_MH(HJC_D,HJC_G,Centre_PS);
PS_Rb=M_R0_Rb\[Centre_PS';1];
HJC=M_R0_Rb\[HJC_D',HJC_G';1,1];
HJC_D_Rb=HJC(1:3,1); % Calcul du HJC droit dans le repère bassin
HJC_G_Rb=HJC(1:3,2); % Calcul du HJC gauche dans le répère bassin

% Femur
% Gauche
M_R0_RfG=calcul_repere_femur_MH(CondExt_G,CondInt_G,HJC_G,'G');
PT=M_R0_RfG\[KJC_G',HJC_G';1,1];
KJC_G_RfG=PT(1:3,1); % Calcul du KJC gauche dans le répère fémur gauche
HJC_G_RfG=PT(1:3,2); % Calcul du HJC gauche dans le répère fémur gauche

% Droit
M_R0_RfD=calcul_repere_femur_MH(CondExt_D,CondInt_D,HJC_D,'D');
PT=M_R0_RfD\[KJC_D',HJC_D';1,1];
KJC_D_RfD=PT(1:3,1); % Calcul du KJC droit dans le répère fémur droit
HJC_D_RfD=PT(1:3,2); % Calcul du HJC droit dans le répère fémur droit

% Tibia
% Gauche
M_R0_RtG=calcul_repere_tibia_MH(KJC_G,Centre_Malleole_ext_G,Centre_Malleole_int_G,'G');
PT=M_R0_RtG\[KJC_G',AJC_G';1,1];
KJC_G_RtG=PT(1:3,1); % Calcul du KJC gauche dans le répère tibia gauche
AJC_G_RtG=PT(1:3,2); % Calcul du AJC gauche dans le répère tibia gauche

% Droit
M_R0_RtD=calcul_repere_tibia_MH(KJC_D,Centre_Malleole_ext_D,Centre_Malleole_int_D,'D');
PT=M_R0_RtD\[KJC_D',AJC_D';1,1];
KJC_D_RtD=PT(1:3,1); % Calcul du KJC droit dans le répère tibia droit
AJC_D_RtD=PT(1:3,2); % Calcul du AJC droit dans le répère tibia droit

% Talus
% Droite
<<<<<<< HEAD
M_R0_RtalusD=calcul_repere_talus_MH(KJC_D,AJC_D,Bas_Malleole_D,'D');
PT=M_R0_RtalusD\[AJC_D';1]; % Calcul du AJC dans le repère talus
AJC_D_RtalusD=PT(1:3);

% Gauche
M_R0_RtalusG=calcul_repere_talus_MH(KJC_G,AJC_G,Bas_Malleole_G,'G');
PT=M_R0_RtalusG\[AJC_G';1]; % Calcul du AJC dans le repère talus
AJC_G_RtalusG=PT(1:3);

% Calcaneus
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
axe_Henke=[0.78717961 0.60474746 -0.12094949]; 
% Axe de Henke mesuré dans OpenSim donc à changer au plus vite
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% Droit
M_R0_RcalD=calcul_repere_calcaneus_MH(axe_Henke);

% Gauche
M_R0_RcalG=M_R0_RcalD;
=======
M_R0_RcD=calcul_repere_talus_MH(KJC_D,AJC_D,Bas_Malleole_D,'D');
AJC_D_RcD=M_R0_RcD\[AJC_D';1];

% Gauche
M_R0_RcG=calcul_repere_talus_MH(KJC_G,AJC_G,Bas_Malleole_G,'G');
AJC_D_RcG=M_R0_RcG\[AJC_G';1];
>>>>>>> dev_diane_ENSAM

%% On range les données dans des structures pour la sortie
reperes.Bassin=M_R0_Rb;
reperes.FemurG=M_R0_RfG;
reperes.FemurD=M_R0_RfD;
reperes.TibiaG=M_R0_RtG;
reperes.TibiaD=M_R0_RtD;
reperes.TalusD=M_R0_RtalusD;
reperes.TalusG=M_R0_RtalusG;
reperes.CalcaneusD=M_R0_RcalD;
reperes.CalcaneusG=M_R0_RcalG;

points.PS=Centre_PS;
points.PS_Rb=PS_Rb(1:3);
points.HJC_D_Rb=HJC_D_Rb;
points.HJC_G_Rb=HJC_G_Rb;
points.HJC_D_RfD=HJC_D_RfD;
points.HJC_G_RfG=HJC_G_RfG;
points.KJC_D_RfD=KJC_D_RfD;
points.KJC_G_RfG=KJC_G_RfG;
points.KJC_D_RtD=KJC_D_RtD;
points.KJC_G_RtG=KJC_G_RtG;
points.AJC_D_RtD=AJC_D_RtD;
points.AJC_G_RtG=AJC_G_RtG;
points.AJC_D_RtalusD=AJC_D_RtalusD;
points.AJC_G_RtalusG=AJC_G_RtalusG;
points.decal_mal_G=decalage_malleole_G_R0;
points.decal_mal_D=decalage_malleole_D_R0;

rayons.FH_D=FH_D.Rayon;
rayons.FH_G=FH_G.Rayon;
rayons.CE_G=CondExt_G_rayon;
rayons.CI_G=CondInt_G_rayon;
rayons.CE_D=CondExt_D_rayon;
rayons.CI_D=CondInt_D_rayon;
end
