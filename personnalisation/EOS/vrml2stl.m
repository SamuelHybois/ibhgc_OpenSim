function vrml2stl(nom_EOS,nom_OS,chemin_EOS,chemin_geo_OS)

% nom_EOS='bassin.wrl';
% nom_OS='pelvis.stl';
% chemin_EOS='E:\etude_modele_rep_EOS\reconstruction_EOS';
% chemin_geo_OS='E:\etude_modele_rep_EOS\Geometry';

f=[chemin_EOS '\' nom_EOS];
movie=lire_fichier_wrml(f);
ecrit_fichier_stl_MB([chemin_geo_OS '\' nom_OS],movie,nom_OS,10^(-3))





end