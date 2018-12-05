% Fonction cinématique directe hors OpenSim
function [coordReconstruite] = cinematiqueDirecte(modeleOsim,coordGeneralisee_t)
% NB : les translations doivent être en m et les rotations en radians (la
% fonction ci-dessous les convertit en degrés quand nécessaire)

List_Coordinates = fieldnames(coordGeneralisee_t);
nb_frame = size(coordGeneralisee_t.(List_Coordinates{1}),1);

% trouve le nombre de bodies du model
struct_Bodies = modeleOsim.Model.BodySet.objects.Body;
nb_bodies = size(struct_Bodies,2);

% calcul de la matrice homogène entre les segments i et i-1
for i_body = 1:nb_bodies
    Name_Body = modeleOsim.Model.BodySet.objects.Body(i_body).ATTRIBUTE.name;
    
    if ~isempty( modeleOsim.Model.BodySet.objects.Body(i_body).Joint)
        % matrice Homogène du Joint dans le body Parent (matrice constante)
        TypeJoint = fieldnames(struct_Bodies(i_body).Joint) ;
        Name_Parent = struct_Bodies(i_body).Joint.(char(TypeJoint)).parent_body;
        Location_in_parent = struct_Bodies(i_body).Joint.(char(TypeJoint)).location_in_parent;
        Orientation_in_parent = struct_Bodies(i_body).Joint.(char(TypeJoint)).orientation_in_parent;
        % sequence x,y,z
        Rot_X = [[1,0,0]',[0,cos(Orientation_in_parent(1)),sin(Orientation_in_parent(1))]',[0,-sin(Orientation_in_parent(1)),cos(Orientation_in_parent(1))]'];
        Rot_Y = [[cos(Orientation_in_parent(2)),0,sin(Orientation_in_parent(2))]',  [0,1,0]', [sin(Orientation_in_parent(2)),0,cos(Orientation_in_parent(2))]'];
        Rot_Z = [[cos(Orientation_in_parent(3)),sin(Orientation_in_parent(3)),0]',[-sin(Orientation_in_parent(3)),cos(Orientation_in_parent(3)),0]',[0,0,1]'];
        Orientation = Rot_X  * Rot_Y  *  Rot_Z ;
        
        Translation = Orientation * Location_in_parent';
        MH_1 = [Orientation, Translation; 0,0,0,1];
        
        
        % Matrice Homogène du Joint dans le body child (matrice constante)
        Location_in_child = struct_Bodies(i_body).Joint.(char(TypeJoint)).location;
        Orientation_in_child = struct_Bodies(i_body).Joint.(char(TypeJoint)).orientation;
        % sequence x,y,z
        Rot_X = [[1,0,0]',[0,cos(Orientation_in_child(1)),sin(Orientation_in_child(1))]',[0,-sin(Orientation_in_child(1)),cos(Orientation_in_child(1))]'];
        Rot_Y = [[cos(Orientation_in_child(2)),0,sin(Orientation_in_child(2))]',  [0,1,0]', [sin(Orientation_in_child(2)),0,cos(Orientation_in_child(2))]'];
        Rot_Z = [[cos(Orientation_in_child(3)),sin(Orientation_in_child(3)),0]',[-sin(Orientation_in_child(3)),cos(Orientation_in_child(3)),0]',[0,0,1]'];
        Orientation = Rot_X  * Rot_Y  *  Rot_Z ;
        
        Translation = Orientation * Location_in_child';
        MH_3 = [Orientation, Translation; 0,0,0,1];
        
        % Matrice Homogène du joint coordinate system (depend du temps)
        if ~isempty(find(strcmp(fieldnames(struct_Bodies(i_body).Joint.(char(TypeJoint))),'SpatialTransform')==1))
            nb_coordinates = size(struct_Bodies(i_body).Joint.(char(TypeJoint)).SpatialTransform.TransformAxis,2);
            for i_coordinate = 1:nb_coordinates
                coordinate_name = struct_Bodies(i_body).Joint.(char(TypeJoint)).SpatialTransform.TransformAxis(i_coordinate).coordinates;
                coordinate_axis = struct_Bodies(i_body).Joint.(char(TypeJoint)).SpatialTransform.TransformAxis(i_coordinate).axis;
                coordinate_xfunction = struct_Bodies(i_body).Joint.(char(TypeJoint)).SpatialTransform.TransformAxis(i_coordinate).xfunction;
                coordinate_attribut = struct_Bodies(i_body).Joint.(char(TypeJoint)).SpatialTransform.TransformAxis(i_coordinate).ATTRIBUTE.name;
                
                if strcmp(fieldnames(coordinate_xfunction),'LinearXfunction')==1
                    Coef =  coordinate_xfunction.LinearXfunction.coefficients;
                    
                    if ~isempty(find(strcmp(List_Coordinates,coordinate_name)==1))
                        real_coordinates = Coef(1)*coordGeneralisee_t.(coordinate_name) + Coef(2);
                        
                    else
                        real_coordinates = zeros(size(coordGeneralisee_t.(List_Coordinates{1}),1),1);
                    end
                    
                    
                elseif strcmp(fieldnames(coordinate_xfunction),'Constant')==1
                    Constante=  coordinate_xfunction.Constant.value;
                    
                    real_coordinates = Constante * ones(size(coordGeneralisee_t.(List_Coordinates{1}),1),1);
                    
                elseif strcmp(fieldnames(coordinate_xfunction),'SimmSpline')==1
                    X =  coordinate_xfunction.SimmSpline.x;
                    Y =  coordinate_xfunction.SimmSpline.y;
                    
                    Coord =  coordGeneralisee_t.(coordinate_name);
                    
                    real_coordinates = interp1(X,Y,Coord,'spline');
                    
                elseif strcmp(fieldnames(coordinate_xfunction),'MultiplierXfunction')==1
                    xfunction = coordinate_xfunction.MultiplierXfunction.xfunction;
                    scale = coordinate_xfunction.MultiplierXfunction.scale;
                    
                    if strcmp(fieldnames(xfunction),'LinearXfunction')==1
                        Coef =  xfunction.LinearXfunction.coefficients;
                        
                        if ~isempty(find(strcmp(List_Coordinates,coordinate_name)==1))
                            real_coordinates = (Coef(1) *coordGeneralisee_t.(coordinate_name) + Coef(2)) * scale;
                            
                        else
                            real_coordinates = zeros(size(coordGeneralisee_t.(List_Coordinates{1}),1),1);
                        end
                        
                        
                    elseif strcmp(fieldnames(xfunction),'Constant')==1
                        Constante=  xfunction.Constant.value;
                        
                        real_coordinates = (Constante * ones(size(coordGeneralisee_t.(List_Coordinates{1}),1),1)) * scale;
                        
                    elseif strcmp(fieldnames(xfunction),'SimmSpline')==1
                        X =  xfunction.SimmSpline.x;
                        Y =  (xfunction.SimmSpline.y) * scale;
                        
                        Coord =  coordGeneralisee_t.(coordinate_name) ;
                        
                        real_coordinates = (interp1(X,Y,Coord,'spline'));
                    end
                    
                end
                
                if ~isempty(strfind(coordinate_attribut,'rotation'))
                    coord_axe = coordinate_axis;
                    angle =  real_coordinates; % a modifier avec fonction
                    
                    if strcmp(coordinate_attribut,'rotation1')==1
                        
                        Rot1 = zeros(3,3,size(real_coordinates,1));
                        for i_frame = 1:size(real_coordinates,1)
                            Rot1(:,:,i_frame) = Mrot_rotation_axe_angle(coord_axe,angle(i_frame),'radians');
                        end
                        
                    elseif strcmp(coordinate_attribut,'rotation2')==1
                        Rot2 = zeros(3,3,size(real_coordinates,1));
                        for i_frame = 1:size(real_coordinates,1)
                            Rot2(:,:,i_frame) = Mrot_rotation_axe_angle(coord_axe,angle(i_frame),'radians');
                        end
                        
                    elseif strcmp(coordinate_attribut,'rotation3')==1
                        Rot3 = zeros(3,3,size(real_coordinates,1));
                        for i_frame = 1:size(real_coordinates,1)
                            Rot3(:,:,i_frame) = Mrot_rotation_axe_angle(coord_axe,angle(i_frame),'radians');
                        end
                        
                    end
                    
                    
                elseif ~isempty(strfind(coordinate_attribut,'translation')) % case translation
                    coord_axe = coordinate_axis;
                    trans =  real_coordinates;
                    
                    
                    if strcmp(coordinate_attribut,'translation1')==1
                        trans1 = trans * coord_axe;
                    elseif strcmp(coordinate_attribut,'translation2')==1
                        trans2 = trans * coord_axe;
                    elseif strcmp(coordinate_attribut,'translation3')==1
                        trans3 = trans * coord_axe;
                        
                    end
                    
                end
            end
            
            % MH du joint
            Translation = (trans1 + trans2 + trans3)';
            
            MH_Joint = zeros(4,4,size(real_coordinates,1));
            MH_Joint(4,4,:) = 1;
            MH_Joint(1:3,4,:) = permute(Translation,[1,3,2]);
            
            for i_frame = 1:size(MH_Joint,3)
                MH_Joint(1:3,1:3,i_frame)= Rot1(:,:,i_frame) * Rot2(:,:,i_frame) * Rot3(:,:,i_frame);
            end
            
            
            
        else
            
            Rot1 = eye(3,3);
            Rot2 = eye(3,3);
            Rot3 = eye(3,3);
            trans1 = [0,0,0];
            trans2 = [0,0,0];
            trans3 = [0,0,0];
            
            
            % MH du joint
            Translation = repmat((trans1 + trans2 + trans3),[nb_frame,1])';
            
            MH_Joint = zeros(4,4,nb_frame);
            MH_Joint(4,4,:) = 1;
            MH_Joint(1:3,4,:) = permute(Translation,[1,3,2]);
            
            for i_frame = 1:size(MH_Joint,3)
                MH_Joint(1:3,1:3,i_frame)= Rot1(:,:) * Rot2(:,:) * Rot3(:,:);
            end
        end
        
        % MH global du Child dans le Parent
        MH_total = zeros(4,4,size(real_coordinates,1));
        for i_frame = 1:size(MH_Joint,3)
            MH_total(:,:,i_frame) =  MH_1 * MH_Joint(:,:,i_frame) * inv(MH_3);
        end
        
        Struct_MH.(Name_Body).where = Name_Parent;
        Struct_MH.(Name_Body).MH = MH_total;
        
    end
end


% Réxpression de proche en proche jusqu'à ce que tous les bodies soient
% exprimés dans R_Ground

List_bodies = fieldnames(Struct_MH);
for i_body = 1:size(List_bodies,1)
    
    flag = 0;
    while flag~=1
        
        Parent = Struct_MH.(List_bodies{i_body}).where;
        if strcmp(Parent,'ground')~=1
            MH1 = Struct_MH.(List_bodies{i_body}).MH;
            MH0 = Struct_MH.(Parent).MH;
            where = Struct_MH.(Parent).where;
            
            MH=zeros(4,4,size(Struct_MH.(List_bodies{i_body}).MH,3));
            for i_frame = 1:size(Struct_MH.(List_bodies{i_body}).MH,3)
                MH(:,:,i_frame) = MH0(:,:,i_frame) * MH1(:,:,i_frame);
            end
            
            Struct_MH.(List_bodies{i_body}).MH = MH;
            Struct_MH.(List_bodies{i_body}).where = where;
        else
            flag=1;
        end
    end
end % end while

%% Calcul de la position des marqueurs reconstruits

Markers = modeleOsim.Model.MarkerSet.objects.Marker ;
nMarkers = size(Markers,2) ;

for i_marker=1:nMarkers
    nom_marker = Markers(i_marker).ATTRIBUTE.name ;
    body = Markers(i_marker).body ;
    coord_Rbody = Markers(i_marker).location ;
    coord_R0 = Struct_MH.(body).MH * [coord_Rbody,1]';
    coordReconstruite.(nom_marker) = coord_R0(1:3) ;
end

end