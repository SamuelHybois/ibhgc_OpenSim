function transfert_fichier_wrl_stl(repertoire_wrl_EOS,cur_sujet,chemin_geometry)
% fonction de transformation des fichiers wrl en stl pour la pipeline
% harmonisée
% decembre 2016
disp('transfert des fichiers EOS pour personnalisation');
path_wrl=fullfile(repertoire_wrl_EOS,'\*.wrl');
fichiers_wrl=dir(path_wrl);
nb_wrl=length(fichiers_wrl);
for i_wrl=1:nb_wrl
    cur_nom_wrl=fichiers_wrl(i_wrl).name;
    file_wrl_entree=fullfile(repertoire_wrl_EOS,cur_nom_wrl);
    file_stl_sortie=fullfile(chemin_geometry,[cur_sujet '_' cur_nom_wrl(1:end-4) '.stl']);
    if exist(file_stl_sortie,'file')==0
        cur_movie=lire_fichier_wrml(file_wrl_entree);
        ecrit_fichier_stl_MB(file_stl_sortie,cur_movie,[cur_sujet '_' cur_nom_wrl(1:end-4)],10^(-3))
    end
end






end

