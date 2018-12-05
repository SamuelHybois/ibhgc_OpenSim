function c3d2trc_crop_chgt_repere_gym(chemin_c3d,M_pass)

[dossier_c3d,nom_c3d,~]=fileparts(chemin_c3d);

[VICON_cine,~] = recuperation_c3d(chemin_c3d); % extraction données c3d

[st_marqueurs_cine] = NettoieMarkerLabels(VICON_cine.Marqueurs); % enlève les marqueurs sans label

[st_marqueurs_cine] = zero2NaN(st_marqueurs_cine); % transforme les [0 0 0] en NaN

Marqueurs = fieldnames(st_marqueurs_cine);
for i_marqueur = 1:size(Marqueurs,1)
    Data_R0= st_marqueurs_cine.(Marqueurs{i_marqueur});
    Data_R1= M_pass' * Data_R0'; % Changement de repère
    st_marqueurs_cine.(Marqueurs{i_marqueur}) = Data_R1';
end

[st_marqueurs_cine] = rectification_nom_marqueurs(st_marqueurs_cine); % change les noms de marqueurs pour correspondre au set actuel

% [frame_max_mrk,~,~]=trouve_frame_max_marqueursV2(st_marqueurs_cine); % Trouve la frame contenant le maximum de marqueurs

VICON_cine.Marqueurs=st_marqueurs_cine;

% crop_inf=frame_max_mrk;
% crop_sup=frame_max_mrk;

if ~isempty(strfind(nom_c3d,' ')) % Changement du nom du c3d s'il contient un espace, on le remplace par un '_'.
    ind_espace=strfind(nom_c3d,' ');
    nom_c3d(ind_espace)='_';
end

ecriture_fich_trc_crop_gym(VICON_cine,nom_c3d,dossier_c3d,1, size(st_marqueurs_cine.(Marqueurs{1}),1)); 
% Crop et conversion c3d vers trc. Le trc contient une seule frame

