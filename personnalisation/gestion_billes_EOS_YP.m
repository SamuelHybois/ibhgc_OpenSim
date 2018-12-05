function [st_marqueurs]=gestion_billes_EOS_YP(rep_wrl_EOS,repertoire_ddr,Protocol,cur_sex)
% étape 1 : déterminer les coordonnées des billes dans le repère EOS

% rep_global='C:\Users\yoann\Desktop\Stage_Charpak\Test_Pipeline_perso_YP_V4';
% rep_wrl_EOS='C:\Users\yoann\Desktop\Stage_Charpak\Test_Pipeline_perso_YP_V4\gym_01_P\fichiers_wrl';
% repertoire_ddr=fullfile(rep_global,'info_global','DDR');
% Protocol=lire_fichier_prot_2('C:\Users\yoann\Desktop\Stage_Charpak\Test_Pipeline_perso_YP_V4\info_global\août2018_test_gym.protOS');
% cur_sex='F';

rep_billes_cc=fullfile(rep_wrl_EOS,'billes','billes_corps_complet');
rep_os_cc=fullfile(rep_wrl_EOS,'os','os_corps_complet');
st_marqueurs=struct;
file_ddr_C7=fullfile(repertoire_ddr, 'Vertebre_C7_CS.ddr');
file_ddr_T8=fullfile(repertoire_ddr, 'Vertebre_T8.ddr');
file_ddr_T12=fullfile(repertoire_ddr, 'Vertebre_T12.ddr');
file_ddr_L5=fullfile(repertoire_ddr, 'Vertebre_L5.ddr');
if ~isempty(cur_sex)
    if strcmp(cur_sex,'M')
        file_ddr_bassin=fullfile(repertoire_ddr,'MG_Bassin_Homme.ddr');
    elseif strcmp(cur_sex,'F')
        file_ddr_bassin=fullfile(repertoire_ddr,'MG_Bassin_Femme.ddr');
    end
else
    file_ddr_bassin=fullfile(repertoire_ddr,'Bassin.ddr');
end

[~,billes_CC]=PathContent_Type(rep_billes_cc,'wrl');


%% Bassin
billes_bassin=Protocol.MARQUEURS_EOS.pelvis;
file_wrl_bassin=fullfile(rep_os_cc,'Bassin.wrl');
Bassin_wrl=lire_fichier_vrml(file_wrl_bassin);
Reg_bassin= lire_fichier_ddr(file_ddr_bassin);
Regions_Bassin=RegtyI2tyII(Reg_bassin,'Polygones');

    % Accetabulum G
    AccetaG = ISOLE_SURF_MAILLAGE('Polygones',Regions_Bassin.Acetabulum_G.Polygones,Bassin_wrl);
    AG = sphere_moindres_carres(AccetaG.Noeuds); 
    AG=AG.Centre;

    % Accetabulum D
    AccetaD = ISOLE_SURF_MAILLAGE('Polygones',Regions_Bassin.Acetabulum_D.Polygones,Bassin_wrl);
    AD = sphere_moindres_carres(AccetaD.Noeuds); 
    AD=AD.Centre;

    %NormaleVerticale
    [EpineSciat_G] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Bassin.EPINE_SCIAT_G.Polygones,Bassin_wrl);
    [EpineSciat_D] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Bassin.EPINE_SCIAT_D.Polygones,Bassin_wrl);
    [NormaleVerticale,~] = plan_moindres_carres([barycentre(EpineSciat_G.Noeuds); barycentre(EpineSciat_D.Noeuds); AD; AG]);
    if NormaleVerticale(3)<0
        NormaleVerticale = -NormaleVerticale; % on veut que la normale soit dirigée vers le haut
    end


