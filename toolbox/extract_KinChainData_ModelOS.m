function [Bodies, Joints] = extract_KinChainData_ModelOS(Model,Constraints)
%% Sauret Christophe,
% 20/01/2016
%
% Permet de resortir de la structure model d'OpenSim: Bodies et Joints
% Model: Structure contenant les données du model OpenSim
% Bodies est une structure contenant la liste des bodies et pour chacun d'eux :
%   Bodies.(Body_Name).Parent : Nom du Parent
%   Bodies.(Body_Name).Children : liste des enfants
%   Bodies.(Body_Name).Joints : liste des articulations définies dans ce body
%
% Joint est une structure contenant la liste de tous les joints du modèle avec pour chacun:
%   Joints.(NameJoint).Type : Type de Joint dans OpenSim
%   Joints.(NameJoint).Parent : Nom du body considéré comme parent
%   Joints.(NameJoint).Child : Nom du body considéré comme enfant

%% création des structures contenants les info relatives aux bodies et aux joints
Model_cin = Model.Model.BodySet.objects.Body;
% nb_bodies = size(Model_cin,2); % modification mai 2017 : Model_cin est
% Nbx1 dans l'exemple.
nb_bodies = length(Model_cin);

list_bodies=cell(nb_bodies,1);
cmp_body=1;
for i_body=1:nb_bodies
    list_bodies{cmp_body}=Model_cin(i_body).ATTRIBUTE.name;
    cmp_body=cmp_body+1;
end

Bodies=[]; Joints=[];
% Parcours des Bodies dans l'ordre de la liste du modèle

