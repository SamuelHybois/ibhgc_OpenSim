function Liste_Joints = ListeJointCroiseMuscle(Muscle,Struct_muscles_points,Bodies,Joints)

 cur_muscle = Muscle;
    
    %Liste des bodies où le muscles s'attache
    nb_pts = length(Struct_muscles_points.(cur_muscle));
    ListeBody = cell(1,nb_pts);
    for i_pts = 1:nb_pts
        ListeBody{i_pts} = Struct_muscles_points.(cur_muscle)(i_pts).body;
    end
    ListeBody = unique(ListeBody);
    
    
%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
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
            ListeBody2 = { ListeBodybis{1:nb_body - i_body}, ...
            ListeBody_new{1:end}, ListeBodybis{nb_body - i_body +1:end} };
        else
            ListeBody2 = ListeBodybis;
        end
    end
    ListeBody2 = unique(ListeBody2,'stable');
%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

    %Trouver les articulations croisées par le muscle
    %Liste des joints croisés
    j = fieldnames(Joints);
    i_list_joint = 1;
    Liste_Joints = cell(1);
    for i_j = 1:length(j)
        cur_j = j{i_j};
        
        test_parent = ~isempty(find(strcmp( Joints.(cur_j).Parent, ListeBody2)==1, 1));
        test_enfant = ~isempty(find(strcmp( Joints.(cur_j).Child, ListeBody2)==1, 1));
        
        if test_parent && test_enfant
            Liste_Joints{i_list_joint} = cur_j;
            i_list_joint = i_list_joint + 1;
            
        end
    end
    Liste_Joints = unique(Liste_Joints,'stable');
    
end