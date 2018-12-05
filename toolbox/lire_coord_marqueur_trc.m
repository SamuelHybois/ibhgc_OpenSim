function [coord] = lire_coord_marqueur_trc(nom_marqueur,fichier_trc)
% Permet de sortir les coordonnées d'un marqueur particulier, pour
% l'ensemble d'un fichier trc

% Sortie : matrice n lignes (n=nombre de frames) et 3 colonnes (X,Y,Z)

% Exemple : AC_droit_coord = lire_coord_marqueur_trc('statique.trc','ACD');

my_trc = lire_donnees_trc(fichier_trc);

IndexC = strfind(my_trc.noms,nom_marqueur);

Index = find(not(cellfun('isempty', IndexC)));

coord = my_trc.coord(:,3*Index-2:3*Index);

end