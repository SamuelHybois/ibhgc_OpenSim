function Struct_BL = calcul_bras_de_levier_musculaire(Bodies,Joints,Struct_CoR,Struct_muscles_points)

muscles = fieldnames(Struct_muscles_points);
nb_frames = size(Struct_muscles_points.(muscles{1})(1).location_in_R0,3);

for i_m = 1:length(muscles)
    
    cur_muscle = muscles{i_m};
    
    %Liste des bodies où le muscles s'attache
    nb_pts = length(Struct_muscles_points.(cur_muscle));
    ListeBody = cell(1,nb_pts);
    for i_pts = 1:nb_pts
        ListeBody{i_pts} = Struct_muscles_points.(cur_muscle)(i_pts).body;
    end
    ListeBody = unique(ListeBody);
    
    %On ajoute les body qui sont manquants entre les segments présents dans
    %la liste
    %ex : deux body pour le semiten (pelvis et tibia), il nous faut le
    %fémur pour bien prendre en compte les articulations.
    ListeBodybis = ListeBody;
    nb_body = length(ListeBodybis);
    for i_body = 1:nb_body-1
        clear ListeBody_new
        cur_body = ListeBodybis{nb_body - i_body +1};
        prev_body = ListeBodybis{nb_body - i_body};
        
        ListeBody_new = Bodies_Intermediaires( Bodies,prev_body,cur_body );
        %Je n'ai pas vérifié pour des cas plus complexe que un segment
        %manquant
        if exist('ListeBody_new') && ~isempty(ListeBody_new) %#ok<EXIST> 
            ListeBody = { ListeBodybis{1:nb_body - i_body}, ...
            ListeBody_new{1:end}, ListeBodybis{nb_body - i_body +1:end} };
        end
    end
    ListeBody = unique(ListeBody,'stable');
    
    %Trouver les articulations croisées par le muscle
    %Liste des joints croisés
    j = fieldnames(Joints);
    i_list_joint = 1;
    Liste_Joints = cell(1);
    for i_j = 1:length(j)
        cur_j = j{i_j};
        
        test_parent = ~isempty(find(strcmp( Joints.(cur_j).Parent, ListeBody)==1, 1));
        test_enfant = ~isempty(find(strcmp( Joints.(cur_j).Child, ListeBody)==1, 1));
        
        if test_parent && test_enfant
            Liste_Joints{i_list_joint} = cur_j;
            i_list_joint = i_list_joint + 1;
            %         elseif test_parent2
            %             Liste_Joints{i_list_joint} = cur_j;
            %             i_list_joint = i_list_joint + 1;
            %         elseif test_enfant2
            %             Liste_Joints{i_list_joint} = cur_j;
            %             i_list_joint = i_list_joint + 1;
        end
    end
    Liste_Joints = unique(Liste_Joints,'stable');
    
    %On construit une liste de points possibles, points de définition du
    %muscles
    % ou intersection droite entre points et plan normal à la droite
    %passant par CoR
    clear Liste_Point
    % ajout des points de definition du muscle
    nb_pts = length(Struct_muscles_points.(cur_muscle));
    for i_pts = 1:nb_pts
        Liste_Point(i_pts).val = Struct_muscles_points.(cur_muscle)(i_pts).location_in_R0;
        Liste_Point(i_pts).type = 'via_points';
    end
    % ajout des points d'intersection droite et plan à la liste
    % Boucle de monstre %% ATTENTION
    % On va obtenir (nb_pts-1)*nombredejoints de points en plus
    nb_jts = length(Liste_Joints);
    nb_pts_av = nb_pts;
    for i_jt = 1 : nb_jts;
        cur_jt = Liste_Joints{i_jt};
        cur_CoR = Struct_CoR.(cur_jt);
        for i_pts = 1 : nb_pts-1;
            nb_pts_av = nb_pts_av + 1;
            for i_f = 1:nb_frames
                
                P1_m = Struct_muscles_points.(cur_muscle)(i_pts).location_in_R0(:,:,i_f);
                P2_m = Struct_muscles_points.(cur_muscle)(i_pts+1).location_in_R0(:,:,i_f);
                
                if ~isnan(P2_m(1,1))
                    if ~isnan(P1_m(1,1))
                        Pnew = [calcul_point_plus_proche_CoR( P1_m ,P2_m , cur_CoR(:,:,i_f)); 1];
                    elseif isnan(P1_m(1,1)) % si le point n'existe pas car conditional
                        % On prend le point précédent !
                        P1_m = Struct_muscles_points.(cur_muscle)(i_pts-1).location_in_R0(:,:,i_f);
                        if isnan(P1_m(1,1)) % On prend le point encore d'avant
                            P1_m = Struct_muscles_points.(cur_muscle)(i_pts-2).location_in_R0(:,:,i_f);
                        end
                        Pnew = [calcul_point_plus_proche_CoR( P1_m ,P2_m , cur_CoR(:,:,i_f)) ; 1];
                    end
                    
                elseif isnan(P2_m(1,1))
                    Liste_Point(nb_pts_av).val(:,:,i_f) = [nan;nan;nan;nan]; % si le point n'existe pas car conditional
                end
                
                % On vérifie que le nouveau point est bien entre les deux
                % points de définition du muscles sinon NaN
                if ~isnan(P2_m(1,1))
                    P1_P2 = norm( P2_m(1:3,1)- P1_m(1:3,1) );
                    P1_Pnew = norm( Pnew(1:3,1)- P1_m(1:3,1) );
                    P2_Pnew = norm( Pnew(1:3,1)- P2_m(1:3,1) );
                    
                    if P1_Pnew< P1_P2 && P2_Pnew< P1_P2
                        Liste_Point(nb_pts_av).val(:,:,i_f) = Pnew;
                    else
                        Liste_Point(nb_pts_av).val(:,:,i_f) = [nan;nan;nan;nan];
                    end
                    Liste_Point(nb_pts_av).type = 'distance_CoR_droite';
                end
            end
            
        end
    end
    
    nb_points = length(Liste_Point);
    
    clear BL
    clear AB
    for i_jt = 1:length(Liste_Joints) % Pour chaque joint
        cur_jt = Liste_Joints{i_jt};
        for i_pts = 1:nb_points % Pour chaque pt
            
            A = Liste_Point(i_pts).val;
            B = Struct_CoR.(cur_jt);
            
            %Distance points du muscles vers CoR (faire l'inverse ??)
            % (dans R0)
            AB.(cur_jt)(1:3,1,:,i_pts) = B(1:3,1,:)-A(1:3,1,:);
            
        end
        % On doit comparer pour chaque frame quel points est le plus proche
        BL = zeros(size(AB.(cur_jt),3) , size(AB.(cur_jt),4));
        for i_f = 1:size(AB.(cur_jt),3)
            for i_pts = 1:size(AB.(cur_jt),4)
                BL(i_f,i_pts) = norm(AB.(cur_jt)(1:3,1,i_f,i_pts));
            end
        end
        [Struct_BL.(cur_jt).(cur_muscle).distance_BL , num_pts_BL] = min(BL,[],2);
        
        % On retient le points et la disntance pour lesquels la distance est la plus courte à
        % chaque frame
        for  i_f = 1:size(AB.(cur_jt),3)
            Struct_BL.(cur_jt).(cur_muscle).Points_BL_dans_R0(:,1,i_f) = Liste_Point(num_pts_BL(i_f)).val(:,1,i_f) ;
            Struct_BL.(cur_jt).(cur_muscle).BL_dans_R0(:,1,i_f) = AB.(cur_jt)(:,1,i_f,num_pts_BL(i_f));
        end
        
    end
end

% end