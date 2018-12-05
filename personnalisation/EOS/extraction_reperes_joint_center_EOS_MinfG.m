function [reperes,points,rayons]=extraction_reperes_joint_center_EOS_MinfG(dir_regions,rep_wrl,points_corps_complet)
%% Lecture des fichiers DDR
File_regions_Femur = 'FemurD_v3.ddr';
Reg_fem = lire_fichier_ddr(fullfile(dir_regions, File_regions_Femur));
Regions_Femur=RegtyI2tyII(Reg_fem,'Polygones');

File_regions_Tibia = 'Tibia_CS.ddr';
Reg_Tibia= lire_fichier_ddr(fullfile(dir_regions, File_regions_Tibia ));
Regions_Tibia=RegtyI2tyII(Reg_Tibia,'Polygones');

File_regions_Fibula = 'Fibula_CS.ddr';
Reg_Fibula= lire_fichier_ddr(fullfile(dir_regions, File_regions_Fibula ));
Regions_Fibula=RegtyI2tyII(Reg_Fibula,'Polygones');

%% Lecture des fichiers wrl
rep_wrl=fullfile(rep_wrl,'os','os_corps_MIG');
% Fémurs
FemurG = lire_fichier_vrml(fullfile(rep_wrl,'FemurG.wrl'));
% Tibias
TibiaG = lire_fichier_vrml(fullfile(rep_wrl,'TibiaG.wrl'));

%% Identification des points d'interet
% Tete femorale
Tetefemorale_G = ISOLE_SURF_MAILLAGE('Polygones',Regions_Femur.TeteFemorale.Polygones,FemurG);
FH_G = sphere_moindres_carres(Tetefemorale_G.Noeuds);
HJC_G = FH_G.Centre;

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

% tibia et fibula
Malleole_Int_G = ISOLE_SURF_MAILLAGE('Polygones',Regions_Tibia.Malleole_Int_complete.Polygones,TibiaG);
Centre_Malleole_int_G = barycentre(Malleole_Int_G.Noeuds);

Centre_Malleole_ext_G=Centre_Malleole_int_G+points_corps_complet.decal_mal_G;

AJC_G = (Centre_Malleole_int_G + Centre_Malleole_ext_G)/2;

%% Calcul des repères segment
% Femur
% Gauche
M_R0_RfG=calcul_repere_femur_MH(CondExt_G,CondInt_G,HJC_G,'G');
PT=M_R0_RfG\[KJC_G',HJC_G';1,1];
KJC_G_RfG=PT(1:3,1); % Calcul du KJC gauche dans le répère fémur gauche
HJC_G_RfG=PT(1:3,2); % Calcul du HJC gauche dans le répère fémur gauche

% Tibia
% Gauche
M_R0_RtG=calcul_repere_tibia_MH(KJC_G,Centre_Malleole_ext_G,Centre_Malleole_int_G,'G');
PT=M_R0_RtG\[KJC_G',AJC_G';1,1];

KJC_G_RtG=PT(1:3,1); % Calcul du KJC gauche dans le répère tibia gauche
AJC_G_RtG=PT(1:3,2); % Calcul du AJC gauche dans le répère tibia gauche

%% On range les données dans des structures pour la sortie
reperes.FemurG=M_R0_RfG;
reperes.TibiaG=M_R0_RtG;

points.HJC_G_RfG=HJC_G_RfG;
points.KJC_G_RfG=KJC_G_RfG;
points.KJC_G_RtG=KJC_G_RtG;
points.AJC_G_RtG=AJC_G_RtG;

rayons.FH_G=FH_G.Rayon;
rayons.CE_G=CondExt_G_rayon;
rayons.CI_G=CondInt_G_rayon;
end
