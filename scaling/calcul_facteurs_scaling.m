function st_factors=calcul_facteurs_scaling(st_mrk_reel,st_mrk_model,st_prot,nb_frame)

% num_frame_max=trouve_frame_max_marqueursV2(st_trc); % on cherche la frame avec le maximum de marqueurs pour tous les avoir
list_factor=fieldnames(st_prot.SCALING); % Liste des facteurs de scaling à calculer
nb_factor=size(list_factor,1);

dist1_reel(nb_frame)=0;
dist2_reel(nb_frame)=0;
dist_reel(nb_frame)=0;

for i_factor=1:nb_factor
    cur_factor=list_factor{i_factor};
    mrk_scale=st_prot.SCALING.(list_factor{i_factor}); % Marqueurs à utiliser pour calculer les facteurs de scaling
    if size(mrk_scale,2)==4 % Si deux paires de marqueurs, on fait la moyenne des deux scale factor
        for i_frame=1:nb_frame
            dist1_reel(i_frame)=norm(st_mrk_reel.(mrk_scale{1})(i_frame,:)-st_mrk_reel.(mrk_scale{2})(i_frame,:));
            dist2_reel(i_frame)=norm(st_mrk_reel.(mrk_scale{3})(i_frame,:)-st_mrk_reel.(mrk_scale{4})(i_frame,:));
        end
        dist1_trc_moy=nanmean(dist1_reel);
        dist2_trc_moy=nanmean(dist2_reel);
        dist1_model=norm(st_mrk_model.(mrk_scale{1}).location-st_mrk_model.(mrk_scale{2}).location);
        dist2_model=norm(st_mrk_model.(mrk_scale{3}).location-st_mrk_model.(mrk_scale{4}).location);
        scale1=dist1_trc_moy/dist1_model;
        scale2=dist2_trc_moy/dist2_model;
        scale=(scale1+scale2)/2;
    elseif size(mrk_scale,2)==2
        for i_frame=1:nb_frame
            dist_reel(i_frame)=norm(st_mrk_reel.(mrk_scale{1})(i_frame,:)-st_mrk_reel.(mrk_scale{2})(i_frame,:));
        end
        dist_trc_moy=nanmean(dist_reel);
        dist_model=norm(st_mrk_model.(mrk_scale{1}).location-st_mrk_model.(mrk_scale{2}).location);
        scale=dist_trc_moy/dist_model;
    end
    % On range les facteurs dans un struct
    cur_seg=cur_factor(1:end-1);
    cur_axe=cur_factor(end);
    switch cur_axe
        case 'X'
            ind=1;
        case 'Y'
            ind=2;
        case 'Z'
            ind=3;
    end
    st_factors.(cur_seg)(ind)=scale;
end

end