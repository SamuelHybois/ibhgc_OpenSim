function Struct_L = calcul_longueur_musculaire(Struct_muscles_points)
%% 4) Relier les points
Struct_L=struct;

muscles = fieldnames(Struct_muscles_points);
nb_frames = size(Struct_muscles_points.(muscles{1})(1).location_in_R0,3);

for i_muscles = 1:length(muscles)

    for i_f = 1:nb_frames
        L_muscle = 0;
        cur_muscle = muscles{i_muscles};
        pts_muscle = Struct_muscles_points.(cur_muscle);
        
        for i_pts = 2 : length(pts_muscle)
            
            cur_pt = Struct_muscles_points.(cur_muscle)(i_pts).location_in_R0 ;
            if ~isnan(cur_pt(1,1,i_f))
                
                prev_pt = Struct_muscles_points.(cur_muscle)(i_pts-1).location_in_R0;
                if isnan(prev_pt(1,1,i_f))
                    i_pts_prev = i_pts-1;
                    while isnan(prev_pt(1,1,i_f))
                        i_pts_prev = i_pts_prev-1;
                        prev_pt = Struct_muscles_points.(cur_muscle)(i_pts_prev).location_in_R0;
                    end
                end
                
                X = [prev_pt(1,1,i_f) - cur_pt(1,1,i_f),...
                    prev_pt(2,1,i_f) - cur_pt(2,1,i_f),...
                    prev_pt(3,1,i_f) - cur_pt(3,1,i_f)];
                
                L_muscle = norm(X)+ L_muscle;
                
            end 
        end
        Struct_L.(cur_muscle)(1,1,i_f)= L_muscle;
    end
    
end
end