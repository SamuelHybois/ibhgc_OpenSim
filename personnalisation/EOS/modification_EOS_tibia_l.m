function []=modification_EOS_tibia_l(model_new,file_wrl_tibia_l,file_ddr_tibia_l)

%création du repère tibia gauche
% repère tibia centré sur les plateaux tibiaux.
% MH_R0Rlocal_tibia_l=calcul_repere_tibia_mod(file_wrl_tibia_l,file_ddr_tibia_l);
[MH_R0Rlocal_tibia_l, mall_mm_l]=calcul_repere_tibia_mod_avec_malleoles(file_wrl_tibia_l,file_ddr_tibia_l);
%%Remarque
% attention l'orientation des axes dépends du coté : pas identique pour le
% tibia droit et pour le tibia gauche
MH_R0Rlocal_tibia_l(1:3,1)=-MH_R0Rlocal_tibia_l(1:3,1);
MH_R0Rlocal_tibia_l(1:3,3)=-MH_R0Rlocal_tibia_l(1:3,3);
MH_R0Rlocal_tibia_l_2=MH_R0Rlocal_tibia_l;
if strcmp(model_new.Model.length_units,'meters')==1
    MH_R0Rlocal_tibia_l_2(1:3,4)=MH_R0Rlocal_tibia_l(1:3,4)*10^(-3);
    mall_l=mall_mm_l/1000;
elseif strcmp(model_new.Model.length_units,'milimeters')==1
    mall_l=mall_mm;
else
    disp('erreur de déclaration unité dans OpenSim')
end

[a_tibia_l b_tibia_l c_tibia_l]=axe_mobile_xyz([MH_R0Rlocal_tibia_l_2(1:3,1:3)]');
angles=2*pi/360*[a_tibia_l b_tibia_l c_tibia_l];

vect=-MH_R0Rlocal_tibia_l_2(1:3,1:3)'*MH_R0Rlocal_tibia_l_2(1:3,4);
mil_mall_l_h_tib=inv(MH_R0Rlocal_tibia_l_2)*[mall_l';1];
model_new.Model.BodySet.objects.Body(nb_talus_l).Joint.CustomJoint.location_in_parent=mil_mall_l_h_tib(1:3)';

model_new.Model.BodySet.objects.Body(nb_tibia_l).VisibleObject.transform=[ 0 0 0 0 0 0];
model_new.Model.BodySet.objects.Body(nb_tibia_l).VisibleObject.GeometrySet.objects.DisplayGeometry(1).transform=[angles vect'];
model_new.Model.BodySet.objects.Body(nb_tibia_l).VisibleObject.GeometrySet.objects.DisplayGeometry(2).transform=[angles vect'];

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

model_new.Model.BodySet.objects.Body(nb_tibia_l).Joint.CustomJoint.location_in_parent=MH_R0R1_genou_l_2(1:3,4)';


centre_condile_EOS_Rtib_l=inv(MH_R0Rlocal_tibia_l_2)*[condiles_EOS_2';1];
centre_condile_EOS_Rtib_l=centre_condile_EOS_Rtib_l(1:3)';

model_new.Model.BodySet.objects.Body(nb_tibia_l).Joint.CustomJoint.location=centre_condile_EOS_Rtib_l+[0 0.0125 0];

Bx=[-2.0944 -1.2217 -0.5236 -0.3491 -0.1745 0.1591 2.0944];
By =[-0.0133 0.0011 0.0103 0.0117 0.0127 0.0140 0.0133];
model_new.Model.BodySet.objects.Body(nb_tibia_r).Joint.CustomJoint.SpatialTransform.TransformAxis(nb_talus_r).xfunction.MultiplierXfunction.xfunction.SimmSpline.x=Bx;
model_new.Model.BodySet.objects.Body(nb_tibia_r).Joint.CustomJoint.SpatialTransform.TransformAxis(nb_talus_r).xfunction.MultiplierXfunction.xfunction.SimmSpline.y=By;
model_new.Model.BodySet.objects.Body(nb_tibia_l).Joint.CustomJoint.SpatialTransform.TransformAxis(nb_talus_r).xfunction.MultiplierXfunction.xfunction.SimmSpline.x=Bx;
model_new.Model.BodySet.objects.Body(nb_tibia_l).Joint.CustomJoint.SpatialTransform.TransformAxis(nb_talus_r).xfunction.MultiplierXfunction.xfunction.SimmSpline.y=By;

BBy=[-0.0032 0.0018 0.0041 0.0041 0.0021 -0.0010 -0.0031 -0.0052 -0.0054 -0.0056 -0.0054 -0.0053];
BBx=[-2.0944 -1.74533 -1.39626 -1.0472 -0.698132 -0.349066 -0.174533 0.197344 0.337395 0.490178 1.52146 2.0944];
model_new.Model.BodySet.objects.Body(nb_tibia_r).Joint.CustomJoint.SpatialTransform.TransformAxis(nb_tibia_r).xfunction.SimmSpline.x=BBx;
model_new.Model.BodySet.objects.Body(nb_tibia_r).Joint.CustomJoint.SpatialTransform.TransformAxis(nb_tibia_r).xfunction.SimmSpline.y=BBy;
model_new.Model.BodySet.objects.Body(nb_tibia_l).Joint.CustomJoint.SpatialTransform.TransformAxis(nb_tibia_r).xfunction.SimmSpline.x=BBx;
model_new.Model.BodySet.objects.Body(nb_tibia_l).Joint.CustomJoint.SpatialTransform.TransformAxis(nb_tibia_r).xfunction.SimmSpline.y=BBy;

end