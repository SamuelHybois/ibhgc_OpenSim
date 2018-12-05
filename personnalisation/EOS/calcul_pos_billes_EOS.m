function st_marqueurs=calcul_pos_billes_EOS(rep_billes_EOS,reperes,Protocol,rep_DDR,rep_wrl,points)

st_marqueurs=struct;
dossier_MID=fullfile(rep_billes_EOS,'billes_corps_MID');
ok_femD=0;
ok_femG=0;
ok_tibD=0;
ok_tibG=0;

if isdir(dossier_MID)
    [~,billes_MID]=PathContent_Type(dossier_MID,'wrl');
    % Femur Droit
    billes_femD=Protocol.SEGMENTS.CuisseD;
    billes_a_trouver_femD=billes_femD;
    reperes_MinfD=extraction_reperes_joint_center_EOS_MinfD(rep_DDR,rep_wrl,points);
    reperes_MinfD.FemurD(1:3,4)=reperes_MinfD.FemurD(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m 
    for i_b_D=1:size(billes_femD,2)
        cur_bille_a_trouver=billes_femD{i_b_D};
        pos=find(strcmp(billes_MID,[cur_bille_a_trouver '.wrl']), 1);
        if ~isempty(pos)
            Sphere_wrl=lire_fichier_vrml(fullfile(dossier_MID,[cur_bille_a_trouver '.wrl']));
            Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
            centre= Sphere.Centre*10^(-3);
            centre=reperes_MinfD.FemurD\[centre';1];
            st_marqueurs.(cur_bille_a_trouver)=centre(1:3);
            billes_a_trouver_femD{i_b_D}={};
        end
    end
    % on enlève les cellules vides pour voir si on a replacé tous les
    % marqueurs
    billes_a_trouver_femD=billes_a_trouver_femD(~cellfun('isempty',billes_a_trouver_femD));
    if isempty(billes_a_trouver_femD)
        ok_femD=1;
    end
    % Tibia Droit
    billes_tibD=Protocol.SEGMENTS.JambeD;
    billes_a_trouver_tibD=billes_femD;
    reperes_MinfD.TibiaD(1:3,4)=reperes_MinfD.TibiaD(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m    
    for i_b_D=1:size(billes_tibD,2)
        cur_bille_a_trouver=billes_tibD{i_b_D};
        pos=find(strcmp(billes_MID,[cur_bille_a_trouver '.wrl']), 1);
        if ~isempty(pos)
            Sphere_wrl=lire_fichier_vrml(fullfile(dossier_MID,[cur_bille_a_trouver '.wrl']));
            Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
            centre= Sphere.Centre*10^(-3);
            centre=reperes_MinfD.TibiaD\[centre';1];
            st_marqueurs.(cur_bille_a_trouver)=centre(1:3);
            billes_a_trouver_tibD{i_b_D}={};
        end
    end
    billes_a_trouver_tibD=billes_a_trouver_tibD(~cellfun('isempty',billes_a_trouver_tibD));
    if isempty(billes_a_trouver_tibD)
        ok_tibD=1;
    end
end

dossier_MIG=fullfile(rep_billes_EOS,'billes_corps_MIG');
if isdir(dossier_MIG)
    [~,billes_MIG]=PathContent_Type(dossier_MIG,'wrl');
    % Femur Gauche
    billes_femG=Protocol.SEGMENTS.CuisseG;
    billes_a_trouver_femG=billes_femG;
    reperes_MinfG=extraction_reperes_joint_center_EOS_MinfG(rep_DDR,rep_wrl,points);
    reperes_MinfG.FemurG(1:3,4)=reperes_MinfG.FemurG(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
    for i_b_G=1:size(billes_femG,2)
        cur_bille_a_trouver=billes_femG{i_b_G};
        pos=find(strcmp(billes_MIG,[cur_bille_a_trouver '.wrl']), 1);
        if ~isempty(pos)
            Sphere_wrl=lire_fichier_vrml(fullfile(dossier_MIG,[cur_bille_a_trouver '.wrl']));
            Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
            centre= Sphere.Centre*10^(-3);
            centre=reperes_MinfG.FemurG\[centre';1];
            st_marqueurs.(cur_bille_a_trouver)=centre(1:3);
            billes_a_trouver_femG{i_b_G}={};
        end
    end
    billes_a_trouver_femG=billes_a_trouver_femG(~cellfun('isempty',billes_a_trouver_femG));
    if isempty(billes_a_trouver_femG)
        ok_femG=1;
    end
    % Tibia Gauche
    billes_tibG=Protocol.SEGMENTS.JambeD;
    billes_a_trouver_tibG=billes_tibG;
    reperes_MinfG.TibiaG(1:3,4)=reperes_MinfG.TibiaG(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
    for i_b_G=1:size(billes_tibG,2)
        cur_bille_a_trouver=billes_tibG{i_b_G};
        pos=find(strcmp(billes_MIG,[cur_bille_a_trouver '.wrl']), 1);
        if ~isempty(pos)
            Sphere_wrl=lire_fichier_vrml(fullfile(dossier_MIG,[cur_bille_a_trouver '.wrl']));
            Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
            centre= Sphere.Centre*10^(-3);
            centre=reperes_MinfG.TibiaG\[centre';1];
            st_marqueurs.(cur_bille_a_trouver)=centre(1:3);
            billes_a_trouver_tibG{i_b_G}={};
        end
    end
    billes_a_trouver_tibG=billes_a_trouver_tibG(~cellfun('isempty',billes_a_trouver_tibG));
    if isempty(billes_a_trouver_tibG)
        ok_tibG=1;
    end
end

dossier_corps_complet=fullfile(rep_billes_EOS,'billes_corps_complet');
if isdir(dossier_corps_complet)
    % Bassin
    [~,billes_CC]=PathContent_Type(dossier_corps_complet,'wrl');
    billes_bassin=Protocol.SEGMENTS.Pelvis;
    reperes.Bassin(1:3,4)=reperes.Bassin(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
    for i_b_pelvis=1:size(billes_bassin,2)
        cur_bille_a_trouver=billes_bassin{i_b_pelvis};
        pos=find(strcmp(billes_CC,[cur_bille_a_trouver '.wrl']), 1);
        if ~isempty(pos)
            Sphere_wrl=lire_fichier_vrml(fullfile(dossier_corps_complet,[cur_bille_a_trouver '.wrl']));
            Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
            centre= Sphere.Centre*10^(-3);
            centre=reperes.Bassin\[centre';1];
            st_marqueurs.(cur_bille_a_trouver)=centre(1:3);
        end
    end
    
    if ok_femD==0
        [~,billes_MID]=PathContent_Type(dossier_corps_complet,'wrl');
        %femur_droit
        billes_femD=Protocol.SEGMENTS.CuisseD;
        reperes.FemurD(1:3,4)=reperes.FemurD(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
        for i_b_D=1:size(billes_femD,2)
            cur_bille_a_trouver=billes_femD{i_b_D};
            pos=find(strcmp(billes_MID,[cur_bille_a_trouver '.wrl']), 1);
            if ~isempty(pos)
                Sphere_wrl=lire_fichier_vrml(fullfile(dossier_corps_complet,[cur_bille_a_trouver '.wrl']));
                Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
                centre= Sphere.Centre*10^(-3);
                centre=reperes.FemurD\[centre';1];
                st_marqueurs.(cur_bille_a_trouver)=centre(1:3);
            end
        end
    end
    
    if ok_femG==0
        [~,billes_MIG]=PathContent_Type(dossier_corps_complet,'wrl');
        %femur_gauche
        billes_femG=Protocol.SEGMENTS.CuisseG;
        reperes.FemurG(1:3,4)=reperes.FemurG(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
        for i_b_G=1:size(billes_femG,2)
            cur_bille_a_trouver=billes_femG{i_b_G};
            pos=find(strcmp(billes_MIG,[cur_bille_a_trouver '.wrl']), 1);
            if ~isempty(pos)
                Sphere_wrl=lire_fichier_vrml(fullfile(dossier_corps_complet,[cur_bille_a_trouver '.wrl']));
                Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
                centre= Sphere.Centre*10^(-3);
                centre=reperes.FemurG\[centre';1];
                st_marqueurs.(cur_bille_a_trouver)=centre(1:3);
            end
        end
    end
    
    if ok_tibD==0
        [~,billes_MID]=PathContent_Type(dossier_corps_complet,'wrl');
        %tibia droit
        billes_tibD=Protocol.SEGMENTS.JambeD;
        reperes.TibiaD(1:3,4)=reperes.TibiaD(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
        for i_b_D=1:size(billes_tibD,2)
            cur_bille_a_trouver=billes_tibD{i_b_D};
            pos=find(strcmp(billes_MID,[cur_bille_a_trouver '.wrl']), 1);
            if ~isempty(pos)
                Sphere_wrl=lire_fichier_vrml(fullfile(dossier_corps_complet,[cur_bille_a_trouver '.wrl']));
                Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
                centre= Sphere.Centre*10^(-3);
                centre=reperes.TibiaD\[centre';1];
                st_marqueurs.(cur_bille_a_trouver)=centre(1:3);
            end
        end
    end
    if ok_tibG==0
        [~,billes_MIG]=PathContent_Type(dossier_corps_complet,'wrl');
        %tibia gauche
        billes_tibG=Protocol.SEGMENTS.JambeG;
        reperes.TibiaG(1:3,4)=reperes.TibiaG(1:3,4)*10^(-3); %EOS est en mm et OpenSim en m
        for i_b_D=1:size(billes_tibG,2)
            cur_bille_a_trouver=billes_tibG{i_b_D};
            pos=find(strcmp(billes_MIG,[cur_bille_a_trouver '.wrl']), 1);
            if ~isempty(pos)
                Sphere_wrl=lire_fichier_vrml(fullfile(dossier_corps_complet,[cur_bille_a_trouver '.wrl']));
                Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
                centre= Sphere.Centre*10^(-3);
                centre=reperes.TibiaG\[centre';1];
                st_marqueurs.(cur_bille_a_trouver)=centre(1:3);
            end
        end
    end
    
end
end