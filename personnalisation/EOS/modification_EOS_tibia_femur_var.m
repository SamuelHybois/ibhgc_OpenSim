function [model_new,MH_R0Rlocal_femur_2,MH_R0Rlocal_tibia_2]=modification_EOS_tibia_femur_var(model_new,file_wrl_tibia,file_ddr_tibia,file_wrl_femur,file_ddr_femur,nb_femur,nb_tibia,nb_talus,nb_patella,cote,decalage_in_EOS_TF_mm,var_med,var_lat)
% decalage_in_EOS_G_mm=[0 0 0];
%création du repère decalé fémur gauche
MH_R0Rlocal_femur=repere_femur_EOS_decal_multiple(file_wrl_femur,file_ddr_femur,decalage_in_EOS_TF_mm,var_med,var_lat);
%%Remarque
% attention l'orientation des axes dépends du coté : pas identique pour le
% fémur droit et pour le fémur gauche
if strcmp(cote,'l')==1
    MH_R0Rlocal_femur(1:3,1)=-MH_R0Rlocal_femur(1:3,1);
    MH_R0Rlocal_femur(1:3,3)=-MH_R0Rlocal_femur(1:3,3);
    MH_R0Rlocal_femur_2=MH_R0Rlocal_femur;
elseif strcmp(cote,'r')==1
    MH_R0Rlocal_femur_2=MH_R0Rlocal_femur;
end
if strcmp(model_new.Model.length_units,'meters')==1
    MH_R0Rlocal_femur_2(1:3,4)=MH_R0Rlocal_femur(1:3,4)*10^(-3);
elseif strcmp(model_new.Model.length_units,'milimeters')==1
else
    disp('erreur de déclaration unité dans OpenSim')
end

decalage_in_EOS_cond_lat=MH_R0Rlocal_femur_2(1:3,1:3)*var_lat;
decalage_in_EOS_cond_med=MH_R0Rlocal_femur_2(1:3,1:3)*var_med;

