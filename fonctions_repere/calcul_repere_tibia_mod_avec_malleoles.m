function MH_tib = calcul_repere_tibia_mod_avec_malleoles(rep_wrl,dir_regions,cote)
% fonction de calcul du rep�re tibia
% Modification Maxime Bourgain f�vrier 2016
% Cette fonction permet de calculer la matrice homog�ne du rep�res tibia �
% partir des fichiers ddr et wrl. 
% Elle permet aussi de sortir les coordonn�es du centre (ou du barycentre)
% des mall�oles. Attention la mall�ole n'est pas exprim�e dans le rep�re
% tibia, mais dans le rep�re initial des datas.
% Modification Thibault Marsan Janvier 2018
% Calcul du rep�re � partir des mall�oles et non des plateaux.

%% D�finition des r�gions
% R�gions de la fibula
File_regions_Fibula = 'Fibula_CS.ddr';
Reg_Fibula= lire_fichier_ddr(fullfile(dir_regions,File_regions_Fibula));
Regions_Fibula=RegtyI2tyII(Reg_Fibula,'Polygones');

% R�gions du tibia
File_regions_tibia='Tibia_CS.ddr';
Reg_tibia=lire_fichier_ddr(fullfile(dir_regions,File_regions_tibia));
Regions_Tibia=RegtyI2tyII(Reg_tibia,'Polygones');

% R�gions du femur
File_regions_femur='FemurD_v3.ddr';
Reg_Femur=lire_fichier_ddr(fullfile(dir_regions,File_regions_femur));
Regions_Femur=RegtyI2tyII(Reg_Femur,'Polygones');

%% lecture des fichier wrl
switch cote
    case 'D'
        Femur = lire_fichier_vrml(fullfile(rep_wrl,'FemurD.wrl'));
        Tibia = lire_fichier_vrml(fullfile(rep_wrl,'TibiaD.wrl'));
        Perone = lire_fichier_vrml(fullfile(rep_wrl,'PeroneD.wrl'));
    case 'G'
        Femur = lire_fichier_vrml(fullfile(rep_wrl,'FemurG.wrl'));
        Tibia = lire_fichier_vrml(fullfile(rep_wrl,'TibiaG.wrl'));
        Perone = lire_fichier_vrml(fullfile(rep_wrl,'PeroneG.wrl'));
end


%% Extraction des mall�oles int et ext et des condyles pour le KJC
% Condyles femoraux
% condyle_Externe
CondyleExterne = ISOLE_SURF_MAILLAGE('Polygones',Regions_Femur.CondyleExt.Polygones,Femur);
CondExt = sphere_moindres_carres(CondyleExterne.Noeuds);
CondExt=CondExt.Centre;

% condyle_Interne
CondyleInterne = ISOLE_SURF_MAILLAGE('Polygones',Regions_Femur.CondyleInt.Polygones,Femur);
CondInt = sphere_moindres_carres(CondyleInterne.Noeuds);
CondInt=CondInt.Centre;

% Knee joint center
KJC = (CondExt + CondInt)/2;

% Mall�oles
% Mall�ole interne
Malleole_Int = ISOLE_SURF_MAILLAGE('Polygones',Regions_Tibia.Malleole_Int_complete.Polygones,Tibia);
Centre_Mallelole_int = barycentre(Malleole_Int.Noeuds);

% Mall�ole externe
Malleole_Ext_G = ISOLE_SURF_MAILLAGE('Polygones',Regions_Fibula.Malleole_laterale_complete.Polygones,Perone);
Centre_Mallelole_ext = barycentre(Malleole_Ext_G.Noeuds);


%% Calcul du rep�re
MH_tib=calcul_repere_tibia_MH(KJC,Centre_Mallelole_ext,Centre_Mallelole_int,cote);
end

