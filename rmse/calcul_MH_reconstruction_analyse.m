function Struct_MH=calcul_MH_reconstruction_analyse(tree,angles_bodies,pos_mass_center)

% trouve le nombre de bodies du model
List_Coordinates = fieldnames(angles_bodies);
struct_Bodies = tree.Model.BodySet.objects.Body;
nb_bodies = max(size(struct_Bodies,1),size(struct_Bodies,2));
nb_frame = size(angles_bodies.(List_Coordinates{1}),1);
% La séquence est celle d'Euler XYZ
axe=eye(3,3);
% calcul de la matrice homogène du segment dans R0
for i_body = 1:nb_bodies
    
    Name_Body = tree.Model.BodySet.objects.Body(i_body).ATTRIBUTE.name;
    mass_center_location = tree.Model.BodySet.objects.Body(i_body).mass_center';
    
    if ~isempty( tree.Model.BodySet.objects.Body(i_body).Joint) % On enlève le ground
        Name_Parent = 'ground'; % Toutes les coordonnées sont exprimées dans le ground
        
        % On construit la matrice homogène
        for i_frame=1:nb_frame
            for i=1:3
                M_rot{i}=Mrot_rotation_axe_angle(axe(:,i),angles_bodies.(char(Name_Body))(i_frame,i));
            end
            MH_total(1:3,1:3,i_frame)=M_rot{1}*M_rot{2}*M_rot{3};
        end

        % La translation correspond à la position du CDM dans R0
        Translation = pos_mass_center.(char(Name_Body));%-repmat(tree.Model.BodySet.objects.Body(i_body).mass_center,size(pos_mass_center.(char(Name_Body)),1),1);
        
        % On veut la position du repère segmentaire dans R0
        Repere_Segmentaire_location = zeros(nb_frame,3);
        for i_frame=1:nb_frame
            Repere_Segmentaire_location(i_frame,:) =...
            Translation(i_frame,:) - (MH_total(1:3,1:3,i_frame)*mass_center_location)'; 
        end
        
        MH_total(1:3,4,:) = permute(Repere_Segmentaire_location,[2,3,1]);
        MH_total(4,4,:) = 1;
        
        Struct_MH.(Name_Body).where = Name_Parent;
        Struct_MH.(Name_Body).MH = MH_total;
    end
end

end
