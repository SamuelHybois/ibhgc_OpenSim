%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Investigations ellipsoïde à partir de l'essai de ScapLoc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nom_sujet = 'SP01SM' ;
[tree, ~, ~] = xml_readOSIM_TJ('E:\MusculoSkeletalModelling\ModeleScapula\abstract3DAHM\traitementOpenSim\SP01SM\modele\SP01SM_model_final.osim') ;
geometrypath = 'E:\MusculoSkeletalModelling\ModeleScapula\abstract3DAHM\traitementOpenSim\SP01SM\modele\Geometry';
myc3d_path = 'E:\MusculoSkeletalModelling\ModeleScapula\SP01SM\Scapula_locator_D\SP01SM_Propulsion_roue_reculee_03.c3d' ;
my_c3d = btk_loadc3d(myc3d_path) ;
[my_c3d] = NettoieMarkerLabels(my_c3d.marker_data.Markers);
dist_SL = 0.09 ; %distance entre les palpeurs/marqueurs du SL
nFrames = size(my_c3d.SCLM,1) ;

%% Création du repère Thorax_Vicon
P_R_Vicon_R_thorax(4,4,nFrames) = 0 ;
SCLM_RVicon(nFrames,3)=0 ;
SCLB_RVicon(nFrames,3)=0 ;
SCLL_RVicon(nFrames,3)=0 ;
ACD_RVicon(nFrames,3)=0 ;
MAN_RVicon(nFrames,3)=0 ;

for i_time = 1:nFrames
    
    SCLM_i_frame = my_c3d.SCLM(i_time,:)./1000 ;
    SCLB_i_frame = my_c3d.SCLB(i_time,:)./1000 ;
    SCLL_i_frame = my_c3d.SCLL(i_time,:)./1000 ;
    
    SCLHM_i_frame = my_c3d.SCLHM(i_time,:)./1000 ;
    SCLHL_i_frame = my_c3d.SCLHL(i_time,:)./1000 ;
    
    
    % Recalage vertical ScapLoc
    u1 = (SCLHM_i_frame - SCLB_i_frame)./norm(SCLHM_i_frame - SCLB_i_frame);
    u2 = (SCLHL_i_frame - SCLB_i_frame)./norm(SCLHL_i_frame - SCLB_i_frame);
    normale_plan_ScapLoc = cross(u1,u2)./norm(cross(u1,u2));
    
    SCLM_RVicon(i_time,:) = SCLM_i_frame + dist_SL.*normale_plan_ScapLoc ;
    SCLB_RVicon(i_time,:) = SCLB_i_frame + dist_SL.*normale_plan_ScapLoc ;
    SCLL_RVicon(i_time,:) = SCLL_i_frame + dist_SL.*normale_plan_ScapLoc ;
    MAN = my_c3d.MAN(i_time,:)./1000 ;
    MAN_RVicon(i_time,:) = MAN ;
    XYP = my_c3d.XYP(i_time,:)./1000 ;
    ACD = my_c3d.ACD(i_time,:)./1000 ;
    ACD_RVicon(i_time,:) = ACD ;
    
    Y_1_RthoraxVicon = (MAN - XYP)./norm(MAN - XYP);
    Z_01_RthoraxVicon = (ACD - MAN)./norm(ACD - MAN);
    X_1_RthoraxVicon = cross(Y_1_RthoraxVicon,Z_01_RthoraxVicon)./norm(cross(Y_1_RthoraxVicon,Z_01_RthoraxVicon));
    Z_1_RthoraxVicon = cross(X_1_RthoraxVicon,Y_1_RthoraxVicon)./norm(cross(X_1_RthoraxVicon,Y_1_RthoraxVicon));
    
    P_R_Vicon_R_thorax(:,:,i_time) = [[X_1_RthoraxVicon' , Y_1_RthoraxVicon', Z_1_RthoraxVicon' , MAN'] ; [0 0 0 1] ] ;
end

SCLM_Rthorax(nFrames,3)=0;
SCLB_Rthorax(nFrames,3)=0;
SCLL_Rthorax(nFrames,3)=0;
ACD_Rthorax(nFrames,3)=0;
MAN_Rthorax(nFrames,3)=0;

