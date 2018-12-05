
% pour le membre inférieur, utiliser la fonction GOLF_personnalisation_EOS_decalage_2_pour_pipeline
% cette fonction est adaptée pour le modèle fullbody développé par Maxime
% Bourgain et Samuel Hybois featuring Christophe Sauret qui ne sait pas
% installer Matlab.

function [model_new, reperesH]=pipeline_harmonisation_personnalisation_EOS(model_old,repertoire_wrl_EOS, st_protocole, sexe, repertoire_ddr, decalage_in_bassin,chemin_geometry,cur_sujet)%,marqueurs)
% decalage_in_bassin=[0 0.02 0]';
reperesH=struct;
if norm(decalage_in_bassin)~=0
    if size(decalage_in_bassin,2)==3
        decalage_in_bassin=decalage_in_bassin';
    end
    decalage_in_bassin_G_m=decalage_in_bassin;% décalage de la tete fémorale G dans le repere bassin en m
    decalage_in_bassin_D_m=decalage_in_bassin;% décalage de la tete fémorale D dans le repere bassin en m
    decalage_in_bassin_G_mm=decalage_in_bassin_G_m*10^3;
    decalage_in_bassin_D_mm=decalage_in_bassin_D_m*10^3;
else
    decalage_in_bassin_D_mm=[0;0;0];
    decalage_in_bassin_G_mm=[0;0;0];
    decalage_in_bassin_D_m=[0;0;0];
    decalage_in_bassin_G_m=[0;0;0];
end




