function [ Liste_Bodies ] = Bodies_Intermediaires( Struct_Bodies,Body1,Body2 )
%JOINTS_INTERMEDIAIRES Summary of this function goes here
%   Detailed explanation goes here

if ~strcmp(Body1,Body2)
    bodies = fieldnames(Struct_Bodies);
    
    % On part avec le body 1
    
    % On cherche ses body parents et enfants
    for i_b = 1:length(bodies)
        cur_b = Struct_Bodies.(bodies{i_b});
        if strcmp(bodies{i_b},Body1)
            Info_Body1 = cur_b;
        end
    end
    
    %On va parcourir les enfants jusqu'à trouver le body2
    Liste_Body={};
    i_rec=0;
    Liste_Bodies = Parcourir_branche_enfant(Struct_Bodies,Body1,Info_Body1,Body2,Liste_Body,i_rec);
    
    
    %Si on n'a rien trouvé dans les enfants, on doit remonter dans les parents
    if length(Liste_Bodies)==1 %Il n'y a que le body1 dans la liste
        Liste_Bodies = Parcourir_branche_parent(Struct_Bodies,Body1,Info_Body1,Body2,Liste_Body,i_rec);
    end
else
    Liste_Bodies={};
end
end

