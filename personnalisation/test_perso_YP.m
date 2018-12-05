function cur_st_model=test_perso_YP(rep_global,cur_sujet,cur_st_model,protocol,perso_cheville_arg_inutile_impose_par_le_main)

%% Déclaration des dossiers
dir_regions=fullfile(rep_global,'info_global','DDR');
rep_wrl=fullfile(rep_global,cur_sujet,'fichiers_wrl');
rep_wrl_os_corps_complet=fullfile(rep_wrl,'os','os_corps_complet');
rep_wrl_billes_corps_complet=fullfile(rep_wrl,'billes','billes_corps_complet');
rep_geometry=fullfile(rep_global,cur_sujet,'modele','Geometry');
rep_sortie_model=fullfile(rep_global,cur_sujet,'modele');

%% Transfert des fichiers wrl vers stl
% On les transfère dans le dossier Geometry
transfert_fichier_wrl_stl(rep_wrl_os_corps_complet,cur_sujet,rep_geometry)

%% Extraction zones d'interet
[reperes,points]=extraction_points_interet_EOS_Vertebres_YP(dir_regions,rep_wrl_os_corps_complet,protocol,rep_wrl_billes_corps_complet);

%Liste des bodies dans le model
bodies_name=cell(length(cur_st_model.Model.BodySet.objects.Body),1);
for i_body=1:length(cur_st_model.Model.BodySet.objects.Body)
    bodies_name{i_body}=cur_st_model.Model.BodySet.objects.Body(i_body).ATTRIBUTE.name;
end

%%Lecture de la fiche clinique
% [~,parametres_fiche_clinique] = PathContent_Type(fullfile(rep_global,cur_sujet),'.xlsx');
% [param_pelvis,rotations]=xls_read_fiche_clinique_YP(fullfile(rep_global,cur_sujet,parametres_fiche_clinique{1}));

%% On remplace les location, location in parent et orientations dans le modèle
%(et on enregistre les angles entre chaque vertèbre pour la suite par rapport à x, y et z)
angles_thor_EOS=zeros(12,3);
angles_lomb_EOS=zeros(5,3);

%Tete & C1-C2
if isfield(protocol.MARQUEURS_EOS,'C2etC1')==1
    ind_C1=strcmp(bodies_name,'cerv1');
    ind_C2=strcmp(bodies_name,'cerv2');
    ind_skull=strcmp(bodies_name,'skull');
    cur_st_model.Model.BodySet.objects.Body(ind_C2).Joint.CustomJoint.location_in_parent=round(points.C2JC_RC3/1000,4); % Conversion mm en m
    cur_st_model.Model.BodySet.objects.Body(ind_C2).Joint.CustomJoint.location=round((points.C2JC_RC3-points.centreC2_RC3)/1000,4);
    
    cur_st_model.Model.BodySet.objects.Body(ind_C1).Joint.CustomJoint.location_in_parent=round((points.C1JC_RC3-points.centreC2_RC3)/1000,4); % Conversion mm en m
    cur_st_model.Model.BodySet.objects.Body(ind_C1).Joint.CustomJoint.location=round((points.C1JC_RC3-points.centreC1_RC3)/1000,4);
    
    if isfield(protocol.MARQUEURS_EOS,'repere_tete')==1
        cur_st_model.Model.BodySet.objects.Body(ind_skull).Joint.CustomJoint.location_in_parent=round((points.skullJC_RC3-points.centreC1_RC3)/1000,4); % Conversion mm en m
        cur_st_model.Model.BodySet.objects.Body(ind_skull).Joint.CustomJoint.location=round((points.skullJC_Rt)/1000,4);

            cur_st_model.Model.BodySet.objects.Body(ind_skull).VisibleObject.GeometrySet.objects.DisplayGeometry(1).transform=[0 0 0 -round((points.skullcenter_RC3-points.skullJC_RC3)/1000,4)'];
        cur_st_model.Model.BodySet.objects.Body(ind_skull).VisibleObject.GeometrySet.objects.DisplayGeometry(2).transform=[0 0 0 -round((points.skullcenter_RC3-points.skullJC_RC3)/1000,4)'];

        reperes.temp=reperes.cerv3\reperes.tete;
        cur_st_model.Model.BodySet.objects.Body(ind_skull).Joint.CustomJoint.orientation_in_parent=...
            round(circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2),5);
    end
end


%FemurD
ind_FD=strcmp(bodies_name,'femur_r');
cur_st_model.Model.BodySet.objects.Body(ind_FD).Joint.CustomJoint.location_in_parent=round(points.HJC_D_Rb/1000,4); % Conversion mm en m

%FemurG
ind_FG=strcmp(bodies_name,'femur_l');
cur_st_model.Model.BodySet.objects.Body(ind_FG).Joint.CustomJoint.location_in_parent=round(points.HJC_G_Rb/1000,4); % Conversion mm en m

% L5
ind_L5=strcmp(bodies_name,'lumbar5');
cur_st_model.Model.BodySet.objects.Body(ind_L5).Joint.CustomJoint.parent_body='pelvis';%On remplace le sacrum par le stl pelvis + sacrum sorti d'EOS
cur_st_model.Model.BodySet.objects.Body(ind_L5).Joint.CustomJoint.location_in_parent=round(points.L5JC_Rb/1000,4); % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_L5).Joint.CustomJoint.location=round(points.L5JC_RL5/1000,4);
reperes.temp=reperes.bassin\reperes.lumbar5;
cur_st_model.Model.BodySet.objects.Body(ind_L5).Joint.CustomJoint.orientation_in_parent=...
    circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);
