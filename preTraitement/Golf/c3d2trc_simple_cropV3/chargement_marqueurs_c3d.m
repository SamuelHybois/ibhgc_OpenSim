function [ marqueurs ] = chargement_marqueurs_c3d( c3dfile )
% fonction permettant de r�cup�rer les positions des marqueurs � partir de
% fichiers c3d. 

% sorties : marqueurs est une structure du type
% marqueurs.nom_marqueur.coordonnees

% [pathc3d, namec3d, ~]=fileparts(c3dfile);
%[nomfichier, repertoire] = uigetfile('*.c3d', 'choix du fichier c3d � traiter');
% complete_dir = fullfile(repertoire, nomfichier);

[h, ~, ~] = btkReadAcquisition(c3dfile);
[marqueurs, ~, ~] = btkGetMarkers(h);


end

