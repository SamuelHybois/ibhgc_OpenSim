[tree, ~, ~] = xml_readOSIM_TJ('E:\MusculoSkeletalModelling\ModeleScapula\abstract3DAHM\traitementOpenSim\SP01SM\modele\SP01SM_model_final.osim') ;
geometrypath = 'E:\MusculoSkeletalModelling\ModeleScapula\abstract3DAHM\traitementOpenSim\SP01SM\modele\Geometry';

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

% Tracé de l'ellipsoide optimal

[x, y, z] = ellipsoid(x_opt(1),x_opt(2),x_opt(3),x_opt(4),x_opt(5),x_opt(6));
S = surfl(x, y, z);
rotate(S,[0 0 1],45)

for i_time = 1:nFrames
scatter3(SCLB_Rthorax(i_time,1),SCLB_Rthorax(i_time,2),SCLB_Rthorax(i_time,3),'b')
scatter3(SCLM_Rthorax(i_time,1),SCLM_Rthorax(i_time,2),SCLM_Rthorax(i_time,3),'b')
scatter3(SCLL_Rthorax(i_time,1),SCLL_Rthorax(i_time,2),SCLL_Rthorax(i_time,3),'b')
hold on
scatter3(SCLB_RthoraxOS(i_time,1),SCLB_RthoraxOS(i_time,2),SCLB_RthoraxOS(i_time,3),'r')
scatter3(SCLM_RthoraxOS(i_time,1),SCLM_RthoraxOS(i_time,2),SCLM_RthoraxOS(i_time,3),'r')
scatter3(SCLL_RthoraxOS(i_time,1),SCLL_RthoraxOS(i_time,2),SCLL_RthoraxOS(i_time,3),'r')
hold on
scatter3(SCLL_clust_vect(i_time,1),SCLL_clust_vect(i_time,2),SCLL_clust_vect(i_time,3),'k')
end