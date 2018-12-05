% function  [Struct_L,Struct_IK_ISB]= OS_AnalyseMusclePerso(rep_global,cur_sujet,cur_activity,...
% cur_acquisition,struct_OSIM,Wraps,Struct_OSIM_gen)
function  [Struct_IK_ISB,Struct_dist_CoR]= OS_AnalyseMusclePerso(rep_global,cur_sujet,cur_activity,...
cur_acquisition,myosim_Matlab_name,struct_OSIM,Struct_OSIM_gen)
%[Struct_L,Struct_BL]
% Initialisation
mass_center=struct;
angles_bodies=struct;
% geometrypath=fullfile(rep_global,cur_sujet,'modele','Geometry');
Analyzefolder = [cur_acquisition(1:end-4) '_' 'ANALYZE'];
% [~,modelname,~] = fileparts(myosim_Matlab_name_unconstrained);
% BK_pos_sto=fullfile(rep_global,cur_sujet,cur_activity, Analyzefolder, [modelname '_BodyKinematics_pos_global.sto']);

[~,modelname,~] = fileparts(myosim_Matlab_name);
BK_pos_sto=fullfile(rep_global,cur_sujet,cur_activity, Analyzefolder, [modelname '_BodyKinematics_pos_global.sto']);

% BK_pos_sto = dir(BK_pos_sto_path);
% BK_pos_sto_n=BK_pos_sto.name;
% BK_pos_sto_path = fullfile(rep_global,cur_sujet,cur_activity, Analyzefolder,...
% BK_pos_sto_n);
% coord_BK=load_sto_file(BK_pos_sto_path);
coord_BK=load_sto_file(BK_pos_sto);
list_coord_BK=fieldnames(coord_BK);
nb_coord_BK = size(list_coord_BK,1);
nb_frame_BK = size(coord_BK.(list_coord_BK{1}),1);

%IK.MOT
rep_ik = fullfile(rep_global,cur_sujet,cur_activity);
file_mot = [cur_acquisition(1:end-4) '_ik_lisse.mot'];
coord_ik = lire_donnee_ik_mot(fullfile(rep_ik,file_mot));
save(fullfile(rep_global,cur_sujet,cur_activity, Analyzefolder,'coord_ik.mat'),'coord_ik')

%lecture du modèle OSIM
[Bodies,Joints]=extract_KinChainData_ModelOS(struct_OSIM,struct_OSIM.Model.ConstraintSet);
list_bodies=fieldnames(Bodies);

%lecture des centres de masse et de leur orientation
for i_coord=1:nb_coord_BK
    cur_nom_coord=list_coord_BK{i_coord};
    cur_value_coord=coord_BK.(cur_nom_coord);
    if strcmp(cur_nom_coord,'time')==0 && ~isempty(strfind(cur_nom_coord,'ground'))==0
        if ~isempty(strfind(cur_nom_coord,'_Ox')) || ~isempty(strfind(cur_nom_coord,'_Oy')) || ~isempty(strfind(cur_nom_coord,'_Oz'))
            cur_body=cur_nom_coord(1:end-3);
            if isfield(angles_bodies,cur_body)==0
                angles_bodies.(cur_body)=cur_value_coord;
            else
                angles_bodies.(cur_body)=[angles_bodies.(cur_body) cur_value_coord];
            end
        elseif ~isempty(strfind(cur_nom_coord,'_X')) || ~isempty(strfind(cur_nom_coord,'_Y')) || ~isempty(strfind(cur_nom_coord,'_Z'))
            cur_body=cur_nom_coord(1:end-2);
            if isfield(mass_center,cur_body)==0
                mass_center.(cur_body)=cur_value_coord;
            else
                mass_center.(cur_body)=[mass_center.(cur_body) cur_value_coord];
            end
        end
    end
end

%% Calcul des matrices homogènes des segments
Struct_MH=calcul_MH_reconstruction_analyse(struct_OSIM,angles_bodies,mass_center);
save(fullfile(rep_global,cur_sujet,cur_activity, Analyzefolder,'Struct_MH.mat'),'Struct_MH')

