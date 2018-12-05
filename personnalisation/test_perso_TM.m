function cur_st_model=test_perso_TM(rep_global,cur_sujet,cur_st_model,protocol,perso_cheville)

model_scale_init=cur_st_model;
%% Déclaration des dossiers
dir_regions=fullfile(rep_global,'info_global','DDR');
rep_wrl=fullfile(rep_global,cur_sujet,'fichiers_wrl');
rep_wrl_os_corps_complet=fullfile(rep_wrl,'os','os_corps_complet');
rep_geometry=fullfile(rep_global,cur_sujet,'modele','Geometry');
rep_billes=fullfile(rep_wrl,'billes');

%% Transfert des fichiers wrl vers stl
% On les transfère dans le dossier Geometry
transfert_fichier_wrl_stl(rep_wrl_os_corps_complet,cur_sujet,rep_geometry)

%% Extraction zones d'interet
[reperes,points]=extraction_reperes_joint_center_EOS_Minf(dir_regions,rep_wrl_os_corps_complet);
[bodies]=extract_KinChainData_ModelOS(cur_st_model);
bodies_name=fieldnames(bodies);
ind_sacrum=strcmp(bodies_name,'sacrum');

%% On remplace les location et location in parent dans le modèle
% L5
ind_L5=strcmp(bodies_name,'lumbar5');
if ~isempty(find(ind_L5,1))
    cur_st_model.Model.BodySet.objects.Body(ind_L5).Joint.CustomJoint.parent_body='pelvis';
    cur_st_model.Model.BodySet.objects.Body(ind_L5).Joint.CustomJoint.location_in_parent=round(points.PS_Rb/1000,4)';
end
% Hanche droite ==> Femur droit
ind_femur_r=strcmp(bodies_name,'femur_r');
cur_st_model.Model.BodySet.objects.Body(ind_femur_r).Joint.CustomJoint.location_in_parent=round(points.HJC_D_Rb/1000,4)'; % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_femur_r).Joint.CustomJoint.location=round(points.HJC_D_RfD/1000,4)';
% Hanche gauche ==> Femur gauche
ind_femur_l=strcmp(bodies_name,'femur_l');
cur_st_model.Model.BodySet.objects.Body(ind_femur_l).Joint.CustomJoint.location_in_parent=round(points.HJC_G_Rb/1000,4)'; % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_femur_l).Joint.CustomJoint.location=round(points.HJC_G_RfG/1000,4)';
% Genou droit ==> Tibia droit
ind_tibia_r=strcmp(bodies_name,'tibia_r');
cur_st_model.Model.BodySet.objects.Body(ind_tibia_r).Joint.CustomJoint.location_in_parent=round(points.KJC_D_RfD/1000,4)'; % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_tibia_r).Joint.CustomJoint.location=round(points.KJC_D_RtD/1000,4)';
% % Genou gauche ==> Tibia gauche
ind_tibia_l=strcmp(bodies_name,'tibia_l');
cur_st_model.Model.BodySet.objects.Body(ind_tibia_l).Joint.CustomJoint.location_in_parent=round(points.KJC_G_RfG/1000,4)'; % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_tibia_l).Joint.CustomJoint.location=round(points.KJC_G_RtG/1000,4)';
% Cheville droite ==> Pied droit
ind_talus_r=strcmp(bodies_name,'talus_r');
cur_st_model.Model.BodySet.objects.Body(ind_talus_r).Joint.CustomJoint.location_in_parent=round(points.AJC_D_RtD/1000,4)'; % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_talus_r).Joint.CustomJoint.location=round(points.AJC_D_RtalusD/1000,4)'; % Conversion mm en m
% Cheville gauche ==> Pied gauche
ind_talus_l=strcmp(bodies_name,'talus_l');
cur_st_model.Model.BodySet.objects.Body(ind_talus_l).Joint.CustomJoint.location_in_parent=round(points.AJC_G_RtG/1000,4)'; % Conversion mm en m
cur_st_model.Model.BodySet.objects.Body(ind_talus_l).Joint.CustomJoint.location=round(points.AJC_G_RtalusG/1000,4)'; % Conversion mm en m

%% Modifications des géométries modèle pour le prise en compte du passage EOS ==> OS
% Bassin
ind_bassin=strcmp(bodies_name,'pelvis');
% On remplace la géométrie du bassin en 2 parties par une seule globale
% comprenant les ailes iliaques et le sacrum
cur_st_model.Model.BodySet.objects.Body(ind_bassin).VisibleObject.GeometrySet.objects.DisplayGeometry=cur_st_model.Model.BodySet.objects.Body(ind_bassin).VisibleObject.GeometrySet.objects.DisplayGeometry(1);
cur_st_model.Model.BodySet.objects.Body(ind_bassin).VisibleObject.GeometrySet.objects.SEQUENCE={'DisplayGeometry',1};
cur_st_model.Model.BodySet.objects.Body(ind_bassin).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_bassin).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_Bassin.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_bassin).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.Bassin,ind_bassin,1);

