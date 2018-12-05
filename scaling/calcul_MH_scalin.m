function Struct_MH=calcul_MH_scalin(tree,nb_frame)

% trouve le nombre de bodies du model
struct_Bodies = tree.Model.BodySet.objects.Body;
nb_bodies = max(size(struct_Bodies,1),size(struct_Bodies,2));
MH_Joint(4,4,nb_frame)=0;
MH_total(4,4,nb_frame)=0;

% calcul de la matrice homogène entre les segments i et i-1
for i_body = 1:nb_bodies
    Name_Body = tree.Model.BodySet.objects.Body(i_body).ATTRIBUTE.name;
    if ~isempty( tree.Model.BodySet.objects.Body(i_body).Joint)
        % matrice Homogène du Joint dans le body Parent (matrice constante)
        TypeJoint = fieldnames(struct_Bodies(i_body).Joint);
        Name_Parent = struct_Bodies(i_body).Joint.(char(TypeJoint)).parent_body;
        Location_in_parent = struct_Bodies(i_body).Joint.(char(TypeJoint)).location_in_parent;
        Orientation_in_parent = struct_Bodies(i_body).Joint.(char(TypeJoint)).orientation_in_parent;
        % sequence x,y,z
        Rot_X = [[1,0,0]',[0,cos(Orientation_in_parent(1)),sin(Orientation_in_parent(1))]',[0,-sin(Orientation_in_parent(1)),cos(Orientation_in_parent(1))]'];
        Rot_Y = [[cos(Orientation_in_parent(2)),0,-sin(Orientation_in_parent(2))]',  [0,1,0]', [sin(Orientation_in_parent(2)),0,cos(Orientation_in_parent(2))]'];
        Rot_Z = [[cos(Orientation_in_parent(3)),sin(Orientation_in_parent(3)),0]',[-sin(Orientation_in_parent(3)),cos(Orientation_in_parent(3)),0]',[0,0,1]'];
        Orientation = Rot_X  * Rot_Y  *  Rot_Z ;
        if ~isempty(strfind(Name_Body,'tibia'))
            Location_in_parent(2)=Location_in_parent(2)-0.39;
        end
        %Translation = Orientation * Location_in_parent';
        Translation = Location_in_parent';
        MH_1 = [Orientation, Translation; 0,0,0,1];
        
        
        % Matrice Homogène du Joint dans le body child (matrice constante)
        Location_in_child = struct_Bodies(i_body).Joint.(char(TypeJoint)).location;
        Orientation_in_child = struct_Bodies(i_body).Joint.(char(TypeJoint)).orientation;
        % sequence x,y,z
        Rot_X = [[1,0,0]',[0,cos(Orientation_in_child(1)),sin(Orientation_in_child(1))]',[0,-sin(Orientation_in_child(1)),cos(Orientation_in_child(1))]'];
        Rot_Y = [[cos(Orientation_in_child(2)),0,-sin(Orientation_in_child(2))]',  [0,1,0]', [sin(Orientation_in_child(2)),0,cos(Orientation_in_child(2))]'];
        Rot_Z = [[cos(Orientation_in_child(3)),sin(Orientation_in_child(3)),0]',[-sin(Orientation_in_child(3)),cos(Orientation_in_child(3)),0]',[0,0,1]'];
        Orientation = Rot_X  * Rot_Y  *  Rot_Z ;
        
        %         Translation = Orientation * Location_in_child';
        Translation = Location_in_child';
        MH_3 = [Orientation, Translation; 0,0,0,1];
                MH_Joint=calcul_MH_joint(tree,i_body,nb_frame);
        % MH global du Child dans le Parent
        for i_frame = 1:nb_frame
            MH_total(:,:,i_frame) =  MH_1 * MH_Joint(:,:,i_frame) / (MH_3);
%             MH_total(:,:,i_frame) =  MH_1 / (MH_3);

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
