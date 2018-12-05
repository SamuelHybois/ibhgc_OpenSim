function [Efforts]  = repartition_efforts_multi_appuis_gym(liste_appuis,st_pf_data,frame,row,xyz_force_location,CoM)

cur_fp=liste_appuis(frame,row);
list_effort=fieldnames(st_pf_data(cur_fp).channels);
Force=zeros(1,3);
Moment=zeros(1,3);
Position=zeros(1,3);
List_tmp={'pied_droit','pied_gauche','main_droite','main_gauche'};
list_row_same_fp=find(liste_appuis(frame,row)==liste_appuis(frame,:)); %nous donne les index dans le tableau "liste_appuis" des appuis simultanés

%Si on a un appui partiel il ne sera pas détecté par le test précédent on le fait donc ici
if length(list_row_same_fp)==1
    for i=1:4
        if contains(num2str(liste_appuis(frame,i)),num2str(liste_appuis(frame,row))) && i~=row
            list_row_same_fp=[row, i];
        end
    end
end


if length(list_row_same_fp)==2 %Deux appuis
    FP=['FP', num2str(cur_fp)];
    second_appui=list_row_same_fp(list_row_same_fp~=row);
    %On récupère le point d'application de la force et les deux CoM estimés
    Position_appui_A=[CoM.(List_tmp{row})(frame,1), 0, CoM.(List_tmp{row})(frame,3)];
    Position_appui_B=[CoM.(List_tmp{second_appui})(frame,1), 0, CoM.(List_tmp{second_appui})(frame,3)];
    Position_Force=xyz_force_location.(FP)(frame,:);
    %On projette en 2D le point d'application de la force mesurée par la
    %plateforme sur la droite qui relie les deux CoM
    point=[Position_Force(1) Position_Force(3)];
    line=[Position_appui_A(1) Position_appui_A(3) Position_appui_B(1)-Position_appui_A(1) Position_appui_B(3)-Position_appui_A(3)];
    projection_F=projPointOnLine(point,line);
    
    %On regarde si le point d'application de la force est entre les deux appuis
    if projection_F(1)>min(Position_appui_A(1),Position_appui_B(1)) && projection_F(1)<max(Position_appui_A(1),Position_appui_B(1))...
            && projection_F(2)>min(Position_appui_A(3),Position_appui_B(3)) && projection_F(1)<max(Position_appui_A(3),Position_appui_B(3))
        ratio=1-(sqrt((Position_appui_A(1)-projection_F(1))^2+(Position_appui_A(3)-projection_F(2))^2)/sqrt((Position_appui_A(1)-Position_appui_B(1))^2+(Position_appui_A(3)-Position_appui_B(3))^2));
    elseif sqrt((projection_F(1)-Position_appui_A(1))^2+(projection_F(2)-Position_appui_A(3))^2) < sqrt((projection_F(1)-Position_appui_B(1))^2+(projection_F(2)-Position_appui_B(3))^2)
        ratio=1;
        for i_axe=1:3
            %Si toute la force passe par un seul appui, on lui attribu le moment aussi
            Moment(1,i_axe)=st_pf_data(cur_fp).channels.(list_effort{i_axe+3})(frame);
        end
    else
        ratio=0;
    end
 
      
    %On multiplie la force par le ratio
    for i_axe=1:3
        Force(1,i_axe)=st_pf_data(cur_fp).channels.(list_effort{i_axe})(frame)*ratio;
    end

    %  ????Que faire des MOMENTS????
    
    
    %On donne à la force un point d'appui au niveau du CoM estimé plus tôt
    %grâce aux marqueurs(pour vérification sur OS)
    Position=[CoM.(List_tmp{row})(frame,1), 0, CoM.(List_tmp{row})(frame,3)];
    
    
    
elseif length(list_row_same_fp)==3 %Trois appuis
elseif length(list_row_same_fp)==4 %Quatre appuis
end

Efforts = [Force Moment Position];
end