angles_lomb_EOS(5,:)=circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);


% L4
ind_L4=strcmp(bodies_name,'lumbar4');
cur_st_model.Model.BodySet.objects.Body(ind_L4).Joint.CustomJoint.location_in_parent=round(points.L4JC_RL5/1000,4); % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_L4).Joint.CustomJoint.location=round(points.L4JC_RL4/1000,4);
reperes.temp=reperes.lumbar5\reperes.lumbar4;
cur_st_model.Model.BodySet.objects.Body(ind_L4).Joint.CustomJoint.orientation_in_parent=...
    circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);
angles_lomb_EOS(4,:)=circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);

% L3
ind_L3=strcmp(bodies_name,'lumbar3');
cur_st_model.Model.BodySet.objects.Body(ind_L3).Joint.CustomJoint.location_in_parent=round(points.L3JC_RL4/1000,4); % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_L3).Joint.CustomJoint.location=round(points.L3JC_RL3/1000,4);
reperes.temp=reperes.lumbar4\reperes.lumbar3;
cur_st_model.Model.BodySet.objects.Body(ind_L3).Joint.CustomJoint.orientation_in_parent=...
    circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);
angles_lomb_EOS(3,:)=circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);

% L2
ind_L2=strcmp(bodies_name,'lumbar2');
cur_st_model.Model.BodySet.objects.Body(ind_L2).Joint.CustomJoint.location_in_parent=round(points.L2JC_RL3/1000,4); % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_L2).Joint.CustomJoint.location=round(points.L2JC_RL2/1000,4);
reperes.temp=reperes.lumbar3\reperes.lumbar2;
cur_st_model.Model.BodySet.objects.Body(ind_L2).Joint.CustomJoint.orientation_in_parent=...
    circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);
angles_lomb_EOS(2,:)=circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);

% L1
ind_L1=strcmp(bodies_name,'lumbar1');
cur_st_model.Model.BodySet.objects.Body(ind_L1).Joint.CustomJoint.location_in_parent=round(points.L1JC_RL2/1000,4); % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_L1).Joint.CustomJoint.location=round(points.L1JC_RL1/1000,4);
reperes.temp=reperes.lumbar2\reperes.lumbar1;
cur_st_model.Model.BodySet.objects.Body(ind_L1).Joint.CustomJoint.orientation_in_parent=...
    circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);
angles_lomb_EOS(1,:)=circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);

% T12
ind_T12=strcmp(bodies_name,'thoracic12');
cur_st_model.Model.BodySet.objects.Body(ind_T12).Joint.CustomJoint.location_in_parent=round(points.T12JC_RL1/1000,4); % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_T12).Joint.CustomJoint.location=round(points.T12JC_RT12/1000,4);
reperes.temp=reperes.lumbar1\reperes.thor12;
cur_st_model.Model.BodySet.objects.Body(ind_T12).Joint.CustomJoint.orientation_in_parent=...
    circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);
angles_thor_EOS(12,:)=circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);

% T11
ind_T11=strcmp(bodies_name,'thoracic11');
cur_st_model.Model.BodySet.objects.Body(ind_T11).Joint.CustomJoint.location_in_parent=round(points.T11JC_RT12/1000,4); % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_T11).Joint.CustomJoint.location=round(points.T11JC_RT11/1000,4);
reperes.temp=reperes.thor12\reperes.thor11;
cur_st_model.Model.BodySet.objects.Body(ind_T11).Joint.CustomJoint.orientation_in_parent=...
    circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);
angles_thor_EOS(11,:)=circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);

% T10
ind_T10=strcmp(bodies_name,'thoracic10');
cur_st_model.Model.BodySet.objects.Body(ind_T10).Joint.CustomJoint.location_in_parent=round(points.T10JC_RT11/1000,4); % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_T10).Joint.CustomJoint.location=round(points.T10JC_RT10/1000,4);
reperes.temp=reperes.thor11\reperes.thor10;
cur_st_model.Model.BodySet.objects.Body(ind_T10).Joint.CustomJoint.orientation_in_parent=...
    circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);
angles_thor_EOS(10,:)=circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);

% T9
ind_T9=strcmp(bodies_name,'thoracic9');
cur_st_model.Model.BodySet.objects.Body(ind_T9).Joint.CustomJoint.location_in_parent=round(points.T9JC_RT10/1000,4); % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_T9).Joint.CustomJoint.location=round(points.T9JC_RT9/1000,4);
reperes.temp=reperes.thor10\reperes.thor9;
cur_st_model.Model.BodySet.objects.Body(ind_T9).Joint.CustomJoint.orientation_in_parent=...
    circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);
angles_thor_EOS(9,:)=circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);

