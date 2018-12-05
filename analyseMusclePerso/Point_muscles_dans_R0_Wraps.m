function [Struct_muscles_points,Struct_muscle_wraps,Struct_wrapping_points] ...
    = Point_muscles_dans_R0_Wraps(tree,Struct_MH,coord_ik,Wraps,nb_frames)

clear Struct_muscles_points
Struct_muscles_points = struct;
Struct_wrapping_points = struct;
if nargin<5
nb_frames = length(coord_ik.tps);
end
point_types={'PathPoint','MovingPathPoint','ConditionalPathPoint'};
%% Type de muscle %Millard,Schutte,Thelen
tree_force = tree.Model.ForceSet.objects;
Forceset_fields = fieldnames(tree_force);
if length(Forceset_fields)==1
    tree_muscle = tree.Model.ForceSet.objects.(Forceset_fields{1});
    Muscletype = Forceset_fields{1};
elseif length(Forceset_fields)>1
    tree_muscle = tree.Model.ForceSet.objects.(Forceset_fields{2});
    Muscletype = Forceset_fields{2};
end
%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%% 1) Wrapping dans R0 (Matrice homogène M_R0_Rw)
%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
nb_w_tot = length(Wraps);
%1)  On place les wraps dans R0
%On place la position des Wraps dans R0 pour chaque frame
for i_w = 1 :nb_w_tot
    for i_frame = 1:nb_frames
        seg_pt = Wraps(i_w).Body;
        
        Wraps(i_w).MH_R0_Rw(:,:,i_frame) =...
            Struct_MH.(seg_pt).MH(:,:,i_frame) * Wraps(i_w).MH_Rs_Rw;
    end
end

