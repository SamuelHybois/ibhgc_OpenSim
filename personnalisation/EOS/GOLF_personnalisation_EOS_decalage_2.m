% function [model_new]=GOLF_personnalisation_EOS(model_old, Protocol,sexe)

% 
function [model_new_9]=GOLF_personnalisation_EOS_decalage_2(model_old,repertoire_wrl_EOS,rep_billes_EOS, Protocol, sexe,decalage_in_bassin)
% decalage_in_bassin=[0 0.02 0]';
decalage_in_bassin_G_m=decalage_in_bassin;% décalage de la tete fémorale G dans le repere bassin en m
decalage_in_bassin_D_m=decalage_in_bassin;% décalage de la tete fémorale D dans le repere bassin en m
decalage_in_bassin_G_mm=decalage_in_bassin_G_m*10^3;
decalage_in_bassin_D_mm=decalage_in_bassin_D_m*10^3;
% 


disp('début de la personnalisation à partir des données EOS');
% prot_file='E:\prot_OS\golf_memb_inf.protOS';
% Protocol = lire_fichier_prot_2( prot_file );
% model_old=xml_readOSIM('E:\prot_OS\golf_001_MJ_model_final.osim');
% model_de_base=xml_readOSIM('E:\prot_OS\memb_inf.osim');
% sexe='M';

% repertoire_wrl_EOS='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\EOS\ReBe_M_1968\reconstruction_6\droit';
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

%% Modification du tibia droit
disp('personnalisation EOS du tibia droit')
nb_tibia_r=find(strcmp(noms_bodies,'tibia_r'));
nb_tibia_r=num2str(nb_tibia_r);

%création du repère tibia droit
% repère tibia centré sur les plateaux tibiaux.
MH_R0Rlocal_tibia_r=calcul_repere_tibia_mod(file_wrl_tibia_r,file_ddr_tibia_r);
MH_R0Rlocal_tibia_r_2=MH_R0Rlocal_tibia_r;
if strcmp(model_new.Model.length_units,'meters')==1
    MH_R0Rlocal_tibia_r_2(1:3,4)=MH_R0Rlocal_tibia_r(1:3,4)*10^(-3);
elseif strcmp(model_new.Model.length_units,'milimeters')==1
else
    disp('erreur de déclaration unité dans OpenSim')
end