% T8
ind_T8=strcmp(bodies_name,'thoracic8');
cur_st_model.Model.BodySet.objects.Body(ind_T8).Joint.CustomJoint.location_in_parent=round(points.T8JC_RT9/1000,4); % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_T8).Joint.CustomJoint.location=round(points.T8JC_RT8/1000,4);
reperes.temp=reperes.thor9\reperes.thor8;
cur_st_model.Model.BodySet.objects.Body(ind_T8).Joint.CustomJoint.orientation_in_parent=...
    circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);
angles_thor_EOS(8,:)=circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);

% T7
ind_T7=strcmp(bodies_name,'thoracic7');
cur_st_model.Model.BodySet.objects.Body(ind_T7).Joint.CustomJoint.location_in_parent=round(points.T7JC_RT8/1000,4); % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_T7).Joint.CustomJoint.location=round(points.T7JC_RT7/1000,4);
reperes.temp=reperes.thor8\reperes.thor7;
cur_st_model.Model.BodySet.objects.Body(ind_T7).Joint.CustomJoint.orientation_in_parent=...
    circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);
angles_thor_EOS(7,:)=circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);

% T6
ind_T6=strcmp(bodies_name,'thoracic6');
cur_st_model.Model.BodySet.objects.Body(ind_T6).Joint.CustomJoint.location_in_parent=round(points.T6JC_RT7/1000,4); % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_T6).Joint.CustomJoint.location=round(points.T6JC_RT6/1000,4);
reperes.temp=reperes.thor7\reperes.thor6;
cur_st_model.Model.BodySet.objects.Body(ind_T6).Joint.CustomJoint.orientation_in_parent=...
    circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);
angles_thor_EOS(6,:)=circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);

% T5
ind_T5=strcmp(bodies_name,'thoracic5');
cur_st_model.Model.BodySet.objects.Body(ind_T5).Joint.CustomJoint.location_in_parent=round(points.T5JC_RT6/1000,4); % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_T5).Joint.CustomJoint.location=round(points.T5JC_RT5/1000,4);
reperes.temp=reperes.thor6\reperes.thor5;
cur_st_model.Model.BodySet.objects.Body(ind_T5).Joint.CustomJoint.orientation_in_parent=...
    circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);
angles_thor_EOS(5,:)=circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);

% T4
ind_T4=strcmp(bodies_name,'thoracic4');
cur_st_model.Model.BodySet.objects.Body(ind_T4).Joint.CustomJoint.location_in_parent=round(points.T4JC_RT5/1000,4); % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_T4).Joint.CustomJoint.location=round(points.T4JC_RT4/1000,4);
reperes.temp=reperes.thor5\reperes.thor4;
cur_st_model.Model.BodySet.objects.Body(ind_T4).Joint.CustomJoint.orientation_in_parent=...
    circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);
angles_thor_EOS(4,:)=circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);

% T3
ind_T3=strcmp(bodies_name,'thoracic3');
cur_st_model.Model.BodySet.objects.Body(ind_T3).Joint.CustomJoint.location_in_parent=round(points.T3JC_RT4/1000,4); % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_T3).Joint.CustomJoint.location=round(points.T3JC_RT3/1000,4);
reperes.temp=reperes.thor4\reperes.thor3;
cur_st_model.Model.BodySet.objects.Body(ind_T3).Joint.CustomJoint.orientation_in_parent=...
    circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);
angles_thor_EOS(3,:)=circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);

% T2
ind_T2=strcmp(bodies_name,'thoracic2');
cur_st_model.Model.BodySet.objects.Body(ind_T2).Joint.CustomJoint.location_in_parent=round(points.T2JC_RT3/1000,4); % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_T2).Joint.CustomJoint.location=round(points.T2JC_RT2/1000,4);
reperes.temp=reperes.thor3\reperes.thor2;
cur_st_model.Model.BodySet.objects.Body(ind_T2).Joint.CustomJoint.orientation_in_parent=...
    circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);
angles_thor_EOS(2,:)=circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);

% T1
ind_T1=strcmp(bodies_name,'thoracic1');
cur_st_model.Model.BodySet.objects.Body(ind_T1).Joint.CustomJoint.location_in_parent=round(points.T1JC_RT2/1000,4); % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_T1).Joint.CustomJoint.location=round(points.T1JC_RT1/1000,4);
reperes.temp=reperes.thor2\reperes.thor1;
cur_st_model.Model.BodySet.objects.Body(ind_T1).Joint.CustomJoint.orientation_in_parent=...
    circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);
angles_thor_EOS(1,:)=circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);

% C7
ind_C7=strcmp(bodies_name,'cerv7');
cur_st_model.Model.BodySet.objects.Body(ind_C7).Joint.CustomJoint.location_in_parent=round(points.C7JC_RT1/1000,4); % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_C7).Joint.CustomJoint.location=round(points.C7JC_RC7/1000,4);
reperes.temp=reperes.thor1\reperes.cerv7;
cur_st_model.Model.BodySet.objects.Body(ind_C7).Joint.CustomJoint.orientation_in_parent=...
    circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);

