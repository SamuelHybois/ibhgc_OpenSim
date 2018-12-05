function [st_marqueurs]=gestion_billes_EOS2(rep_billes_EOS,repertoire_ddr,Protocol,cur_sex)
% rep_billes_EOS='G:\_31_mise_en_forme_data_EOS\golf_036_XP';
% étape 1 : déterminer les coordonnées des billes dans le repère EOS,
% sachant qu'elles peuvent être dans 3 repères différents.
% On part du principe que s'il y a un dossier du membre inf (G ou D) c'est
% qu'il faut prendre les marqueurs CLD, CMD ,MMD, cluster cuisse et tibia
% dans ce dossier. Sinon, il les prend dans le dossier corps_complet. Les
% marqueurs du bassin proviennent forcément du dossier corps_complet.
% rep_global='G:\_30_EOS_etude';
% rep_billes_EOS='G:\_31_mise_en_forme_data_EOS\golf_036_XP';
% repertoire_ddr=fullfile(rep_global,'info_global','fichiers_ddr');
% Protocol=lire_fichier_prot_2('G:\_30_EOS_etude\info_global\aout_2017_IBHGC_fullbodyV4_golf.protOS');
% cur_sex='M';
st_marqueurs=struct;
dossier3=fullfile(rep_billes_EOS,'billes_MID');
ok_femD=0;
ok_femG=0;
ok_tibD=0;
ok_tibG=0;
file_ddr_femur_l=fullfile(repertoire_ddr, 'FemurD_v3.ddr');
file_ddr_femur_r=fullfile(repertoire_ddr, 'FemurD_v3.ddr');
file_ddr_tibia_r=fullfile(repertoire_ddr, 'tibia_peroneD.ddr');
file_ddr_tibia_l=fullfile(repertoire_ddr, 'tibia_peroneG.ddr');
if exist(dossier3,'dir')==7
    [~,billes_MID]=PathContent_Type(dossier3,'wrl');
    %femur_droit
    billes_femD=Protocol.MARQUEURS_EOS.femur_r;
    for i_b_D=1:size(billes_femD,2)
        cur_bille_a_trouver=billes_femD{i_b_D};
        pos=find(strcmp(billes_MID,[cur_bille_a_trouver '.wrl']), 1);
        file_wrl_femurD=fullfile(dossier3,'FemurD.wrl');
        MH_R0Rlocal=repere_femur_EOS_decal(file_wrl_femurD,file_ddr_femur_r,0);
        MH_R0Rlocal(1:3,4)=MH_R0Rlocal(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
        if ~isempty(pos)
            Sphere_wrl=lire_fichier_vrml(fullfile(dossier3,[cur_bille_a_trouver '.wrl']));
            Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
           centre= Sphere.Centre*10^(-3);
                centre=MH_R0Rlocal\[centre';1];
                st_marqueurs.(cur_bille_a_trouver)=centre(1:3);
            ok_femD=1;
        end
    end
    billes_tibD=Protocol.MARQUEURS_EOS.tibia_r;
    file_wrl_tibia=fullfile(dossier3,'TibiaD.wrl');
        MH_R0Rlocal=calcul_repere_tibia_mod_avec_malleoles(dossier3,repertoire_ddr,'D');
        MH_R0Rlocal(1:3,4)=MH_R0Rlocal(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
    for i_b_D=1:size(billes_tibD,2)
        cur_bille_a_trouver=billes_tibD{i_b_D};
        pos=find(strcmp(billes_MID,[cur_bille_a_trouver '.wrl']), 1);
        if ~isempty(pos)
            Sphere_wrl=lire_fichier_vrml(fullfile(dossier3,[cur_bille_a_trouver '.wrl']));
            Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
            centre= Sphere.Centre*10^(-3);
            centre=MH_R0Rlocal\[centre';1];
                st_marqueurs.(cur_bille_a_trouver)=centre(1:3);
            ok_tibD=1;
        end
    end
end

dossier2=fullfile(rep_billes_EOS,'billes_MIG');
if exist(dossier2,'dir')==7
    [~,billes_MIG]=PathContent_Type(dossier2,'wrl');
    %femur_droit
    billes_femG=Protocol.MARQUEURS_EOS.femur_l;
    for i_b_G=1:size(billes_femG,2)
        cur_bille_a_trouver=billes_femD{i_b_G};
        pos=find(strcmp(billes_MIG,[cur_bille_a_trouver '.wrl']), 1);
         file_wrl_femurG=fullfile(dossier2,'FemurG.wrl');
        MH_R0Rlocal=repere_femur_EOS_decal(file_wrl_femurG,file_ddr_femur_l,0);
        MH_R0Rlocal(1:3,4)=MH_R0Rlocal(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
        MH_R0Rlocal(1:3,1)=-MH_R0Rlocal(1:3,1);
        MH_R0Rlocal(1:3,3)=-MH_R0Rlocal(1:3,3);
        if ~isempty(pos)
            Sphere_wrl=lire_fichier_vrml(fullfile(dossier2,[cur_bille_a_trouver '.wrl']));
            Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
            centre= Sphere.Centre*10^(-3);
                centre=MH_R0Rlocal\[centre';1];
                st_marqueurs.(cur_bille_a_trouver)=centre(1:3);
            ok_femG=1;
        end
    end
    billes_tibG=Protocol.MARQUEURS_EOS.tibia_l;
    for i_b_G=1:size(billes_tibG,2)
        cur_bille_a_trouver=billes_tibG{i_b_G};
        pos=find(strcmp(billes_MIG,[cur_bille_a_trouver '.wrl']), 1);
        file_wrl_tibia=fullfile(dossier2,'TibiaG.wrl');
        MH_R0Rlocal=calcul_repere_tibia_mod_avec_malleoles(dossier2,repertoire_ddr,'G');
        MH_R0Rlocal(1:3,4)=MH_R0Rlocal(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
        MH_R0Rlocal(1:3,1)=-MH_R0Rlocal(1:3,1);
        MH_R0Rlocal(1:3,3)=-MH_R0Rlocal(1:3,3);
        if ~isempty(pos)
            Sphere_wrl=lire_fichier_vrml(fullfile(dossier2,[cur_bille_a_trouver '.wrl']));
            Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
            centre= Sphere.Centre*10^(-3);
                centre=MH_R0Rlocal\[centre';1];
                st_marqueurs.(cur_bille_a_trouver)=centre(1:3);
            ok_tibG=1;
        end
    end
end

dossier1=fullfile(rep_billes_EOS,'billes_corps_complet');
if exist(dossier1,'dir')==7
    [~,billes_CC]=PathContent_Type(dossier1,'wrl');
    %bassin
    billes_bassin=Protocol.MARQUEURS_EOS.pelvis;
    if ~isempty(cur_sex)
        if strcmp(cur_sex,'M')
            file_ddr_bassin=fullfile(repertoire_ddr,'MG_Bassin_Homme.ddr');
        elseif strcmp(cur_sex,'F')
            file_ddr_bassin=fullfile(repertoire_ddr,'MG_Bassin_Femme.ddr');
        end
    else
        file_ddr_bassin=fullfile(repertoire_ddr,'Bassin.ddr');
    end
    file_wrl_bassin=fullfile(dossier1,'Bassin.wrl');
    MH_R0Rlocal=repere_bassin_wrl_decalage(file_wrl_bassin,file_ddr_bassin,0,0);
    MH_R0Rlocal(1:3,4)=MH_R0Rlocal(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
    for i_pelvis=1:size(billes_bassin,2)
        cur_bille_a_trouver=billes_bassin{i_pelvis};
        pos=find(strcmp(billes_CC,[cur_bille_a_trouver '.wrl']), 1);
        if ~isempty(pos)
            Sphere_wrl=lire_fichier_vrml(fullfile(dossier1,[cur_bille_a_trouver '.wrl']));
            Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
            centre= Sphere.Centre*10^(-3);
            centre=MH_R0Rlocal\[centre';1];
            st_marqueurs.(cur_bille_a_trouver)=centre(1:3);
            
        end
    end
    
    if ok_femD==0
        [~,billes_MID]=PathContent_Type(dossier1,'wrl');
        %femur_droit
        billes_femD=Protocol.MARQUEURS_EOS.femur_r;
        file_wrl_femurD=fullfile(dossier1,'FemurD.wrl');
        MH_R0Rlocal=repere_femur_EOS_decal(file_wrl_femurD,file_ddr_femur_r,0);
        MH_R0Rlocal(1:3,4)=MH_R0Rlocal(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
        for i_b_D=1:size(billes_femD,2)
            cur_bille_a_trouver=billes_femD{i_b_D};
            pos=find(strcmp(billes_MID,[cur_bille_a_trouver '.wrl']), 1);
            if ~isempty(pos)
                Sphere_wrl=lire_fichier_vrml(fullfile(dossier1,[cur_bille_a_trouver '.wrl']));
                Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
                centre= Sphere.Centre*10^(-3);
                centre=MH_R0Rlocal\[centre';1];
                st_marqueurs.(cur_bille_a_trouver)=centre(1:3);
            end
        end
    end
    
    if ok_femG==0
        [~,billes_MIG]=PathContent_Type(dossier1,'wrl');
        %femur_gauche
        billes_femG=Protocol.MARQUEURS_EOS.femur_l;
        file_wrl_femurG=fullfile(dossier1,'FemurG.wrl');
        MH_R0Rlocal=repere_femur_EOS_decal(file_wrl_femurG,file_ddr_femur_l,0);
        MH_R0Rlocal(1:3,4)=MH_R0Rlocal(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
        MH_R0Rlocal(1:3,1)=-MH_R0Rlocal(1:3,1);
        MH_R0Rlocal(1:3,3)=-MH_R0Rlocal(1:3,3);
        for i_b_G=1:size(billes_femG,2)
            cur_bille_a_trouver=billes_femG{i_b_G};
            pos=find(strcmp(billes_MIG,[cur_bille_a_trouver '.wrl']), 1);
            if ~isempty(pos)
                Sphere_wrl=lire_fichier_vrml(fullfile(dossier1,[cur_bille_a_trouver '.wrl']));
                Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
                centre= Sphere.Centre*10^(-3);
                centre=MH_R0Rlocal\[centre';1];
                st_marqueurs.(cur_bille_a_trouver)=centre(1:3);
            end
        end
    end
    
    if ok_tibD==0
        [~,billes_MID]=PathContent_Type(dossier1,'wrl');
        %tibia droit
        billes_tibD=Protocol.MARQUEURS_EOS.tibia_r;
        file_wrl_tibia=fullfile(dossier1,'TibiaD.wrl');
        MH_R0Rlocal=calcul_repere_tibia_mod_avec_malleoles(dossier1,repertoire_ddr,'D');
        MH_R0Rlocal(1:3,4)=MH_R0Rlocal(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
        for i_b_D=1:size(billes_tibD,2)
            cur_bille_a_trouver=billes_tibD{i_b_D};
            pos=find(strcmp(billes_MID,[cur_bille_a_trouver '.wrl']), 1);
            if ~isempty(pos)
                Sphere_wrl=lire_fichier_vrml(fullfile(dossier1,[cur_bille_a_trouver '.wrl']));
                Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
                centre= Sphere.Centre*10^(-3);
                centre=MH_R0Rlocal\[centre';1];
                st_marqueurs.(cur_bille_a_trouver)=centre(1:3);
            end
        end
    end
    if ok_tibG==0
        [~,billes_MIG]=PathContent_Type(dossier1,'wrl');
        %tibia gauche
        billes_tibG=Protocol.MARQUEURS_EOS.tibia_l;
        file_wrl_tibia=fullfile(dossier1,'TibiaG.wrl');
        MH_R0Rlocal=calcul_repere_tibia_mod_avec_malleoles(dossier1,repertoire_ddr,'G');
        MH_R0Rlocal(1:3,4)=MH_R0Rlocal(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
        MH_R0Rlocal(1:3,1)=-MH_R0Rlocal(1:3,1);
        MH_R0Rlocal(1:3,3)=-MH_R0Rlocal(1:3,3);
        for i_b_D=1:size(billes_tibG,2)
            cur_bille_a_trouver=billes_tibG{i_b_D};
            pos=find(strcmp(billes_MIG,[cur_bille_a_trouver '.wrl']), 1);
            if ~isempty(pos)
                Sphere_wrl=lire_fichier_vrml(fullfile(dossier1,[cur_bille_a_trouver '.wrl']));
                Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
                centre= Sphere.Centre*10^(-3);
                centre=MH_R0Rlocal\[centre';1];
                st_marqueurs.(cur_bille_a_trouver)=centre(1:3);
            end
        end
    end
    
end
end