[a_tibia_r b_tibia_r c_tibia_r]=axe_mobile_xyz([MH_R0Rlocal_tibia_r_2(1:3,1:3)]');
angles=2*pi/360*[a_tibia_r b_tibia_r c_tibia_r];

vect=-MH_R0Rlocal_tibia_r_2(1:3,1:3)'*MH_R0Rlocal_tibia_r_2(1:3,4);

model_new_9.Model.BodySet.objects.Body(4).VisibleObject.transform=[ 0 0 0 0 0 0];
model_new_9.Model.BodySet.objects.Body(4).VisibleObject.GeometrySet.objects.DisplayGeometry(1).transform=[angles vect'];
model_new_9.Model.BodySet.objects.Body(4).VisibleObject.GeometrySet.objects.DisplayGeometry(2).transform=[angles vect'];

%création du repère genou
% repère genou centré sur les condiles
[MH_R0R1_genou_r, plateaux_EOS, condiles_EOS,rayon_cond_r]=genou_rep_femur_decal(MH_R0Rlocal_femur_r, file_wrl_femur_r,file_ddr_femur_r,file_wrl_tibia_r,file_ddr_tibia_r);
MH_R0R1_genou_r_2=MH_R0R1_genou_r;
plateaux_EOS_2=plateaux_EOS;
condiles_EOS_2=condiles_EOS;
if strcmp(model_new.Model.length_units,'meters')==1
    MH_R0R1_genou_r_2(1:3,4)=MH_R0R1_genou_r(1:3,4)*10^(-3);
    plateaux_EOS_2=plateaux_EOS_2*10^(-3);
    condiles_EOS_2=condiles_EOS_2*10^(-3);
elseif strcmp(model_new.Model.length_units,'milimeters')==1
else
    disp('erreur de déclaration unité dans OpenSim')
end

model_new_9.Model.BodySet.objects.Body(4).Joint.CustomJoint.location_in_parent=MH_R0R1_genou_r_2(1:3,4)';%+decal_tib_genou_l_femur_2(1:3)';

centre_condile_EOS_Rtib_r=inv(MH_R0Rlocal_tibia_r_2)*[condiles_EOS_2';1];
centre_condile_EOS_Rtib_r=centre_condile_EOS_Rtib_r(1:3)';

model_new_9.Model.BodySet.objects.Body(4).Joint.CustomJoint.location=centre_condile_EOS_Rtib_r+[0 0.0125 0];

%% Modification du tibia gauche
disp('personnalisation EOS du tibia gauche')
nb_tibia_l=find(strcmp(noms_bodies,'tibia_l'));
nb_tibia_l=num2str(nb_tibia_l);

%création du repère tibia gauche
% repère tibia centré sur les plateaux tibiaux.
MH_R0Rlocal_tibia_l=calcul_repere_tibia_mod(file_wrl_tibia_l,file_ddr_tibia_l);
%%Remarque
% attention l'orientation des axes dépends du coté : pas identique pour le
% tibia droit et pour le tibia gauche 
MH_R0Rlocal_tibia_l(1:3,1)=-MH_R0Rlocal_tibia_l(1:3,1);
MH_R0Rlocal_tibia_l(1:3,3)=-MH_R0Rlocal_tibia_l(1:3,3);
MH_R0Rlocal_tibia_l_2=MH_R0Rlocal_tibia_l;
if strcmp(model_new.Model.length_units,'meters')==1
    MH_R0Rlocal_tibia_l_2(1:3,4)=MH_R0Rlocal_tibia_l(1:3,4)*10^(-3);
elseif strcmp(model_new.Model.length_units,'milimeters')==1
else
    disp('erreur de déclaration unité dans OpenSim')
end

[a_tibia_l b_tibia_l c_tibia_l]=axe_mobile_xyz([MH_R0Rlocal_tibia_l_2(1:3,1:3)]');
angles=2*pi/360*[a_tibia_l b_tibia_l c_tibia_l];

vect=-MH_R0Rlocal_tibia_l_2(1:3,1:3)'*MH_R0Rlocal_tibia_l_2(1:3,4);

model_new_9.Model.BodySet.objects.Body(9).VisibleObject.transform=[ 0 0 0 0 0 0];
model_new_9.Model.BodySet.objects.Body(9).VisibleObject.GeometrySet.objects.DisplayGeometry(1).transform=[angles vect'];
model_new_9.Model.BodySet.objects.Body(9).VisibleObject.GeometrySet.objects.DisplayGeometry(2).transform=[angles vect'];

%création du repère genou
% repère genou centré sur les condiles
[MH_R0R1_genou_l, plateaux_EOS, condiles_EOS,rayon_cond_l]=genou_rep_femur_decal(MH_R0Rlocal_femur_l, file_wrl_femur_l,file_ddr_femur_l,file_wrl_tibia_l,file_ddr_tibia_l);
MH_R0R1_genou_l_2=MH_R0R1_genou_l;
plateaux_EOS_2=plateaux_EOS;
condiles_EOS_2=condiles_EOS;
if strcmp(model_new.Model.length_units,'meters')==1
    MH_R0R1_genou_l_2(1:3,4)=MH_R0R1_genou_l(1:3,4)*10^(-3);
    plateaux_EOS_2=plateaux_EOS_2*10^(-3);
    condiles_EOS_2=condiles_EOS_2*10^(-3);
elseif strcmp(model_new.Model.length_units,'milimeters')==1
else
    disp('erreur de déclaration unité dans OpenSim')
end

model_new_9.Model.BodySet.objects.Body(9).Joint.CustomJoint.location_in_parent=MH_R0R1_genou_l_2(1:3,4)';


centre_condile_EOS_Rtib_l=inv(MH_R0Rlocal_tibia_l_2)*[condiles_EOS_2';1];
centre_condile_EOS_Rtib_l=centre_condile_EOS_Rtib_l(1:3)';

model_new_9.Model.BodySet.objects.Body(9).Joint.CustomJoint.location=centre_condile_EOS_Rtib_l+[0 0.0125 0];

Bx=[-2.0944 -1.2217 -0.5236 -0.3491 -0.1745 0.1591 2.0944];
By =[-0.0133 0.0011 0.0103 0.0117 0.0127 0.0140 0.0133];
model_new_9.Model.BodySet.objects.Body(4).Joint.CustomJoint.SpatialTransform.TransformAxis(5).xfunction.MultiplierXfunction.xfunction.SimmSpline.x=Bx;
model_new_9.Model.BodySet.objects.Body(4).Joint.CustomJoint.SpatialTransform.TransformAxis(5).xfunction.MultiplierXfunction.xfunction.SimmSpline.y=By;
model_new_9.Model.BodySet.objects.Body(9).Joint.CustomJoint.SpatialTransform.TransformAxis(5).xfunction.MultiplierXfunction.xfunction.SimmSpline.x=Bx;
model_new_9.Model.BodySet.objects.Body(9).Joint.CustomJoint.SpatialTransform.TransformAxis(5).xfunction.MultiplierXfunction.xfunction.SimmSpline.y=By;

BBy=[-0.0032 0.0018 0.0041 0.0041 0.0021 -0.0010 -0.0031 -0.0052 -0.0054 -0.0056 -0.0054 -0.0053];
BBx=[-2.0944 -1.74533 -1.39626 -1.0472 -0.698132 -0.349066 -0.174533 0.197344 0.337395 0.490178 1.52146 2.0944];
model_new_9.Model.BodySet.objects.Body(4).Joint.CustomJoint.SpatialTransform.TransformAxis(4).xfunction.SimmSpline.x=BBx;
model_new_9.Model.BodySet.objects.Body(4).Joint.CustomJoint.SpatialTransform.TransformAxis(4).xfunction.SimmSpline.y=BBy;
model_new_9.Model.BodySet.objects.Body(9).Joint.CustomJoint.SpatialTransform.TransformAxis(4).xfunction.SimmSpline.x=BBx;
model_new_9.Model.BodySet.objects.Body(9).Joint.CustomJoint.SpatialTransform.TransformAxis(4).xfunction.SimmSpline.y=BBy;
cd('E:\test_etude_variation_hanche');
RootName ='OpenSimDocument';

%% gestion des marqueurs
% création de la structure reperesH
disp('rassemblement des repères homogènes');
reperesH.pelvis=MH_R0Rlocal_bassin_2;
reperesH.femur_l=MH_R0Rlocal_femur_l_2;
reperesH.femur_r=MH_R0Rlocal_femur_r_2;
reperesH.tibia_r=MH_R0Rlocal_tibia_r_2;
reperesH.tibia_l=MH_R0Rlocal_tibia_l_2;
reperesH.torso=MH_R0Rlocal_bassin_2;


% Genere_Bille_EOS
% Relabel_bille_EOS

% %ReBe
% repgen='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\EOS\ReBe_M_1968\reconstruction_6\bille_mod';
%MaJe
disp('prise en compte de la vue complète')
% repgen_comp='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\EOS\2015_08_26-donnees_EOS\reconstructions\bille_mod';
marqueurs=centre_des_billes_en_m(rep_billes_EOS);


%
% disSp('prise en compte de la vue partielle memb inf droite')
% repgen_partD='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\EOS\2015_08_26-donnees_EOS\reconstructions\bille_mod_inf_partiel_D';
% marqueurs_vue_partielle=centre_des_billes_en_m(repgen_partD);
% reperesH.femur_r_vue_partielle=MH_R0Rlocal_femur_r_2_vue_partielle;
% file_wrl_femur_r_vue_partielle=strcat(repgen_partD, '\femurD.wrl');
% MH_R0Rlocal_femur_r_vue_partielle=repere_femur_EOS(file_wrl_femur_r_vue_partielle,file_ddr_femur_r);


%% possibilité 1 pour les marqueurs : second fichier
% disp('écriture du fichier des marqueurs issus de EOS')
% fichier_sortie='E:\prot_OS\marqueurs_ReBe_2.xml';
% ecriture_XML_marqueurs_EOS(marqueurs, fichier_sortie, Protocol, reperesH)

%% possibilité 2 pour les marqueurs : écriture dans le fichier OSIM
[model_new_9]=modif_marqueurs_in_OSIM(model_new_9,marqueurs,Protocol, reperesH);

% xml_writeOSIM('modele_perso_ReBe_test2.osim',model_new_9,RootName,struct('StructItem',false,'CellItem',false));

end


