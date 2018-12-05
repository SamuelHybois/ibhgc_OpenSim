function [Position_CoR_dans_R0] = calcul_position_CoR_dans_R0(bodies,Struct_MH)
% Entrée :
%         * Matrice de passage Struct_MH des segments vers R0 (MH_R0_Rs)
%         * Position et orientation des CoR dans Rs (Repère Segmentaire)
%         dans bodies
% Sortie :
%         * Position_CoR_dans_R0 Position des Centres de rotations entre les
%         segments enfant et son parent
%%%% Puchaud Pierre %%%


segments = fieldnames(Struct_MH);
Position_CoR_dans_R0 = struct;

for i_seg = 1:length(segments)
    
    cur_seg = segments{i_seg};
    
    Position_frame_seg_in_R0 = Struct_MH.(cur_seg).MH(1:3,4,:);
    
    nb_frames = size(Position_frame_seg_in_R0,3);
    Distance_frame_CoR_dans_R0 = zeros(3,1,nb_frames);
    
    for i_f = 1:nb_frames
        Distance_frame_CoR_dans_R0(:,:,i_f) = ...
            Struct_MH.(cur_seg).MH(1:3,1:3,i_f) * ...
            bodies.(cur_seg).Parent_Joint_CoR_location_dans_Rs';
    end
    
    cur_joint = bodies.(cur_seg).Parent_Joint; 
    
    Position_CoR_dans_R0.(cur_joint) =  Position_frame_seg_in_R0 + Distance_frame_CoR_dans_R0;
end

%%%%%%%%%%%%%%%%%% To handle scapulothoracic joint %%%%%%%%%%%%%%%%%%%%%%%%%
try
if ~isfield(Position_CoR_dans_R0,'acromioclavicular_r')
    for i_f = 1:nb_frames
        Position_CoR_dans_R0.acromioclavicular_r(:,:,i_f) = ...
            Struct_MH.clavicle_r.MH(1:3,1:3,i_f) * ...
            bodies.clavicle_r.PointContraint' + Struct_MH.clavicle_r.MH(1:3,4,i_f) ;
    end
end

if ~isfield(Position_CoR_dans_R0,'acromioclavicular_l')
    for i_f = 1:nb_frames
        Position_CoR_dans_R0.acromioclavicular_l(:,:,i_f) = ...
            Struct_MH.clavicle_l.MH(1:3,1:3,i_f) * ...
            bodies.clavicle_l.PointContraint' + Struct_MH.clavicle_l.MH(1:3,4,i_f) ;
    end
end
end

end