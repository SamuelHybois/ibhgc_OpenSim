function [mass_center,coord_bodies]=separation_sortie_analyse_OS(list_bodies,coord,list_coord)

mass_center=struct;
coord_bodies=struct;
nb_coord=size(list_coord,1);
for i_body = 1:size(list_bodies,1)
    
    nom_body = list_bodies{i_body};
    %initialisation
    num_coord_mass_center = 1;
    num_coord_angles_bodies = 1;
    
    for i_coord=1:nb_coord
        
        nom_coord = list_coord{i_coord};
        nom_coord_split = strsplit(nom_coord,'_');
        
        % On cherche les coordonnées associées au body
        if strfind(nom_coord,nom_body) == 1 
            % Si la dernière partie de la coordonnée possède 1 caractère, 
            % X ou Y ou Z, alors c'est la position
            if size(nom_coord_split{end},2) == 1 
                
                mass_center.(char(nom_body))(:,num_coord_mass_center) =...
                 coord.(char(nom_coord));
             
                num_coord_mass_center = num_coord_mass_center + 1;
                
            % Si elle en possède 2, c'est Ox ou Oy ou Oz 
            % donc c'est l'orientation   
            elseif size(nom_coord_split{end},2) == 2
                
                coord_bodies.(char(nom_body))(:,num_coord_angles_bodies) =...
                coord.(char(nom_coord));
            
                num_coord_angles_bodies = num_coord_angles_bodies + 1;
            end
        end
    end
end