% C6
ind_C6=strcmp(bodies_name,'cerv6');
cur_st_model.Model.BodySet.objects.Body(ind_C6).Joint.CustomJoint.location_in_parent=round(points.C6JC_RC7/1000,4); % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_C6).Joint.CustomJoint.location=round(points.C6JC_RC6/1000,4);
reperes.temp=reperes.cerv7\reperes.cerv6;
cur_st_model.Model.BodySet.objects.Body(ind_C6).Joint.CustomJoint.orientation_in_parent=...
    circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);

% C5
ind_C5=strcmp(bodies_name,'cerv5');
cur_st_model.Model.BodySet.objects.Body(ind_C5).Joint.CustomJoint.location_in_parent=round(points.C5JC_RC6/1000,4); % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_C5).Joint.CustomJoint.location=round(points.C5JC_RC5/1000,4);
reperes.temp=reperes.cerv6\reperes.cerv5;
cur_st_model.Model.BodySet.objects.Body(ind_C5).Joint.CustomJoint.orientation_in_parent=...
    circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);

% C4
ind_C4=strcmp(bodies_name,'cerv4');
cur_st_model.Model.BodySet.objects.Body(ind_C4).Joint.CustomJoint.location_in_parent=round(points.C4JC_RC5/1000,4); % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_C4).Joint.CustomJoint.location=round(points.C4JC_RC4/1000,4);
reperes.temp=reperes.cerv5\reperes.cerv4;
cur_st_model.Model.BodySet.objects.Body(ind_C4).Joint.CustomJoint.orientation_in_parent=...
    circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);

% C3
ind_C3=strcmp(bodies_name,'cerv3');
cur_st_model.Model.BodySet.objects.Body(ind_C3).Joint.CustomJoint.location_in_parent=round(points.C3JC_RC4/1000,4); % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_C3).Joint.CustomJoint.location=round(points.C3JC_RC3/1000,4);
reperes.temp=reperes.cerv4\reperes.cerv3;
cur_st_model.Model.BodySet.objects.Body(ind_C3).Joint.CustomJoint.orientation_in_parent=...
    circshift(axemobile(reperes.temp(1:3,1:3),'zxy')*pi/180,2);

%% Modifications des géométries modèle pour le prise en compte du passage EOS ==> OS
%On cache l'ancien sacrum
ind_sacrum=strcmp(bodies_name,'sacrum');
cur_st_model.Model.BodySet.objects.Body(ind_sacrum).VisibleObject.GeometrySet.objects.DisplayGeometry.display_preference=0;

% Bassin
ind_bassin=strcmp(bodies_name,'pelvis');
% On remplace la géométrie du bassin en 2 parties par une seule globale
% comprenant les ailes iliaques et le sacrum
cur_st_model.Model.BodySet.objects.Body(ind_bassin).VisibleObject.GeometrySet.objects.DisplayGeometry=cur_st_model.Model.BodySet.objects.Body(ind_bassin).VisibleObject.GeometrySet.objects.DisplayGeometry(1);
cur_st_model.Model.BodySet.objects.Body(ind_bassin).VisibleObject.GeometrySet.objects.SEQUENCE={'DisplayGeometry',1};
cur_st_model.Model.BodySet.objects.Body(ind_bassin).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_bassin).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_Bassin.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_bassin).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.bassin,ind_bassin,1);

% L5
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.lumbar5,ind_L5,1);
cur_st_model.Model.BodySet.objects.Body(ind_L5).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_Vertebre_L5.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_L5).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_L5).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];

% L4
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.lumbar4,ind_L4,1);
cur_st_model.Model.BodySet.objects.Body(ind_L4).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_Vertebre_L4.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_L4).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_L4).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];

% L3
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.lumbar3,ind_L3,1);
cur_st_model.Model.BodySet.objects.Body(ind_L3).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_Vertebre_L3.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_L3).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_L3).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];

% L2
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.lumbar2,ind_L2,1);
cur_st_model.Model.BodySet.objects.Body(ind_L2).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_Vertebre_L2.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_L2).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_L2).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];

% L1
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.lumbar1,ind_L1,1);
cur_st_model.Model.BodySet.objects.Body(ind_L1).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_Vertebre_L1.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_L1).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_L1).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];

% T12
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.thor12,ind_T12,1);
cur_st_model.Model.BodySet.objects.Body(ind_T12).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_Vertebre_T12.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_T12).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_T12).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];

% T11
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.thor11,ind_T11,1);
cur_st_model.Model.BodySet.objects.Body(ind_T11).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_Vertebre_T11.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_T11).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_T11).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];

% T10
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.thor10,ind_T10,1);
cur_st_model.Model.BodySet.objects.Body(ind_T10).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_Vertebre_T10.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_T10).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_T10).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];

% T9
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.thor9,ind_T9,1);
cur_st_model.Model.BodySet.objects.Body(ind_T9).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_Vertebre_T9.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_T9).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_T9).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];

% T8
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.thor8,ind_T8,1);
cur_st_model.Model.BodySet.objects.Body(ind_T8).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_Vertebre_T8.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_T8).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_T8).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];

