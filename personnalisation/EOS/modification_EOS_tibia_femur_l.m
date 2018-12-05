function [model_new,MH_R0Rlocal_femur_2,MH_R0Rlocal_tibia_2]=modification_EOS_tibia_femur(model_new,file_wrl_tibia,file_ddr_tibia,file_wrl_femur,file_ddr_femur,nb_femur,nb_tibia,nb_talus,cote)
decalage_in_EOS_G_mm=[0 0 0];
%création du repère decalé fémur gauche
MH_R0Rlocal_femur=repere_femur_EOS_decal(file_wrl_femur,file_ddr_femur,decalage_in_EOS_G_mm);
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

[a_femur b_femur c_femur]=axe_mobile_xyz([MH_R0Rlocal_femur_2(1:3,1:3)]');
angles=2*pi/360*[a_femur b_femur c_femur];

vect=-MH_R0Rlocal_femur_2(1:3,1:3)'*MH_R0Rlocal_femur_2(1:3,4);

model_new.Model.BodySet.objects.Body(nb_femur).VisibleObject.transform=[ 0 0 0 0 0 0];
model_new.Model.BodySet.objects.Body(nb_femur).VisibleObject.GeometrySet.objects.DisplayGeometry.transform=[angles vect'];
%création du repère tibia gauche
% repère tibia centré sur les plateaux tibiaux.
% MH_R0Rlocal_tibia_l=calcul_repere_tibia_mod(file_wrl_tibia_l,file_ddr_tibia_l);
[MH_R0Rlocal_tibia, mall_mm_l]=calcul_repere_tibia_mod_avec_malleoles(file_wrl_tibia,file_ddr_tibia);
%%Remarque
% attention l'orientation des axes dépends du coté : pas identique pour le
% tibia droit et pour le tibia gauche
MH_R0Rlocal_tibia(1:3,1)=-MH_R0Rlocal_tibia(1:3,1);
MH_R0Rlocal_tibia(1:3,3)=-MH_R0Rlocal_tibia(1:3,3);
MH_R0Rlocal_tibia_2=MH_R0Rlocal_tibia;
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
[MH_R0R1_genou_l, plateaux_EOS, condiles_EOS,rayon_cond_l]=genou_rep_femur_decal(MH_R0Rlocal_femur, file_wrl_femur,file_ddr_femur,file_wrl_tibia,file_ddr_tibia);
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

model_new.Model.BodySet.objects.Body(nb_tibia).Joint.CustomJoint.SpatialTransform.TransformAxis(5).xfunction.MultiplierXfunction.xfunction.SimmSpline.x=Bx;
model_new.Model.BodySet.objects.Body(nb_tibia).Joint.CustomJoint.SpatialTransform.TransformAxis(5).xfunction.MultiplierXfunction.xfunction.SimmSpline.y=By;
model_new.Model.BodySet.objects.Body(nb_tibia).Joint.CustomJoint.SpatialTransform.TransformAxis(5).xfunction.MultiplierXfunction.scale=1;

model_new.Model.BodySet.objects.Body(nb_tibia).Joint.CustomJoint.SpatialTransform.TransformAxis(6).xfunction.MultiplierXfunction.scale=1;



% BBy=[-0.0032 0.0018 0.0041 0.0041 0.0021 -0.0010 -0.0031 -0.0052 -0.0054 -0.0056 -0.0054 -0.0053];
% BBx=[-2.0944 -1.74533 -1.39626 -1.0472 -0.698132 -0.349066 -0.174533 0.197344 0.337395 0.490178 1.52146 2.0944];
% model_new.Model.BodySet.objects.Body(nb_tibia_l).Joint.CustomJoint.SpatialTransform.TransformAxis(nb_tibia_l).xfunction.SimmSpline.x=BBx;
% model_new.Model.BodySet.objects.Body(nb_tibia_l).Joint.CustomJoint.SpatialTransform.TransformAxis(nb_tibia_l).xfunction.SimmSpline.y=BBy;

end