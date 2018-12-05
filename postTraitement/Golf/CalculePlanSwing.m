function [ st_plan_swing,st_param] = CalculePlanSwing( file_c3d,st_param,st_mark_club,noms_mark_plan_swing,portion,affichage,dossier_sauvegarde )
%UNTITLED13 Summary of this function goes here
%   Detailed explanation goes here
st_plan_swing=struct;
if affichage==1
    figure
    hold on
    taille_aff_1=floor((size(file_c3d,2))^0.5+1);
    if size(file_c3d,2)^0.5~=taille_aff_1
        taille_aff_2=taille_aff_1-1;
    end
end

for i_file=1:size(file_c3d,2)
    cur_file=file_c3d;
    [~,nom_c3d,~]=fileparts(cur_file);
    %% récupération des bornes du cycle
    cur_frame_debut_back=st_param.frame_debut;
    cur_frame_debut_down=st_param.frame_debut_downswing;
    cur_frame_impact=st_param.frame_impact;
    cur_frame_fin=st_param.frame_fin;
    
    
    offset=floor(portion*(cur_frame_fin-cur_frame_debut_down)); % on enlève un peu du début où le joueur est suceptible de faire un mouvement différent.
    pos_total=[];
    if affichage==1
        subplot(taille_aff_1,taille_aff_2,i_file)
        hold on
    end
    for i_mark=1:size(noms_mark_plan_swing,2)
        cur_nom_mark=noms_mark_plan_swing{i_mark};
        cur_pos=st_mark_club.(cur_nom_mark);
        cur_pos=cur_pos(cur_frame_debut_down+offset-cur_frame_debut_back:cur_frame_fin-cur_frame_debut_back,:);
        if affichage==1
            plot3(cur_pos(:,1),cur_pos(:,2),cur_pos(:,3))
        end
        pos_total=[pos_total;cur_pos];
    end
%     pos_total=remove_NaN(pos_total);
    [N,P]=plan_moindres_carres(pos_total);
    % on impose que la normale soit orienté vers le haut
    if N(1,3)<0
        N=-N;
    end
    st_plan_swing.normale=N;
    st_plan_swing.point=P;
%     visualisation_plan( N,P,4,[] )
end

if affichage==1
savefig(fullfile(dossier_sauvegarde,[nom_c3d '_trajectoire_marqueurs_club.fig']));
end


end

