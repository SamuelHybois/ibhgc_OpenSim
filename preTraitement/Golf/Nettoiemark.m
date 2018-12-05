function [ st_mark_out,noms_mark_non_admissible ] = Nettoiemark( st_mark_in,ratio_NaN)
%fonction permettant d'enlever les marqueurs dans le fichier trc s'ils
%contiennent un ratio de NaN supérieur à ratio_NaN


st_mark_out=struct;
noms_mark=fieldnames(st_mark_in);
nb_mark=size(noms_mark,1);
nb_frame=size(st_mark_in.(noms_mark{1}),1);
nb_NaN_admissible=floor(nb_frame*ratio_NaN)*3;
noms_mark_non_admissible={};
for i_mark=1:nb_mark
    cur_nom_mark=noms_mark{i_mark};
    cur_coord=st_mark_in.(cur_nom_mark);
    [cur_N_NaN]=compteurNaN(cur_coord);
    if cur_N_NaN<=nb_NaN_admissible
        st_mark_out.(cur_nom_mark)=cur_coord;
    else
        noms_mark_non_admissible{end+1}=cur_nom_mark;
    end
    
end

end
