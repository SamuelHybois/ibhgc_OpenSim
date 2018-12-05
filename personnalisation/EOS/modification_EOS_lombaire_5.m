function [model_new,MH_R0Rlocal_L5_2]=modification_EOS_lombaire_5(model_new,file_wrl_L5,file_ddr_L5,nb_L5,MH_R0Rlocal_bassin_2)

%% Lombaire 5
% idées : 
% AXES : on veut créer la base définies par les axes définis par l'ISB.
% CENTRE ARTICULAIRE : on veut déclarer que le centre articulaire entre le bassin et L5
% soit au niveau du centre des deux pédicules de L5. 
% il faut donc déterminer la position de ce point dans le repère bassin
% ainsi que dans le repère vertèbre.



% création de la base de L5
% étape 1 : création du repère dans la base EOS
[MH_R0Rlocal_L5, centre_sup_L5, centre_inf_L5, centre_pedicule_d, centre_pedicule_g]=calcul_repere_lombaire(file_wrl_L5,file_ddr_L5);
MH_R0Rlocal_L5_2=MH_R0Rlocal_L5;

if strcmp(model_new.Model.length_units,'meters')==1
    MH_R0Rlocal_L5_2(1:3,4)=MH_R0Rlocal_L5(1:3,4)*10^(-3);
    centre_sup_L5=centre_sup_L5/1000;
    centre_inf_L5=centre_inf_L5/1000;
    centre_pedicule_d=centre_pedicule_d/1000;
    centre_pedicule_g=centre_pedicule_g/1000;
elseif strcmp(model_new.Model.length_units,'milimeters')==1
    centre_inf_L5=centre_inf_L5;
    centre_sup_L5=centre_sup_L5;
    centre_pedicule_d=centre_pedicule_d;
    centre_pedicule_g=centre_pedicule_g;
else
    disp('erreur de déclaration unité dans OpenSim')
end

centre_pedicules=(centre_pedicule_d+centre_pedicule_g)*0.5;
MH_R0Rlocal_L5_2(1:3,4)=centre_pedicules;


MH_RL5_R_bassin(1:3,1:3)=MH_R0Rlocal_L5_2(1:3,1:3)'*MH_R0Rlocal_bassin_2(1:3,1:3);
[a_L5 b_L5 c_L5]=axe_mobile_xyz([MH_RL5_R_bassin(1:3,1:3)]');
angles=2*pi/360*[a_L5 b_L5 c_L5];
% modification du joint à partir des repères.
vect=-MH_R0Rlocal_L5_2(1:3,1:3)'*MH_R0Rlocal_L5_2(1:3,4);
centre_pedicule_L5_in_bassin=inv(MH_R0Rlocal_bassin_2)*[centre_pedicules;1];
model_new.Model.BodySet.objects.Body(nb_L5).Joint.CustomJoint.location_in_parent=centre_pedicule_L5_in_bassin(1:3)';
model_new.Model.BodySet.objects.Body(nb_L5).Joint.CustomJoint.orientation_in_parent=angles;
model_new.Model.BodySet.objects.Body(nb_L5).Joint.CustomJoint.location=[0 0 0];
model_new.Model.BodySet.objects.Body(nb_L5).Joint.CustomJoint.orientation=[0 0 0];


[a_L5 b_L5 c_L5]=axe_mobile_xyz([MH_R0Rlocal_L5_2(1:3,1:3)]');
angles=2*pi/360*[a_L5 b_L5 c_L5];
vect=-MH_R0Rlocal_L5_2(1:3,1:3)'*MH_R0Rlocal_L5_2(1:3,4);
model_new.Model.BodySet.objects.Body(nb_L5).VisibleObject.transform=[ 0 0 0 0 0 0];
model_new.Model.BodySet.objects.Body(nb_L5).VisibleObject.GeometrySet.objects.DisplayGeometry(1).transform=[angles vect'];

end