MH_R0Rlocal=calcul_reperes_harmo_YP('bassin',AD,AG,NormaleVerticale);
MH_R0Rlocal(1:3,4)=MH_R0Rlocal(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
for i_pelvis=1:size(billes_bassin,2)
    cur_bille_a_trouver=billes_bassin{i_pelvis};
    pos=find(strcmp(billes_CC,[cur_bille_a_trouver '.wrl']), 1);
    if ~isempty(pos)
        Sphere_wrl=lire_fichier_vrml(fullfile(rep_billes_cc,[cur_bille_a_trouver '.wrl']));
        Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
        centre= Sphere.Centre*10^(-3);
        centre=MH_R0Rlocal\[centre';1];
        st_marqueurs.(cur_bille_a_trouver)=centre(1:3);
    end
end

%% C7
bille_C7=Protocol.MARQUEURS_EOS.C7;
file_wrl_C7=fullfile(rep_os_cc,'Vertebre_C7.wrl');
C7_wrl=lire_fichier_vrml(file_wrl_C7);
Regions= lire_fichier_ddr(file_ddr_C7);
Regions_Cerv7=RegtyI2tyII(Regions,'Polygones');

    [Plat_sup_C7] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Cerv7.Plateau_sup.Polygones,C7_wrl);
    CentrePS_C7 = barycentre(Plat_sup_C7.Noeuds);

    [Plat_inf_C7] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Cerv7.Plateau_inf.Polygones,C7_wrl);
    CentrePI_C7 = barycentre(Plat_inf_C7.Noeuds);

    [Apophyse_Transverse_G]=ISOLE_SURF_MAILLAGE('Polygones',Regions_Cerv7.Apophyse_Transverse_G.Polygones,C7_wrl);
    CentreApG_C7=barycentre(Apophyse_Transverse_G.Noeuds);

    [Apophyse_Transverse_D]=ISOLE_SURF_MAILLAGE('Polygones',Regions_Cerv7.Apophyse_Transverse_D.Polygones,C7_wrl);
    CentreApD_C7=barycentre(Apophyse_Transverse_D.Noeuds);


MH_R0Rlocal=calcul_reperes_harmo_YP('cervicale',CentrePI_C7,CentrePS_C7,CentreApG_C7,CentreApD_C7);
MH_R0Rlocal(1:3,4)=MH_R0Rlocal(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
cur_bille_a_trouver=bille_C7{1};
pos=find(strcmp(billes_CC,[cur_bille_a_trouver '.wrl']), 1);
if ~isempty(pos)
    Sphere_wrl=lire_fichier_vrml(fullfile(rep_billes_cc,[cur_bille_a_trouver '.wrl']));
    Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
    centre= Sphere.Centre*10^(-3);
    centre=MH_R0Rlocal\[centre';1];
    st_marqueurs.(cur_bille_a_trouver)=centre(1:3);
end

%% T8
bille_T8=Protocol.MARQUEURS_EOS.T8;
file_wrl_T8=fullfile(rep_os_cc,'Vertebre_T8.wrl');
T8_wrl=lire_fichier_vrml(file_wrl_T8);
Regions= lire_fichier_ddr(file_ddr_T8);
Regions_Thor8=RegtyI2tyII(Regions,'Polygones');

    [Plat_sup_T8] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor8.plat_sup.Polygones,T8_wrl);
    CentrePS_T8 = barycentre(Plat_sup_T8.Noeuds);

    [Plat_inf_T8] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor8.plat_inf.Polygones,T8_wrl);
    CentrePI_T8 = barycentre(Plat_inf_T8.Noeuds);

    [Pedicule_G_T8] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor8.pedicule_g.Polygones,T8_wrl);
    CentrePedG_T8 = barycentre(Pedicule_G_T8.Noeuds);

    [Pedicule_D_T8] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor8.pedicule_d.Polygones,T8_wrl);
    CentrePedD_T8 = barycentre(Pedicule_D_T8.Noeuds);


MH_R0Rlocal=calcul_reperes_harmo_YP('thoracique',CentrePI_T8,CentrePS_T8,CentrePedG_T8,CentrePedD_T8);
MH_R0Rlocal(1:3,4)=MH_R0Rlocal(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
cur_bille_a_trouver=bille_T8{1};
pos=find(strcmp(billes_CC,[cur_bille_a_trouver '.wrl']), 1);
if ~isempty(pos)
    Sphere_wrl=lire_fichier_vrml(fullfile(rep_billes_cc,[cur_bille_a_trouver '.wrl']));
    Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
    centre= Sphere.Centre*10^(-3);
    centre=MH_R0Rlocal\[centre';1];
    st_marqueurs.(cur_bille_a_trouver)=centre(1:3);
end

%% T12
bille_T12=Protocol.MARQUEURS_EOS.T12;
file_wrl_T12=fullfile(rep_os_cc,'Vertebre_T12.wrl');
T12_wrl=lire_fichier_vrml(file_wrl_T12);
Regions= lire_fichier_ddr(file_ddr_T12);
Regions_Thor12=RegtyI2tyII(Regions,'Polygones');

    [Plat_sup_T12] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor12.plat_sup.Polygones,T12_wrl);
    CentrePS_T12 = barycentre(Plat_sup_T12.Noeuds);

    [Plat_inf_T12] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor12.plat_inf.Polygones,T12_wrl);
    CentrePI_T12 = barycentre(Plat_inf_T12.Noeuds);

    [Pedicule_G_T12] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor12.pedicule_g.Polygones,T12_wrl);
    CentrePedG_T12 = barycentre(Pedicule_G_T12.Noeuds);

    [Pedicule_D_T12] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor12.pedicule_d.Polygones,T12_wrl);
    CentrePedD_T12 = barycentre(Pedicule_D_T12.Noeuds);


