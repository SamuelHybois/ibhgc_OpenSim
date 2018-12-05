function [nQ,labelQ,Aeq,beq,lb,ub] = CoordonneesGeneralisees(modeleOsim)

struct_Bodies = modeleOsim.Model.BodySet.objects.Body;
nb_bodies = size(struct_Bodies,2);
nQ = 0 ;
labelQ = {} ;

for i_body = 1:nb_bodies
    
    if ~isempty( modeleOsim.Model.BodySet.objects.Body(i_body).Joint)
        TypeJoint = fieldnames(struct_Bodies(i_body).Joint) ;
        
        if ~isempty(find(strcmp(fieldnames(struct_Bodies(i_body).Joint.(char(TypeJoint{1}))),'SpatialTransform')==1))
            
            nb_coordinates = size(struct_Bodies(i_body).Joint.(char(TypeJoint{1})).SpatialTransform.TransformAxis,2);
            list_coord = [] ;
            for i_coord = 1:nb_coordinates
                nom_coord = struct_Bodies(i_body).Joint.(char(TypeJoint{1})).SpatialTransform.TransformAxis(i_coord).coordinates ;
                
                if ~isempty(nom_coord)&&strcmp(nom_coord,list_coord)==0
                    
                    nQ = nQ + 1 ;
                    list_coord = [list_coord nom_coord] ;
                    
                    for i_q = 1:size(struct_Bodies(i_body).Joint.(char(TypeJoint{1})).CoordinateSet.objects.Coordinate,2)
                        if strcmp(nom_coord,struct_Bodies(i_body).Joint.(char(TypeJoint{1})).CoordinateSet.objects.Coordinate(i_q).ATTRIBUTE.name)==1
                            labelQ.(nom_coord).range = struct_Bodies(i_body).Joint.(char(TypeJoint{1})).CoordinateSet.objects.Coordinate(i_q).range ;
                        end
                    end % for i_q
                    
                end % s'il y a un nom de DDL associé
            end % for i_coord
            
        else ~isempty(find(strcmp(fieldnames(struct_Bodies(i_body).Joint.(char(TypeJoint{1}))),'thoracic_ellipsoid_radii_x_y_z')==1))
            
            nb_coordinates = size(struct_Bodies(i_body).Joint.(char(TypeJoint{1})).CoordinateSet.objects.Coordinate,2);
            list_coord = [] ;
            for i_coord = 1:nb_coordinates
                nom_coord = struct_Bodies(i_body).Joint.(char(TypeJoint{1})).CoordinateSet.objects.Coordinate(i_coord).ATTRIBUTE.name ;
                
                if ~isempty(nom_coord)&&strcmp(nom_coord,list_coord)==0
                    
                    nQ = nQ + 1 ;
                    list_coord = [list_coord nom_coord] ;
                    
                    for i_q = 1:size(struct_Bodies(i_body).Joint.(char(TypeJoint{1})).CoordinateSet.objects.Coordinate,2)
                        if strcmp(nom_coord,struct_Bodies(i_body).Joint.(char(TypeJoint{1})).CoordinateSet.objects.Coordinate(i_q).ATTRIBUTE.name)==1
                            labelQ.(nom_coord).range = struct_Bodies(i_body).Joint.(char(TypeJoint{1})).CoordinateSet.objects.Coordinate(i_q).range ;
                        end
                    end % for i_q
                    
                end % s'il y a un nom de DDL associé
            end % for i_coord
        end % s'il y a un SpatialTransform
    end % s'il y a un Joint
end % for i_body

%Gestion des contraintes
Aeq = [] ;
nConstraints = size(modeleOsim.Model.ConstraintSet.objects,2);
for i_constraint=1:nConstraints
    TypeConstraint = fieldnames(modeleOsim.Model.ConstraintSet.objects);
    if ~isempty(find(strcmp(TypeConstraint,'CoordinateCouplerConstraint')==1))
        names_dep = char(modeleOsim.Model.ConstraintSet.objects.CoordinateCouplerConstraint(:).dependent_coordinate_name) ;
        names_dep = deblank(names_dep);
        names_indep = char(modeleOsim.Model.ConstraintSet.objects.CoordinateCouplerConstraint(:).independent_coordinate_names) ;
        names_indep = deblank(names_indep);
        %%% PRENDRE EN COMPTE LE SCALE FACTOR ?!
        for i_n = 1:size(names_dep,1)
            index_dep = strcmp(names_dep(i_n),fieldnames(labelQ)) ;
            index_indep = strcmp(names_indep(i_n),fieldnames(labelQ)) ;
            Aeq(end+1,:) = double(index_dep)' + double(index_indep)' ;
        end
    end
end % for i_constraint
beq = zeros(1,size(Aeq,1))' ;
liste_q = fieldnames(labelQ) ;
lb(1,nQ) = 0 ;
ub(1,nQ) = 0 ;
for i_q = 1:nQ
    nom_q = liste_q{i_q} ;
    lb(i_q) = min(labelQ.(nom_q).range) ;
    ub(i_q) = max(labelQ.(nom_q).range) ;
end
end