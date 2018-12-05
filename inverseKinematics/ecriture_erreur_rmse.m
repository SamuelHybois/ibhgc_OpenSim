function ecriture_erreur_rmse(fichier_trc,fichier_sto)

[rep_sortie,nom_sortie,~]=fileparts(fichier_trc);
%fichier_trc : issu du c3d expérimental : positions "vraies" des markers
%fichier_sto : issu de l'IK : positions reconstruites des markers

marqueurs_sto=load_sto_file(fichier_sto);
data_trc = lire_donnees_trc(fichier_trc);

%Gestion des cas de fichiers de durées différentes%

ti_1=data_trc.tps(1,1);
tf_1=data_trc.tps(end,1);

ti_2=marqueurs_sto.time(1,1);
tf_2=marqueurs_sto.time(end,1);

Temps_ini = max(ti_1,ti_2);
Temps_fin = min(tf_1,tf_2);

index_sto = find(marqueurs_sto.time(:,1)>=Temps_ini & marqueurs_sto.time(:,1)<=Temps_fin);
index_trc = find(data_trc.tps(:,1)>=Temps_ini & data_trc.tps(:,1)<=Temps_fin);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

st_RMSE_sto={};
noms_marqueurs=fieldnames(marqueurs_sto);
for i_marqueurs=1:length(noms_marqueurs)
    tmp_marqueurs=noms_marqueurs{i_marqueurs};
    if strcmp('Er_',tmp_marqueurs(1:3))~=1 && strcmp('tx',tmp_marqueurs(end-1:end))
       cur_marqueur=tmp_marqueurs(1:end-3); 
       cur_x=[cur_marqueur '_tx'];
       cur_x=marqueurs_sto.(cur_x)(index_sto);
       cur_y=[cur_marqueur '_ty'];
       cur_y=marqueurs_sto.(cur_y)(index_sto);
       cur_z=[cur_marqueur '_tz'];
       cur_z=marqueurs_sto.(cur_z)(index_sto);
       [coord_trc] = lire_coord_marqueur_trc(cur_marqueur,fichier_trc);
       coord_trc = coord_trc(index_trc,:);
       st_RMSE_sto.(cur_marqueur)=sqrt((cur_x-coord_trc(:,1)).^2+(cur_y-coord_trc(:,2)).^2+(cur_z-coord_trc(:,3)).^2);
    end
end

cd(rep_sortie);
save([nom_sortie '_RMSE.mat'],'st_RMSE_sto');

end