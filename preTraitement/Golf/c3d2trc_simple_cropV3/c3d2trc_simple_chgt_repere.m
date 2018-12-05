function c3d2trc_simple_chgt_repere( myc3d_path ,M_pass_VICON_OS)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% myc3d_path='C:\Users\2016-1416.ENSAM\Desktop\rep_global\2017_01_20_golf_028_AM\modele\statique01.c3d';
[dossier_c3d,nom_c3d,~]=fileparts(myc3d_path);
[VICON_cine,~] = recuperation_c3d(myc3d_path); % extraction données c3d
[ st_marqueurs_cine] = NettoieMarkerLabels(VICON_cine.Marqueurs); % enlève les marqueurs sans label
[st_marqueurs_cine] = zero2NaN(st_marqueurs_cine); % transforme les [0 0 0] en NaN

Marqueurs = fieldnames(st_marqueurs_cine);
for i_marqueur = 1:size(Marqueurs,1)
    Data_R0= st_marqueurs_cine.(Marqueurs{i_marqueur});
    Data_R1= M_pass_VICON_OS' * Data_R0';
    st_marqueurs_cine.(Marqueurs{i_marqueur}) = Data_R1';
end

[ st_marqueurs_cine ] = chargement_marqueurs_c3d(myc3d_path); % noms des marqueurs dans le c3d

[ st_marqueurs_cine] = NettoieMarkerLabels(st_marqueurs_cine); % enlève les marqueurs sans label

[st_marqueurs_cine] = rectification_nom_marqueurs(st_marqueurs_cine); % change les noms de marqueurs pour correspondre au set actuel

[st_marqueurs_cine] = zero2NaN(st_marqueurs_cine); % transforme les [0 0 0] en NaN

ecriture_fich_trc( st_marqueurs_cine, VICON_cine, nom_c3d ,dossier_c3d);

% end