disp('début de la personnalisation à partir des données EOS');
%% déclaration des chemins des wrl
file_wrl_bassin=fullfile(repertoire_wrl_EOS, 'bassin.wrl');
file_wrl_femur_l=fullfile(repertoire_wrl_EOS, 'FemurG.wrl');
file_wrl_femur_r=fullfile(repertoire_wrl_EOS, 'FemurD.wrl');
file_wrl_tibia_r=fullfile(repertoire_wrl_EOS, 'TibiaD.wrl');
file_wrl_tibia_l=fullfile(repertoire_wrl_EOS, 'TibiaG.wrl');
file_wrl_L1=fullfile(repertoire_wrl_EOS, 'Vertebre_L1.wrl');
file_wrl_L2=fullfile(repertoire_wrl_EOS, 'Vertebre_L2.wrl');
file_wrl_L3=fullfile(repertoire_wrl_EOS, 'Vertebre_L3.wrl');
file_wrl_L4=fullfile(repertoire_wrl_EOS, 'Vertebre_L4.wrl');
file_wrl_L5=fullfile(repertoire_wrl_EOS, 'Vertebre_L5.wrl');
file_wrl_T1=fullfile(repertoire_wrl_EOS, 'Vertebre_T1.wrl');
file_wrl_T2=fullfile(repertoire_wrl_EOS, 'Vertebre_T2.wrl');
file_wrl_T3=fullfile(repertoire_wrl_EOS, 'Vertebre_T3.wrl');
file_wrl_T4=fullfile(repertoire_wrl_EOS, 'Vertebre_T4.wrl');
file_wrl_T5=fullfile(repertoire_wrl_EOS, 'Vertebre_T5.wrl');
file_wrl_T6=fullfile(repertoire_wrl_EOS, 'Vertebre_T6.wrl');
file_wrl_T7=fullfile(repertoire_wrl_EOS, 'Vertebre_T7.wrl');
file_wrl_T8=fullfile(repertoire_wrl_EOS, 'Vertebre_T8.wrl');
file_wrl_T9=fullfile(repertoire_wrl_EOS, 'Vertebre_T9.wrl');
file_wrl_T10=fullfile(repertoire_wrl_EOS, 'Vertebre_T10.wrl');
file_wrl_T11=fullfile(repertoire_wrl_EOS, 'Vertebre_T11.wrl');
file_wrl_T12=fullfile(repertoire_wrl_EOS, 'Vertebre_T12.wrl');
file_wrl_C1=fullfile(repertoire_wrl_EOS, 'Vertebre_C1.wrl');
file_wrl_C2=fullfile(repertoire_wrl_EOS, 'Vertebre_C2.wrl');
file_wrl_C3=fullfile(repertoire_wrl_EOS, 'Vertebre_C3.wrl');
file_wrl_C4=fullfile(repertoire_wrl_EOS, 'Vertebre_C4.wrl');
file_wrl_C5=fullfile(repertoire_wrl_EOS, 'Vertebre_C5.wrl');
file_wrl_C6=fullfile(repertoire_wrl_EOS, 'Vertebre_C6.wrl');
file_wrl_C7=fullfile(repertoire_wrl_EOS, 'Vertebre_C7.wrl');



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
file_ddr_L1=fullfile(repertoire_ddr,'Vertebre_L1.ddr');
file_ddr_L2=fullfile(repertoire_ddr,'Vertebre_L2.ddr');
file_ddr_L3=fullfile(repertoire_ddr,'Vertebre_L3.ddr');
file_ddr_L4=fullfile(repertoire_ddr,'Vertebre_L4.ddr');
file_ddr_L5=fullfile(repertoire_ddr,'Vertebre_L5.ddr');
file_ddr_T1=fullfile(repertoire_ddr,'Vertebre_T1.ddr');
file_ddr_T2=fullfile(repertoire_ddr,'Vertebre_T2.ddr');
file_ddr_T3=fullfile(repertoire_ddr,'Vertebre_T3.ddr');
file_ddr_T4=fullfile(repertoire_ddr,'Vertebre_T4.ddr');
file_ddr_T5=fullfile(repertoire_ddr,'Vertebre_T5.ddr');
file_ddr_T6=fullfile(repertoire_ddr,'Vertebre_T6.ddr');
file_ddr_T7=fullfile(repertoire_ddr,'Vertebre_T7.ddr');
file_ddr_T8=fullfile(repertoire_ddr,'Vertebre_T8.ddr');
file_ddr_T9=fullfile(repertoire_ddr,'Vertebre_T9.ddr');
file_ddr_T10=fullfile(repertoire_ddr,'Vertebre_T10.ddr');
file_ddr_T11=fullfile(repertoire_ddr,'Vertebre_T11.ddr');
file_ddr_T12=fullfile(repertoire_ddr,'Vertebre_T12.ddr');


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
model_new.Model.ATTRIBUTE.name=[cur_sujet '_perso_EOS'];

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
[MH_R0Rlocal_bassin, centre_plat_sacre]=repere_bassin_wrl_decalage(file_wrl_bassin,file_ddr_bassin,decalage_in_bassin_G_mm,decalage_in_bassin_D_mm);
MH_R0Rlocal_bassin_2=MH_R0Rlocal_bassin;
if strcmp(model_new.Model.length_units,'meters')==1
    MH_R0Rlocal_bassin_2(1:3,4)=MH_R0Rlocal_bassin(1:3,4)*10^(-3);
    centre_plat_sacre=centre_plat_sacre*10^(-3);
elseif strcmp(model_new.Model.length_units,'milimeters')==1
else
    disp('erreur de déclaration unité dans OpenSim')
end

if norm(decalage_in_bassin)~=0
    decalage_in_EOS_D_mm=MH_R0Rlocal_bassin(1:3,1:3)*decalage_in_bassin_D_mm;
    decalage_in_EOS_G_mm=MH_R0Rlocal_bassin(1:3,1:3)*decalage_in_bassin_G_mm;
    decalage_in_EOS_D_m=MH_R0Rlocal_bassin(1:3,1:3)*decalage_in_bassin_D_m;
    decalage_in_EOS_G_m=MH_R0Rlocal_bassin(1:3,1:3)*decalage_in_bassin_G_m;
else
    decalage_in_EOS_D_mm=[0;0;0];
    decalage_in_EOS_G_mm=[0;0;0];
    decalage_in_EOS_D_m=[0;0;0];
    decalage_in_EOS_G_m=[0;0;0];
end

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

MH_R0R1_hanche_G=hanche_rep_bassin_decal(MH_R0Rlocal_bassin, file_wrl_femur_l,file_ddr_femur_l,decalage_in_EOS_G_mm);
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

MH_R0R1_hanche_D=hanche_rep_bassin_decal(MH_R0Rlocal_bassin, file_wrl_femur_r,file_ddr_femur_r,decalage_in_EOS_D_mm);
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