for i_body = 1:nb_bodies
    cur_body = Model_cin(i_body).ATTRIBUTE.name;
    
    % création de la liste des bodies
    if ~isfield(Bodies,(cur_body))
        Bodies.(cur_body).Parent = {};
        Bodies.(cur_body).Children = {};
        Bodies.(cur_body).Joints = {};
    end
    
    % orientation du vecteur gravité g par rapport au ground
    if strcmp(cur_body,'ground')==1
        Bodies.(cur_body).gravity = Model.Model.gravity;
    end
    
    
    % définition de la liste des joints avec type, parent et enfant
    if ~isempty(Model_cin(i_body).Joint)
        TypeJoint = fieldnames(Model_cin(i_body).Joint);
        TypeJoint = TypeJoint{1};
        NameJoint = Model_cin(i_body).Joint.(TypeJoint).ATTRIBUTE.name;
        Parent = Model_cin(i_body).Joint.(TypeJoint).parent_body;
        
        Joints.(NameJoint).Type = TypeJoint;
        Joints.(NameJoint).Parent = Parent ;
        Joints.(NameJoint).Child = Model_cin(i_body).ATTRIBUTE.name;
        Bodies.(cur_body).Parent{end+1,1} = Model_cin(i_body).Joint.(TypeJoint).parent_body;
        Bodies.(cur_body).Parent{end,2} = find(strcmp(list_bodies,Bodies.(cur_body).Parent{1,1}));
        Bodies.(Parent).Children{end+1,1} = Model_cin(i_body).ATTRIBUTE.name;
        Bodies.(Parent).Children{end,2}=find(strcmp(list_bodies,Model_cin(i_body).ATTRIBUTE.name));
        Bodies.(cur_body).Joints = NameJoint;
        
        % Partie constante de la matrice de transformation
        % Matrice homogène du Joint dans le body parent (matrice constante)
        Location_in_parent = Model_cin(i_body).Joint.(TypeJoint).location_in_parent;
        Orientation_in_parent = Model_cin(i_body).Joint.(TypeJoint).orientation_in_parent;
        % Sequence x,y,z
        Rot_X = [[1,0,0]',[0,cos(Orientation_in_parent(1)),sin(Orientation_in_parent(1))]',[0,-sin(Orientation_in_parent(1)),cos(Orientation_in_parent(1))]'];
        Rot_Y = [[cos(Orientation_in_parent(2)),0,sin(Orientation_in_parent(2))]',  [0,1,0]', [sin(Orientation_in_parent(2)),0,cos(Orientation_in_parent(2))]'];
        Rot_Z = [[cos(Orientation_in_parent(3)),sin(Orientation_in_parent(3)),0]',[-sin(Orientation_in_parent(3)),cos(Orientation_in_parent(3)),0]',[0,0,1]'];
        Orientation = Rot_X  * Rot_Y  *  Rot_Z ;
        
        % Translation = Orientation * Location_in_parent';
        Translation = Location_in_parent';
        
        MH_p = [Orientation, Translation; 0,0,0,1];
        
        % Matrice Homogène du Joint dans le body child (matrice constante)
        Location_in_child = Model_cin(i_body).Joint.(TypeJoint).location;
        Orientation_in_child = Model_cin(i_body).Joint.(TypeJoint).orientation;
        % Sequence x,y,z
        Rot_X = [[1,0,0]',[0,cos(Orientation_in_child(1)),sin(Orientation_in_child(1))]',[0,-sin(Orientation_in_child(1)),cos(Orientation_in_child(1))]'];
        Rot_Y = [[cos(Orientation_in_child(2)),0,sin(Orientation_in_child(2))]',  [0,1,0]', [sin(Orientation_in_child(2)),0,cos(Orientation_in_child(2))]'];
        Rot_Z = [[cos(Orientation_in_child(3)),sin(Orientation_in_child(3)),0]',[-sin(Orientation_in_child(3)),cos(Orientation_in_child(3)),0]',[0,0,1]'];
        Orientation = Rot_X  * Rot_Y  *  Rot_Z ;
        
        % Translation = Orientation * Location_in_child';
        Translation = Location_in_child';
        
        MH_c = [Orientation, Translation; 0,0,0,1];
        
        Joints.(NameJoint).MH_p = MH_p;
        Joints.(NameJoint).MH_c = MH_c;
        Joints.(NameJoint).MH_c_inv = inv(MH_c);
        
        
        if strcmpi(TypeJoint,'WeldJoint')==0 && strcmpi(TypeJoint,'ScapulothoracicJoint')==0
            Coordinates = Model_cin(i_body).Joint.(TypeJoint).SpatialTransform.TransformAxis;
        end
        
        nb_coordinates = size(Coordinates,2);
        liste_coord{nb_coordinates}=0;
        liste_rot{nb_coordinates}=0;
        liste_axis{nb_coordinates}=0;
        liste_func{nb_coordinates}=0;
        coord_func{nb_coordinates}=0;
        
        for ii = 1:nb_coordinates
            Coordinate_name = Coordinates(ii).coordinates;
            % Teste si la coordonnée concernée est une translation ou une
            % rotation
            if sum(strfind(Coordinates(ii).ATTRIBUTE.name,'rotation'))~=0
                liste_rot{ii}=1;
            else liste_rot{ii}=0;
            end
            liste_axis{ii} = Coordinates(ii).axis;
            liste_coord{ii} = Coordinate_name;
            function_tmp = fieldnames(Coordinates(ii).xfunction);
            liste_func{ii} = function_tmp{1};
            
            if strcmp('SimmSpline',liste_func{ii})==1
                X = Coordinates(ii).xfunction.(liste_func{ii}).x;
                Y = Coordinates(ii).xfunction.(liste_func{ii}).y;
                spline_val = spline(X,Y);
                coord_func{ii}.pieces = spline_val.pieces;
                coord_func{ii}.order = spline_val.order;
                coord_func{ii}.X = X;
                coord_func{ii}.coefs = spline_val.coefs;
                
            elseif strcmp('MultiplierXfunction',liste_func{ii})==1&&sum(strcmp('SimmSpline',fieldnames(Coordinates(ii).xfunction.(liste_func{ii}).xfunction)))~=0
                    X = Coordinates(ii).xfunction.(liste_func{ii}).xfunction.SimmSpline.x;
                    Y = Coordinates(ii).xfunction.(liste_func{ii}).xfunction.SimmSpline.y;
                    scale = Coordinates(ii).xfunction.(liste_func{ii}).scale;
                    X = X*scale;
                    Y = Y*scale;
                    spline_val = spline(X,Y);
                    coord_func{ii}.xfunction.SimmSpline.pieces = spline_val.pieces;
                    coord_func{ii}.xfunction.SimmSpline.order = spline_val.order;
                    coord_func{ii}.xfunction.SimmSpline.X = X;
                    coord_func{ii}.xfunction.SimmSpline.coefs = spline_val.coefs;
                    coord_func{ii}.scale = scale;

            else
                coord_func{ii} = Coordinates(ii).xfunction.(liste_func{ii});
                
            end
            clear function_tmp
        end
        
        Joints.(NameJoint).coordinates = liste_coord;
        Joints.(NameJoint).rotation = liste_rot;
        Joints.(NameJoint).axes = liste_axis;
        Joints.(NameJoint).coord_function = liste_func;
        Joints.(NameJoint).coord_value = coord_func;
        
        
        % Paramètres inertiels
        % Vecteur avec 10 composantes contenant les infos des paramètres inertiels du segment,
        % dans l'ordre :
        % masse (kg), coordonnées du centre de masse (m)
        % moment d'inertie xx, yy, zz
        % produits d'inertie xy, xz, yz
        
        Bodies.(cur_body).BSIP = [Model_cin(i_body).mass,Model_cin(i_body).mass_center,...
            Model_cin(i_body).inertia_xx, Model_cin(i_body).inertia_yy,...
            Model_cin(i_body).inertia_zz, Model_cin(i_body).inertia_xy,...
            Model_cin(i_body).inertia_xz, Model_cin(i_body).inertia_yz];
        
        %         if nargin>1
        %             try
        %                 for i_con=1:length(Constraints.objects.PointConstraint)
        %
        %                     if strcmp(cur_body,Constraints.objects.PointConstraint(i_con).body_1)
        %                          Bodies.(cur_body).PointContraint = Constraints.objects.PointConstraint(i_con).location_body_1;
        %                     elseif strcmp(cur_body,Constraints.objects.PointConstraint(i_con).body_2)
        %                          Bodies.(cur_body).PointContraint = Constraints.objects.PointConstraint(i_con).location_body_2;
        %                     end
        %                 end
        %             catch
        %             end
        %         end
    end
    
    clear liste_axis liste_coord liste_rot liste_func coord_func TypeJoint NameJoint
end

clear nb_bodies

% % Definition des attributs de chaque body :  nb children, children
% list_joints = fieldnames(Joints);
% nb_joints = size(list_joints,1);
% for i_joint = 1:nb_joints
%     NameJoint = list_joints{i_joint};
%     Joint_Parent = Joints.(list_joints{i_joint}).Parent;
%     Joint_Child = Joints.(list_joints{i_joint}).Child;
%
%     nb_joint_in_parent = size(Bodies.(Joint_Parent).Children,1);
%     Bodies.(Joint_Parent).Children{nb_joint_in_parent+1,1}=Joint_Child;
%     Bodies.(Joint_Parent).Joints{nb_joint_in_parent+1,1} = NameJoint;
% end
% clear i_joint nb_joints NameJoint Joint_Parent Joint_Child

% Boucle fermée scapulothoracique ou acromioclaviculaire
% try
%     Con = Model.Model.ConstraintSet.objects.PointConstraint;
%
%     for i_c = 1:length(Con)
%     cur_c = Con(i_c);
%
%     NameJoint = ['acromioclavicular' cur_c.body_1(end-1:end)] ;
%     Joint_Parent = cur_c.body_2;
%     Joint_Child = cur_c.body_1;
%
%     Joints.(NameJoint).Parent = Joint_Parent;
%     Joints.(NameJoint).Child = Joint_Child;
%     Joints.(NameJoint).Type = 'PointConstraint';
%
%     nb_joint_in_parent = size(Bodies.(Joint_Parent).Children,1);
%     Bodies.(Joint_Parent).Children{nb_joint_in_parent+1,1}=Joint_Child;
%     Bodies.(Joint_Parent).Joints{nb_joint_in_parent+1,1} = NameJoint;
%
%     Bodies.(Joint_Child).Children{nb_joint_in_parent+1,1}=Joint_Parent;
%     Bodies.(Joint_Child).Joints{nb_joint_in_parent+1,1} = NameJoint;
%
%     end
% catch
% end

% Ajout des marqueurs du bodies
Markers = Model.Model.MarkerSet.objects.Marker  ;
nb_m = length(Markers);
for i_m= 1:nb_m
    cur_m = Markers(i_m);
    try
        Bodies.(cur_m.body).Markers{end+1}=cur_m.ATTRIBUTE.name;
    catch
        Bodies.(cur_m.body).Markers ={};
        Bodies.(cur_m.body).Markers{end+1}=cur_m.ATTRIBUTE.name;
    end
end

end
