function [model_new,MH_R0Rlocal_courant]=modification_EOS_cervicale_generique(model_new,file_wrl_courante,file_o3_courante,nb_courante,MH_R0local_Rparent)

%% Lombaire 5
% id�es : 
% AXES : on veut cr�er la base d�finies par les axes d�finis par l'ISB.
% CENTRE ARTICULAIRE : on veut d�clarer que le centre articulaire entre le bassin et L4
% soit au niveau du centre des deux p�dicules de . 
% il faut donc d�terminer la position de ce point dans le rep�re bassin
% ainsi que dans le rep�re vert�bre.



% cr�ation de la base de
% �tape 1 : cr�ation du rep�re dans la base EOS
[MH_R0Rlocal_Ci, centre_sup_Ci, centre_inf_Ci, centre_pedicule_d, centre_pedicule_g]=calcul_repere_cervicale(file_wrl_courante,file_o3_courante);
MH_R0Rlocal_courant=MH_R0Rlocal_Ci;

if strcmp(model_new.Model.length_units,'meters')==1
    MH_R0Rlocal_courant(1:3,4)=MH_R0Rlocal_Ci(1:3,4)*10^(-3);
    centre_sup_Ci=centre_sup_Ci/1000;
    centre_inf_Ci=centre_inf_Ci/1000;
    centre_pedicule_d=centre_pedicule_d/1000;
    centre_pedicule_g=centre_pedicule_g/1000;
elseif strcmp(model_new.Model.length_units,'milimeters')==1
    centre_inf_Ci=centre_inf_Ci;
    centre_sup_Ci=centre_sup_Ci;
    centre_pedicule_d=centre_pedicule_d;
    centre_pedicule_g=centre_pedicule_g;
else
    disp('erreur de d�claration unit� dans OpenSim')
end

centre_pedicules=(centre_pedicule_d+centre_pedicule_g)*0.5;
MH_R0Rlocal_courant(1:3,4)=centre_pedicules;


MH_RLi_R_bassin(1:3,1:3)=MH_R0Rlocal_courant(1:3,1:3)'*MH_R0local_Rparent(1:3,1:3);
[a_Li b_Li c_Li]=axe_mobile_xyz([MH_RLi_R_bassin(1:3,1:3)]');
angles=2*pi/360*[a_Li b_Li c_Li];
% modification du joint � partir des rep�res.
vect=-MH_R0Rlocal_courant(1:3,1:3)'*MH_R0Rlocal_courant(1:3,4);
centre_pedicule_Li_in_bassin=inv(MH_R0local_Rparent)*[centre_pedicules';1];
model_new.Model.BodySet.objects.Body(nb_courante).Joint.CustomJoint.location_in_parent=centre_pedicule_Li_in_bassin(1:3)';
model_new.Model.BodySet.objects.Body(nb_courante).Joint.CustomJoint.orientation_in_parent=angles;
model_new.Model.BodySet.objects.Body(nb_courante).Joint.CustomJoint.location=[0 0 0];
model_new.Model.BodySet.objects.Body(nb_courante).Joint.CustomJoint.orientation=[0 0 0];


[a_Li b_Li c_Li]=axe_mobile_xyz([MH_R0Rlocal_courant(1:3,1:3)]');
angles=2*pi/360*[a_Li b_Li c_Li];
vect=-MH_R0Rlocal_courant(1:3,1:3)'*MH_R0Rlocal_courant(1:3,4);
model_new.Model.BodySet.objects.Body(nb_courante).VisibleObject.transform=[ 0 0 0 0 0 0];
model_new.Model.BodySet.objects.Body(nb_courante).VisibleObject.GeometrySet.objects.DisplayGeometry(1).transform=[angles vect'];

end