[model_new,MH_R0Rlocal_femur_l_2,MH_R0Rlocal_tibia_l_2]=modification_EOS_tibia_femur(model_new,file_wrl_tibia_l,file_ddr_tibia_l,file_wrl_femur_l,file_ddr_femur_l,nb_femur_l,nb_tibia_l,nb_talus_l,nb_patella_l,'l');

disp('personnalisation EOS du fémur + tibia + patella droit')
nb_tibia_r=find(strcmp(noms_bodies,'tibia_r'));
nb_femur_r=find(strcmp(noms_bodies,'femur_r'));
nb_talus_r=find(strcmp(noms_bodies,'talus_r'));
nb_patella_r=find(strcmp(noms_bodies,'patella_r'));

[model_new,MH_R0Rlocal_femur_r_2,MH_R0Rlocal_tibia_r_2]=modification_EOS_tibia_femur(model_new,file_wrl_tibia_r,file_ddr_tibia_r,file_wrl_femur_r,file_ddr_femur_r,nb_femur_r,nb_tibia_r,nb_talus_r,nb_patella_r,'r');
% 
% 
% Bx=[-2.0944 -1.2217 -0.5236 -0.3491 -0.1745 0.1591 2.0944];
% By =[-0.0133 0.0011 0.0103 0.0117 0.0127 0.0140 0.0133];
% model_new.Model.BodySet.objects.Body(nb_tibia_r).Joint.CustomJoint.SpatialTransform.TransformAxis(nb_talus_r).xfunction.MultiplierXfunction.xfunction.SimmSpline.x=Bx;
% model_new.Model.BodySet.objects.Body(nb_tibia_r).Joint.CustomJoint.SpatialTransform.TransformAxis(nb_talus_r).xfunction.MultiplierXfunction.xfunction.SimmSpline.y=By;
% model_new.Model.BodySet.objects.Body(nb_tibia_l).Joint.CustomJoint.SpatialTransform.TransformAxis(nb_talus_r).xfunction.MultiplierXfunction.xfunction.SimmSpline.x=Bx;
% model_new.Model.BodySet.objects.Body(nb_tibia_l).Joint.CustomJoint.SpatialTransform.TransformAxis(nb_talus_r).xfunction.MultiplierXfunction.xfunction.SimmSpline.y=By;
% 
% BBy=[-0.0032 0.0018 0.0041 0.0041 0.0021 -0.0010 -0.0031 -0.0052 -0.0054 -0.0056 -0.0054 -0.0053];
% BBx=[-2.0944 -1.74533 -1.39626 -1.0472 -0.698132 -0.349066 -0.174533 0.197344 0.337395 0.490178 1.52146 2.0944];
% model_new.Model.BodySet.objects.Body(nb_tibia_r).Joint.CustomJoint.SpatialTransform.TransformAxis(nb_tibia_r).xfunction.SimmSpline.x=BBx;
% model_new.Model.BodySet.objects.Body(nb_tibia_r).Joint.CustomJoint.SpatialTransform.TransformAxis(nb_tibia_r).xfunction.SimmSpline.y=BBy;
% model_new.Model.BodySet.objects.Body(nb_tibia_l).Joint.CustomJoint.SpatialTransform.TransformAxis(nb_tibia_r).xfunction.SimmSpline.x=BBx;
% model_new.Model.BodySet.objects.Body(nb_tibia_l).Joint.CustomJoint.SpatialTransform.TransformAxis(nb_tibia_r).xfunction.SimmSpline.y=BBy;

%% Modification du fémur droit
% disp('personnalisation EOS du fémur droit')