[a_femur b_femur c_femur]=axe_mobile_xyz([MH_R0Rlocal_femur_2(1:3,1:3)]');
angles=2*pi/360*[a_femur b_femur c_femur];

vect=-MH_R0Rlocal_femur_2(1:3,1:3)'*MH_R0Rlocal_femur_2(1:3,4);

model_new.Model.BodySet.objects.Body(nb_femur).VisibleObject.transform=[ 0 0 0 0 0 0];
model_new.Model.BodySet.objects.Body(nb_femur).VisibleObject.GeometrySet.objects.DisplayGeometry.transform=[angles vect'];
%création du repère tibia gauche
% repère tibia centré sur les plateaux tibiaux.
% MH_R0Rlocal_tibia_l=calcul_repere_tibia_mod(file_wrl_tibia_l,file_ddr_tibia_l);
[MH_R0Rlocal_tibia, mall_mm_l]=calcul_repere_tibia_mod_avec_malleoles_decal(file_wrl_tibia,file_ddr_tibia,decalage_in_EOS_cond_lat,decalage_in_EOS_cond_med);
%%Remarque
% attention l'orientation des axes dépends du coté : pas identique pour le
% tibia droit et pour le tibia gauche

if strcmp(cote,'l')==1
    MH_R0Rlocal_tibia(1:3,1)=-MH_R0Rlocal_tibia(1:3,1);
    MH_R0Rlocal_tibia(1:3,3)=-MH_R0Rlocal_tibia(1:3,3);
    MH_R0Rlocal_tibia_2=MH_R0Rlocal_tibia;
elseif strcmp(cote,'r')==1
    MH_R0Rlocal_tibia_2=MH_R0Rlocal_tibia;
end
if strcmp(model_new.Model.length_units,'meters')==1
    MH_R0Rlocal_tibia_2(1:3,4)=MH_R0Rlocal_tibia(1:3,4)*10^(-3);
    mall_l=mall_mm_l/1000;
elseif strcmp(model_new.Model.length_units,'milimeters')==1
    mall_l=mall_mm;
else
    disp('erreur de déclaration unité dans OpenSim')
end

[a_tibia b_tibia c_tibia]=axe_mobile_xyz([MH_R0Rlocal_tibia_2(1:3,1:3)]');
angles=2*pi/360*[a_tibia b_tibia c_tibia];

vect=-MH_R0Rlocal_tibia_2(1:3,1:3)'*MH_R0Rlocal_tibia_2(1:3,4);
mil_mall_l_h_tib=inv(MH_R0Rlocal_tibia_2)*[mall_l';1];
model_new.Model.BodySet.objects.Body(nb_talus).Joint.CustomJoint.location_in_parent=mil_mall_l_h_tib(1:3)';

model_new.Model.BodySet.objects.Body(nb_tibia).VisibleObject.transform=[ 0 0 0 0 0 0];
model_new.Model.BodySet.objects.Body(nb_tibia).VisibleObject.GeometrySet.objects.DisplayGeometry(1).transform=[angles vect'];
model_new.Model.BodySet.objects.Body(nb_tibia).VisibleObject.GeometrySet.objects.DisplayGeometry(2).transform=[angles vect'];

%création du repère genou
% repère genou centré sur les condiles
[MH_R0R1_genou_l, plateaux_EOS, condiles_EOS,rayon_cond_l]=genou_rep_femur_decal_multiple(MH_R0Rlocal_femur, file_wrl_femur,file_ddr_femur,file_wrl_tibia,file_ddr_tibia,decalage_in_EOS_cond_lat,decalage_in_EOS_cond_med);
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

model_new.Model.BodySet.objects.Body(nb_tibia).Joint.CustomJoint.location_in_parent=MH_R0R1_genou_l_2(1:3,4)';


centre_condile_EOS_Rtib_l=inv(MH_R0Rlocal_tibia_2)*[condiles_EOS_2';1];
centre_condile_EOS_Rtib_l=centre_condile_EOS_Rtib_l(1:3)';

model_new.Model.BodySet.objects.Body(nb_tibia).Joint.CustomJoint.location=centre_condile_EOS_Rtib_l+[0 0.0125 0];

Bx=[-2.0944 -1.2217 -0.5236 -0.3491 -0.1745 0.1591 2.0944];
By =[-0.0133 0.0011 0.0103 0.0117 0.0127 0.0140 0.0133];
disp('personnalisation du centre articulaire du genou non faite')
model_new.Model.BodySet.objects.Body(nb_tibia).Joint.CustomJoint.SpatialTransform.TransformAxis(4).xfunction.MultiplierXfunction.xfunction.SimmSpline.x=Bx;
model_new.Model.BodySet.objects.Body(nb_tibia).Joint.CustomJoint.SpatialTransform.TransformAxis(4).xfunction.MultiplierXfunction.xfunction.SimmSpline.y=By;
model_new.Model.BodySet.objects.Body(nb_tibia).Joint.CustomJoint.SpatialTransform.TransformAxis(4).xfunction.MultiplierXfunction.scale=1;

BBy=[-0.0032 0.0018 0.0041 0.0041 0.0021 -0.0010 -0.0031 -0.0052 -0.0054 -0.0056 -0.0054 -0.0053];
BBx=[-2.0944 -1.74533 -1.39626 -1.0472 -0.698132 -0.349066 -0.174533 0.197344 0.337395 0.490178 1.52146 2.0944];
model_new.Model.BodySet.objects.Body(nb_tibia).Joint.CustomJoint.SpatialTransform.TransformAxis(5).xfunction.MultiplierXfunction.xfunction.SimmSpline.x=BBx;
model_new.Model.BodySet.objects.Body(nb_tibia).Joint.CustomJoint.SpatialTransform.TransformAxis(5).xfunction.MultiplierXfunction.xfunction.SimmSpline.y=BBy;
model_new.Model.BodySet.objects.Body(nb_tibia).Joint.CustomJoint.SpatialTransform.TransformAxis(5).xfunction.MultiplierXfunction.scale=1;

model_new.Model.BodySet.objects.Body(nb_tibia).Joint.CustomJoint.SpatialTransform.TransformAxis(6).xfunction.MultiplierXfunction.scale=1;

% lien générique entre rotation patella et rotation genou
x_patella=[0 0.17453 0.34907 0.5236 0.69813 0.87267 1.0472 1.2217 1.3963 1.5708 1.7453 1.9199 2.0944];
y_patella=[0.0011369 -0.0062921 -0.10558 -0.25368 -0.41424 -0.57905 -0.74724 -0.91799 -1.0904 -1.2638 -1.4376 -1.6119 -1.7863];
model_new.Model.BodySet.objects.Body(4).Joint.CustomJoint.SpatialTransform.TransformAxis(1).xfunction.SimmSpline.x=x_patella;
model_new.Model.BodySet.objects.Body(4).Joint.CustomJoint.SpatialTransform.TransformAxis(1).xfunction.SimmSpline.y=y_patella;

% lien générique entre translation 1 et rotation genou
x_patella_trans_1=[0 0.17453 0.34907 0.5236 0.69813 0.87267 1.0472 1.2217 1.3963 1.5708 1.7453 1.9199 2.0944];
y_patella_trans_1=[0.0444 0.0407 0.0356 0.0290 0.0215 0.0135 0.0055 -0.0024 -0.0100 -0.0169 -0.0229 -0.0277 -0.0308];
model_new.Model.BodySet.objects.Body(nb_patella).Joint.CustomJoint.SpatialTransform.TransformAxis(4).xfunction.MultiplierXfunction.scale=1;
model_new.Model.BodySet.objects.Body(nb_patella).Joint.CustomJoint.SpatialTransform.TransformAxis(4).xfunction.MultiplierXfunction.xfunction.SimmSpline.x=x_patella_trans_1;
model_new.Model.BodySet.objects.Body(nb_patella).Joint.CustomJoint.SpatialTransform.TransformAxis(4).xfunction.MultiplierXfunction.xfunction.SimmSpline.y=y_patella_trans_1;

% lien générique entre translation 2 et rotation genou
x_patella_trans_2=[0 0.17453 0.34907 0.5236 0.69813 0.87267 1.0472 1.2217 1.3963 1.5708 1.7453 1.9199 2.0944];
y_patella_trans_2=[-0.4187 -0.4270 -0.4342  -0.4402 -0.4446 -0.4475 -0.4487 -0.4483 -0.4464 -0.4428 -0.4380 -0.4324 -0.4266];
model_new.Model.BodySet.objects.Body(nb_patella).Joint.CustomJoint.SpatialTransform.TransformAxis(5).xfunction.MultiplierXfunction.scale=1;
model_new.Model.BodySet.objects.Body(nb_patella).Joint.CustomJoint.SpatialTransform.TransformAxis(5).xfunction.MultiplierXfunction.xfunction.SimmSpline.x=x_patella_trans_2;
model_new.Model.BodySet.objects.Body(nb_patella).Joint.CustomJoint.SpatialTransform.TransformAxis(5).xfunction.MultiplierXfunction.xfunction.SimmSpline.y=y_patella_trans_2;

% BBy=[-0.0032 0.0018 0.0041 0.0041 0.0021 -0.0010 -0.0031 -0.0052 -0.0054 -0.0056 -0.0054 -0.0053];
% BBx=[-2.0944 -1.74533 -1.39626 -1.0472 -0.698132 -0.349066 -0.174533 0.197344 0.337395 0.490178 1.52146 2.0944];
% model_new.Model.BodySet.objects.Body(nb_tibia_l).Joint.CustomJoint.SpatialTransform.TransformAxis(nb_tibia_l).xfunction.SimmSpline.x=BBx;
% model_new.Model.BodySet.objects.Body(nb_tibia_l).Joint.CustomJoint.SpatialTransform.TransformAxis(nb_tibia_l).xfunction.SimmSpline.y=BBy;

end