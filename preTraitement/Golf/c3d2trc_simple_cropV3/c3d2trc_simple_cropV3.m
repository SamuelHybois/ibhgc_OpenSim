function c3d2trc_simple_cropV3( myc3d_path,st_marqueurs_cine,crop_inf, crop_sup, chemin_sortie, cur_sujet )
% crop en frame vicon
% chemin de sortie pouvant être différent

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% myc3d_path='F:\sauvegarde_ddr\Cours_these\Recherche\DATA\2016_04_28_Golf_007_YLC\mouvfct\marche2.c3d';
[~,nom_c3d,~]=fileparts(myc3d_path);

if ~isempty(strfind(nom_c3d,' ')) % Changement du nom du c3d s'il contient un espace, on le remplace par un '_'.
    ind_espace=strfind(nom_c3d,' ');
    nom_c3d(ind_espace)='_';
end

[VICON_cine,~] = recuperation_c3d(myc3d_path); % extraction données c3d

[ st_marqueurs_cine] = NettoieMarkerLabels(st_marqueurs_cine); % enlève les marqueurs sans label

[st_marqueurs_cine] = rectification_nom_marqueurs(st_marqueurs_cine); % change les noms de marqueurs pour correspondre au set actuel

[st_marqueurs_cine] = zero2NaN(st_marqueurs_cine); % transforme les [0 0 0] en NaN

VICON_cine.Marqueurs=st_marqueurs_cine;

ecriture_fich_trc_crop(VICON_cine, [cur_sujet '_' nom_c3d] ,chemin_sortie,crop_inf, crop_sup);

end

