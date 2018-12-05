function struct_Bodies = storeJointMatrices(struct_Bodies)

nBodies = size(struct_Bodies,2) ;

for i_body=1:nBodies
    
    if ~isempty(struct_Bodies(i_body).Joint)
        
        TypeJoint = fieldnames(struct_Bodies(i_body).Joint) ;
        TypeJoint = char(TypeJoint{1}) ;
        
        % Matrice homogène du Joint dans le body parent (matrice constante)
        Location_in_parent = struct_Bodies(i_body).Joint.(TypeJoint).location_in_parent;
        Orientation_in_parent = struct_Bodies(i_body).Joint.(TypeJoint).orientation_in_parent;
        % sequence x,y,z
        Rot_X = [[1,0,0]',[0,cos(Orientation_in_parent(1)),sin(Orientation_in_parent(1))]',[0,-sin(Orientation_in_parent(1)),cos(Orientation_in_parent(1))]'];
        Rot_Y = [[cos(Orientation_in_parent(2)),0,sin(Orientation_in_parent(2))]',  [0,1,0]', [sin(Orientation_in_parent(2)),0,cos(Orientation_in_parent(2))]'];
        Rot_Z = [[cos(Orientation_in_parent(3)),sin(Orientation_in_parent(3)),0]',[-sin(Orientation_in_parent(3)),cos(Orientation_in_parent(3)),0]',[0,0,1]'];
        Orientation = Rot_X  * Rot_Y  *  Rot_Z ;
        
        %         Translation = Orientation * Location_in_parent';
        Translation = Location_in_parent';
        
        MH_p = [Orientation, Translation; 0,0,0,1];
        
        
        % Matrice Homogène du Joint dans le body child (matrice constante)
        Location_in_child = struct_Bodies(i_body).Joint.(TypeJoint).location;
        Orientation_in_child = struct_Bodies(i_body).Joint.(TypeJoint).orientation;
        % sequence x,y,z
        Rot_X = [[1,0,0]',[0,cos(Orientation_in_child(1)),sin(Orientation_in_child(1))]',[0,-sin(Orientation_in_child(1)),cos(Orientation_in_child(1))]'];
        Rot_Y = [[cos(Orientation_in_child(2)),0,sin(Orientation_in_child(2))]',  [0,1,0]', [sin(Orientation_in_child(2)),0,cos(Orientation_in_child(2))]'];
        Rot_Z = [[cos(Orientation_in_child(3)),sin(Orientation_in_child(3)),0]',[-sin(Orientation_in_child(3)),cos(Orientation_in_child(3)),0]',[0,0,1]'];
        Orientation = Rot_X  * Rot_Y  *  Rot_Z ;
        
        %         Translation = Orientation * Location_in_child';
        Translation = Location_in_child';
        
        MH_c = [Orientation, Translation; 0,0,0,1];
        
        struct_Bodies(i_body).Joint.StoredMatrices.MH_c = MH_c ;
        struct_Bodies(i_body).Joint.StoredMatrices.MH_c_inv = inv(MH_c) ;
        struct_Bodies(i_body).Joint.StoredMatrices.MH_p = MH_p ;

        
    end
    
end

end