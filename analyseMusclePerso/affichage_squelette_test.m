% #########################################################################
% Fonction pour afficher le squelette à partir d'un fichier .osim
% En entrée il faut le nombre de segments, le struct contenant le .osim,
% le struct contenant les matrices homogènes des différents segments et le
% numéro de la frame.
%
% La sortie est l'affichage du squelette
%
% #########################################################################

function affichage_squelette_test(tree,frame,geometrypath,Struct_MH)
% frame=156;
[Bodies,~]=extract_KinChainData_ModelOS(tree);
List_bodies = fieldnames(Bodies);
nb_bodies=length(List_bodies);
figure('Name','Squelette','NumberTitle','off')
for i_body =1:nb_bodies
    
    Name_Body = List_bodies{i_body};
%     if ~isempty( tree.Model.BodySet.objects.Body(i_body).Joint)
%         draw_frame(Struct_MH.(Name_Body).MH(:,:,frame),0.1,0); % Affiche les repères associés à chaque segment
%     end
    
    if strcmp(Name_Body,'ground')~=1
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
                    % sequence x,y,z
                    Rot_X = [[1,0,0]',[0,cos(Transform(1)),sin(Transform(1))]',[0,-sin(Transform(1)),cos(Transform(1))]'];
                    Rot_Y = [[cos(Transform(2)),0,-sin(Transform(2))]',  [0,1,0]', [sin(Transform(2)),0,cos(Transform(2))]'];
                    Rot_Z = [[cos(Transform(3)),sin(Transform(3)),0]',[-sin(Transform(3)),cos(Transform(3)),0]',[0,0,1]'];
                    
                    Rot_X_seg = [[1,0,0]',[0,cos(Transform_segment(1)),sin(Transform_segment(1))]',[0,-sin(Transform_segment(1)),cos(Transform_segment(1))]'];
                    Rot_Y_seg =[[cos(Transform_segment(2)),0,-sin(Transform_segment(2))]',  [0,1,0]', [sin(Transform_segment(2)),0,cos(Transform_segment(2))]'];
                    Rot_Z_seg =[[cos(Transform_segment(3)),sin(Transform_segment(3)),0]',[-sin(Transform_segment(3)),cos(Transform_segment(3)),0]',[0,0,1]'];
                    Orientation_seg = Rot_X_seg * Rot_Y_seg * Rot_Z_seg;
                    Translation_seg = Orientation_seg * Transform_segment(4:6)';
%                     Translation_seg = Orientation_seg * Transform_segment(4:6)'-tree.Model.BodySet.objects.Body(i_body).mass_center';
                    MH_seg=[Orientation_seg, Translation_seg;0,0,0,1];
                    
                    % on applique la transformation aux noeuds
                    Orientation = Rot_X  * Rot_Y  *  Rot_Z ;
                    
                    Translation = Orientation * Transform(4:6)';
                    MH = [Orientation, Translation; 0,0,0,1];
                    
                    % Appliquer scaling du vtp puis Transform du vtp
                    % on applique le facteur d'échelle
                    
                    obj.Noeuds = obj.Noeuds .* repmat(Scale_vtp,[size(obj.Noeuds,1),1]);
                    
                    Noeuds_coordHomogene = MH * [obj.Noeuds,ones(size(obj.Noeuds,1),1)]';
                    obj.Noeuds = Noeuds_coordHomogene(1:3,:)';
                    
                    
                    
                    % On applique la pose du solide dans l'espace
                    % Appliquer le scaling du segment puis la transform du segment
                    
                    if ~isempty(find(strcmp(List_bodies,Name_Body)==1,1)) % permet d'éviter Problème si le 'ground' possède une géométrie
                        obj.Noeuds = obj.Noeuds.*repmat(Scale_segment,[size(obj.Noeuds,1),1]);
                        obj.Noeuds = MH_seg * [obj.Noeuds';ones(1,size(obj.Noeuds,1))];
                        obj.Noeuds = obj.Noeuds(1:3,:)';
                        % Enfin, passer les noeuds dans R0
                        obj.Noeuds = Struct_MH.(Name_Body).MH(:,:,frame) * [obj.Noeuds,ones(size(obj.Noeuds,1),1)]';
                        obj.Noeuds = obj.Noeuds(1:3,:)';
                    end
                    
                    obj.Polygones = obj.Polygones+1;
                    
                    % afficher l'objet
                    
                    affiche_objet_movie(obj,'axe',gca);
                    hold on
                else
                    disp(filename_objet);
                end
            end
        end
    end
end
end