Struct_MH_ISB = calcul_MH_ISB(Struct_MH,struct_OSIM,Struct_OSIM_gen);
Struct_IK_ISB = Tranformation_matrix_shoulder(Struct_MH,Struct_MH_ISB);
save(fullfile(rep_global,cur_sujet,cur_activity, Analyzefolder,'Struct_IK_ISB.mat'),'Struct_IK_ISB')

% %% Version 1 ne tient pas compte des wraps.
% % Calcul des coordonnées homogènes des points des muscles dans R0
% Struct_muscles_points = Point_muscles_dans_R0(st_model,Struct_MH,coord_ik);
% 
% Calcul des CoR dans R0
Struct_CoR = calcul_position_CoR_dans_R0(Bodies,Struct_MH);
Struct_dist_CoR = calcul_distance_CoR_dans_R0(Struct_CoR);
% 
% % Calcul des longueurs musculaires distance-via points
% Struct_L = calcul_longueur_musculaire(Struct_muscles_points);
% 
% % Calcul des bras de levier musculaires par méthode directe
% Struct_BL = calcul_bras_de_levier_musculaire(Bodies,Joints,Struct_CoR,Struct_muscles_points);

%% Version 2, Tenir compte des wraps.

% Calcul des coordonnées homogènes des points des muscles 
% et points de contournement des wraps) dans R0
[Struct_muscles_points,Struct_muscle_wraps,Struct_wrapping_points] =...
 Point_muscles_dans_R0_Wraps(struct_OSIM,Struct_MH,coord_ik,Wraps,1); % Pour une frame.

% save(fullfile(rep_global,cur_sujet,cur_activity, Analyzefolder,'Struct_muscles_points.mat'),'Struct_muscles_points')
% save(fullfile(rep_global,cur_sujet,cur_activity, Analyzefolder,'Struct_muscle_wraps.mat'),'Struct_muscle_wraps')
% save(fullfile(rep_global,cur_sujet,cur_activity, Analyzefolder,'Struct_wrapping_points.mat'),'Struct_wrapping_points')

% % Calcul des longueurs musculaires distance-via points
% Struct_L = calcul_longueur_musculaire_wraps(Struct_muscles_points,Struct_muscle_wraps,Struct_wrapping_points);
% save(fullfile(rep_global,cur_sujet,cur_activity, Analyzefolder,'Struct_L.mat'),'Struct_L');

% Calcul des CoR dans R0
% Struct_CoR = calcul_position_CoR_dans_R0(Bodies,Struct_MH);
% save(fullfile(rep_global,cur_sujet,cur_activity, Analyzefolder,'Struct_CoR.mat'),'Struct_CoR');

% Struct_BL = calcul_bras_de_levier_musculaire_wrap(Bodies,Joints,Struct_CoR,Struct_muscles_points,Struct_muscle_wraps,Struct_wrapping_points);
% calcul_bras_de_levier_musculaire
%affichage_squelette_test(st_model,1,fullfile(rep_global,cur_sujet,'modele','Geometry'),Struct_MH)
%affichage_muscles_wraps(1,Struct_muscles_points,Struct_muscle_wraps,Struct_wrapping_points)

% Struct_BL = calcul_bras_de_levier_TE(Struct_MH,Wraps,Struct_L,...
% Struct_muscles_points,Struct_muscle_wraps,Struct_wrapping_points,Struct_MH_ISB,Struct_IK_ISB,...
% Bodies,Joints);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Pas encore codé
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calcul des CoR dans R0
% Struct_CoR = calcul_position_CoR_dans_R0(Bodies,Struct_MH);
% 
% % Calcul des longueurs musculaires distance-via points
% Struct_L = calcul_longueur_musculaire(Struct_muscles_points);
% 
% % Calcul des bras de levier musculaires par méthode directe
% Struct_BL = calcul_bras_de_levier_musculaire(Bodies,Joints,Struct_CoR,Struct_muscles_points);
% 

%Peut-être on aura besoin de spatial transform pour les axes de rotations
%particulier


end