function c3d2trc_crop_chgt_repere_V2(chemin_c3d,M_pass,dossier_sortie)

[~,nom_c3d,~]=fileparts(chemin_c3d);

[VICON_cine,~] = recuperation_c3d(chemin_c3d); % extraction donn�es c3d

[st_marqueurs_cine] = NettoieMarkerLabels(VICON_cine.Marqueurs); % enl�ve les marqueurs sans label
if ~isempty(st_marqueurs_cine)
    
    [st_marqueurs_cine] = zero2NaN(st_marqueurs_cine); % transforme les [0 0 0] en NaN
    
    Marqueurs = fieldnames(st_marqueurs_cine);
    for i_marqueur = 1:size(Marqueurs,1)
        Data_R0= st_marqueurs_cine.(Marqueurs{i_marqueur});
        Data_R1= M_pass' * Data_R0'; % Changement de rep�re
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
    
    ecriture_fich_trc_crop(VICON_cine,nom_c3d,dossier_sortie,1, size(st_marqueurs_cine.(Marqueurs{1}),1));
else
    disp(['Pas de cr�ation du trc pour ',nom_c3d])
end
% Crop et conversion c3d vers trc. Le trc contient une seule frame

