function Struct_muscles_points = Point_muscles_dans_R0(tree,Struct_MH,coord_ik)

clear Struct_muscles_points
Struct_muscles_points = struct;

nb_frames = length(coord_ik.tps);

%% Type de muscle %Millard,Schutte,Thelen
tree_force = tree.Model.ForceSet.objects;
Forceset_fields = fieldnames(tree_force);
if length(Forceset_fields)==1
    tree_muscle = tree.Model.ForceSet.objects.(Forceset_fields{1});
    Muscletype = Forceset_fields{1};
elseif length(Forceset_fields)==2
    tree_muscle = tree.Model.ForceSet.objects.(Forceset_fields{2});
    Muscletype = Forceset_fields{2};
end

%% 1) Récupérer les points d'un muscle
for i_muscle = 1:length(tree_muscle)
    clear tree_pts_1Muscle;
    clear Muscles_points;
    clear tree_pts_1Muscle;
    
    muscle_name = tree_muscle(i_muscle).ATTRIBUTE.name;
    point_types={'PathPoint','MovingPathPoint','ConditionalPathPoint'};
    
    % On organise l'arbre des points du muscle
    for i_pt_type = 1:length(point_types)
        cur_pt_type = point_types{i_pt_type};
        if isfield( tree_muscle(i_muscle).GeometryPath.PathPointSet.objects ,cur_pt_type)
            
            tree_pts_1Muscle.(cur_pt_type) =...
                tree_muscle(i_muscle).GeometryPath.PathPointSet.objects.(cur_pt_type);
        end
    end
    
    %% 2) On organise les données selon les Types de points dans le Repère Segmentaire
    
    % PathPoint : Fixed ne rien faire
    if isfield(tree_pts_1Muscle,'PathPoint')
        nb_pts = max(size(tree_pts_1Muscle.PathPoint,2),size(tree_pts_1Muscle.PathPoint,1));
        for i_pts = 1:nb_pts
            
            % Détermination du numéro du points
            
            num_pts = strsplit(tree_pts_1Muscle.PathPoint(i_pts).ATTRIBUTE.name,[muscle_name '-P']);
            num_pts = str2double(cell2mat(num_pts(end)));
            
            for i_f = 1:nb_frames
                Muscles_points(num_pts).location_in_Rs(1:3,1,i_f) = tree_pts_1Muscle.PathPoint(i_pts).location';
            end
            
            Muscles_points(num_pts).body = tree_pts_1Muscle.PathPoint(i_pts).body;
            Muscles_points(num_pts).muscle = muscle_name;
            Muscles_points(num_pts).num = num_pts;
            Muscles_points(num_pts).type = 'Fixed';
        end
        
    end
    
    
    % Conditional : Détecter l'angle du joint
    if isfield(tree_pts_1Muscle,'ConditionalPathPoint')
        nb_pts = max(size(tree_pts_1Muscle.ConditionalPathPoint,2),size(tree_pts_1Muscle.ConditionalPathPoint,1));
        for i_pts = 1:nb_pts
            
            % Détermination du numéro du points 
            num_pts = strsplit(tree_pts_1Muscle.ConditionalPathPoint(i_pts).ATTRIBUTE.name,[muscle_name '-P']);
            num_pts = str2double(cell2mat(num_pts(end)));
            
            Muscles_points(num_pts).body = tree_pts_1Muscle.ConditionalPathPoint(i_pts).body;
            Muscles_points(num_pts).muscle = muscle_name;
            Muscles_points(num_pts).num = num_pts;
               
            % On regarde quel coordinate est concerné
            Conditional_coord = tree_pts_1Muscle.ConditionalPathPoint(i_pts).coordinate;
            
            % On cherche la colonne dans coord_ik
            for i_crd = 1:length(coord_ik.noms)
                cur_coord = coord_ik.noms{i_crd};
                if strcmp(cur_coord,Conditional_coord)
                    num_col= i_crd;
                end
            end
            
            Angle = coord_ik.coord(:,num_col);
            
            range = tree_pts_1Muscle.ConditionalPathPoint(i_pts).range*180/pi;
            
            % On vérifie si la valeur de l'angle est dans l'intervalle de
            % creation du point
            test_range = find(range(1)<Angle & Angle<range(2));
            
            % Si non le points n'existe pas => matrice NaN
            if isempty(test_range) 
                for i_f = 1:nb_frames
                    Muscles_points(num_pts).location_in_Rs(1:3,1,i_f) = [nan ; nan; nan];
                end
                Muscles_points(num_pts).type = 'Conditional';
                % Si oui tout le temps le points existe il est ajouté
            elseif length(test_range)==length(Angle) && ~isempty(test_range)
                for i_f = 1:nb_frames
                    Muscles_points(num_pts).location_in_Rs(1:3,1,i_f) = tree_pts_1Muscle.ConditionalPathPoint(i_pts).location';
                end
                Muscles_points(num_pts).type = 'Conditional';
                % Si seulement à certains moments tout au long de l'essai
            elseif length(test_range)<length(Angle)
                
                %On écrit des nan pour toutes les frames
                for i_f = 1:nb_frames
                    Muscles_points(num_pts).location_in_Rs(1:3,1,i_f) = [nan ; nan; nan];
                end
                %On écrit les coordonnées du points pour les frames où l'angle est
                % assez grand
                for ii = 1:length(test_range)
                    i_f = test_range(ii);
                    Muscles_points(num_pts).location_in_Rs(1:3,1,i_f) = tree_pts_1Muscle.ConditionalPathPoint(i_pts).location';
                end
                Muscles_points(num_pts).type = 'Conditional';
            end
        end
    end
    
    % MMP : Détecter l'angle du joint pour placer le point dans le repère
    % segmentaire
    if isfield(tree_pts_1Muscle,'MovingPathPoint')
        nb_pts = max(size(tree_pts_1Muscle.MovingPathPoint,2),size(tree_pts_1Muscle.MovingPathPoint,1));
        for i_pts = 1:nb_pts
            
            % Détermination du numéro du points
            
            num_pts = strsplit(tree_pts_1Muscle.MovingPathPoint(i_pts).ATTRIBUTE.name,[muscle_name '-P']);
            num_pts = str2double(cell2mat(num_pts(end)));
            
            Muscles_points(num_pts).body = tree_pts_1Muscle.MovingPathPoint(i_pts).body;
            Muscles_points(num_pts).muscle = muscle_name;
            Muscles_points(num_pts).num = num_pts;
            
            % On regarde quel coordinate est concerné pour chaque direction
            d_xyz = {'x','y','z'};
            
            for i_dir=1:length(d_xyz)
                coordinate = [d_xyz{i_dir} '_coordinate'];
                location = [d_xyz{i_dir}  '_location'];
                
                coord.(d_xyz{i_dir} ) = tree_pts_1Muscle.MovingPathPoint(i_pts).(coordinate);
                
                % On cherche la colonne dans coord_ik
                for i_crd = 1:length(coord_ik.noms)
                    cur_coord = coord_ik.noms{i_crd};
                    if strcmp(cur_coord,coord.(d_xyz{i_dir} ))
                        num_col_2.(char(d_xyz{i_dir}) )= i_crd;
                    end
                end
                
                coord.(d_xyz{i_dir}) = Regression_Position_Point_Muscle_Rs( tree_pts_1Muscle.MovingPathPoint(i_pts).(location),...
                    coord_ik.coord(:, num_col_2.( d_xyz{i_dir} ) ) ) ;
            end
            
            new_coord_pt_Rs = permute([coord.x,coord.y,coord.z],[2,3,1]);
            
            Muscles_points(num_pts).location_in_Rs = new_coord_pt_Rs;
            Muscles_points(num_pts).type = 'Moving';
        end
    end

    %Certains points n'ont pas les numéros tous à la suite, on supprime les
    %lignes vides
    i_pts_prime = 0;
    
    for i_pts = 1:length(Muscles_points)
        i_pts = i_pts - i_pts_prime;
        if isempty(Muscles_points(i_pts).location_in_Rs)
            Muscles_points(i_pts)=[];
            i_pts_prime = i_pts_prime +1;
        end
    end
    
    
    %% 3) Placer les points du muscle dans R0 pour chaque frame
    
    for i_pts = 1 :length(Muscles_points)
        
        for i_frame = 1:nb_frames
            
            seg_pt = Muscles_points(i_pts).body;
            
            Muscles_points(i_pts).location_in_R0(:,:,i_frame) =...
                Struct_MH.(seg_pt).MH(:,:,i_frame) * [Muscles_points(i_pts).location_in_Rs(:,:,i_frame) ; 1 ];
            
        end
    end
    
    Struct_muscles_points.(muscle_name) = Muscles_points;
    
end
end