% T7
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.thor7,ind_T7,1);
cur_st_model.Model.BodySet.objects.Body(ind_T7).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_Vertebre_T7.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_T7).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_T7).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];

% T6
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.thor6,ind_T6,1);
cur_st_model.Model.BodySet.objects.Body(ind_T6).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_Vertebre_T6.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_T6).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_T6).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];

% T5
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.thor5,ind_T5,1);
cur_st_model.Model.BodySet.objects.Body(ind_T5).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_Vertebre_T5.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_T5).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_T5).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];

% T4
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.thor4,ind_T4,1);
cur_st_model.Model.BodySet.objects.Body(ind_T4).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_Vertebre_T4.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_T4).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_T4).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];

% T3
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.thor3,ind_T3,1);
cur_st_model.Model.BodySet.objects.Body(ind_T3).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_Vertebre_T3.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_T3).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_T3).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];

% T2
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.thor2,ind_T2,1);
cur_st_model.Model.BodySet.objects.Body(ind_T2).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_Vertebre_T2.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_T2).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_T2).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];

% T1
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.thor1,ind_T1,1);
cur_st_model.Model.BodySet.objects.Body(ind_T1).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_Vertebre_T1.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_T1).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_T1).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];

% C7
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.cerv7,ind_C7,1);
cur_st_model.Model.BodySet.objects.Body(ind_C7).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_Vertebre_C7.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_C7).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_C7).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];

% C6
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.cerv6,ind_C6,1);
cur_st_model.Model.BodySet.objects.Body(ind_C6).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_Vertebre_C6.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_C6).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_C6).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];

% C5
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.cerv5,ind_C5,1);
cur_st_model.Model.BodySet.objects.Body(ind_C5).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_Vertebre_C5.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_C5).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_C5).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];

% C4
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.cerv4,ind_C4,1);
cur_st_model.Model.BodySet.objects.Body(ind_C4).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_Vertebre_C4.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_C4).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_C4).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];

% C3
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.cerv3,ind_C3,1);
cur_st_model.Model.BodySet.objects.Body(ind_C3).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_Vertebre_C3.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_C3).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_C3).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];
 

%% Repartition des rotations inter-vertebrales
% Definition des range pour les vertebres lombaire, thoraciques puis cervicales
cur_st_model.Model.BodySet.objects.Body(ind_L5).Joint.CustomJoint.CoordinateSet.objects.Coordinate(1).range=[-0.78 0.78]; %FE
cur_st_model.Model.BodySet.objects.Body(ind_L5).Joint.CustomJoint.CoordinateSet.objects.Coordinate(2).range=[-0.349066 0.349066]; %LB
cur_st_model.Model.BodySet.objects.Body(ind_L5).Joint.CustomJoint.CoordinateSet.objects.Coordinate(3).range=[-0.2181662 0.2181662]; %AR

cur_st_model.Model.BodySet.objects.Body(ind_T12).Joint.CustomJoint.CoordinateSet.objects.Coordinate(1).range=[-0.523599 0.698132]; %FE
cur_st_model.Model.BodySet.objects.Body(ind_T12).Joint.CustomJoint.CoordinateSet.objects.Coordinate(2).range=[-0.523599 0.523599]; %LB
cur_st_model.Model.BodySet.objects.Body(ind_T12).Joint.CustomJoint.CoordinateSet.objects.Coordinate(3).range=[-0.523599 0.523599]; %AR

cur_st_model.Model.BodySet.objects.Body(ind_C7).Joint.CustomJoint.CoordinateSet.objects.Coordinate(1).range=[-1.22173 1.39626]; %FE
cur_st_model.Model.BodySet.objects.Body(ind_C7).Joint.CustomJoint.CoordinateSet.objects.Coordinate(2).range=[-0.349066 0.349066]; %LB
cur_st_model.Model.BodySet.objects.Body(ind_C7).Joint.CustomJoint.CoordinateSet.objects.Coordinate(3).range=[-0.872665 0.872665]; %AR
    
