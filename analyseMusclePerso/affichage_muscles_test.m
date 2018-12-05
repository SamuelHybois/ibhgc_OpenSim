function affichage_muscles_test(frame,Struct_muscles_points)
f=frame;
%% 4) Relier les points
muscles = fieldnames(Struct_muscles_points);

for i_muscles = 1:length(muscles)
    cur_muscle = muscles{i_muscles};
    pts_muscle = Struct_muscles_points.(cur_muscle);
    
    for i_pts = 1 : length(pts_muscle)
        
        cur_pt = Struct_muscles_points.(cur_muscle)(i_pts).location_in_R0 ;
        
        if ~isnan(cur_pt(1,1,frame));
        
        scatter3(cur_pt(1,1,frame),cur_pt(2,1,frame),...
            cur_pt(3,1,frame),'r.');
        hold on
        
        if i_pts>1
            
            prev_pt = Struct_muscles_points.(cur_muscle)(i_pts-1).location_in_R0;
            if isnan(prev_pt(1,1,frame)) % pour gérer les conditionals pathpoint
                i_pts_prev = i_pts-1;
                while isnan(prev_pt(1,1,frame))
                    i_pts_prev = i_pts_prev-1;
                    prev_pt = Struct_muscles_points.(cur_muscle)(i_pts_prev).location_in_R0;
                end
            end
            
            pl=line([cur_pt(1,1,frame) prev_pt(1,1,frame)],...
                [cur_pt(2,1,frame) prev_pt(2,1,frame)],...
                [cur_pt(3,1,frame) prev_pt(3,1,frame)]);
            pl.Color = 'r';
            hold on
            
            
        end
        
        end
    end
end

end