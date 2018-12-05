function Struct_MH = parcoursModeleCinematiqueDirecte(coordGeneralisee_t,struct_Bodies,struct_Joints,Name_Body,Struct_MH)

if ~isempty(struct_Bodies.(Name_Body).Children)

    if ~isempty(struct_Bodies.(Name_Body).Joints)
        Nom_Joint = struct_Bodies.(Name_Body).Joints;
        Type_Joint = struct_Joints.(Nom_Joint).Type;
        Nom_Parent = struct_Joints.(Nom_Joint).Parent;
        
        MH_1 = struct_Joints.(Nom_Joint).MH_p;
        MH_3_inv = struct_Joints.(Nom_Joint).MH_c_inv;
        
        
        switch Type_Joint
            
            case 'CustomJoint'
                nb_coordinates = size(struct_Joints.(Nom_Joint).coordinates,2);
                num_rot = 1;
                num_trans = 1;
                for i_coordinate = 1:nb_coordinates
                    coordinate_name = struct_Joints.(Nom_Joint).coordinates{i_coordinate};
                    coordinate_rot = struct_Joints.(Nom_Joint).rotation{i_coordinate};
                    coordinate_axis = struct_Joints.(Nom_Joint).axes{i_coordinate};
                    coordinate_xfunction = struct_Joints.(Nom_Joint).coord_function{i_coordinate};
                    coordinate_val = struct_Joints.(Nom_Joint).coord_value{i_coordinate};
                    
                    switch coordinate_xfunction
                        
                        case 'LinearXfunction'
                            Coef =  coordinate_val.coefficients;
                            real_coordinates = Coef(1)*coordGeneralisee_t.(coordinate_name) + Coef(2);
                            
                            
                        case 'Constant'
                            Constante =  coordinate_val.value;
                            real_coordinates = Constante;
                            
                        case 'SimmSpline'
                            Coord =  coordGeneralisee_t.(coordinate_name);
                            real_coordinates = valeurCoordSpline(Coord,coordinate_val);
                            
                        case 'MultiplierXfunction'
                            xfunction = coordinate_val.xfunction;
                            scale = coordinate_val.scale;
                            
                            if ~(sum(strcmp(fieldnames(xfunction),'LinearXfunction'))==0)
                                Coef =  xfunction.LinearXfunction.coefficients;
                                real_coordinates = (Coef(1) *coordGeneralisee_t.(coordinate_name) + Coef(2)) * scale;
                                
                                
                            elseif ~(sum(strcmp(fieldnames(xfunction),'Constant'))==0)
                                Constante=  xfunction.Constant.value;
                                real_coordinates = Constante * scale;
                                
                            elseif ~(sum(strcmp(fieldnames(xfunction),'SimmSpline'))==0)
                                Coord =  coordGeneralisee_t.(coordinate_name);
                                real_coordinates = valeurCoordSpline(Coord,coordinate_val.xfunction.SimmSpline);
                            end
                            
                    end
                    
                    if coordinate_rot==1
                        
                        
                        coord_axe = coordinate_axis;
                        angle =  real_coordinates; % a modifier avec fonction
                        
                        switch num_rot
                            case 1
                                Rot1 = Mrot_rotation_axe_angle(coord_axe,angle,'radians');
                            case 2
                                Rot2= Mrot_rotation_axe_angle(coord_axe,angle,'radians');
                            case 3
                                Rot3 = Mrot_rotation_axe_angle(coord_axe,angle,'radians');
                        end
                        
                        num_rot = num_rot +1; %incrément rotation 1,2;3
                        
                    else % case translation
                        
                        coord_axe = coordinate_axis;
                        trans =  real_coordinates;
                        
                        switch num_trans
                            case 1
                                trans1 = trans * coord_axe;
                            case 2
                                trans2 = trans * coord_axe;
                            case 3
                                trans3 = trans * coord_axe;
                        end
                        
                        num_trans = num_trans +1; %incrément translation 1,2;3
                    end
                end
                % MH du joint
                Translation = (trans1 + trans2 + trans3)';
                
                MH_Joint = eye(4,4);
                MH_Joint(1:3,4) = permute(Translation,[1,3,2]);
                
                
                MH_Joint(1:3,1:3)= Rot1* Rot2 * Rot3;
                
            case 'ScapulothoracicJont'
                
                nb_coordinates = length(struct_Bodies(i_body).Joint.(Type_Joint).CoordinateSet.objects.Coordinate);
                h = struct_Bodies(i_body).Joint.(Type_Joint).thoracic_ellipsoid_radii_x_y_z(2);
                w = struct_Bodies(i_body).Joint.(Type_Joint).thoracic_ellipsoid_radii_x_y_z(1);
                d = struct_Bodies(i_body).Joint.(Type_Joint).thoracic_ellipsoid_radii_x_y_z(3);
                
                real_coordinates(1,nb_coordinates) = 0;
                for i_coordinate = 1:nb_coordinates
                    coordinate_name = struct_Bodies(i_body).Joint.(Type_Joint).CoordinateSet.objects.Coordinate(i_coordinate).ATTRIBUTE.name;
                    real_coordinates(:,i_coordinate) =  coordGeneralisee_t.(coordinate_name);
                end
                
                MH_Joint = eye(4,4);
                %             Rot4 = eye(4,4);
                
                Rot1 = Mrot_rotation_axe_angle([0 1 0],real_coordinates(1,1),'radians'); %abduction
                Rot2 = Mrot_rotation_axe_angle([1 0 0],real_coordinates(1,2),'radians'); %elevation
                Rot3 = Mrot_rotation_axe_angle([0 0 1],real_coordinates(1,3),'radians'); %upward rot
                Rot4 = Mrot_rotation_axe_angle([0 1 0],real_coordinates(1,4),'radians'); %internal rot
                MH_Joint(1:3,1:3) = Rot1*Rot2*Rot3*Rot4;
                
                trans1 = h * sin(real_coordinates(1,2));
                trans2 = w * (-sin(real_coordinates(1,1)) * cos(real_coordinates(1,2)));
                trans3 = d * (cos(real_coordinates(1,1)) * cos(real_coordinates(1,2)));
                MH_Joint(1:3,4) = [trans1  trans2  trans3]';
                
        end
        
        Struct_MH.(Name_Body).where = Nom_Parent;
        Struct_MH.(Name_Body).MH = MH_1*MH_Joint*MH_3_inv;
    end
    
    nChildren = size(struct_Bodies.(Name_Body).Children,1);
    
    for i_child = 1:nChildren
        Struct_MH = parcoursModeleCinematiqueDirecte(coordGeneralisee_t,struct_Bodies,struct_Joints,struct_Bodies.(Name_Body).Children{i_child,1},Struct_MH);
    end
    
