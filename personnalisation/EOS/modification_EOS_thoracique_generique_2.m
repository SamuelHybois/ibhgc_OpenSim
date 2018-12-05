function [model_new,MH_R0Rlocal_T1]=modification_EOS_thoracique_generique_2(model_new,file_wrl_T1,file_ddr_T1,nb_thorax,nb_clav_g,nb_clav_d,nb_scap_g,nb_scap_d,nb_cerv_7,MH_R0local_L1)

%% Lombaire 5
% idées : 
% AXES : on veut créer la base définies par les axes définis par l'ISB.
% CENTRE ARTICULAIRE : on veut déclarer que le centre articulaire entre le bassin et L4
% soit au niveau du centre des deux pédicules de L4. 
% il faut donc déterminer la position de ce point dans le repère bassin
% ainsi que dans le repère vertèbre.



% création de la base de T1
% étape 1 : création du repère dans la base EOS
[MH_R0Rlocal_T1, centre_sup_T1, centre_inf_T1, centre_pedicule_d_T1, centre_pedicule_g_T1,facette_sup_d_T1, facette_sup_g_T1]=calcul_repere_thoracique_2(file_wrl_T1,file_ddr_T1);
MH_R0Rlocal_T1=MH_R0Rlocal_T1;

if strcmp(model_new.Model.length_units,'meters')==1
    MH_R0Rlocal_T1(1:3,4)=MH_R0Rlocal_T1(1:3,4)*10^(-3);
    centre_sup_T1=centre_sup_T1/1000;
    centre_inf_T1=centre_inf_T1/1000;
    centre_pedicule_d_T1=centre_pedicule_d_T1/1000;
    centre_pedicule_g_T1=centre_pedicule_g_T1/1000;
    facette_sup_d_T1=facette_sup_d_T1/1000;
    facette_sup_g_T1=facette_sup_g_T1/1000;
elseif strcmp(model_new.Model.length_units,'milimeters')==1
    centre_inf_T1=centre_inf_T1;
    centre_sup_T1=centre_sup_T1;
    centre_pedicule_d_T1=centre_pedicule_d_T1;
    centre_pedicule_g_T1=centre_pedicule_g_T1;
    facette_sup_g_T1=facette_sup_g_T1;
    facette_sup_d_T1=facette_sup_d_T1;
else
    disp('erreur de déclaration unité dans OpenSim')
end

centre_pedicules_T1=(centre_pedicule_d_T1+centre_pedicule_g_T1)*0.5;
MH_R0Rlocal_T1(1:3,4)=centre_pedicules_T1;


