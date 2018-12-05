% % 
% % %% Modification du fémur droit
% % disp('personnalisation EOS du fémur droit')
% % nb_femur_r=find(strcmp(noms_bodies,'femur_r'));
% % nb_femur_r=num2str(nb_femur_r);file_ddr_bassin
% % 
% % %création du repère fémur droit
% % obj_wrl_femur_r=lire_fichier_vrml(file_wrl_femur_r);
% % obj_ddr_femur_r= lire_fichier_ddr(file_ddr_femur_r);
% % MH_R0Rlocal_femur_r=repere_femur_EOS_mod(obj_wrl_femur_r,obj_ddr_femur_r);
% % 
% % if strcmp(model_new.Model.length_units,'meters')==1
% %     MH_R0Rlocal_femur_r(1:3,4)=MH_R0Rlocal_femur_r(1:3,4)*10^(-3);
% % elseif strcmp(model_new.Model.length_units,'milimeters')==1
% % else
% %     disp('erreur de déclaration unité dans OpenSim')
% % end
% % 
% % % attribution de l'écart 
% % [a_femur_r b_femur_r c_femur_r]=axe_mobile_xyz([MH_R0Rlocal_femur_r(1:3,1:3)]');
% % angles=2*pi/360*[a_femur_r b_femur_r c_femur_r];
% % 
% % vect=-MH_R0Rlocal_femur_r(1:3,1:3)'*MH_R0Rlocal_femur_r(1:3,4);
% % 
% % model_new_9.Model.BodySet.objects.Body(3).VisibleObject.transform=[ 0 0 0 0 0 0];
% % model_new_9.Model.BodySet.objects.Body(3).VisibleObject.GeometrySet.objects.DisplayGeometry.transform=[angles vect'];





% % % % % % % 
% % % % % % % %attribution de la position du centre articulaire hanche dans le repère
% % % % % % % %parent
% % % % % % % centre_hanche_G_parent=MH_R0R1_hanche_G(1:3,4)';
% % % % % % % h=['model_new.Model.BodySet.objects.Body(' nb_femur_l ').Joint.CustomJoint.location_in_parent=[' num2str(centre_hanche_G_parent) '];'];
% % % % % % % eval(h)
% % % % % % % 
% % % % % % % %création du repère fémur gauche
% % % % % % % obj_wrl_femur_l=lire_fichier_vrml(file_wrl_femur_l);
% % % % % % % obj_ddr_femur_l= lire_fichier_ddr(file_ddr_femur_l);
% % % % % % % MH_R0Rlocal_femur_l=repere_femur_EOS_mod(obj_wrl_femur_l,obj_ddr_femur_l);
% % % % % % % 
% % % % % % % if strcmp(model_new.Model.length_units,'meters')==1
% % % % % % %     MH_R0Rlocal_femur_l(1:3,4)=MH_R0Rlocal_femur_l(1:3,4)*10^(-3);
% % % % % % % elseif strcmp(model_new.Model.length_units,'milimeters')==1
% % % % % % % else
% % % % % % %     disp('erreur de déclaration unité dans OpenSim')
% % % % % % % end
% % % % % % % 
% % % % % % % %expression de repère du fémur gauche dans le repère bassin (repère parent)
% % % % % % % MH_bassinRlocal_femur_l(1:3,1:3)=[MH_R0Rlocal_femur_l(1:3,1:3)]'*MH_R0Rlocal_bassin(1:3,1:3);
% % % % % % % MH_bassinRlocal_femur_l(1:3,4)=MH_bassinRlocal_femur_l(1:3,1:3)*MH_R0Rlocal_femur_l(1:3,4)-...
% % % % % % %     MH_R0Rlocal_bassin(1:3,4);
% % % % % % % MH_bassinRlocal_femur_l=[MH_bassinRlocal_femur_l; 0 0 0 1];
% % % % % % % 
% % % % % % % %attribution de la position du centre articulaire hanche dans le repère
% % % % % % % %enfant
% % % % % % % centre_hanche_G_enfant=MH_bassinRlocal_femur_l(1:3,4)';
% % % % % % % h=['model_new.Model.BodySet.objects.Body(' nb_femur_l ').Joint.CustomJoint.location_in_parent=[' num2str(centre_hanche_G_enfant) '];'];
% % % % % % % eval(h)
% % % % % % % 
% % % % % % % %récupération de la séquence d'axe
% % % % % % % h=['axe1=model_new.Model.BodySet.objects.Body(' nb_femur_l ').Joint.CustomJoint.SpatialTransform.TransformAxis(1).axis;'];
% % % % % % % eval(h)
% % % % % % % h=['axe2=model_new.Model.BodySet.objects.Body(' nb_femur_l ').Joint.CustomJoint.SpatialTransform.TransformAxis(2).axis;'];
% % % % % % % eval(h)
% % % % % % % h=['axe3=model_new.Model.BodySet.objects.Body(' nb_femur_l ').Joint.CustomJoint.SpatialTransform.TransformAxis(3).axis;'];
% % % % % % % eval(h)
% % % % % % % seq=trouver_seq(axe1,axe2,axe3);
% % % % % % % 
% % % % % % % %évaluation des angles selon la séquence d'axes
% % % % % % % h=['[a_femur_l b_femur_l c_femur_l]=axe_mobile_' seq '(MH_bassinRlocal_femur_l(1:3,1:3));'];
% % % % % % % eval(h)
% % % % % % % 
% % % % % % % %attribution de la séquence d'axes dans la structure
% % % % % % % angles=[a_femur_l b_femur_l c_femur_l];
% % % % % % % angles=angles*2*pi/360;
% % % % % % % h=['model_new.Model.BodySet.objects.Body(' nb_femur_l ').Joint.CustomJoint.orientation_in_parent=[' num2str(angles) '];'];
% % % % % % % eval(h)
% % % % % % % 
% % % % % % % %% Modification du fémur droit
% % % % % % % disp('personnalisation EOS du fémur droit')
% % % % % % % nb_femur_r=find(strcmp(noms_bodies,'femur_r'));
% % % % % % % nb_femur_r=num2str(nb_femur_r);
% % % % % % % %définition du repère hanche gauche dans le repère bassin
% % % % % % % MH_R0R1_hanche_D=hanche_rep_bassin(MH_R0Rlocal_bassin, file_wrl_femur_r,file_ddr_femur_r);
% % % % % % % if strcmp(model_new.Model.length_units,'meters')==1
% % % % % % %     MH_R0R1_hanche_D(1:3,4)=MH_R0R1_hanche_D(1:3,4)*10^(-3);
% % % % % % % elseif strcmp(model_new.Model.length_units,'milimeters')==1
% % % % % % % else
% % % % % % %     disp('erreur de déclaration unité dans OpenSim')
% % % % % % % end
% % % % % % % 
% % % % % % % %attribution de la position du centre articulaire hanche dans le repère
% % % % % % % %parent
% % % % % % % centre_hanche_D_parent=MH_R0R1_hanche_D(1:3,4)';
% % % % % % % h=['model_new.Model.BodySet.objects.Body(' nb_femur_r ').Joint.CustomJoint.location_in_parent=[' num2str(centre_hanche_D_parent) '];'];
% % % % % % % eval(h)
% % % % % % % 
% % % % % % % %création du repère fémur gauche
% % % % % % % obj_wrl_femur_r=lire_fichier_vrml(file_wrl_femur_r);
% % % % % % % obj_ddr_femur_r= lire_fichier_ddr(file_ddr_femur_r);
% % % % % % % MH_R0Rlocal_femur_r=repere_femur_EOS_mod(obj_wrl_femur_r,obj_ddr_femur_r);
% % % % % % % 
% % % % % % % if strcmp(model_new.Model.length_units,'meters')==1
% % % % % % %     MH_R0Rlocal_femur_r(1:3,4)=MH_R0Rlocal_femur_r(1:3,4)*10^(-3);
% % % % % % % elseif strcmp(model_new.Model.length_units,'milimeters')==1
% % % % % % % else
% % % % % % %     disp('erreur de déclaration unité dans OpenSim')
% % % % % % % end
% % % % % % % 
% % % % % % % %expression de repère du fémur gauche dans le repère bassin (repère parent)
% % % % % % % MH_bassinRlocal_femur_r(1:3,1:3)=[MH_R0Rlocal_femur_r(1:3,1:3)]'*MH_R0Rlocal_bassin(1:3,1:3);
% % % % % % % MH_bassinRlocal_femur_r(1:3,4)=MH_bassinRlocal_femur_r(1:3,1:3)*MH_R0Rlocal_femur_r(1:3,4)-...
% % % % % % %     MH_R0Rlocal_bassin(1:3,4);
% % % % % % % MH_bassinRlocal_femur_r=[MH_bassinRlocal_femur_r; 0 0 0 1];
% % % % % % % 
% % % % % % % %attribution de la position du centre articulaire hanche dans le repère
% % % % % % % %enfant
% % % % % % % centre_hanche_D_enfant=MH_bassinRlocal_femur_r(1:3,4)';
% % % % % % % h=['model_new.Model.BodySet.objects.Body(' nb_femur_r ').Joint.CustomJoint.location_in_parent=[' num2str(centre_hanche_D_enfant) '];'];
% % % % % % % eval(h)
% % % % % % % 
% % % % % % % %récupération de la séquence d'axe
% % % % % % % h=['axe1=model_new.Model.BodySet.objects.Body(' nb_femur_r ').Joint.CustomJoint.SpatialTransform.TransformAxis(1).axis;'];
% % % % % % % eval(h)
% % % % % % % h=['axe2=model_new.Model.BodySet.objects.Body(' nb_femur_r ').Joint.CustomJoint.SpatialTransform.TransformAxis(2).axis;'];
% % % % % % % eval(h)
% % % % % % % h=['axe3=model_new.Model.BodySet.objects.Body(' nb_femur_r ').Joint.CustomJoint.SpatialTransform.TransformAxis(3).axis;'];
% % % % % % % eval(h)
% % % % % % % seq=trouver_seq(axe1,axe2,axe3);
% % % % % % % 
% % % % % % % %évaluation des angles selon la séquence d'axes
% % % % % % % h=['[a_femur_r b_femur_r c_femur_r]=axe_mobile_' seq '(MH_bassinRlocal_femur_r(1:3,1:3));'];
% % % % % % % eval(h)
% % % % % % % 
% % % % % % % %attribution de la séquence d'axes dans la structure
% % % % % % % angles=[a_femur_r b_femur_r c_femur_r];
% % % % % % % angles=angles*2*pi/360;
% % % % % % % h=['model_new.Model.BodySet.objects.Body(' nb_femur_r ').Joint.CustomJoint.orientation_in_parent=[' num2str(angles) '];'];
% % % % % % % eval(h)