% Transport des coordonnées dans Rthorax
for i_time = 1:nFrames
    SCLM_Rthorax_tmp = P_R_Vicon_R_thorax(:,:,i_time)\[SCLM_RVicon(i_time,:), 1]' ;
    SCLM_Rthorax(i_time,:) = SCLM_Rthorax_tmp(1:3);
    SCLB_Rthorax_tmp= P_R_Vicon_R_thorax(:,:,i_time)\[SCLB_RVicon(i_time,:), 1]' ;
    SCLB_Rthorax(i_time,:) = SCLB_Rthorax_tmp(1:3) ;
    SCLL_Rthorax_tmp = P_R_Vicon_R_thorax(:,:,i_time)\[SCLL_RVicon(i_time,:), 1]' ;
    SCLL_Rthorax(i_time,:) =SCLL_Rthorax_tmp(1:3) ;
    ACD_Rthorax_tmp = P_R_Vicon_R_thorax(:,:,i_time)\[ACD_RVicon(i_time,:), 1]' ;
    ACD_Rthorax(i_time,:) = ACD_Rthorax_tmp(1:3);
    MAN_Rthorax_tmp = P_R_Vicon_R_thorax(:,:,i_time)\[MAN_RVicon(i_time,:), 1]' ;
    MAN_Rthorax(i_time,:) = MAN_Rthorax_tmp(1:3);
end

%% Afficher le body thorax
[Bodies,~]=extract_KinChainData_ModelOS(tree);
List_bodies = fieldnames(Bodies);
nb_bodies=length(List_bodies);
figure('Name','Squelette','NumberTitle','off')
for i_body =1:nb_bodies
    
    Name_Body = List_bodies{i_body};
    %     if ~isempty( tree.Model.BodySet.objects.Body(i_body).Joint)
    %         draw_frame(Struct_MH.(Name_Body).MH(:,:,frame),0.1,0); % Affiche les repères associés à chaque segment
    %     end
    
    if sum(strcmp(Name_Body,{'thorax'}))==1
        if ~isempty(find(strcmp(fieldnames(tree.Model.BodySet.objects.Body(i_body).VisibleObject),'GeometrySet')==1,1))
            files_geometry = tree.Model.BodySet.objects.Body(i_body).VisibleObject.GeometrySet.objects.DisplayGeometry;
            
            nb_objets = size(char(files_geometry.geometry_file),1);
            Files_list = char(files_geometry.geometry_file);
            
            for i_objet = 1 : nb_objets
                filename_objet = fullfile(geometrypath,Files_list(i_objet,:));
                [~,~,Recup_extension] = fileparts(filename_objet);
                
                ME=[];
                try
                    if strcmp(cellstr(Recup_extension),'.vtp')==1
                        obj = lire_fichier_vtp(filename_objet);
                    elseif strcmp(cellstr(Recup_extension),'.stl')==1
                        obj = stlread(filename_objet); %  problem stlread
                    elseif strcmp(cellstr(Recup_extension),'.wrl')==1
                        obj = lire_fichier_vrml(filename_objet) ;
                    end
                catch
                    ME=1;
                    disp('probleme de lecture de fichier de geometrie')
                end
                
                if isempty(ME)
                    if ~isempty(find(strcmp(fieldnames(tree.Model.BodySet.objects.Body(i_body).VisibleObject),'transform')==1,1))
                        Transform_segment = tree.Model.BodySet.objects.Body(i_body).VisibleObject.transform;
                    else
                        Transform_segment = [0 0 0 0 0 0];
                    end
                    Scale_segment = tree.Model.BodySet.objects.Body(i_body).VisibleObject.scale_factors;
                    Transform = files_geometry(i_objet).transform;
                    Scale_vtp = files_geometry(i_objet).scale_factors;
                    
                    
                    % on applique la transformation aux noeuds
                    Orientation = eye(3,3) ;
                    
                    Translation = Orientation * Transform(4:6)';
                    MH = [Orientation, Translation; 0,0,0,1];
                    
                    % Appliquer scaling du vtp puis Transform du vtp
                    % on applique le facteur d'échelle
                    
                    obj.Noeuds = obj.Noeuds .* repmat(Scale_vtp,[size(obj.Noeuds,1),1]);
                    
                    Noeuds_coordHomogene = MH * [obj.Noeuds,ones(size(obj.Noeuds,1),1)]';
                    obj.Noeuds = Noeuds_coordHomogene(1:3,:)';
                    
                    
                    obj.Polygones = obj.Polygones+1;
                    
                    % afficher l'objet
                    
                    affiche_objet_movie(obj,'axe',gca,'alpha',0.9);
                    hold on
                else
                    disp(filename_objet);
                end
            end
        end
        
    else if sum(strcmp(Name_Body,{'scapula_r'}))==1
            
            dim_ellipsoid = tree.Model.BodySet.objects.Body(i_body).Joint.ScapulothoracicJoint.thoracic_ellipsoid_radii_x_y_z ;
            loc_ellipsoid = tree.Model.BodySet.objects.Body(i_body).Joint.ScapulothoracicJoint.location_in_parent ;
            orientation_ellipsoid = tree.Model.BodySet.objects.Body(i_body).Joint.ScapulothoracicJoint.orientation_in_parent ;
            
        end
        
    end
