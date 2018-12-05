% model_old=xml_readOSIM('E:\ok_pour_ISBS\Re_Be_M_1968.osim');
% repertoire_wrl_EOS='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\EOS\ReBe_M_1968\reconstruction_6\droit';
% sexe='M';
% nom_sortie='2_modele_decal_EOS.osim';
% repertoire_modeles='E:\ISBS_data_ID_2\Re_Be_M_1968\golf_003_RB\traitement_OpenSim\golf_003_RB\nouveaux_modeles';
% prot_file='E:\ISBS_data_ID_2\Re_Be_M_1968\golf_003_RB\golf_perso_EOS_1.protOS';
% Protocol=lire_fichier_prot_2( prot_file );
% decalage_in_bassin=[0 0 0.02]';
% rep_billes_EOS='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\EOS\ReBe_M_1968\reconstruction_6\bille_mod';

function [model_new_9]=GOLF_variation_hanche_EOS(model_old,repertoire_wrl_EOS, Protocol, sexe, repertoire_modeles, nom_sortie, decalage_in_bassin)
disp('début de la personnalisation à partir des données EOS');

repertoire_wrl_EOS='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\EOS\ReBe_M_1968\reconstruction_6\droit';
file_wrl_bassin=strcat(repertoire_wrl_EOS, '\bassin.wrl');
file_wrl_femur_l=strcat(repertoire_wrl_EOS, '\FemurG.wrl');
file_wrl_femur_r=strcat(repertoire_wrl_EOS, '\FemurD.wrl');
file_wrl_tibia_r=strcat(repertoire_wrl_EOS, '\TibiaD.wrl');
file_wrl_tibia_l=strcat(repertoire_wrl_EOS, '\TibiaG.wrl');

if strcmp(sexe,'M')==1
    file_ddr_bassin='H:\sauvegarde_ddr\Cours_these\Recherche\fonctions_Matlab\Chrsitophe\MG_Bassin_Homme.ddr';
elseif strcmp(sexe,'F')==1
    file_ddr_bassin='H:\sauvegarde_ddr\Cours_these\Recherche\fonctions_Matlab\Chrsitophe\MG_Bassin_Femme.ddr';
end
file_ddr_femur_l='H:\sauvegarde_ddr\Cours_these\Recherche\fonctions_Matlab\Chrsitophe\FemurD_v3.ddr';
file_ddr_femur_r='H:\sauvegarde_ddr\Cours_these\Recherche\fonctions_Matlab\Chrsitophe\FemurD_v3.ddr';
file_ddr_tibia_r='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\EOS\fichiers_ddr\tibia_peroneD.ddr';
file_ddr_tibia_l='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\EOS\fichiers_ddr\tibia_peroneG.ddr';

% [Bodies, Joints] = extract_KinChainData_ModelOS(model_old);
[Bodies, ~] = extract_KinChainData_ModelOS(model_old);

[ Bodies ] = attribution_nom_visualisation_OS( Bodies, Protocol );
noms_bodies=fieldnames(Bodies);