% Femur
%   Droit
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.FemurD,ind_femur_r,1);
cur_st_model.Model.BodySet.objects.Body(ind_femur_r).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_FemurD.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_femur_r).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_femur_r).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];
%   Gauche
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.FemurG,ind_femur_l,1);
cur_st_model.Model.BodySet.objects.Body(ind_femur_l).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[cur_sujet,'_FemurG.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_femur_l).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_femur_l).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];

% Tibia
%   Droit
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.TibiaD,ind_tibia_r,1);
cur_st_model.Model.BodySet.objects.Body(ind_tibia_r).VisibleObject.GeometrySet.objects.DisplayGeometry(1).geometry_file=[cur_sujet,'_TibiaD.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_tibia_r).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_tibia_r).VisibleObject.GeometrySet.objects.DisplayGeometry(1).scale_factors=[1 1 1];
%   Gauche
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.TibiaG,ind_tibia_l,1);
cur_st_model.Model.BodySet.objects.Body(ind_tibia_l).VisibleObject.GeometrySet.objects.DisplayGeometry(1).geometry_file=[cur_sujet,'_TibiaG.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_tibia_l).VisibleObject.scale_factors=[1 1 1];
cur_st_model.Model.BodySet.objects.Body(ind_tibia_l).VisibleObject.GeometrySet.objects.DisplayGeometry(1).scale_factors=[1 1 1];

% Fibula
%   Gauche
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.TibiaG,ind_tibia_l,2);
cur_st_model.Model.BodySet.objects.Body(ind_tibia_l).VisibleObject.GeometrySet.objects.DisplayGeometry(2).geometry_file=[cur_sujet,'_PeroneG.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_tibia_l).VisibleObject.GeometrySet.objects.DisplayGeometry(2).scale_factors=[1 1 1];
%   Droit
cur_st_model=modif_transform_EOS2OS(cur_st_model,reperes.TibiaD,ind_tibia_r,2);
cur_st_model.Model.BodySet.objects.Body(ind_tibia_r).VisibleObject.GeometrySet.objects.DisplayGeometry(2).geometry_file=[cur_sujet,'_PeroneD.stl'];
cur_st_model.Model.BodySet.objects.Body(ind_tibia_r).VisibleObject.GeometrySet.objects.DisplayGeometry(2).scale_factors=[1 1 1];

%% Modification des axes pour personnaliser la cheville avec deux axes de rotation indépendants.
if str2double(perso_cheville)==1
    disp('Personnalisation de la cheville')
    ind_calc_r=strcmp(bodies_name,'calcn_r');
    ind_calc_l=strcmp(bodies_name,'calcn_l');
    
    % On laisse un seul degré de liberté entre le tibia et le talus : la
    % flexion/extension de cheville en bloquant le 2eme DDL
    cur_st_model.Model.BodySet.objects.Body(ind_talus_r).Joint.CustomJoint.CoordinateSet.objects.Coordinate(2).locked='true';
    cur_st_model.Model.BodySet.objects.Body(ind_talus_l).Joint.CustomJoint.CoordinateSet.objects.Coordinate(2).locked='true';
    
    % On débloque l'articulation entre le talus et le calcaneus que l'on va
    % personnaliser par la suite
    cur_st_model.Model.BodySet.objects.Body(ind_calc_r).Joint.CustomJoint.CoordinateSet.objects.Coordinate.locked='false';
    cur_st_model.Model.BodySet.objects.Body(ind_calc_l).Joint.CustomJoint.CoordinateSet.objects.Coordinate.locked='false';
    
    % Repère cheville
    R_chevilleD=reperes.TalusD(1:3,1:3)/reperes.TibiaD(1:3,1:3);
    R_chevilleG=reperes.TalusG(1:3,1:3)/reperes.TibiaG(1:3,1:3);
    
    % Repère articulation sous-talaire   
    [angles_cheville_D(1),angles_cheville_D(2),angles_cheville_D(3)]=axe_mobile_xyz(R_chevilleD);
    [angles_cheville_G(1),angles_cheville_G(2),angles_cheville_G(3)]=axe_mobile_xyz(R_chevilleG);
    
    % On change les orientation in parent
    %   Talus
    cur_st_model.Model.BodySet.objects.Body(ind_talus_r).Joint.CustomJoint.orientation_in_parent=angles_cheville_D*pi/180;
    cur_st_model.Model.BodySet.objects.Body(ind_talus_l).Joint.CustomJoint.orientation_in_parent=angles_cheville_G*pi/180;
    
end
%% Modification de l'articulation du genou
% A faire : personnalisation avec les condyles

Bx=[-2.0944 -1.2217 -0.5236 -0.3491 -0.1745 0.1591 2.0944];
By =[-0.0133 0.0011 0.0103 0.0117 0.0127 0.0140 0.0133];
cur_st_model.Model.BodySet.objects.Body(ind_tibia_r).Joint.CustomJoint.SpatialTransform.TransformAxis(4).xfunction.MultiplierXfunction.xfunction.SimmSpline.x=Bx;
cur_st_model.Model.BodySet.objects.Body(ind_tibia_r).Joint.CustomJoint.SpatialTransform.TransformAxis(4).xfunction.MultiplierXfunction.xfunction.SimmSpline.y=By;
cur_st_model.Model.BodySet.objects.Body(ind_tibia_r).Joint.CustomJoint.SpatialTransform.TransformAxis(4).xfunction.MultiplierXfunction.scale=1;

cur_st_model.Model.BodySet.objects.Body(ind_tibia_l).Joint.CustomJoint.SpatialTransform.TransformAxis(4).xfunction.MultiplierXfunction.xfunction.SimmSpline.x=Bx;
cur_st_model.Model.BodySet.objects.Body(ind_tibia_l).Joint.CustomJoint.SpatialTransform.TransformAxis(4).xfunction.MultiplierXfunction.xfunction.SimmSpline.y=By;
cur_st_model.Model.BodySet.objects.Body(ind_tibia_l).Joint.CustomJoint.SpatialTransform.TransformAxis(4).xfunction.MultiplierXfunction.scale=1;

BBy=[-0.0032 0.0018 0.0041 0.0041 0.0021 -0.0010 -0.0031 -0.0052 -0.0054 -0.0056 -0.0054 -0.0053];
BBx=[-2.0944 -1.74533 -1.39626 -1.0472 -0.698132 -0.349066 -0.174533 0.197344 0.337395 0.490178 1.52146 2.0944];
cur_st_model.Model.BodySet.objects.Body(ind_tibia_r).Joint.CustomJoint.SpatialTransform.TransformAxis(5).xfunction.MultiplierXfunction.xfunction.SimmSpline.x=BBx;
cur_st_model.Model.BodySet.objects.Body(ind_tibia_r).Joint.CustomJoint.SpatialTransform.TransformAxis(5).xfunction.MultiplierXfunction.xfunction.SimmSpline.y=BBy;
cur_st_model.Model.BodySet.objects.Body(ind_tibia_r).Joint.CustomJoint.SpatialTransform.TransformAxis(5).xfunction.MultiplierXfunction.scale=1;

cur_st_model.Model.BodySet.objects.Body(ind_tibia_l).Joint.CustomJoint.SpatialTransform.TransformAxis(5).xfunction.MultiplierXfunction.xfunction.SimmSpline.x=BBx;
cur_st_model.Model.BodySet.objects.Body(ind_tibia_l).Joint.CustomJoint.SpatialTransform.TransformAxis(5).xfunction.MultiplierXfunction.xfunction.SimmSpline.y=BBy;
cur_st_model.Model.BodySet.objects.Body(ind_tibia_l).Joint.CustomJoint.SpatialTransform.TransformAxis(5).xfunction.MultiplierXfunction.scale=1;

cur_st_model.Model.BodySet.objects.Body(ind_tibia_r).Joint.CustomJoint.SpatialTransform.TransformAxis(6).xfunction.MultiplierXfunction.scale=1;
cur_st_model.Model.BodySet.objects.Body(ind_tibia_l).Joint.CustomJoint.SpatialTransform.TransformAxis(6).xfunction.MultiplierXfunction.scale=1;

%% Modifications des marqueurs pour les passer dans les repères des nouveaux segments
st_marqueur=calcul_pos_billes_EOS(rep_billes,reperes,protocol,dir_regions,rep_wrl,points);
list_mrk_a_changer=fieldnames(st_marqueur);
list_mrk_model=extract_mrkName_modelOS(cur_st_model);
for i_mrk=1:size(list_mrk_a_changer,1)
    cur_mrk=list_mrk_a_changer{i_mrk};
    if isfield(st_marqueur,cur_mrk)
        ind_cur_mrk_model=strcmp(cur_mrk,list_mrk_model);
        cur_st_model.Model.MarkerSet.objects.Marker(ind_cur_mrk_model).location=st_marqueur.(cur_mrk)';
    end
end
% % st_marqueur=gestion_billes_EOS2(rep_billes,dir_regions,protocol,'M');
% list_mrk_a_changer=fieldnames(st_marqueur);
% % list_mrk_a_changer={'EASG','EPSG','EPSD','EASD','CLD','CMD','CLG','CMG','MLG','MMG','MLD','MMD'}';
% list_mrk_model=extract_mrkName_modelOS(cur_st_model);
% for i_mrk=1:size(list_mrk_a_changer,1)
%     cur_mrk=list_mrk_a_changer{i_mrk};
%     if isfield(st_marqueur,cur_mrk)
%         ind_cur_mrk_model=strcmp(cur_mrk,list_mrk_model);
%         cur_st_model.Model.MarkerSet.objects.Marker(ind_cur_mrk_model).location=st_marqueur.(cur_mrk)';
%     end
% end
%% Personnalisation des muscles
perso_muscles_EOS(cur_st_model,rep_wrl,model_scale_init);
%% On supprime la ligne du sacrum car il est intégré au wrl du bassin
cur_st_model.Model.BodySet.objects.Body(ind_sacrum)=[];
if isfield(cur_st_model.Model.BodySet.objects,'SEQUENCE')
    cur_st_model.Model.BodySet.objects.SEQUENCE(end,:)=[];
end
end