end

hold on

[x_ell,y_ell,z_ell] = ellipsoid(loc_ellipsoid(1),loc_ellipsoid(2),loc_ellipsoid(3),...
    dim_ellipsoid(1),dim_ellipsoid(2),dim_ellipsoid(3)) ;
hSurface = surf(x_ell,y_ell,z_ell);
alpha 0.5

angle_rot = norm(orientation_ellipsoid) ;
U = eye(3,3) ;

t_debut = 397 ;
t_fin = 555 ;

d_SCLM(t_fin-t_debut+1) = 0 ;
d_SCLL(t_fin-t_debut+1) = 0 ;
d_SCLB(t_fin-t_debut+1) = 0 ;
i_t = 0 ;
for i_time = [t_debut:1:t_fin]
    
    i_t = i_t + 1 ;
    
    scatter3(SCLM_Rthorax(i_time,1),SCLM_Rthorax(i_time,2),SCLM_Rthorax(i_time,3),'k') ;
    scatter3(SCLB_Rthorax(i_time,1),SCLB_Rthorax(i_time,2),SCLB_Rthorax(i_time,3),'b') ;
    scatter3(SCLL_Rthorax(i_time,1),SCLL_Rthorax(i_time,2),SCLL_Rthorax(i_time,3),'r') ;
    scatter3(MAN_Rthorax(i_time,1),MAN_Rthorax(i_time,2),MAN_Rthorax(i_time,3),'k') ;
    scatter3(ACD_Rthorax(i_time,1),ACD_Rthorax(i_time,2),ACD_Rthorax(i_time,3),'g') ;

% SCL médial
xProj_SCLM = EllPrj(SCLM_Rthorax(i_time,:), dim_ellipsoid, U, loc_ellipsoid,true) ;
nbProj = size(xProj_SCLM,2);
min_d_SCLM = zeros(1,nbProj) ;
for i_col=1:nbProj
min_d_SCLM(i_col) = norm(xProj_SCLM(:,i_col)'-SCLM_Rthorax(i_time,:)) ;
end
d_SCLM(i_t) = min(min_d_SCLM) ;

% SCL latéral
xProj_SCLL = EllPrj(SCLL_Rthorax(i_time,:), dim_ellipsoid, U, loc_ellipsoid,true) ;
nbProj = size(xProj_SCLL,2);
min_d_SCLL = zeros(1,nbProj) ;
for i_col=1:nbProj
min_d_SCLL(i_col) = norm(xProj_SCLL(:,i_col)'-SCLL_Rthorax(i_time,:)) ;
end
d_SCLL(i_t) = min(min_d_SCLL) ;

% SCL bas
xProj_SCLB = EllPrj(SCLB_Rthorax(i_time,:), dim_ellipsoid, U, loc_ellipsoid,true) ;
nbProj = size(xProj_SCLB,2);
min_d_SCLB = zeros(1,nbProj) ;
for i_col=1:nbProj
min_d_SCLB(i_col) = norm(xProj_SCLB(:,i_col)'-SCLB_Rthorax(i_time,:)) ;
end
d_SCLB(i_t) = min(min_d_SCLB) ;  

end

distanceMoyenneEllipsoide = (mean(d_SCLM)+mean(d_SCLL)+mean(d_SCLB))/3 ;