%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%% 2) Récupérer les points d'un muscle
%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
for i_muscle = 1:length(tree_muscle)
    clear tree_pts_1Muscle;
    clear Muscles_points;
    clear tree_pts_1Muscle;
    clear struct_Wraping_Points;
    muscle_name = tree_muscle(i_muscle).ATTRIBUTE.name;
    if ~isempty(strfind(muscle_name,'_l'))
        % On organise l'arbre des points du muscle
        for i_pt_type = 1:length(point_types)
            cur_pt_type = point_types{i_pt_type};
            if isfield( tree_muscle(i_muscle).GeometryPath.PathPointSet.objects ,cur_pt_type)
                
                tree_pts_1Muscle.(cur_pt_type) =...
                    tree_muscle(i_muscle).GeometryPath.PathPointSet.objects.(cur_pt_type);
            end
        end
        %xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        %% 3) On organise les données selon les Types (MMP,viaP,cdtionalP)..
        % de points dans le Repère Segmentaire
        %xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        % PathPoint : Fixed ne rien faire
        %xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
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
        %xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        % Conditional : Détecter l'angle du joint (à partir du fichier de l'ik)
        % prevoir à partir du BodyKinematics...
        %xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
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
        %xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        % MMP : Détecter l'angle du joint pour placer le point dans le repère
        % segmentaire (grace ik.mot) => prevoir à partir du BodyKinematics
        %xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
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
                    
                    coord.(d_xyz{i_dir}) = Regression_Position_Point_Muscle_Rs( ...
                        tree_pts_1Muscle.MovingPathPoint(i_pts).(location),...
                        coord_ik.coord(:, num_col_2.( d_xyz{i_dir} ) ) ) ;
                end
                
                new_coord_pt_Rs = permute([coord.x,coord.y,coord.z],[2,3,1]);
                
                Muscles_points(num_pts).location_in_Rs = new_coord_pt_Rs;
                Muscles_points(num_pts).type = 'Moving';
            end
        end
        
        %Certains points n'ont pas les numéros tous à la suite, on supprime les
        %lignes vides (P1,P2,[],P4)=>(P1,P2,P4)
        i_pts_prime = 0;
        nb_pt_muscle = length(Muscles_points);
        
        for i_pts = 1:nb_pt_muscle
            i_pts = i_pts - i_pts_prime;
            if isempty(Muscles_points(i_pts).location_in_Rs)
                Muscles_points(i_pts)=[];
                i_pts_prime = i_pts_prime +1;
            end
        end
        
        
        %% 4) Placer les points du muscle dans R0 pour chaque frame
        
        for i_pts = 1 :length(Muscles_points)
            for i_frame = 1:nb_frames
                seg_pt = Muscles_points(i_pts).body;
                Muscles_points(i_pts).location_in_R0(:,:,i_frame) =...
                    Struct_MH.(seg_pt).MH(:,:,i_frame) *...
                    [Muscles_points(i_pts).location_in_Rs(:,:,i_frame) ; 1 ];
            end
        end
        
        Struct_muscles_points.(muscle_name) = Muscles_points;
        %xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        %% 5) Wrapping
        %xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        %5.1) On ajoute des wraps du muscles, S'il y en a...
        try
            bool_Wraps1 = ~isempty(tree_muscle(i_muscle).GeometryPath.PathWrapSet);
            bool_Wraps2 = isfield(tree_muscle(i_muscle).GeometryPath.PathWrapSet,'objects');
            bool_Wraps3 = ~isempty(tree_muscle(i_muscle).GeometryPath.PathWrapSet.objects);
            bool_Wraps4 = ~isempty(tree_muscle(i_muscle).GeometryPath.PathWrapSet.objects.PathWrap);
        catch
            bool_Wraps1 =0;
        end
        
        if     bool_Wraps1 && bool_Wraps2 && bool_Wraps3 && bool_Wraps4
            nb_mw=length(tree_muscle(i_muscle).GeometryPath.PathWrapSet.objects.PathWrap);
            for i_mw = 1:nb_mw
                cur_mw = tree_muscle(i_muscle).GeometryPath.PathWrapSet.objects.PathWrap(i_mw);
                for i_w=1 :nb_w_tot
                    if strcmp(cur_mw.wrap_object,Wraps(i_w).Nom)
                        tree_pts_1Muscle.Wraps(i_mw) = Wraps(i_w);
                    end
                end
            end
            
            Wraps_m = tree_pts_1Muscle.Wraps;
            
            %5.2) On passe les points des muscles dans le repère des wraps Rw concernés
            for i_pts = 1 :length(Muscles_points)
                for i_mw=1:nb_mw
                    for i_frame = 1:nb_frames
                        Muscles_points(i_pts).location_in_Rw.(Wraps_m(i_mw).Nom)(:,:,i_frame)=...
                            Wraps_m(i_mw).MH_R0_Rw(:,:,i_frame)\Muscles_points(i_pts).location_in_R0(:,:,i_frame);
                        % ce qui est commenté n'est pas la même chose
                        % il faut faire attention car il faut repasser par
                        % R0 quand le wraps n'est pas défini dans le même
                        % repère local que le point.
                        %Muscles_points(i_pts).location_in_Rw.(Wraps_m(i_mw).Nom)(:,:,i_frame)=...
                        %   Wraps_m(i_mw).MH_Rs_Rw\[Muscles_points(i_pts).location_in_Rs(:,:,i_frame);1];
                    end
                end
            end
            
            
            %5.3) On vérifie si les points croises les wraps et crée des points
            %nouveaux sur la surface exterieure associée du wraps pouur chaque
            %type excepté le tore.
            struct_Wraping_Points = struct;
            for i_mw=1:nb_mw
                %
                for i_pts = 2 : length(Muscles_points)
                    i_pair = i_pts-1;
                    
                    for i_f = 1:nb_frames
                        clear nan_pts
                        prev_pt = Muscles_points(i_pts-1).location_in_Rw.(Wraps_m(i_mw).Nom)(:,:,i_f);
                        cur_pt = Muscles_points(i_pts).location_in_Rw.(Wraps_m(i_mw).Nom)(:,:,i_f) ;
                        
                        if  ~isnan(cur_pt(1))
                            nan_pts=0;
                            if isnan(prev_pt(1))
                                i_pts_prev = i_pts-1;
                                while isnan(prev_pt)
                                    i_pts_prev = i_pts_prev-1;
                                    prev_pt = Muscles_points(i_pts_prev-1).location_in_Rw.(Wraps_m(i_mw).Nom)(:,:,i_f);
                                end
                                nan_pts=1;
                            end
                            
                            if strcmp(Wraps_m(i_mw).type,'WrapCylinder')
                                
                                % on vérifie si les points sont à l'extérieur de
                                % l'objets
                                bool_pt1 = IsInside_Cylinder(Wraps_m(i_mw),prev_pt);
                                bool_pt2 = IsInside_Cylinder(Wraps_m(i_mw),cur_pt);
                                
                                %Si le premier point est dans l'objet alors on ne
                                %contourne pas
                                if i_pair ==1 && bool_pt1==1
                                    %rien
                                    
                                elseif bool_pt2==1 && i_pts == length(Muscles_points)
                                    struct_Wraping_Points(i_pair).pts(:,:,i_f)=[i_pts-1 i_pts];
                                    struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).bool(:,:,i_f) = 0;
                                    struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).Pts_in_Rw(:,:,i_f) = repmat([nan;nan;nan],[1,45]);
                                    struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).bool(:,:,i_f) = nan;
                                    
                                    %Si le deuxieme point est dans l'objet alors on passe
                                    %au points suivant
                                elseif bool_pt2==1
                                    %rien
                                    
                                    %Si le premier point est dans l'objet alors on prend
                                    %le points précédent
                                elseif bool_pt1==1
                                    i_prev = i_pts-1;
                                    while IsInside_Cylinder(Wraps_m(i_mw),prev_pt)==1 && i_prev>0
                                        prev_pt = Muscles_points(i_prev).location_in_Rw.(Wraps_m(i_mw).Nom)(:,:,i_f);
                                        i_prev = i_prev-1;
                                    end
                                    
                                    if i_prev==0
                                        %on ne fait rien : tous les points précédents
                                        %sont dans l'objet wraps
                                    else
                                        % On contourne
                                        struct_Wraping_Points(i_pair).pts(:,:,i_f)=[i_prev i_pts];
                                        
                                        [struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).Pts_in_Rw(:,:,i_f),...
                                            struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).Longueur(:,:,i_f),...
                                            struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).bool(:,:,i_f)] ...
                                            = ContourneCylinder(Wraps_m(i_mw),prev_pt,cur_pt);
                                    end
                                    
                                elseif bool_pt2==0 && bool_pt1==0
                                    % Comment je vais gérer le saut de points pour chaque frame ??
                                    
                                    % On contourne
                                    if nan_pts==1
                                        struct_Wraping_Points(i_pair).pts(:,:,i_f)=[i_pts_prev-1 i_pts];
                                    else
                                        struct_Wraping_Points(i_pair).pts(:,:,i_f)=[i_pts-1 i_pts];
                                    end
                                    [struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).Pts_in_Rw(:,:,i_f),...
                                        struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).Longueur(:,:,i_f),...
                                        struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).bool(:,:,i_f)] ...
                                        = ContourneCylinder(Wraps_m(i_mw),prev_pt,cur_pt);
                                end
                                
                                
                            elseif strcmp(Wraps_m(i_mw).type,'WrapEllipsoid')
                                % en en cours solution non définitive.
                                % on vérifie si les points sont à l'extérieur de
                                % l'objets
                                bool_pt1 = IsInside_Ellipsoid(Wraps_m(i_mw),prev_pt);
                                bool_pt2 = IsInside_Ellipsoid(Wraps_m(i_mw),cur_pt);
                                
                                %Si le premier point est dans l'objet alors on ne
                                %contourne pas
                                if i_pair ==1 && bool_pt1==1
                                    %rien
                                    
                                elseif bool_pt2==1 && i_pts == length(Muscles_points)
                                    struct_Wraping_Points(i_pair).pts(:,:,i_f)=[i_pts-1 i_pts];
                                    struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).bool(:,:,i_f) = 0;
                                    struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).Pts_in_Rw(:,:,i_f) = repmat([nan;nan;nan],[1,45]);
                                    struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).bool(:,:,i_f) = nan;
                                    
                                    %Si le deuxieme point est dans l'objet alors on passe
                                    %au points suivant
                                elseif bool_pt2==1
                                    %rien
                                    
                                    %Si le premier point est dans l'objet alors on prend
                                    %le points précédent
                                elseif bool_pt1==1
                                    i_prev = i_pts-1;
                                    while IsInside_Ellipsoid(Wraps_m(i_mw),prev_pt)==1 && i_prev>0
                                        prev_pt = Muscles_points(i_prev).location_in_Rw.(Wraps_m(i_mw).Nom)(:,:,i_f);
                                        i_prev = i_prev-1;
                                    end
                                    
                                    if i_prev==0
                                        %on ne fait rien : tous les points précédents
                                        %sont dans l'objet wraps
                                    else
                                        % On contourne
                                        struct_Wraping_Points(i_pair).pts(:,:,i_f)=[i_prev i_pts];
                                        
                                        [struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).Pts_in_Rw(:,:,i_f),...
                                            struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).Longueur(:,:,i_f),...
                                            struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).bool(:,:,i_f)]...
                                            = ContourneEllipsoid(Wraps_m(i_mw),prev_pt,cur_pt);
                                    end
                                    
                                elseif bool_pt2==0 && bool_pt1==0
                                    % On contourne
                                    if nan_pts==1
                                        struct_Wraping_Points(i_pair).pts(:,:,i_f)=[i_pts_prev-1 i_pts];
                                    else
                                        struct_Wraping_Points(i_pair).pts(:,:,i_f)=[i_pts-1 i_pts];
                                    end
                                    
                                    [struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).Pts_in_Rw(:,:,i_f),...
                                        struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).Longueur(:,:,i_f),...
                                        struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).bool(:,:,i_f)]...
                                        = ContourneEllipsoid(Wraps_m(i_mw),prev_pt,cur_pt);
                                end
                            elseif strcmp(Wraps_m(i_mw).type,'WrapTorus')
                                % pas encore géré
                            elseif strcmp(Wraps_m(i_mw).type,'WrapSphere')
                                % on vérifie si les points sont à l'extérieur de
                                % l'objets
                                bool_pt1 = IsInside_Sphere(Wraps_m(i_mw),prev_pt);
                                bool_pt2 = IsInside_Sphere(Wraps_m(i_mw),cur_pt);
                                
                                %Si le premier point est dans l'objet alors on ne
                                %contourne pas
                                if i_pair ==1 && bool_pt1==1
                                    %rien
                                    
                                elseif bool_pt2==1 && i_pts == length(Muscles_points)
                                    struct_Wraping_Points(i_pair).pts(:,:,i_f)=[i_pts-1 i_pts];
                                    struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).bool(:,:,i_f) = 0;
                                    struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).Pts_in_Rw(:,:,i_f) = repmat([nan;nan;nan],[1,45]);
                                    struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).bool(:,:,i_f) = nan;
                                    
                                    %Si le deuxieme point est dans l'objet alors on passe
                                    %au points suivant
                                elseif bool_pt2==1
                                    %rien
                                    
                                    %Si le premier point est dans l'objet alors on prend
                                    %le points précédent
                                elseif bool_pt1==1
                                    i_prev = i_pts-1;
                                    while IsInside_Sphere(Wraps_m(i_mw),prev_pt)==1 && i_prev>0
                                        prev_pt = Muscles_points(i_prev).location_in_Rw.(Wraps_m(i_mw).Nom)(:,:,i_f);
                                        i_prev = i_prev-1;
                                    end
                                    
                                    if i_prev==0
                                        %on ne fait rien : tous les points précédents
                                        %sont dans l'objet wraps
                                    else
                                        % On contourne
                                        struct_Wraping_Points(i_pair).pts(:,:,i_f)=[i_prev i_pts];
                                        
                                        [struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).Pts_in_Rw(:,:,i_f),...
                                            struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).Longueur(:,:,i_f),...
                                            struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).bool(:,:,i_f)] ...
                                            = ContourneSphere(Wraps_m(i_mw),prev_pt,cur_pt);
                                    end
                                    
                                elseif bool_pt2==0 && bool_pt1==0
                                    % Comment je vais gérer le saut de points pour chaque frame ??
                                    
                                    % On contourne
                                    if nan_pts==1
                                        struct_Wraping_Points(i_pair).pts(:,:,i_f)=[i_pts_prev-1 i_pts];
                                    else
                                        struct_Wraping_Points(i_pair).pts(:,:,i_f)=[i_pts-1 i_pts];
                                    end
                                    
                                    [struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).Pts_in_Rw(:,:,i_f),...
                                        struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).Longueur(:,:,i_f),...
                                        struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).bool(:,:,i_f)] ...
                                        = ContourneSphere(Wraps_m(i_mw),prev_pt,cur_pt);
                                end
                                
                            end
                        else
                             struct_Wraping_Points(i_pair).pts(:,:,i_f)=[i_pts-1 i_pts];
                                    struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).bool(:,:,i_f) = 0;
                                    struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).Pts_in_Rw(:,:,i_f) = repmat([nan;nan;nan],[1,45]);
                                    struct_Wraping_Points(i_pair).( Wraps_m(i_mw).Nom ).bool(:,:,i_f) = nan;
                                    
                        end %if isnan
                    end % for frame
                end % chaque points (pair)
            end
            
            %5.4)Placer les points des wraps muscle dans R0 pour chaque frame
            nb_pair_muscle = length(struct_Wraping_Points);
            for i_pair = 1 :nb_pair_muscle
                for i_w_m = 1:nb_mw
                    cur_w_m = Wraps_m(i_w_m).Nom;
                    
                    for i_f =1:nb_frames
                        if isfield(struct_Wraping_Points(i_pair),(cur_w_m))
                            if ~isempty( struct_Wraping_Points(i_pair).(cur_w_m) )
                                %i_c tous les points créée à la surface du
                                %wraps assumé 45 pts.
                                
                                for i_c=1:size(struct_Wraping_Points(i_pair).( cur_w_m).Pts_in_Rw(:,:,i_f),2)
                                    
                                    struct_Wraping_Points(i_pair).( cur_w_m ).Pts_in_R0(:,i_c,i_f) =...
                                        Wraps_m(i_w_m).MH_R0_Rw(:,:,i_f) ...
                                        * [struct_Wraping_Points(i_pair).( cur_w_m ).Pts_in_Rw(:,i_c,i_f) ; 1 ];
                                end
                            end
                        end
                    end
                    
                end
            end
            
            Struct_muscles_points.(muscle_name) = Muscles_points;
            Struct_muscle_wraps.(muscle_name) = Wraps_m;
            Struct_wrapping_points.(muscle_name)=struct_Wraping_Points;
            
        end
        
    end% si c'est un muscle du coté gauche.
end% boucle muscle

end