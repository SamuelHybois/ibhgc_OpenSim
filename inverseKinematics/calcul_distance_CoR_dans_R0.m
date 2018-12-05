function [ Struct_dist ] = calcul_distance_CoR_dans_R0(Struct_CoR)
% Entrée :
%         * Position_CoR_dans_R0 Position des Centres de rotations entre les
%         segments enfant et son parent
% Sortie :
%         * Distance des joints dans R0
% Related function : calcul_position_CoR_dans_R0
%%%% Puchaud Pierre %%%


jts = fieldnames(Struct_CoR);
Struct_dist = struct;

for i_jts = 1:length(jts)    
    cur_jts= jts{i_jts};
    Struct_dist.(cur_jts) =  Norm3D(Struct_CoR.(cur_jts));
end

end

