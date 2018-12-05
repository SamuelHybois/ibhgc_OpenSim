
% pour le membre inférieur, utiliser la fonction GOLF_personnalisation_EOS_decalage_2_pour_pipeline
% cette fonction est adaptée pour le modèle fullbody développé par Maxime
% Bourgain et Samuel Hybois featuring Christophe Sauret qui ne sait pas
% installer Matlab.

function [model_new, reperesH]=pipeline_harmonisation_personnalisation_EOS_memb_inf_var(model_old,repertoire_wrl_EOS, sexe, repertoire_ddr,chemin_geometry,cur_sujet,cur_var,num_cas)%,marqueurs)
% cur var est le set des variations des variables à modifier.
% dans la première version de l'étude de cas, les variables à modifier
% sont: 
% - position tete fémorale D
% - position tete fémorale G
% - position condyle medial D
% - position condyle lateral D
% - position condyle medial G
% - position condyle lateral G
% dans les trois directions de l'espace.
% cur_var contient donc 18 nombres, exprimés en mm.

variations.tete_fem_D=cur_var(1:3)';
variations.tete_fem_G=cur_var(4:6)';
variations.condyle_med_D=cur_var(7:9)';
variations.condyle_lat_D=cur_var(10:12)';
variations.condyle_med_G=cur_var(13:15)';
variations.condyle_lat_G=cur_var(16:18)';



disp('début de la personnalisation à partir des données EOS');
%% déclaration des chemins des wrl
file_wrl_bassin=fullfile(repertoire_wrl_EOS, 'bassin.wrl');
file_wrl_femur_l=fullfile(repertoire_wrl_EOS, 'FemurG.wrl');
file_wrl_femur_r=fullfile(repertoire_wrl_EOS, 'FemurD.wrl');
file_wrl_tibia_r=fullfile(repertoire_wrl_EOS, 'TibiaD.wrl');
file_wrl_tibia_l=fullfile(repertoire_wrl_EOS, 'TibiaG.wrl');



%% décalaration des chemins des ddr
if strcmp(sexe,'M')==1
    file_ddr_bassin=fullfile(repertoire_ddr, 'MG_Bassin_Homme.ddr');
elseif strcmp(sexe,'F')==1
    file_ddr_bassin=fullfile(repertoire_ddr, 'MG_Bassin_Femme.ddr');
end
file_ddr_femur_l=fullfile(repertoire_ddr, 'FemurD_v3.ddr');
file_ddr_femur_r=fullfile(repertoire_ddr, 'FemurD_v3.ddr');
file_ddr_tibia_r=fullfile(repertoire_ddr, 'tibia_peroneD.ddr');
file_ddr_tibia_l=fullfile(repertoire_ddr, 'tibia_peroneG.ddr');


%% lecture de la structure des Bodies du modèle initial
[Bodies, ~] = extract_KinChainData_ModelOS(model_old);


% actualisation de la visualisation de chaque Body.
%%% ATTENTION : déclaration rigide par rapport au modèle.
[ Bodies_visualisation ] = attribution_nom_visualisation_OS_fullbody( chemin_geometry, cur_sujet );
% vérification que chaque Body a bien un nouveauset de viualisation
comparaison_set_bodies(Bodies,Bodies_visualisation);

%% modification de la visualisation
% Si cette fonction est lancée après l'opération de scaling, il est
% possible que des facteurs de scaling soient gardés. Or, en prenant les
% géométries EOS, il faut attribuer le facteur [1 1 1]
% Gestion du changement du nombre d'éléments géométriques dans chaque Body.
model_new=model_old;
model_new.Model.ATTRIBUTE.name=[cur_sujet '_perso_EOS_' num2str(num_cas)];

nb_bodies=length(fieldnames(Bodies));
noms_bodies=fieldnames(Bodies);
for i=1:nb_bodies
    cur_nom=noms_bodies{i};
    body_visu=Bodies_visualisation.(cur_nom);
    body_visu=body_visu';
    if isempty(body_visu)~=1
        [model_new]=change_scale_et_visu_geo_model_OS(model_new, i, body_visu);
    end
end



%% Modification du bassin
%
disp('personnalisation EOS du bassin');
nb_bassin=find(strcmp(noms_bodies,'pelvis'));


%création du repère bassin

[MH_R0Rlocal_bassin, centre_plat_sacre]=repere_bassin_wrl_decalage(file_wrl_bassin,file_ddr_bassin,variations.tete_fem_G,variations.tete_fem_D);
MH_R0Rlocal_bassin_2=MH_R0Rlocal_bassin;
if strcmp(model_new.Model.length_units,'meters')==1
    MH_R0Rlocal_bassin_2(1:3,4)=MH_R0Rlocal_bassin(1:3,4)*10^(-3);
    centre_plat_sacre=centre_plat_sacre*10^(-3);
elseif strcmp(model_new.Model.length_units,'milimeters')==1
else
    disp('erreur de déclaration unité dans OpenSim')
end


    decalage_in_EOS_tete_fem_D_mm=MH_R0Rlocal_bassin(1:3,1:3)*variations.tete_fem_D;
    decalage_in_EOS_tete_fem_G_mm=MH_R0Rlocal_bassin(1:3,1:3)*variations.tete_fem_G;
    decalage_in_EOS_tete_fem_D_m=MH_R0Rlocal_bassin(1:3,1:3)*variations.tete_fem_D;
    decalage_in_EOS_tete_fem_G_m=MH_R0Rlocal_bassin(1:3,1:3)*variations.tete_fem_G;