for cc=1:7
    if cc==1
        ext='xp_';
        decalage_in_bassin=[0.02 0 0]';
        disp('cas x+')
    elseif cc==2
        ext='xm_';
        decalage_in_bassin=[-0.02 0 0]';
        disp('cas x-')
    elseif cc==3
        ext='yp_';
        decalage_in_bassin=[0 0.02 0]';
        disp('cas y+')
    elseif cc==4
        ext='ym_';
        decalage_in_bassin=[0 -0.02 0]';
        disp('cas y-')
    elseif cc==5
        ext='zp_';
        decalage_in_bassin=[0 0 0.02]';
        disp('cas z+')
    elseif cc==6
        ext='zm_';
        decalage_in_bassin=[0 0 -0.02]';
        disp('cas z-')
    elseif cc==7
        ext='ref_';
        decalage_in_bassin=[0 0 0]';
        disp('cas reference')
    end
    
    
    decalage_in_bassin_G_m=decalage_in_bassin;% décalage de la tete fémorale G dans le repere bassin en m
    decalage_in_bassin_D_m=decalage_in_bassin;% décalage de la tete fémorale D dans le repere bassin en m
    decalage_in_bassin_G_mm=decalage_in_bassin_G_m*10^3;
    decalage_in_bassin_D_mm=decalage_in_bassin_D_m*10^3;
    %
    
    
    
    %% modification de la visualisation
    % Si cette fonction est lancée après l'opération de scaling, il est
    % possible que des facteurs de scaling soient gardés. Or, en prenant les
    % géométries EOS, il faut attribuer le facteur [1 1 1]
    % Gestion du changement du nombre d'éléments géoémtriques dans chaque Body.
    model_new=model_old;
    
    nb_bodies=length(fieldnames(Bodies));
    noms_bodies=fieldnames(Bodies);
    for i=1:nb_bodies
        cur_nom=noms_bodies{i};
        A=['body_visu=Bodies.' cur_nom '.visualisation;'];
        eval(A);
        if isempty(body_visu)~=1
            [model_new]=change_scale_et_visu_geo_model_OS(model_new, i, body_visu);
        end
    end
    model_new_9=model_new;
    clear A
    clear cur_nom
    %% Modification du bassin
    %
    disp('personnalisation EOS du bassin');
    nb_bassin=find(strcmp(noms_bodies,'pelvis'));
    nb_bassin=num2str(nb_bassin);
    
    %création du repère bassin
    MH_R0Rlocal_bassin=repere_bassin_wrl_decalage(file_wrl_bassin,file_ddr_bassin,decalage_in_bassin_G_mm,decalage_in_bassin_D_mm);
    MH_R0Rlocal_bassin_2=MH_R0Rlocal_bassin;
    if strcmp(model_new.Model.length_units,'meters')==1
        MH_R0Rlocal_bassin_2(1:3,4)=MH_R0Rlocal_bassin(1:3,4)*10^(-3);
    elseif strcmp(model_new.Model.length_units,'milimeters')==1
    else
        disp('erreur de déclaration unité dans OpenSim')
    end
    
    decalage_in_EOS_D_mm=MH_R0Rlocal_bassin(1:3,1:3)*decalage_in_bassin_D_mm;
    decalage_in_EOS_G_mm=MH_R0Rlocal_bassin(1:3,1:3)*decalage_in_bassin_G_mm;
    decalage_in_EOS_D_m=MH_R0Rlocal_bassin(1:3,1:3)*decalage_in_bassin_D_m;
    decalage_in_EOS_G_m=MH_R0Rlocal_bassin(1:3,1:3)*decalage_in_bassin_G_m;
    
    model_new_9=model_new;
    
    [a_bassin b_bassin c_bassin]=axe_mobile_xyz([MH_R0Rlocal_bassin_2(1:3,1:3)]');
    angles=2*pi/360*[a_bassin b_bassin c_bassin];
    
    
    vect=-MH_R0Rlocal_bassin_2(1:3,1:3)'*MH_R0Rlocal_bassin_2(1:3,4);
    
    model_new_9.Model.BodySet.objects.Body(2).VisibleObject.transform=[ 0 0 0 0 0 0];
    try
        model_new_9.Model.BodySet.objects.Body(2).VisibleObject.GeometrySet.objects.DisplayGeometry(1).transform=[angles vect'];
        model_new_9.Model.BodySet.objects.Body(2).VisibleObject.GeometrySet.objects.DisplayGeometry(2)=[];
        model_new_9.Model.BodySet.objects.Body(2).VisibleObject.GeometrySet.objects.DisplayGeometry(3)=[];
    catch
        model_new_9.Model.BodySet.objects.Body(2).VisibleObject.GeometrySet.objects.DisplayGeometry.transform=[angles vect'];
    end
    
    MH_R0R1_hanche_G=hanche_rep_bassin_decal(MH_R0Rlocal_bassin, file_wrl_femur_l,file_ddr_femur_l,decalage_in_EOS_G_mm);
    MH_R0R1_hanche_G_2=MH_R0R1_hanche_G;
    if strcmp(model_new.Model.length_units,'meters')==1
        MH_R0R1_hanche_G_2(1:3,4)=MH_R0R1_hanche_G(1:3,4)*10^(-3);
    elseif strcmp(model_new.Model.length_units,'milimeters')==1
    else
        disp('erreur de déclaration unité dans OpenSim')
    end
    
    model_new_9.Model.BodySet.objects.Body(8).Joint.CustomJoint.location_in_parent=MH_R0R1_hanche_G_2(1:3,4);
    
    MH_R0R1_hanche_D=hanche_rep_bassin_decal(MH_R0Rlocal_bassin, file_wrl_femur_r,file_ddr_femur_r,decalage_in_EOS_D_mm);
    MH_R0R1_hanche_D_2=MH_R0R1_hanche_D;
    if strcmp(model_new.Model.length_units,'meters')==1
        MH_R0R1_hanche_D_2(1:3,4)=MH_R0R1_hanche_D(1:3,4)*10^(-3);
    elseif strcmp(model_new.Model.length_units,'milimeters')==1
    else
        disp('erreur de déclaration unité dans OpenSim')
    end
    
    model_new_9.Model.BodySet.objects.Body(3).Joint.CustomJoint.location_in_parent=MH_R0R1_hanche_D_2(1:3,4);
    
    
    %% Modification du fémur gauche
    disp('personnalisation EOS du fémur gauche')
    nb_femur_l=find(strcmp(noms_bodies,'femur_l'));
    nb_femur_l=num2str(nb_femur_l);
    
    %création du repère decalé fémur gauche
    MH_R0Rlocal_femur_l=repere_femur_EOS_decal(file_wrl_femur_l,file_ddr_femur_l,decalage_in_EOS_G_mm);
    %%Remarque
    % attention l'orientation des axes dépends du coté : pas identique pour le
    % fémur droit et pour le fémur gauche
    MH_R0Rlocal_femur_l(1:3,1)=-MH_R0Rlocal_femur_l(1:3,1);
    MH_R0Rlocal_femur_l(1:3,3)=-MH_R0Rlocal_femur_l(1:3,3);
    MH_R0Rlocal_femur_l_2=MH_R0Rlocal_femur_l;
    if strcmp(model_new.Model.length_units,'meters')==1
        MH_R0Rlocal_femur_l_2(1:3,4)=MH_R0Rlocal_femur_l(1:3,4)*10^(-3);
    elseif strcmp(model_new.Model.length_units,'milimeters')==1
    else
        disp('erreur de déclaration unité dans OpenSim')
    end
    
    [a_femur_l b_femur_l c_femur_l]=axe_mobile_xyz([MH_R0Rlocal_femur_l_2(1:3,1:3)]');
    angles=2*pi/360*[a_femur_l b_femur_l c_femur_l];
    
    vect=-MH_R0Rlocal_femur_l_2(1:3,1:3)'*MH_R0Rlocal_femur_l_2(1:3,4);
    
    model_new_9.Model.BodySet.objects.Body(8).VisibleObject.transform=[ 0 0 0 0 0 0];
    model_new_9.Model.BodySet.objects.Body(8).VisibleObject.GeometrySet.objects.DisplayGeometry.transform=[angles vect'];
    
    %% Modification du fémur droit
    disp('personnalisation EOS du fémur droit')
    nb_femur_r=find(strcmp(noms_bodies,'femur_r'));
    nb_femur_r=num2str(nb_femur_r);
    
    %création du repère fémur droit
    MH_R0Rlocal_femur_r=repere_femur_EOS_decal(file_wrl_femur_r,file_ddr_femur_r,decalage_in_EOS_D_mm);
    MH_R0Rlocal_femur_r_2=MH_R0Rlocal_femur_r;
    if strcmp(model_new.Model.length_units,'meters')==1
        MH_R0Rlocal_femur_r_2(1:3,4)=MH_R0Rlocal_femur_r(1:3,4)*10^(-3);
    elseif strcmp(model_new.Model.length_units,'milimeters')==1
    else
        disp('erreur de déclaration unité dans OpenSim')
    end
    
    [a_femur_r b_femur_r c_femur_r]=axe_mobile_xyz([MH_R0Rlocal_femur_r_2(1:3,1:3)]');
    angles=2*pi/360*[a_femur_r b_femur_r c_femur_r];
    
    vect=-MH_R0Rlocal_femur_r_2(1:3,1:3)'*MH_R0Rlocal_femur_r_2(1:3,4);
    
    model_new_9.Model.BodySet.objects.Body(3).VisibleObject.transform=[ 0 0 0 0 0 0];
    model_new_9.Model.BodySet.objects.Body(3).VisibleObject.GeometrySet.objects.DisplayGeometry.transform=[angles vect'];
    
    cd(repertoire_modeles);
    RootName ='OpenSimDocument';
    %% gestion des marqueurs
    % création de la structure reperesH
%     disp('rassemblement des repères homogènes');
%     reperesH.pelvis=MH_R0Rlocal_bassin_2;
%     reperesH.femur_l=MH_R0Rlocal_femur_l_2;
%     reperesH.femur_r=MH_R0Rlocal_femur_r_2;
%     reperesH.tibia_r=MH_R0Rlocal_tibia_r_2;
%     reperesH.tibia_l=MH_R0Rlocal_tibia_l_2;
%     marqueurs=centre_des_billes_en_m(rep_billes_EOS);
    % fichier_sortie='E:\prot_OS\marqueurs_ReBe_2.xml';
    % list_seg={'femur_r'; 'femur_l'; 'pelvis'};
    
%     disp('modification des coordonnées de marqueurs');
%     [model_new_9]=modif_marqueurs_in_OSIM(model_new_9,marqueurs,Protocol, reperesH);
    
    % ecriture_XML_marqueurs_EOS_selection(marqueurs, fichier_sortie, Protocol, reperesH, list_seg)
    
    disp('écriture du nouveau fichier OSIM');
    xml_writeOSIM([ext nom_sortie],model_new_9,RootName,struct('StructItem',false,'CellItem',false));
    
    disp('cinématique inverse')

end



end