else % arrêt de la fonction récursive : plus de children
    Nom_Joint = struct_Bodies.(Name_Body).Joints;
    Type_Joint = struct_Joints.(Nom_Joint).Type;
    Nom_Parent = struct_Joints.(Nom_Joint).Parent;
    
    MH_1 = struct_Joints.(Nom_Joint).MH_p;
    MH_3_inv = struct_Joints.(Nom_Joint).MH_c_inv;
    
    
    switch Type_Joint
        
        case 'CustomJoint'
            nb_coordinates = size(struct_Joints.(Nom_Joint).coordinates,2);
            num_rot = 1;
            num_trans = 1;
            for i_coordinate = 1:nb_coordinates
                coordinate_name = struct_Joints.(Nom_Joint).coordinates{i_coordinate};
                coordinate_rot = struct_Joints.(Nom_Joint).rotation{i_coordinate};
                coordinate_axis = struct_Joints.(Nom_Joint).axes{i_coordinate};
                coordinate_xfunction = struct_Joints.(Nom_Joint).coord_function{i_coordinate};
                coordinate_val = struct_Joints.(Nom_Joint).coord_value{i_coordinate};
                
                switch coordinate_xfunction
                    
                    case 'LinearXfunction'
                        Coef =  coordinate_val.coefficients;
                        real_coordinates = Coef(1)*coordGeneralisee_t.(coordinate_name) + Coef(2);
                        
                    case 'Constant'
                        Constante =  coordinate_val.value;
                        real_coordinates = Constante;
                        
                    case 'SimmSpline'
                        Coord =  coordGeneralisee_t.(coordinate_name);
                        real_coordinates = valeurCoordSpline(Coord,coordinate_val);
                        
                    case 'MultiplierXfunction'
                        xfunction = coordinate_val.xfunction;
                        scale = coordinate_val.scale;
                        
                        if ~(sum(strcmp(fieldnames(xfunction),'LinearXfunction'))==0)
                            Coef =  xfunction.LinearXfunction.coefficients;
                            real_coordinates = (Coef(1) *coordGeneralisee_t.(coordinate_name) + Coef(2)) * scale;
                            
                            
                        elseif ~(sum(strcmp(fieldnames(xfunction),'Constant'))==0)
                            Constante=  xfunction.Constant.value;
                            real_coordinates = Constante * scale;
                            
                        elseif ~(sum(strcmp(fieldnames(xfunction),'SimmSpline'))==0)
                            Coord =  coordGeneralisee_t.(coordinate_name);
                            real_coordinates = valeurCoordSpline(Coord,coordinate_val.xfunction.SimmSpline);
                        end
                        
                end
                
                if coordinate_rot==1
                    
                    coord_axe = coordinate_axis;
                    angle =  real_coordinates; % a modifier avec fonction
                    
                    switch num_rot
                        case 1
                            Rot1 = Mrot_rotation_axe_angle(coord_axe,angle,'radians');
                        case 2
                            Rot2= Mrot_rotation_axe_angle(coord_axe,angle,'radians');
                        case 3
                            Rot3 = Mrot_rotation_axe_angle(coord_axe,angle,'radians');
                    end
                    
                    num_rot = num_rot +1; %incrément rotation 1,2;3
                    
                else % case translation
                    
                    coord_axe = coordinate_axis;
                    trans =  real_coordinates;
                    
                    switch num_trans
                        case 1
                            trans1 = trans * coord_axe;
                        case 2
                            trans2 = trans * coord_axe;
                        case 3
                            trans3 = trans * coord_axe;
                    end
                    
                    num_trans = num_trans +1; %incrément translation 1,2;3
                end
            end
            % MH du joint
            Translation = (trans1 + trans2 + trans3)';
            
            MH_Joint = eye(4,4);
            MH_Joint(1:3,4) = permute(Translation,[1,3,2]);
            
            
            MH_Joint(1:3,1:3)= Rot1* Rot2 * Rot3;
            
        case 'ScapulothoracicJont'
            
            nb_coordinates = length(struct_Bodies(i_body).Joint.(Type_Joint).CoordinateSet.objects.Coordinate);
            h = struct_Bodies(i_body).Joint.(Type_Joint).thoracic_ellipsoid_radii_x_y_z(2);
            w = struct_Bodies(i_body).Joint.(Type_Joint).thoracic_ellipsoid_radii_x_y_z(1);
            d = struct_Bodies(i_body).Joint.(Type_Joint).thoracic_ellipsoid_radii_x_y_z(3);
            
            real_coordinates(1,nb_coordinates) = 0;
            for i_coordinate = 1:nb_coordinates
                coordinate_name = struct_Bodies(i_body).Joint.(Type_Joint).CoordinateSet.objects.Coordinate(i_coordinate).ATTRIBUTE.name;
                real_coordinates(:,i_coordinate) =  coordGeneralisee_t.(coordinate_name);
            end
            
            MH_Joint = eye(4,4);
            %             Rot4 = eye(4,4);
            
            Rot1 = Mrot_rotation_axe_angle([0 1 0],real_coordinates(1,1),'radians'); %abduction
            Rot2 = Mrot_rotation_axe_angle([1 0 0],real_coordinates(1,2),'radians'); %elevation
            Rot3 = Mrot_rotation_axe_angle([0 0 1],real_coordinates(1,3),'radians'); %upward rot
            Rot4 = Mrot_rotation_axe_angle([0 1 0],real_coordinates(1,4),'radians'); %internal rot
            MH_Joint(1:3,1:3) = Rot1*Rot2*Rot3*Rot4;
            
            trans1 = h * sin(real_coordinates(1,2));
            trans2 = w * (-sin(real_coordinates(1,1)) * cos(real_coordinates(1,2)));
            trans3 = d * (cos(real_coordinates(1,1)) * cos(real_coordinates(1,2)));
            MH_Joint(1:3,4) = [trans1  trans2  trans3]';
            
    end
    
    Struct_MH.(Name_Body).where = Nom_Parent;
    Struct_MH.(Name_Body).MH = MH_1*MH_Joint*MH_3_inv;
end

end