% % 
% % %création du repère fémur droit
% % MH_R0Rlocal_femur_r=repere_femur_EOS_decal(file_wrl_femur_r,file_ddr_femur_r,decalage_in_EOS_D_mm);
% % MH_R0Rlocal_femur_r_2=MH_R0Rlocal_femur_r;
% % if strcmp(model_new.Model.length_units,'meters')==1
% %     MH_R0Rlocal_femur_r_2(1:3,4)=MH_R0Rlocal_femur_r(1:3,4)*10^(-3);
% % elseif strcmp(model_new.Model.length_units,'milimeters')==1
% % else
% %     disp('erreur de déclaration unité dans OpenSim')
% % end
% % 
% % [a_femur_r b_femur_r c_femur_r]=axe_mobile_xyz([MH_R0Rlocal_femur_r_2(1:3,1:3)]');
% % angles=2*pi/360*[a_femur_r b_femur_r c_femur_r];
% % 
% % vect=-MH_R0Rlocal_femur_r_2(1:3,1:3)'*MH_R0Rlocal_femur_r_2(1:3,4);
% % 
% % model_new.Model.BodySet.objects.Body(nb_femurD).VisibleObject.transform=[ 0 0 0 0 0 0];
% % model_new.Model.BodySet.objects.Body(nb_femurD).VisibleObject.GeometrySet.objects.DisplayGeometry.transform=[angles vect'];
% % 
% % %% Modification du tibia droit
% % disp('personnalisation EOS du tibia droit')
% % nb_tibia_r=find(strcmp(noms_bodies,'tibia_r'));
% % nb_talus_r=find(strcmp(noms_bodies,'talus_r'));
% % 
% % %création du repère tibia droit
% % % repère tibia centré sur les plateaux tibiaux.
% % % MH_R0Rlocal_tibia_r=calcul_repere_tibia_mod(file_wrl_tibia_r,file_ddr_tibia_r);
% % % [MH_R0Rlocal_tibia_r, mall_int_mm_r, mall_ext_mm_r]=calcul_repere_tibia_mod_avec_malleoles(file_wrl_tibia_r,file_ddr_tibia_r);
% % [MH_R0Rlocal_tibia_r, mall_mm_r]=calcul_repere_tibia_mod_avec_malleoles(file_wrl_tibia_r,file_ddr_tibia_r);
% % 
% % MH_R0Rlocal_tibia_r_2=MH_R0Rlocal_tibia_r;
% % %     mall_int_r=mall_int_mm_r;
% % %     mall_ext_r=mall_ext_mm_r;
% % 
% % if strcmp(model_new.Model.length_units,'meters')==1
% %     MH_R0Rlocal_tibia_r_2(1:3,4)=MH_R0Rlocal_tibia_r(1:3,4)*10^(-3);
% %     %     mall_int_r=mall_int_mm_r*10^(-3);
% %     %     mall_ext_r=mall_ext_mm_r*10^(-3);
% %     mall_r=mall_mm_r/1000;
% % elseif strcmp(model_new.Model.length_units,'milimeters')==1
% %     mall_r=mall_mm_r;
% % else
% %     disp('erreur de déclaration unité dans OpenSim')
% % end
% % 
% % %prise en compte de le cheville avec comme centre le milieu des malléoles
% % % mil_mall_r=0.5*(mall_int_r+mall_ext_r);
% % % mil_mall_r_h_tib=inv(MH_R0Rlocal_tibia_r_2)*[mil_mall_r' ;1];
% % mil_mall_r_h_tib=inv(MH_R0Rlocal_tibia_r_2)*[mall_r' ;1];
% % model_new.Model.BodySet.objects.Body(nb_talus_r).Joint.CustomJoint.location_in_parent=mil_mall_r_h_tib(1:3)';
% % 
% % 
% % [a_tibia_r b_tibia_r c_tibia_r]=axe_mobile_xyz([MH_R0Rlocal_tibia_r_2(1:3,1:3)]');
% % angles=2*pi/360*[a_tibia_r b_tibia_r c_tibia_r];
% % 
% % vect=-MH_R0Rlocal_tibia_r_2(1:3,1:3)'*MH_R0Rlocal_tibia_r_2(1:3,4);
% % 
% % model_new.Model.BodySet.objects.Body(nb_tibia_r).VisibleObject.transform=[ 0 0 0 0 0 0];
% % model_new.Model.BodySet.objects.Body(nb_tibia_r).VisibleObject.GeometrySet.objects.DisplayGeometry(1).transform=[angles vect'];
% % model_new.Model.BodySet.objects.Body(nb_tibia_r).VisibleObject.GeometrySet.objects.DisplayGeometry(2).transform=[angles vect'];
% % 
% % %création du repère genou
% % % repère genou centré sur les condiles
% % [MH_R0R1_genou_r, plateaux_EOS, condiles_EOS,rayon_cond_r]=genou_rep_femur_decal(MH_R0Rlocal_femur_r, file_wrl_femur_r,file_ddr_femur_r,file_wrl_tibia_r,file_ddr_tibia_r);
% % MH_R0R1_genou_r_2=MH_R0R1_genou_r;
% % plateaux_EOS_2=plateaux_EOS;
% % condiles_EOS_2=condiles_EOS;
% % if strcmp(model_new.Model.length_units,'meters')==1
% %     MH_R0R1_genou_r_2(1:3,4)=MH_R0R1_genou_r(1:3,4)*10^(-3);
% %     plateaux_EOS_2=plateaux_EOS_2*10^(-3);
% %     condiles_EOS_2=condiles_EOS_2*10^(-3);
% % elseif strcmp(model_new.Model.length_units,'milimeters')==1
% % else
% %     disp('erreur de déclaration unité dans OpenSim')
% % end
% % 
% % model_new.Model.BodySet.objects.Body(nb_tibia_r).Joint.CustomJoint.location_in_parent=MH_R0R1_genou_r_2(1:3,4)';%+decal_tib_genou_l_femur_2(1:3)';
% % 
% % centre_condile_EOS_Rtib_r=inv(MH_R0Rlocal_tibia_r_2)*[condiles_EOS_2';1];
% % centre_condile_EOS_Rtib_r=centre_condile_EOS_Rtib_r(1:3)';
% % %%
% % model_new.Model.BodySet.objects.Body(nb_tibia_r).Joint.CustomJoint.location=centre_condile_EOS_Rtib_r+[0 0.0125 0];


%% Lombaire 5
% idées :
% AXES : on veut créer la base définies par les axes définis par l'ISB.
% CENTRE ARTICULAIRE : on veut déclarer que le centre articulaire entre le bassin et L5
% soit au niveau du centre des deux pédicules de L5.
% il faut donc déterminer la position de ce point dans le repère bassin
% ainsi que dans le repère vertèbre.

disp('personnalisation EOS de L5')
nb_L5=find(strcmp(noms_bodies,'lumbar5'));
%  [model_new,MH_R0Rlocal_L5]=modification_EOS_lombaire_5(model_new,file_wrl_L5,file_ddr_L5,nb_L5,MH_R0Rlocal_bassin_2);
[model_new,MH_R0Rlocal_L5]=modification_EOS_lombaire_generique(model_new,file_wrl_L5,file_ddr_L5,nb_L5,MH_R0Rlocal_bassin_2);

disp('personnalisation EOS de L4')
nb_L4=find(strcmp(noms_bodies,'lumbar4'));
%  [model_new,MH_R0Rlocal_L4]=modification_EOS_lombaire_4(model_new,file_wrl_L4,file_ddr_L4,nb_L4,MH_R0Rlocal_L5);
[model_new,MH_R0Rlocal_L4]=modification_EOS_lombaire_generique(model_new,file_wrl_L4,file_ddr_L4,nb_L4,MH_R0Rlocal_L5);

disp('personnalisation EOS de L3')
nb_L3=find(strcmp(noms_bodies,'lumbar3'));
[model_new,MH_R0Rlocal_L3]=modification_EOS_lombaire_generique(model_new,file_wrl_L3,file_ddr_L3,nb_L3,MH_R0Rlocal_L4);

disp('personnalisation EOS de L2')
nb_L2=find(strcmp(noms_bodies,'lumbar2'));
[model_new,MH_R0Rlocal_L2]=modification_EOS_lombaire_generique(model_new,file_wrl_L2,file_ddr_L2,nb_L2,MH_R0Rlocal_L3);

disp('personnalisation EOS de L1')
nb_L1=find(strcmp(noms_bodies,'lumbar1'));
[model_new,MH_R0Rlocal_L1]=modification_EOS_lombaire_generique(model_new,file_wrl_L1,file_ddr_L1,nb_L1,MH_R0Rlocal_L2);

disp('personnalisation EOS de T1')
nb_thorax=find(strcmp(noms_bodies,'thorax'));
nb_clav_d=find(strcmp(noms_bodies,'clavicle_r'));
nb_clav_g=find(strcmp(noms_bodies,'clavicle_l'));
nb_scap_g=find(strcmp(noms_bodies,'scapula_l'));
nb_scap_d=find(strcmp(noms_bodies,'scapula_r'));
nb_cerv_7=find(strcmp(noms_bodies,'cerv_7'));
nb_cerv_6=find(strcmp(noms_bodies,'cerv_6'));
nb_cerv_5=find(strcmp(noms_bodies,'cerv_5'));
nb_cerv_4=find(strcmp(noms_bodies,'cerv_4'));
nb_cerv_3=find(strcmp(noms_bodies,'cerv_3'));
nb_cerv_2=find(strcmp(noms_bodies,'cerv_2'));
nb_cerv_1=find(strcmp(noms_bodies,'cerv_1'));
[model_new,MH_R0Rlocal_T1]=modification_EOS_thoracique_generique_2(model_new,file_wrl_T1,file_ddr_T1,nb_thorax,nb_clav_g,nb_clav_d,nb_scap_g,nb_scap_d,nb_cerv_7,MH_R0Rlocal_L1);

%% gestion des cervicales
chemin_o3=fullfile(repertoire_wrl_EOS,[cur_sujet '.o3']);
if exist(chemin_o3,'file') ~=0
    if exist(file_wrl_C7,'file')~=0
        disp('personnalisation EOS C7')
        [model_new,MH_R0Rlocal_C7]=modification_EOS_cervicale_generique(model_new,file_wrl_C7,chemin_o3,nb_cerv_7,MH_R0Rlocal_T1);
        if exist(file_wrl_C6,'file')~=0
            disp('personnalisation EOS C6')
            [model_new,MH_R0Rlocal_C6]=modification_EOS_cervicale_generique(model_new,file_wrl_C6,chemin_o3,nb_cerv_6,MH_R0Rlocal_C7);
            if exist(file_wrl_C5,'file')~=0
                disp('personnalisation EOS C5')
                [model_new,MH_R0Rlocal_C5]=modification_EOS_cervicale_generique(model_new,file_wrl_C5,chemin_o3,nb_cerv_5,MH_R0Rlocal_C6);
                if exist(file_wrl_C4,'file')~=0
                    disp('personnalisation EOS C4')
                    [model_new,MH_R0Rlocal_C4]=modification_EOS_cervicale_generique(model_new,file_wrl_C4,chemin_o3,nb_cerv_4,MH_R0Rlocal_C5);
                    if exist(file_wrl_C3,'file')~=0
                        disp('personnalisation EOS C3')
                        [model_new,MH_R0Rlocal_C3]=modification_EOS_cervicale_generique(model_new,file_wrl_C3,chemin_o3,nb_cerv_3,MH_R0Rlocal_C4);
                        if exist(file_wrl_C2,'file')~=0
                            disp('personnalisation EOS C2')
                            [model_new,MH_R0Rlocal_C2]=modification_EOS_cervicale_generique(model_new,file_wrl_C2,chemin_o3,nb_cerv_2,MH_R0Rlocal_C3);
                            if exist(file_wrl_C1,'file')~=0
                                disp('personnalisation EOS C1')
                                [model_new,MH_R0Rlocal_C1]=modification_EOS_cervicale_generique(model_new,file_wrl_C1,chemin_o3,nb_cerv_1,MH_R0Rlocal_C2);
                            end
                        end
                    end
                end
            end
        end
    end
else
    disp('il faut ajouter le fichier o3 dans le repertoire des wrl EOS')
end
%% création de la structure reperesH
disp('rassemblement des repères homogènes');
reperesH.pelvis=MH_R0Rlocal_bassin_2;
reperesH.femur_l=MH_R0Rlocal_femur_l_2;
reperesH.femur_r=MH_R0Rlocal_femur_r_2;
reperesH.tibia_r=MH_R0Rlocal_tibia_r_2;
reperesH.tibia_l=MH_R0Rlocal_tibia_l_2;
reperesH.L5=MH_R0Rlocal_L5;
reperesH.L4=MH_R0Rlocal_L4;
reperesH.L3=MH_R0Rlocal_L3;
reperesH.L2=MH_R0Rlocal_L2;
reperesH.L1=MH_R0Rlocal_L1;

% reperesH.torso=MH_R0Rlocal_thorax;
end


