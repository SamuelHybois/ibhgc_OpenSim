function pre_traitement_golfV2( chemin_c3d, excel_labellisation, dossier_sortie, nom_sujet,fichier_protocole,M_pass_VICON_OS)
% fonction permettant d'effectuer les différentes étapes de pré-traitement
% pour traiter une acquisition de golf via OpenSim

%% ETAPES
% - lire le excel avec les frames de début/fin de mouvement
% - créer le trc cropé
% - créer le .mot des efforts.

%% Initialisation des données

ratio_NaN=0.3;

[~, nom_c3d, ~]=fileparts(chemin_c3d);

% identification du cas
[ test_fer ] = ~isempty(strfind( nom_c3d, 'fer' ));
[ test_driver ] = ~isempty(strfind( nom_c3d, 'driver' ));
[ test_marche ] = ~isempty(strfind( nom_c3d, 'arche' ));
% [ test_amplitude ] = ~isempty(strfind( nom_c3d, 'amplit' ));

% Lecture du fichier protocole
st_protocole_pretraitement=lire_fichier_prot_2(fichier_protocole);

% Détermination des frames de début et fin pour l'acquisition considérée

nb_col=size(excel_labellisation,2);
nb_ligne=size(excel_labellisation,1);

for i_col=1:nb_col
    cur_col=excel_labellisation{1,i_col};
    if strcmp(cur_col,'debut') % Détermination de la colonne de début
        col_debut=i_col;
    end
end
for i_col=1:nb_col
    cur_col=excel_labellisation{1,i_col};
    if strcmp(cur_col,'fin') % Détermination de la colonne de fin
        col_fin=i_col;
    end
end
for i_ligne=1:nb_ligne
    cur_ligne=excel_labellisation{i_ligne,1};
    if strcmp(cur_ligne,nom_c3d) % Détermination de la ligne correspondant au nom du c3d
        ligne_acq=i_ligne;
    end
end

cur_frame_vicon_debut=excel_labellisation{ligne_acq,col_debut};
cur_frame_vicon_fin=excel_labellisation{ligne_acq,col_fin};

% [ test_putting ] = strcmp_complet( nom_c3d, 'putting');
% [ test_MCV ] = strcmp_complet( nom_c3d, 'MCV');
% [ test_mvtfct ] = strcmp_complet( nom_c3d, 'mvtfct');
if test_fer==1
    dossier_sortie=fullfile(dossier_sortie,'fer6');
elseif test_driver==1
    dossier_sortie=fullfile(dossier_sortie,'driver');
    % elseif test_putting==1
    %     dossier_sortie=fullfile(dossier_sortie,'putting');
    % elseif test_MCV==1
    %     dossier_sortie=fullfile(dossier_sortie,'MCV');
    % elseif test_mvtfct==1
    %     dossier_sortie=fullfile(dossier_sortie,'mvtfct');
elseif test_marche==1
    dossier_sortie=fullfile(dossier_sortie,'marche');
    % elseif  test_amplitude==1
    %     dossier_sortie=fullfile(dossier_sortie,'amplitudes_max');
else
    disp('type de c3d non reconnu, attention à l''arborescence de pré-traitement')
end
%% Traitement du c3d
% disp('Nettoyage des marqueurs du c3d')
% % 1.1 Lecture du fichier c3d
[VICON_cine,~] = recuperation_c3d(chemin_c3d); % extraction données c3d

[ st_marqueurs_cine] = NettoieMarkerLabels2(VICON_cine.Marqueurs); % enlève les marqueurs sans label

[st_marqueurs_cine] = zero2NaN(st_marqueurs_cine); % transforme les [0 0 0] en NaN
Marqueurs = fieldnames(st_marqueurs_cine);

%1.2 Amélioration des données cinématique
%1.2.1 Changement de système d'axe pour éviter gimbal lock
for i_marqueur = 1:size(Marqueurs,1)
    Data_R0= st_marqueurs_cine.(Marqueurs{i_marqueur});
    Data_R1= M_pass_VICON_OS' * Data_R0';
    st_marqueurs_cine.(Marqueurs{i_marqueur}) = Data_R1';
end


%1.2.2 interpolation si petit trous
taille_trou = 15;
n_mg = 5;
nb_min_points = round( taille_trou/2);

for i_marqueur = 1:size(Marqueurs,1)
    Data = st_marqueurs_cine.(Marqueurs{i_marqueur});
    Data_output = bouche_petits_trous_coord3D(Data,n_mg,taille_trou,nb_min_points);
    st_marqueurs_cine.(Marqueurs{i_marqueur}) = Data_output;
end

% 1.2.3 Recalage rigide si gros trous

list_seg=fieldnames(st_protocole_pretraitement.SEGMENTS);
nb_seg=size(list_seg,1);

for i_seg=1:nb_seg
    try
        cur_seg=list_seg{i_seg};
        Marqueurs_Segment=st_protocole_pretraitement.SEGMENTS.(cur_seg);
        st_marqueurs_cine = recalage_rigide_grands_trous(st_marqueurs_cine,Marqueurs_Segment);
    catch
        disp(['!!! Erreur recalage rigide pour ',cur_seg,', marqueurs manquants dans le c3d !!!'])
    end
    
    
end

% 1.2.4 Re interpolation si petits trous

for i_marqueur = 1:size(Marqueurs,1)
    Data = st_marqueurs_cine.(Marqueurs{i_marqueur});
    Data_output = bouche_petits_trous_coord3D(Data,n_mg,taille_trou,nb_min_points);
    st_marqueurs_cine.(Marqueurs{i_marqueur}) = Data_output;
end

% 1.2.5 Extrapolation sur les bords

for i_marqueur = 1:size(Marqueurs,1)
    st_marqueurs_cine.(Marqueurs{i_marqueur}) = extrapolation_petits_trous_bords(st_marqueurs_cine.(Marqueurs{i_marqueur}),taille_trou);
end

% 1.2.6 On enlève les marqueurs où il reste des NaN
[st_marqueurs_cine,~]=Nettoiemark(st_marqueurs_cine,ratio_NaN);



%% écriture du trc

disp(['Création du trc cropé pour ',nom_c3d])
c3d2trc_simple_cropV3(chemin_c3d,st_marqueurs_cine,cur_frame_vicon_debut,cur_frame_vicon_fin,dossier_sortie,nom_sujet ) % crop en frames vicon et passage du repère VICON vers Opensim

%% écriture du fichier mot des efforts
st_protocole_pretraitement=lire_fichier_prot_2(fichier_protocole);
data_c3d=btk_loadc3d(chemin_c3d);
frequence_vicon=data_c3d.marker_data.Info.frequency;
cur_temps_debut=cur_frame_vicon_debut/frequence_vicon;
cur_temps_fin=cur_frame_vicon_fin/frequence_vicon;
nom_fichier_mot_effort=[nom_sujet '_' nom_c3d];

% Passage du repère VICON vers OpenSim et création du fichier mot
disp(['Création du fichier mot pour ',nom_c3d])
[~]=harmonised_ecriture_mot_effortV2(data_c3d, nom_fichier_mot_effort,chemin_c3d,M_pass_VICON_OS, dossier_sortie, cur_temps_debut, cur_temps_fin,st_protocole_pretraitement);


end

