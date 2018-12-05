function [model_new,MH_R0Rlocal_L5_2]=modification_EOS_lombaire_5(model_new,file_wrl_L5,file_ddr_L5,nb_L5,MH_R0Rlocal_bassin_2)

%% Lombaire 5
% id�es : 
% AXES : on veut cr�er la base d�finies par les axes d�finis par l'ISB.
% CENTRE ARTICULAIRE : on veut d�clarer que le centre articulaire entre le bassin et L5
% soit au niveau du centre des deux p�dicules de L5. 
% il faut donc d�terminer la position de ce point dans le rep�re bassin
% ainsi que dans le rep�re vert�bre.



% cr�ation de la base de L5
% �tape 1 : cr�ation du rep�re dans la base EOS
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
    disp('erreur de d�claration unit� dans OpenSim')
end

centre_pedicules=(centre_pedicule_d+centre_pedicule_g)*0.5;
MH_R0Rlocal_L5_2(1:3,4)=centre_pedicules;


MH_RL5_R_bassin(1:3,1:3)=MH_R0Rlocal_L5_2(1:3,1:3)'*MH_R0Rlocal_bassin_2(1:3,1:3);
[a_L5 b_L5 c_L5]=axe_mobile_xyz([MH_RL5_R_bassin(1:3,1:3)]');
angles=2*pi/360*[a_L5 b_L5 c_L5];
% modification du joint � partir des rep�res.
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
