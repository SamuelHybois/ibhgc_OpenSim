function Struct_L = calcul_longueur_musculaire_wraps(Struct_muscles_points,struct_muscle_wraps,Struct_wraps_pts)
%% 4) Relier les points
Struct_L=struct;

muscles = fieldnames(Struct_muscles_points);
nb_frames = size(Struct_muscles_points.(muscles{1})(1).location_in_R0,3);

for i_m = 1:length(muscles)
    
    L_muscle = 0;
    cur_muscle = muscles{i_m};
    pts_muscle = Struct_muscles_points.(cur_muscle);
    
    
    if isfield(struct_muscle_wraps,cur_muscle) % S'il y a des wraps pour ce muscle
        cur_wraps = struct_muscle_wraps.(cur_muscle);
    else
        cur_wraps=struct;
    end
    
    for i_f = 1:nb_frames
    L_muscle = 0;
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
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %boolean wrapping
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                bool1=0;
                bool2=0;
                bool0=0;
                if isfield(struct_muscle_wraps,cur_muscle) % le muscle a-t'il des wraps ?
                    n_w_m=length(cur_wraps);
                    bool1=zeros(n_w_m,1);
                    bool2=zeros(n_w_m,1);
                    bool0=zeros(n_w_m,1);
                    
                    for i_w=1:n_w_m
                        cur_w = cur_wraps(i_w).Nom;
                        bool0(i_w)=isfield(Struct_wraps_pts.(cur_muscle),cur_w);
                        try
                            bool1(i_w)=~isempty(Struct_wraps_pts.(cur_muscle)(i_pts-1).(cur_w));
                            bool2(i_w)=~isnan(Struct_wraps_pts.(cur_muscle)(i_pts-1).(cur_w).Longueur(1,1,i_f));
                        catch
                            bool1(i_w)=0;
                            bool2(i_w)=0;
                        end
                    end
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if isempty(find(bool2==1, 1))
                    
                    X = [prev_pt(1,1,i_f) - cur_pt(1,1,i_f),...
                        prev_pt(2,1,i_f) - cur_pt(2,1,i_f),...
                        prev_pt(3,1,i_f) - cur_pt(3,1,i_f)];
                    
                    L_muscle = norm(X)+ L_muscle;
                    
                elseif ~isempty(find(bool2==1, 1)) %Longueur avec wraps
                    w=find(bool2==1, 1);
                    for ii=1:length(w)
                        cur_w = cur_wraps(w(ii)).Nom;
                        if ~isempty(Struct_wraps_pts.(cur_muscle)(i_pts-1).(cur_w))
                            L_ajout = Struct_wraps_pts.(cur_muscle)(i_pts-1).(cur_w).Longueur(1,1,i_f);
                            if ~isnan(L_ajout)
                                
                                first_pt(:,1,i_f) = Struct_wraps_pts.(cur_muscle)(i_pts-1).(cur_w).Pts_in_R0(:,end,i_f);
                                last_pt(:,1,i_f) = Struct_wraps_pts.(cur_muscle)(i_pts-1).(cur_w).Pts_in_R0(:,end,i_f);
                                
                                X1 = [prev_pt(1,1,i_f) - first_pt(1,1,i_f),...
                                    prev_pt(2,1,i_f) - first_pt(2,1,i_f),...
                                    prev_pt(3,1,i_f) - first_pt(3,1,i_f)];
                                
                                X2 = [last_pt(1,1,i_f) - cur_pt(1,1,i_f),...
                                    last_pt(2,1,i_f) - cur_pt(2,1,i_f),...
                                    last_pt(3,1,i_f) - cur_pt(3,1,i_f)];
                                
                                L_muscle = norm(X1) + norm(X2)+ L_muscle + L_ajout;
                                
                            end
                        end
                    end
                    X = [prev_pt(1,1,i_f) - cur_pt(1,1,i_f),...
                        prev_pt(2,1,i_f) - cur_pt(2,1,i_f),...
                        prev_pt(3,1,i_f) - cur_pt(3,1,i_f)];
                    
                    L_muscle = norm(X)+ L_muscle;
                    
                end
                
            end
        end
        Struct_L.(cur_muscle)(1,1,i_f)= L_muscle;
        clear L_muscle;
    end
    
end
end