[a_bassin b_bassin c_bassin]=axe_mobile_xyz([MH_R0Rlocal_bassin_2(1:3,1:3)]');
angles=2*pi/360*[a_bassin b_bassin c_bassin];


vect=-MH_R0Rlocal_bassin_2(1:3,1:3)'*MH_R0Rlocal_bassin_2(1:3,4);

model_new.Model.BodySet.objects.Body(nb_bassin).VisibleObject.transform=[ 0 0 0 0 0 0];

try
    model_new.Model.BodySet.objects.Body(nb_bassin).VisibleObject.GeometrySet.objects.DisplayGeometry(1).transform=[angles vect'];
    model_new.Model.BodySet.objects.Body(nb_bassin).VisibleObject.GeometrySet.objects.DisplayGeometry(2)=[];
    model_new.Model.BodySet.objects.Body(nb_bassin).VisibleObject.GeometrySet.objects.DisplayGeometry(3)=[];
catch
    model_new.Model.BodySet.objects.Body(nb_bassin).VisibleObject.GeometrySet.objects.DisplayGeometry.transform=[angles vect'];
end

MH_R0R1_hanche_G=hanche_rep_bassin_decal(MH_R0Rlocal_bassin, file_wrl_femur_l,file_ddr_femur_l,variations.tete_fem_G);
MH_R0R1_hanche_G_2=MH_R0R1_hanche_G;
if strcmp(model_new.Model.length_units,'meters')==1
    MH_R0R1_hanche_G_2(1:3,4)=MH_R0R1_hanche_G(1:3,4)*10^(-3);
elseif strcmp(model_new.Model.length_units,'milimeters')==1
else
    disp('erreur de déclaration unité dans OpenSim')
end

nb_femurG=find(strcmp(noms_bodies,'femur_l'));
nb_femurD=find(strcmp(noms_bodies,'femur_r'));

model_new.Model.BodySet.objects.Body(nb_femurG).Joint.CustomJoint.location_in_parent=MH_R0R1_hanche_G_2(1:3,4)';

MH_R0R1_hanche_D=hanche_rep_bassin_decal(MH_R0Rlocal_bassin, file_wrl_femur_r,file_ddr_femur_r,variations.tete_fem_D);
MH_R0R1_hanche_D_2=MH_R0R1_hanche_D;
if strcmp(model_new.Model.length_units,'meters')==1
    MH_R0R1_hanche_D_2(1:3,4)=MH_R0R1_hanche_D(1:3,4)*10^(-3);
elseif strcmp(model_new.Model.length_units,'milimeters')==1
else
    disp('erreur de déclaration unité dans OpenSim')
end

model_new.Model.BodySet.objects.Body(nb_femurD).Joint.CustomJoint.location_in_parent=MH_R0R1_hanche_D_2(1:3,4)';


%% Modification du fémur gauche
disp('personnalisation EOS du fémur + tibia + patella gauche')
nb_tibia_l=find(strcmp(noms_bodies,'tibia_l'));
nb_femur_l=find(strcmp(noms_bodies,'femur_l'));
nb_talus_l=find(strcmp(noms_bodies,'talus_l'));
nb_patella_l=find(strcmp(noms_bodies,'patella_l'));
% [model_new,MH_R0Rlocal_femur_l_2,MH_R0Rlocal_tibia_l_2]=modification_EOS_tibia_femur(model_new,file_wrl_tibia_l,file_ddr_tibia_l,file_wrl_femur_l,file_ddr_femur_l,nb_femur_l,nb_tibia_l,nb_talus_l,nb_patella_l,'l');

[model_new,MH_R0Rlocal_femur_l_2,MH_R0Rlocal_tibia_l_2]=...
    modification_EOS_tibia_femur_var(model_new,file_wrl_tibia_l,file_ddr_tibia_l,file_wrl_femur_l,file_ddr_femur_l,nb_femur_l,nb_tibia_l,nb_talus_l,nb_patella_l,'l',decalage_in_EOS_tete_fem_G_mm,variations.condyle_med_G,variations.condyle_lat_G);

disp('personnalisation EOS du fémur + tibia + patella droit')
nb_tibia_r=find(strcmp(noms_bodies,'tibia_r'));
nb_femur_r=find(strcmp(noms_bodies,'femur_r'));
nb_talus_r=find(strcmp(noms_bodies,'talus_r'));
nb_patella_r=find(strcmp(noms_bodies,'patella_r'));

[model_new,MH_R0Rlocal_femur_r_2,MH_R0Rlocal_tibia_r_2]=modification_EOS_tibia_femur(model_new,file_wrl_tibia_r,file_ddr_tibia_r,file_wrl_femur_r,file_ddr_femur_r,nb_femur_r,nb_tibia_r,nb_talus_r,nb_patella_r,'r');

% %% création de la structure reperesH
disp('rassemblement des repères homogènes');
reperesH.pelvis=MH_R0Rlocal_bassin_2;
reperesH.femur_l=MH_R0Rlocal_femur_l_2;
reperesH.femur_r=MH_R0Rlocal_femur_r_2;
reperesH.tibia_r=MH_R0Rlocal_tibia_r_2;
reperesH.tibia_l=MH_R0Rlocal_tibia_l_2;
% reperesH.torso=MH_R0Rlocal_thorax;
end