MH_R0Rlocal=calcul_reperes_harmo_YP('thoracique',CentrePI_T12,CentrePS_T12,CentrePedG_T12,CentrePedD_T12);
MH_R0Rlocal(1:3,4)=MH_R0Rlocal(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
cur_bille_a_trouver=bille_T12{1};
pos=find(strcmp(billes_CC,[cur_bille_a_trouver '.wrl']), 1);
if ~isempty(pos)
    Sphere_wrl=lire_fichier_vrml(fullfile(rep_billes_cc,[cur_bille_a_trouver '.wrl']));
    Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
    centre= Sphere.Centre*10^(-3);
    centre=MH_R0Rlocal\[centre';1];
    st_marqueurs.(cur_bille_a_trouver)=centre(1:3);
end

%% L5

if any(contains(billes_CC,'L5'))
    bille_L5=Protocol.MARQUEURS_EOS.L5;
    file_wrl_L5=fullfile(rep_os_cc,'Vertebre_L5.wrl');
    L5_wrl=lire_fichier_vrml(file_wrl_L5);
    Regions= lire_fichier_ddr(file_ddr_L5);
    Regions_Lomb5=RegtyI2tyII(Regions,'Polygones');

        [Plat_sup_L5] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb5.plat_sup.Polygones,L5_wrl);
        CentrePS_L5 = barycentre(Plat_sup_L5.Noeuds);

        [Plat_inf_L5] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb5.plat_inf.Polygones,L5_wrl);
        CentrePI_L5 = barycentre(Plat_inf_L5.Noeuds);

        [Pedicule_G_L5] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb5.pedicule_g.Polygones,L5_wrl);
        CentrePedG_L5 = barycentre(Pedicule_G_L5.Noeuds);

        [Pedicule_D_L5] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb5.pedicule_d.Polygones,L5_wrl);
        CentrePedD_L5 = barycentre(Pedicule_D_L5.Noeuds);


    MH_R0Rlocal=calcul_reperes_harmo_YP('lombaire',CentrePI_L5,CentrePS_L5,CentrePedG_L5,CentrePedD_L5);
    MH_R0Rlocal(1:3,4)=MH_R0Rlocal(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
    cur_bille_a_trouver=bille_L5{1};
    pos=find(strcmp(billes_CC,[cur_bille_a_trouver '.wrl']), 1);
    if ~isempty(pos)
        Sphere_wrl=lire_fichier_vrml(fullfile(rep_billes_cc,[cur_bille_a_trouver '.wrl']));
        Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
        centre= Sphere.Centre*10^(-3);
        centre=MH_R0Rlocal\[centre';1];
        st_marqueurs.(cur_bille_a_trouver)=centre(1:3);
    end
end

%% Tete
%Calcul repere tete à partir de marqueurs
if isfield(Protocol.MARQUEURS_EOS,'repere_tete')
    billes_repere_tete = Protocol.MARQUEURS_EOS.repere_tete;
    for i_repere_tete=1:size(billes_repere_tete,2)
        cur_bille_a_trouver=billes_repere_tete{i_repere_tete};
        Sphere_wrl=lire_fichier_vrml(fullfile(rep_billes_cc,[cur_bille_a_trouver '.wrl']));
        Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
        centre= Sphere.Centre*10^(-3);
        if strcmp(cur_bille_a_trouver,'01_NASI')
            nasion=centre;
        elseif strcmp(cur_bille_a_trouver,'03_EARD')
            orD = centre;
        elseif strcmp(cur_bille_a_trouver,'04_EARG')
            orG = centre;
        end
    end
    MH_R0Rlocal=calcul_reperes_harmo_YP('tete',nasion,orD,orG);

    billes_tete = Protocol.MARQUEURS_EOS.tete;
    for i_tete=1:size(billes_tete,2)
        cur_bille_a_trouver=billes_tete{i_tete};
        pos=find(strcmp(billes_CC,[cur_bille_a_trouver '.wrl']), 1);
        if ~isempty(pos)
            Sphere_wrl=lire_fichier_vrml(fullfile(rep_billes_cc,[cur_bille_a_trouver '.wrl']));
            Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
            centre= Sphere.Centre*10^(-3);
            centre=MH_R0Rlocal\[centre';1];
            st_marqueurs.(cur_bille_a_trouver)=centre(1:3);
        end
    end
end
end