function [ num_frame_max , Mat_nb_mark,max_nb_mark ] = trouve_frame_max_marqueursV2( data_markers )
% fonction permettant de trouver la frame qui contient le plus de marqueur
% dans un fichier c3d.
% critère basé sur la norme (un marqueur manquant aura une norme de 0. 
% S'il existe une frame avec tous les marqueurs, la boucle s'arrête.
% Nota : le maximum de marqueurs considéré est celui du nombre de marqueur
% dans le C3D. 

noms_marqueurs=fieldnames(data_markers);
nb_marqueurs=length(noms_marqueurs);
nb_frame=size(data_markers.(noms_marqueurs{1}),1);

i_frame=0;
old_nb_mark=0;
old_num_frame_max=0;
test_mark=0;
Mat_nb_mark=[];
while test_mark==0
    i_frame=i_frame+1;
    cur_nb_mark=0;
    for i_mark=1:nb_marqueurs
        cur_mark=noms_marqueurs{i_mark};
        cur_data=data_markers.(cur_mark)(i_frame,:);
        if norm(cur_data)~=0
            cur_nb_mark=cur_nb_mark+1;
        end
    end
    Mat_nb_mark=[Mat_nb_mark; cur_nb_mark];
    if cur_nb_mark>old_nb_mark
        old_num_frame_max=i_frame;
        old_nb_mark=cur_nb_mark;
    end
    
    if cur_nb_mark==nb_marqueurs || i_frame==nb_frame
        test_mark=1;
        num_frame_max=old_num_frame_max;
    end
end

max_nb_mark=max(Mat_nb_mark);

end