%Repartition de la rotation dans les vertebres thoraciques
%Flexion Extension
cur_st_model.Model.BodySet.objects.Body(ind_T12).Joint.CustomJoint.SpatialTransform.TransformAxis(1).xfunction.LinearXfunction.coefficients=[0.0674 0]; %T12_L1_FE
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(32).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0674 0]; %T11_T12_FE
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(33).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0674 0]; %T10_T11_FE
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(34).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0494 0]; %T9_T10_FE
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(35).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0412 0]; %T8_T9_FE
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(36).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0387 0]; %T7_T8_FE
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(37).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0383 0]; %T6_T7_FE
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(38).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0350 0]; %T5_T6_FE
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(39).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0461 0]; %T4_T5_FE
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(40).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0529 0]; %T3_T4_FE
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(41).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.1372 0]; %T2_T3_FE
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(42).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.3592 0]; %T1_T2_FE
%Lateral Bending
cur_st_model.Model.BodySet.objects.Body(ind_T12).Joint.CustomJoint.SpatialTransform.TransformAxis(2).xfunction.LinearXfunction.coefficients=[0.0674 0]; %T12_L1_LB
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(43).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0674 0]; %T11_T12_LB
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(44).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0674 0]; %T10_T11_LB
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(45).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0494 0]; %T9_T10_LB
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(46).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0412 0]; %T8_T9_LB
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(47).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0387 0]; %T7_T8_LB
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(48).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0383 0]; %T6_T7_LB
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(49).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0350 0]; %T5_T6_LB
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(50).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0461 0]; %T4_T5_LB
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(51).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0529 0]; %T3_T4_LB
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(52).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.1372 0]; %T2_T3_LB
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(53).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.3592 0]; %T1_T2_LB
%Axial Rotation
cur_st_model.Model.BodySet.objects.Body(ind_T12).Joint.CustomJoint.SpatialTransform.TransformAxis(3).xfunction.LinearXfunction.coefficients=[0.0349 0]; %T12_L1_AR
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(54).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0419 0]; %T11_T12_AR
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(55).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0503 0]; %T10_T11_AR
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(56).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0461 0]; %T9_T10_AR
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(57).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0512 0]; %T8_T9_AR
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(58).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0665 0]; %T7_T8_AR
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(59).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0645 0]; %T6_T7_AR
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(60).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0599 0]; %T5_T6_AR
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(61).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0806 0]; %T4_T5_AR
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(62).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0926 0]; %T3_T4_AR
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(63).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.1600 0]; %T2_T3_AR
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(64).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.2515 0]; %T1_T2_AR

%Vertebres cervicales (Model upper body Master 2017)
%Flexion-Extension
cur_st_model.Model.BodySet.objects.Body(ind_C7).Joint.CustomJoint.SpatialTransform.TransformAxis(1).xfunction.LinearXfunction.coefficients=[0.0989 0]; %T1_C7_FE
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(3).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.1868 0]; %C7_C6_FE
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(6).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.2198 0]; %C6_C5_FE
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(9).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.2198 0]; %C5_C4_FE
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(12).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.1648 0]; %C4_C3_FE
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(15).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.1099 0]; %C3_C2_FE
%Lateral Bending
cur_st_model.Model.BodySet.objects.Body(ind_C7).Joint.CustomJoint.SpatialTransform.TransformAxis(2).xfunction.LinearXfunction.coefficients=[0.0767 0]; %T1_C7_LB
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(2).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.1849 0]; %C7_C6_LB
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(5).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.2153 0]; %C6_C5_LB
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(8).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.2153 0]; %C5_C4_LB
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(11).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.2153 0]; %C4_C3_LB
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(14).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.0924 0]; %C3_C2_LB
%Axial Rotation
cur_st_model.Model.BodySet.objects.Body(ind_C7).Joint.CustomJoint.SpatialTransform.TransformAxis(3).xfunction.LinearXfunction.coefficients=[0.0640 0]; %T1_C7_AR
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(1).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.1391 0]; %C7_C6_AR
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(4).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.1594 0]; %C6_C5_AR
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(7).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.2193 0]; %C5_C4_AR
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(10).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.2193 0]; %C4_C3_AR
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(13).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.1990 0]; %C3_C2_AR

% Vertebres Lombaires  (A Musculoskeletal model for the lumbar spine, M. Christophy)
%Flexion-Extension
cur_st_model.Model.BodySet.objects.Body(ind_L5).Joint.CustomJoint.SpatialTransform.TransformAxis(1).xfunction.LinearXfunction.coefficients=[0.125 0]; %L5_S1_FE
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(17).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.185 0]; %L4_L5_FE
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(20).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.204 0]; %L3_L4_FE
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(23).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.231 0]; %L2_L3_FE
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(26).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.255 0]; %L1_L2_FE
%Lateral Bending
cur_st_model.Model.BodySet.objects.Body(ind_L5).Joint.CustomJoint.SpatialTransform.TransformAxis(2).xfunction.LinearXfunction.coefficients=[0.1356 0]; %L5_S1_LB
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(19).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.1812 0]; %L4_L5_LB
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(22).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.2452 0]; %L3_L4_LB
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(25).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.25 0]; %L2_L3_LB
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(28).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.188 0]; %L1_L2_LB
%Axial Rotation
cur_st_model.Model.BodySet.objects.Body(ind_L5).Joint.CustomJoint.SpatialTransform.TransformAxis(3).xfunction.LinearXfunction.coefficients=[0.207793847184211 0]; %L5_S1_AR
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(18).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.220779501600999 0]; %L4_L5_AR
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(21).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.220779501600999 0]; %L3_L4_AR
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(24).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.181816694221734 0]; %L2_L3_AR
cur_st_model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(27).coupled_coordinates_xfunction.LinearXfunction.coefficients=[0.168830455 0]; %L1_L2_AR


%% Placement des Center Of Mass vertèbres
%On place les COM par rapport au joint center d'après Vette et al. 2010
%Attention, dans la littérature les COM sont exprimés dans le repère "global"

