function reperes=extraction_reperes_joint_center_EOS_MinfD(dir_regions,rep_wrl,points_corps_complet)
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
rep_wrl=fullfile(rep_wrl,'os','os_corps_MID');
% Fémur
FemurD = lire_fichier_vrml(fullfile(rep_wrl,'FemurD.wrl'));
% Tibia
TibiaD = lire_fichier_vrml(fullfile(rep_wrl,'TibiaD.wrl'));

%% Identification des points d'interet
% Tete femorale
Tetefemorale_D = ISOLE_SURF_MAILLAGE('Polygones',Regions_Femur.TeteFemorale.Polygones,FemurD);
FH_D = sphere_moindres_carres(Tetefemorale_D.Noeuds);
HJC_D = FH_D.Centre;

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

% Tibia et Fibula
Malleole_Int_D = ISOLE_SURF_MAILLAGE('Polygones',Regions_Tibia.Malleole_Int_complete.Polygones,TibiaD);
Centre_Malleole_int_D = barycentre(Malleole_Int_D.Noeuds);

Centre_Malleole_ext_D=Centre_Malleole_int_D+points_corps_complet.decal_mal_D;
AJC_D = (Centre_Malleole_int_D + Centre_Malleole_ext_D)/2;

%% Calcul des repères segment
% Femur Droit
M_R0_RfD=calcul_repere_femur_MH(CondExt_D,CondInt_D,HJC_D,'D');
PT=M_R0_RfD\[KJC_D',HJC_D';1,1];
KJC_D_RfD=PT(1:3,1); % Calcul du KJC droit dans le répère fémur droit
HJC_D_RfD=PT(1:3,2); % Calcul du HJC droit dans le répère fémur droit

% Tibia Droit
M_R0_RtD=calcul_repere_tibia_MH(KJC_D,Centre_Malleole_ext_D,Centre_Malleole_int_D,'D');
PT=M_R0_RtD\[KJC_D',AJC_D';1,1];
KJC_D_RtD=PT(1:3,1); % Calcul du KJC droit dans le répère tibia droit
AJC_D_RtD=PT(1:3,2); % Calcul du AJC droit dans le répère tibia droit

%% On range les données dans des structures pour la sortie
reperes.FemurD=M_R0_RfD;
reperes.TibiaD=M_R0_RtD;

end