MH_RLi_R_bassin(1:3,1:3)=MH_R0Rlocal_T1(1:3,1:3)'*MH_R0local_L1(1:3,1:3);
[a_Li b_Li c_Li]=axe_mobile_xyz([MH_RLi_R_bassin(1:3,1:3)]');
angles=2*pi/360*[a_Li b_Li c_Li];
% modification du joint à partir des repères.
vect=-MH_R0Rlocal_T1(1:3,1:3)'*MH_R0Rlocal_T1(1:3,4);
centre_pedicule_T1_in_L1=inv(MH_R0local_L1)*[centre_pedicules_T1;1];
MH_R0local_thorax=MH_R0Rlocal_T1;% le thorax est fusionné avec les vertèbres thoraciques et est fixé par T1
centre_pedicules_L1=MH_R0local_L1(1:3,4);
centre_pedicule_L1_in_thorax=-inv(MH_R0local_thorax)*[centre_pedicules_L1;1];
model_new.Model.BodySet.objects.Body(nb_thorax).Joint.CustomJoint.location_in_parent=[ 0 0 0 ];%%%% centre_pedicule_T1_in_L1(1:3)';%%%%%
model_new.Model.BodySet.objects.Body(nb_thorax).Joint.CustomJoint.orientation_in_parent=angles;
model_new.Model.BodySet.objects.Body(nb_thorax).Joint.CustomJoint.location=-centre_pedicule_L1_in_thorax(1:3)';% il me faut la position du centre du repère de L1 exprimé dans le repère du thorax
model_new.Model.BodySet.objects.Body(nb_thorax).Joint.CustomJoint.orientation=[0 0 0];


[a_Li b_Li c_Li]=axe_mobile_xyz([MH_R0Rlocal_T1(1:3,1:3)]');
angles=2*pi/360*[a_Li b_Li c_Li];
vect=-MH_R0Rlocal_T1(1:3,1:3)'*MH_R0Rlocal_T1(1:3,4);%+centre_pedicule_L1_in_thorax(1:3);
model_new.Model.BodySet.objects.Body(nb_thorax).VisibleObject.transform=[ 0 0 0 0 0 0];
model_new.Model.BodySet.objects.Body(nb_thorax).VisibleObject.GeometrySet.objects.DisplayGeometry(1).transform=[angles vect'];
%% hypothèse : on positionne les thoraciques selon la même position qu'elles avaient dans EOS
disp('personnalisation EOS de T2')
model_new.Model.BodySet.objects.Body(nb_thorax).VisibleObject.GeometrySet.objects.DisplayGeometry(2).transform=[angles vect'];
disp('personnalisation EOS de T3')
model_new.Model.BodySet.objects.Body(nb_thorax).VisibleObject.GeometrySet.objects.DisplayGeometry(3).transform=[angles vect'];
disp('personnalisation EOS de T4')
model_new.Model.BodySet.objects.Body(nb_thorax).VisibleObject.GeometrySet.objects.DisplayGeometry(4).transform=[angles vect'];
disp('personnalisation EOS de T5')
model_new.Model.BodySet.objects.Body(nb_thorax).VisibleObject.GeometrySet.objects.DisplayGeometry(5).transform=[angles vect'];
disp('personnalisation EOS de T6')
model_new.Model.BodySet.objects.Body(nb_thorax).VisibleObject.GeometrySet.objects.DisplayGeometry(6).transform=[angles vect'];
disp('personnalisation EOS de T7')
model_new.Model.BodySet.objects.Body(nb_thorax).VisibleObject.GeometrySet.objects.DisplayGeometry(7).transform=[angles vect'];
disp('personnalisation EOS de T8')
model_new.Model.BodySet.objects.Body(nb_thorax).VisibleObject.GeometrySet.objects.DisplayGeometry(8).transform=[angles vect'];
disp('personnalisation EOS de T9')
model_new.Model.BodySet.objects.Body(nb_thorax).VisibleObject.GeometrySet.objects.DisplayGeometry(9).transform=[angles vect'];
disp('personnalisation EOS de T10')
model_new.Model.BodySet.objects.Body(nb_thorax).VisibleObject.GeometrySet.objects.DisplayGeometry(10).transform=[angles vect'];
disp('personnalisation EOS de T11')
model_new.Model.BodySet.objects.Body(nb_thorax).VisibleObject.GeometrySet.objects.DisplayGeometry(11).transform=[angles vect'];
disp('personnalisation EOS de T12')
model_new.Model.BodySet.objects.Body(nb_thorax).VisibleObject.GeometrySet.objects.DisplayGeometry(12).transform=[angles vect'];
%% hypothèse : on vient positionner le thorax de sorte que la côte la plus crâniale soit centrée sur les pédicules de T1
% Remarque : le thorax.vtp que l'on a lors de la création de cette pipeline
% (modèle fullbody issu de la fusion de Seth et de Raabe), le thorax est
% centré sur le Manubrium.
%dans le repère thorax défini par T12, le centre de la naissance des cotes
%a pour coordonnées -0.065 0.035 0 
disp('recalage du thorax')
centre_facettesOpenSim=[-0.065 0.035 0];
centre_facettesREOS=(facette_sup_d_T1+facette_sup_g_T1)/2;
% centre_facettesREOS=[centre_facettesREOS';1];

decalage_facettes_pedicules_EOS=centre_facettesREOS'-MH_R0Rlocal_T1(1:3,4);
decalage_facettes_pedicules_T1=-MH_R0Rlocal_T1(1:3,1:3)'*decalage_facettes_pedicules_EOS;
% decalage_facettes_pedicules_EOS=[decalage_facettes_pedicules_EOS;1];
% 
% centre_facettesRT1=MH_R0Rlocal_courant*centre_facettesRT1
% 
% % centre_facettesRT1=MH_R0Rlocal_courant*centre_facettesREOS;
% % centre_facettesRT1=centre_facettesRT1(1:3);
% % centre_facettesRT1=centre_facettesRT1-MH_R0Rlocal_courant(1:3,4);
% % centre_facettesRT1=centre_facettesRT1';
% % vect=centre_facettesRT1-centre_facettesOpenSim;
% % vect=vect(1:3);
% % 
% % centre_facettesRT1=MH_R0Rlocal_courant*centre_facettesREOS;
vect=-centre_facettesOpenSim+decalage_facettes_pedicules_T1';

model_new.Model.BodySet.objects.Body(nb_thorax).VisibleObject.GeometrySet.objects.DisplayGeometry(13).transform=[0 0 0 vect];
disp('recalage des clacivules')
cur_location_in_parent=model_new.Model.BodySet.objects.Body(nb_clav_d).Joint.CustomJoint.location_in_parent;
model_new.Model.BodySet.objects.Body(nb_clav_d).Joint.CustomJoint.location_in_parent=cur_location_in_parent+vect;
cur_location_in_parent=model_new.Model.BodySet.objects.Body(nb_clav_g).Joint.CustomJoint.location_in_parent;
model_new.Model.BodySet.objects.Body(nb_clav_g).Joint.CustomJoint.location_in_parent=cur_location_in_parent+vect;
disp('recalage des ellispoides')
cur_translation=model_new.Model.BodySet.objects.Body(nb_thorax).WrapObjectSet.objects.WrapEllipsoid(1).translation;
model_new.Model.BodySet.objects.Body(nb_thorax).WrapObjectSet.objects.WrapEllipsoid(1).translation=cur_translation+vect;
cur_location_in_parent=model_new.Model.BodySet.objects.Body(nb_scap_g).Joint.ScapulothoracicJoint.location_in_parent;
model_new.Model.BodySet.objects.Body(nb_scap_g).Joint.ScapulothoracicJoint.location_in_parent=cur_location_in_parent+vect;

cur_translation=model_new.Model.BodySet.objects.Body(nb_thorax).WrapObjectSet.objects.WrapEllipsoid(2).translation;
model_new.Model.BodySet.objects.Body(nb_thorax).WrapObjectSet.objects.WrapEllipsoid(2).translation=cur_translation+vect;
cur_location_in_parent=model_new.Model.BodySet.objects.Body(nb_scap_d).Joint.ScapulothoracicJoint.location_in_parent;
model_new.Model.BodySet.objects.Body(nb_scap_d).Joint.ScapulothoracicJoint.location_in_parent=cur_location_in_parent+vect;

cur_location_in_parent=model_new.Model.BodySet.objects.Body(nb_scap_g).Joint.ScapulothoracicJoint.location_in_parent;
model_new.Model.BodySet.objects.Body(nb_scap_g).Joint.CustomJoint.location_in_parent=cur_location_in_parent+vect;
cur_location_in_parent=model_new.Model.BodySet.objects.Body(nb_scap_d).Joint.ScapulothoracicJoint.location_in_parent;
disp('recalage des scapulas')
model_new.Model.BodySet.objects.Body(nb_scap_d).Joint.CustomJoint.location_in_parent=cur_location_in_parent+vect;
cur_location_in_parent=model_new.Model.BodySet.objects.Body(nb_cerv_7).Joint.CustomJoint.location_in_parent;
model_new.Model.BodySet.objects.Body(nb_cerv_7).Joint.CustomJoint.location_in_parent=cur_location_in_parent+vect;


end
