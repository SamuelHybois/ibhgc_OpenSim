function MH_tib = calcul_repere_tibia_mod_avec_malleoles(rep_wrl,dir_regions,cote)
% fonction de calcul du repère tibia
% Modification Maxime Bourgain février 2016
% Cette fonction permet de calculer la matrice homogène du repères tibia à
% partir des fichiers ddr et wrl. 
% Elle permet aussi de sortir les coordonnées du centre (ou du barycentre)
% des malléoles. Attention la malléole n'est pas exprimée dans le repère
% tibia, mais dans le repère initial des datas.
% Modification Thibault Marsan Janvier 2018
% Calcul du repère à partir des malléoles et non des plateaux.

%% Définition des régions
% Régions de la fibula
File_regions_Fibula = 'Fibula_CS.ddr';
Reg_Fibula= lire_fichier_ddr(fullfile(dir_regions,File_regions_Fibula));
Regions_Fibula=RegtyI2tyII(Reg_Fibula,'Polygones');

% Régions du tibia
File_regions_tibia='Tibia_CS.ddr';
Reg_tibia=lire_fichier_ddr(fullfile(dir_regions,File_regions_tibia));
Regions_Tibia=RegtyI2tyII(Reg_tibia,'Polygones');

% Régions du femur
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


%% Extraction des malléoles int et ext et des condyles pour le KJC
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

% Malléoles
% Malléole interne
Malleole_Int = ISOLE_SURF_MAILLAGE('Polygones',Regions_Tibia.Malleole_Int_complete.Polygones,Tibia);
Centre_Mallelole_int = barycentre(Malleole_Int.Noeuds);

% Malléole externe
Malleole_Ext_G = ISOLE_SURF_MAILLAGE('Polygones',Regions_Fibula.Malleole_laterale_complete.Polygones,Perone);
Centre_Mallelole_ext = barycentre(Malleole_Ext_G.Noeuds);


%% Calcul du repère
MH_tib=calcul_repere_tibia_MH(KJC,Centre_Mallelole_ext,Centre_Mallelole_int,cote);
end

