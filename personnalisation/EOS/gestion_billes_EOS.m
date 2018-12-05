function [model_new,marqueurs]=gestion_billes_EOS(rep_billes_EOS,model_old, Protocol, reperesH,fichier_sortie)
% rep_billes_EOS='G:\_31_mise_en_forme_data_EOS\golf_036_XP';
% étape 1 : déterminer les coordonnées des billes dans le repère EOS,
% sachant qu'elles peuvent être dans 3 repères différents.
dossier_ddr=fullfile(rep_global,'info_global','fichiers_ddr');
marqueurs=struct;
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
        pos=find(strcmp(billes_MID,[cur_bille_a_trouver '.wrl']));
        file_wrl_femurD=fullfile(dossier1,'FemurD.wrl');
        MH_R0Rlocal=repere_femur_EOS_decal(file_wrl_femurD,file_ddr_femur_r,0);
        MH_R0Rlocal(1:3,4)=MH_R0Rlocal(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
        if ~isempty(pos)
            Sphere_wrl=lire_fichier_vrml(fullfile(dossier3,[cur_bille_a_trouver '.wrl']));
            Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
           centre= Sphere.Centre*10^(-3);
                centre=inv(MH_R0Rlocal)*[centre;1];
                marqueurs.(cur_bille_a_trouver)=centre;
            ok_femD=1;
        end
    end
    billes_tibD=Protocol.MARQUEURS_EOS.tibia_r;
    file_wrl_tibia=fullfile(dossier1,'TibiaD.wrl');
        [MH_R0Rlocal, ~]=calcul_repere_tibia_mod_avec_malleoles(file_wrl_tibia,file_ddr_tibia_r);
        MH_R0Rlocal(1:3,4)=MH_R0Rlocal(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
    for i_b_D=1:size(billes_tibD,2)
        cur_bille_a_trouver=billes_tibD{i_b_D};
        pos=find(strcmp(billes_MID,[cur_bille_a_trouver '.wrl']));
        if ~isempty(pos)
            Sphere_wrl=lire_fichier_vrml(fullfile(dossier3,[cur_bille_a_trouver '.wrl']));
            Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
            centre= Sphere.Centre*10^(-3);
            centre=inv(MH_R0Rlocal)*[centre;1];
                marqueurs.(cur_bille_a_trouver)=centre(1:3);
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
        pos=find(strcmp(billes_MIG,[cur_bille_a_trouver '.wrl']));
         file_wrl_femurG=fullfile(dossier1,'FemurG.wrl');
        MH_R0Rlocal=repere_femur_EOS_decal(file_wrl_femurG,file_ddr_femur_l,0);
        MH_R0Rlocal(1:3,4)=MH_R0Rlocal(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
        MH_R0Rlocal(1:3,1)=-MH_R0Rlocal(1:3,1);
        MH_R0Rlocal(1:3,3)=-MH_R0Rlocal(1:3,3);
        if ~isempty(pos)
            Sphere_wrl=lire_fichier_vrml(fullfile(dossier2,[cur_bille_a_trouver '.wrl']));
            Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
            centre= Sphere.Centre*10^(-3);
                centre=inv(MH_R0Rlocal)*[centre;1];
                marqueurs.(cur_bille_a_trouver)=centre(1:3);
            ok_femG=1;
        end
    end
    billes_tibG=Protocol.MARQUEURS_EOS.tibia_l;
    for i_b_G=1:size(billes_tibG,2)
        cur_bille_a_trouver=billes_tibG{i_b_G};
        pos=find(strcmp(billes_MIG,[cur_bille_a_trouver '.wrl']));
        file_wrl_tibia=fullfile(dossier1,'TibiaG.wrl');
        [MH_R0Rlocal, ~]=calcul_repere_tibia_mod_avec_malleoles(file_wrl_tibia,file_ddr_tibia_l);
        MH_R0Rlocal(1:3,4)=MH_R0Rlocal(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
        MH_R0Rlocal(1:3,1)=-MH_R0Rlocal(1:3,1);
        MH_R0Rlocal(1:3,3)=-MH_R0Rlocal(1:3,3);
        if ~isempty(pos)
            Sphere_wrl=lire_fichier_vrml(fullfile(dossier2,[cur_bille_a_trouver '.wrl']));
            Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
            centre= Sphere.Centre*10^(-3);
                centre=inv(MH_R0Rlocal)*[centre;1];
                marqueurs.(cur_bille_a_trouver)=centre(1:3);
            ok_tibG=1;
        end
    end
end

dossier1=fullfile(rep_billes_EOS,'billes_corps_complet');
if exist(dossier1,'dir')==7
    [~,billes_CC]=PathContent_Type(dossier1,'wrl');
    %bassin
    billes_bassin=Protocol.MARQUEURS_EOS.pelvis;
    if exist(cur_sex)
        if strcmp(cur_sex,'M')
            file_wrl_bassin=fullfile(dossier_ddr,'MG_Bassin_Homme.ddr');
        elseif strcmp(cur_sex,'F')
            file_wrl_bassin=fullfile(dossier_ddr,'MG_Bassin_Femme.ddr');
        end
    else
        file_ddr_bassin=fullfile(dossier_ddr,'Bassin.ddr');
    end
    file_wrl_bassin=fullfile(dossier1,'Bassin.wrl');
    MH_R0Rlocal=repere_bassin_wrl(file_wrl_bassin,file_ddr_bassin);
    MH_R0Rlocal(1:3,4)=MH_R0Rlocal(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
    for i_pelvis=1:size(billes_femG,2)
        cur_bille_a_trouver=billes_bassin{i_pelvis};
        pos=find(strcmp(billes_CC,[cur_bille_a_trouver '.wrl']));
        if ~isempty(pos)
            Sphere_wrl=lire_fichier_vrml(fullfile(dossier1,[cur_bille_a_trouver '.wrl']));
            Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
            centre= Sphere.Centre*10^(-3);
            centre=inv(MH_R0Rlocal)*[centre;1];
            marqueurs.(cur_bille_a_trouver)=centre(1:3);
            
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
            pos=find(strcmp(billes_MID,[cur_bille_a_trouver '.wrl']));
            if ~isempty(pos)
                Sphere_wrl=lire_fichier_vrml(fullfile(dossier1,[cur_bille_a_trouver '.wrl']));
                Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
                centre= Sphere.Centre*10^(-3);
                centre=inv(MH_R0Rlocal)*[centre;1];
                marqueurs.(cur_bille_a_trouver)=centre;
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
            pos=find(strcmp(billes_MIG,[cur_bille_a_trouver '.wrl']));
            if ~isempty(pos)
                Sphere_wrl=lire_fichier_vrml(fullfile(dossier1,[cur_bille_a_trouver '.wrl']));
                Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
                centre= Sphere.Centre*10^(-3);
                centre=inv(MH_R0Rlocal)*[centre;1];
                marqueurs.(cur_bille_a_trouver)=centre(1:3);
            end
        end
    end
    
    if ok_tibD==0
        [~,billes_MID]=PathContent_Type(dossier1,'wrl');
        %tibia droit
        billes_tibD=Protocol.MARQUEURS_EOS.tibia_r;
        file_wrl_tibia=fullfile(dossier1,'TibiaD.wrl');
        [MH_R0Rlocal, ~]=calcul_repere_tibia_mod_avec_malleoles(file_wrl_tibia,file_ddr_tibia_r);
        MH_R0Rlocal(1:3,4)=MH_R0Rlocal(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
        for i_b_D=1:size(billes_tibD,2)
            cur_bille_a_trouver=billes_tibD{i_b_D};
            pos=find(strcmp(billes_MID,[cur_bille_a_trouver '.wrl']));
            if ~isempty(pos)
                Sphere_wrl=lire_fichier_vrml(fullfile(dossier1,[cur_bille_a_trouver '.wrl']));
                Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
                centre= Sphere.Centre*10^(-3);
                centre=inv(MH_R0Rlocal)*[centre;1];
                marqueurs.(cur_bille_a_trouver)=centre(1:3);
            end
        end
    end
    if ok_tibG==0
        [~,billes_MIG]=PathContent_Type(dossier1,'wrl');
        %tibia gauche
        billes_tibG=Protocol.MARQUEURS_EOS.tibia_l;
        file_wrl_tibia=fullfile(dossier1,'TibiaG.wrl');
        [MH_R0Rlocal, ~]=calcul_repere_tibia_mod_avec_malleoles(file_wrl_tibia,file_ddr_tibia_l);
        MH_R0Rlocal(1:3,4)=MH_R0Rlocal(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
        MH_R0Rlocal(1:3,1)=-MH_R0Rlocal(1:3,1);
        MH_R0Rlocal(1:3,3)=-MH_R0Rlocal(1:3,3);
        for i_b_D=1:size(billes_tibG,2)
            cur_bille_a_trouver=billes_tibG{i_b_D};
            pos=find(strcmp(billes_MIG,[cur_bille_a_trouver '.wrl']));
            if ~isempty(pos)
                Sphere_wrl=lire_fichier_vrml(fullfile(dossier1,[cur_bille_a_trouver '.wrl']));
                Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
                centre= Sphere.Centre*10^(-3);
                centre=inv(MH_R0Rlocal)*[centre;1];
                marqueurs.(cur_bille_a_trouver)=centre(1:3);
            end
        end
    end
    
end


%
% disSp('prise en compte de la vue partielle memb inf droite')
% repgen_partD='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\EOS\2015_08_26-donnees_EOS\reconstructions\bille_mod_inf_partiel_D';
% marqueurs_vue_partielle=centre_des_billes_en_m(repgen_partD);
% reperesH.femur_r_vue_partielle=MH_R0Rlocal_femur_r_2_vue_partielle;
% file_wrl_femur_r_vue_partielle=strcat(repgen_partD, '\femurD.wrl');
% MH_R0Rlocal_femur_r_vue_partielle=repere_femur_EOS(file_wrl_femur_r_vue_partielle,file_ddr_femur_r);

disp('écriture du fichier des marqueurs issus de EOS')
% fichier_sortie='E:\prot_OS\marqueurs_ReBe.xml';
ecriture_XML_marqueurs_EOS_2(marqueurs, fichier_sortie, Protocol, reperesH);

[model_new]=modif_marqueurs_in_OSIM_2(model_old,marqueurs, Protocol, reperesH);

end