cur_st_model.Model.BodySet.objects.Body(ind_L5).mass_center=round(cur_st_model.Model.BodySet.objects.Body(ind_L5).Joint.CustomJoint.location' + points.COM_L5_RL5'/1000,4); % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_L4).mass_center=round(cur_st_model.Model.BodySet.objects.Body(ind_L4).Joint.CustomJoint.location' + points.COM_L4_RL4'/1000,4);
cur_st_model.Model.BodySet.objects.Body(ind_L3).mass_center=round(cur_st_model.Model.BodySet.objects.Body(ind_L3).Joint.CustomJoint.location' + points.COM_L3_RL3'/1000,4);
cur_st_model.Model.BodySet.objects.Body(ind_L2).mass_center=round(cur_st_model.Model.BodySet.objects.Body(ind_L2).Joint.CustomJoint.location' + points.COM_L2_RL2'/1000,4);
cur_st_model.Model.BodySet.objects.Body(ind_L1).mass_center=round(cur_st_model.Model.BodySet.objects.Body(ind_L1).Joint.CustomJoint.location' + points.COM_L1_RL1'/1000,4);
cur_st_model.Model.BodySet.objects.Body(ind_T12).mass_center=round(cur_st_model.Model.BodySet.objects.Body(ind_T12).Joint.CustomJoint.location' + points.COM_T12_RT12'/1000,4);
cur_st_model.Model.BodySet.objects.Body(ind_T11).mass_center=round(cur_st_model.Model.BodySet.objects.Body(ind_T11).Joint.CustomJoint.location' + points.COM_T11_RT11'/1000,4);
cur_st_model.Model.BodySet.objects.Body(ind_T10).mass_center=round(cur_st_model.Model.BodySet.objects.Body(ind_T10).Joint.CustomJoint.location' + points.COM_T10_RT10'/1000,4);
cur_st_model.Model.BodySet.objects.Body(ind_T9).mass_center=round(cur_st_model.Model.BodySet.objects.Body(ind_T9).Joint.CustomJoint.location' + points.COM_T9_RT9'/1000,4);
cur_st_model.Model.BodySet.objects.Body(ind_T8).mass_center=round(cur_st_model.Model.BodySet.objects.Body(ind_T8).Joint.CustomJoint.location' + points.COM_T8_RT8'/1000,4);
cur_st_model.Model.BodySet.objects.Body(ind_T7).mass_center=round(cur_st_model.Model.BodySet.objects.Body(ind_T7).Joint.CustomJoint.location' + points.COM_T7_RT7'/1000,4);
cur_st_model.Model.BodySet.objects.Body(ind_T6).mass_center=round(cur_st_model.Model.BodySet.objects.Body(ind_T6).Joint.CustomJoint.location' + points.COM_T6_RT6'/1000,4);
cur_st_model.Model.BodySet.objects.Body(ind_T5).mass_center=round(cur_st_model.Model.BodySet.objects.Body(ind_T5).Joint.CustomJoint.location' + points.COM_T5_RT5'/1000,4);
cur_st_model.Model.BodySet.objects.Body(ind_T4).mass_center=round(cur_st_model.Model.BodySet.objects.Body(ind_T4).Joint.CustomJoint.location' + points.COM_T4_RT4'/1000,4);
cur_st_model.Model.BodySet.objects.Body(ind_T3).mass_center=round(cur_st_model.Model.BodySet.objects.Body(ind_T3).Joint.CustomJoint.location' + points.COM_T3_RT3'/1000,4);
cur_st_model.Model.BodySet.objects.Body(ind_T2).mass_center=round(cur_st_model.Model.BodySet.objects.Body(ind_T2).Joint.CustomJoint.location' + points.COM_T2_RT2'/1000,4);
cur_st_model.Model.BodySet.objects.Body(ind_T1).mass_center=round(cur_st_model.Model.BodySet.objects.Body(ind_T1).Joint.CustomJoint.location' + points.COM_T1_RT1'/1000,4);
cur_st_model.Model.BodySet.objects.Body(ind_C7).mass_center=round(cur_st_model.Model.BodySet.objects.Body(ind_C7).Joint.CustomJoint.location' + points.COM_C7_RC7'/1000,4);
cur_st_model.Model.BodySet.objects.Body(ind_C6).mass_center=round(cur_st_model.Model.BodySet.objects.Body(ind_C6).Joint.CustomJoint.location' + points.COM_C6_RC6'/1000,4);
cur_st_model.Model.BodySet.objects.Body(ind_C5).mass_center=round(cur_st_model.Model.BodySet.objects.Body(ind_C5).Joint.CustomJoint.location' + points.COM_C5_RC5'/1000,4);
cur_st_model.Model.BodySet.objects.Body(ind_C4).mass_center=round(cur_st_model.Model.BodySet.objects.Body(ind_C4).Joint.CustomJoint.location' + points.COM_C4_RC4'/1000,4);
cur_st_model.Model.BodySet.objects.Body(ind_C3).mass_center=round(cur_st_model.Model.BodySet.objects.Body(ind_C3).Joint.CustomJoint.location' + points.COM_C3_RC3'/1000,4);
ind_C2=strcmp(bodies_name,'cerv2');
cur_st_model.Model.BodySet.objects.Body(ind_C2).mass_center=round(cur_st_model.Model.BodySet.objects.Body(ind_C2).Joint.CustomJoint.location' + [5.38 10.257 0]/1000,4);
ind_C1=strcmp(bodies_name,'cerv1');
ind_skull=strcmp(bodies_name,'skull');
cur_st_model.Model.BodySet.objects.Body(ind_skull).mass_center=round(cur_st_model.Model.BodySet.objects.Body(ind_skull).Joint.CustomJoint.location' ...
    + cur_st_model.Model.BodySet.objects.Body(ind_C1).Joint.CustomJoint.location' + [-0.09 70.718 0]/1000,4); %Skull+jaw+C1

%% On "redresse" les inerties attribuées à chaque segment vertèbral 
% Puisqu'elles sont issues de la littérature et calculées pour des segments
% horizontaux et que dans notre modèle les repères vertèbres sont penchés.

%Il faut calculer la matrice de passage pour chaque vertèbre
angles_vertebres = [angles_thor_EOS;angles_lomb_EOS]; %rotation des vertebres les une par rapport aux autres de T1 à L5
Inertia_Rground=zeros(3);
list_ind=[ind_T1,ind_T2,ind_T3,ind_T4,ind_T5,ind_T6,ind_T7,ind_T8,ind_T9,ind_T10,ind_T11,ind_T12,ind_L1,ind_L2,ind_L3,ind_L4,ind_L5];
for i=1:length(angles_vertebres)
    %On va chercher la valeur de base
    Inertia_Rground(1,1)=cur_st_model.Model.BodySet.objects.Body(list_ind(:,i)).inertia_xx;
    Inertia_Rground(2,2)=cur_st_model.Model.BodySet.objects.Body(list_ind(:,i)).inertia_yy;
    Inertia_Rground(3,3)=cur_st_model.Model.BodySet.objects.Body(list_ind(:,i)).inertia_zz;
    xyz_tmp=sum(angles_vertebres(end+1-i:end,:),1);
    %Calcul de la matrice de passage
    [Rx,Ry,Rz]=Rotations2Matrix_xyz(xyz_tmp(1),xyz_tmp(2),xyz_tmp(3));
    Mrot=Rx*Ry*Rz;
    %Calcule de la nouvelle inertie
    Inertia_Rvertebre=(Mrot\Inertia_Rground)*Mrot;
    %On assigne la nouvelle valeur
    cur_st_model.Model.BodySet.objects.Body(list_ind(:,i)).inertia_xx=Inertia_Rvertebre(1,1);
    cur_st_model.Model.BodySet.objects.Body(list_ind(:,i)).inertia_yy=Inertia_Rvertebre(2,2);
    cur_st_model.Model.BodySet.objects.Body(list_ind(:,i)).inertia_zz=Inertia_Rvertebre(3,3);
end

%% Modifications des marqueurs anatomiques pour les passer dans les nouveaux repères segments
st_marqueur=gestion_billes_EOS_YP(rep_wrl,dir_regions,protocol,'F');
list_mrk_a_changer=fieldnames(st_marqueur);
list_mrk_model=extract_mrkName_modelOS(cur_st_model);
for i_mrk=1:size(list_mrk_a_changer,1)
    cur_mrk=list_mrk_a_changer{i_mrk};
    if isfield(st_marqueur,cur_mrk)
        ind_cur_mrk_model=strcmp(cur_mrk,list_mrk_model);
        cur_st_model.Model.MarkerSet.objects.Marker(ind_cur_mrk_model).location=st_marqueur.(cur_mrk)';
    end
end


%% Changement de nom du model
cur_st_model.Model.ATTRIBUTE.name=[cur_sujet '_scaled_EOS'];

%% Creation d'un static.mot pour le model perso EOS
myosim_Matlab_name=fullfile(rep_global,cur_sujet,'modele',[cur_sujet,'_perso_EOS.osim']);
xml_writeOSIM_TJ(myosim_Matlab_name,cur_st_model,'OpenSimDocument');

[~,nom_fichier_statique]=PathContent_Type(rep_sortie_model,'trc');
[~,nom_source_trc,~]=fileparts(char(fullfile(rep_sortie_model,nom_fichier_statique)));
plugin_STJ = protocol.PARAMETRES_OPENSIM.plugin_STJ{1} ;

xmlfile = fullfile(rep_sortie_model, [nom_source_trc, '_scaling_1_setup.xml']);
OpenSimDocument = xml_readOSIM_TJ(xmlfile);
OpenSimDocument.ScaleTool.ModelScaler.apply='false';
OpenSimDocument.ScaleTool.GenericModelMaker.model_file=[cur_sujet,'_perso_EOS.osim'];
OpenSimDocument.ScaleTool.MarkerPlacer.output_motion_file=[cur_sujet, '_motion_perso_EOS.mot'];
OpenSimDocument.ScaleTool.MarkerPlacer.output_model_file='useless1.osim';
OpenSimDocument.ScaleTool.MarkerPlacer.output_marker_file=('useless2.osim');
xml_writeOSIM_TJ(fullfile(rep_sortie_model, [nom_source_trc, '_scaling_setup-EOS.xml']),OpenSimDocument);

com = ['scale -S ' fullfile(rep_sortie_model, [nom_source_trc, '_scaling_setup-EOS.xml']) ' -L ' plugin_STJ];
system(com);

end