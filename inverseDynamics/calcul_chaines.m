function chaines_stockees=calcul_chaines(struct_bodies)
list_bodies=fieldnames(struct_bodies);
nb_body=size(list_bodies,1);
% M_parent(nb_body,nb_body)=0;
M_enfant(nb_body,nb_body)=0;
for i_body=1:nb_body
    cur_body=list_bodies{i_body};
%     if ~isempty(struct_bodies.(cur_body).Parent)
%         M_parent(i_body,cell2mat(struct_bodies.(cur_body).Parent(:,2)))=1;
%     end
    if ~isempty(struct_bodies.(cur_body).Children)
        M_enfant(i_body,cell2mat(struct_bodies.(cur_body).Children(:,2)))=1;
    end
end
% M_adj=M_parent+M_enfant;

extremites=find(sum(M_enfant,2)==0);
noeuds=find(sum(M_enfant,2)>1);
ind_ground=find(sum(M_enfant,1)==0);

%% On cherche les chaines en partant des extrémités
for i_extremite=1:size(extremites,1)
    cur_extremite=extremites(i_extremite);
    cur_parent=find(M_enfant(:,cur_extremite),1);
    chaine=cur_extremite;
    if length(cur_parent)>1
        % Boucle fermée à faire
        disp('Boucle fermée détectée, changez de modèle')
    else
        while isempty(find(noeuds==cur_parent,1))
            chaine=[chaine,cur_parent];
            cur_parent=find(M_enfant(:,cur_parent),1);
        end
        chaine=[chaine,cur_parent]; % Pour ajouter le noeud
        chaines_stockees.noeud_fin{i_extremite}=chaine;
    end
end

list_bodies_trouves=unique(cell2mat(chaines_stockees.noeud_fin));
if size(list_bodies_trouves,2)~=size(list_bodies,1) % On cherche si on a trouvé toutes les chaines
    % Chaines manquantes : celles qui sont entre deux noeuds
    for i_noeud=1:size(noeuds,1);
        cur_noeud=noeuds(i_noeud);
        chaine=cur_noeud;
        cur_parent=find(M_enfant(:,cur_noeud),1);
        
        while isempty(find(noeuds==cur_parent,1))
            chaine=[chaine,cur_parent];
            cur_parent=find(M_enfant(:,cur_parent),1);
            if isempty(cur_parent)
                cur_parent=ind_ground;
                break
            end
        end
        chaine=[chaine,cur_parent]; % Pour ajouter le noeud
        chaines_stockees.noeud_noeud{i_noeud}=unique(chaine);
    end
end
chaines_stockees.extremites=extremites;
chaines_stockees.noeuds=noeuds;
chaines_stockees.ind_ground=ind_ground;
end

