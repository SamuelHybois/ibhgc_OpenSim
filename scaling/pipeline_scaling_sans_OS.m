<<<<<<< HEAD
function [myosim_scaled_path,struct_OSIM]=pipeline_scaling_sans_OS(nom_model,rep_global,st_protocole,cur_sujet,cur_mass,nom_sortie_model)
path_model=fullfile(rep_global,'info_global',nom_model);
geometry_path=fullfile(rep_global,'info_global','Geometry');
=======
function [ myosim_scaled_path,struct_OSIM ]=pipeline_scaling_sans_OS(nom_model,rep_global,st_protocole,cur_sujet,cur_mass,nom_sortie_model)
%% Définition des chemins (temporaire)
% nom_sortie_model='test_scaling.osim';
% rep_global='C:\Users\visiteur\Desktop\test_scaling';
% cur_sujet='TdT_B_A008_P1';
% nom_model='IBHGC_fullbodyV7_golf_test.osim';
path_model=fullfile(rep_global,'info_global',nom_model);

%% ouverture fichiers
% [~,nom_prot]=PathContent_Type(fullfile(rep_global,'info_global'),'.protOS');
% prot_file=fullfile(rep_global,'info_global',nom_prot{1});
% st_protocole=lire_fichier_prot_2(prot_file);
% path_info_sujet=fullfile(rep_global,'info_global');
% [~,nom_xls]=PathContent_Type(path_info_sujet,'.xlsx');
% [~,~,xls_raw]=xlsread(fullfile(path_info_sujet,nom_xls{1}));

%% Fonction
>>>>>>> dev_diane_ENSAM
path_statique=fullfile(rep_global,cur_sujet,'modele');
[~,nom_c3d_statique]=PathContent_Type(path_statique,'.c3d');

%% Ouverture du c3d et extraction de la structure de marqueurs
st_c3d=btk_loadc3d(fullfile(path_statique,nom_c3d_statique{1}));
st_mrk_reel=st_c3d.marker_data.Markers;
list_mrk=fieldnames(st_mrk_reel);
M_pass_VICON_OS=[[0 -1 0]',[0 0 1]',[-1 0 0]'];
for i_mrk=1:size(list_mrk,1)
    cur_mrk=list_mrk{i_mrk};
    st_mrk_reel.(cur_mrk)=M_pass_VICON_OS*st_mrk_reel.(cur_mrk)';
    st_mrk_reel.(cur_mrk)=st_mrk_reel.(cur_mrk)'/1000;
end

%% Ouverture du modèle osim et extraction d'un struct contenant les marqueurs.
st_model_init=xml_readOSIM_TJ(path_model);
st_mrk_model=extract_st_mrk_from_model(st_model_init);

%% calcul des matrices homogènes des segments avec les coordonnées généralisées à 0
nb_frame=size(st_mrk_reel.(list_mrk{1}),1);
Struct_MH=calcul_MH_scalin(st_model_init,nb_frame);

%% Passage des coordonnées simulées des marqueurs dans R0
list_mrk=fieldnames(st_mrk_model);
nb_mrk=size(list_mrk,1);
for i_mrk=1:nb_mrk
    cur_mrk=list_mrk{i_mrk};
    cur_body=st_mrk_model.(cur_mrk).body;
    cur_MH=Struct_MH.(cur_body).MH(:,:,1);
    cur_location_mrk=st_mrk_model.(cur_mrk).location;
    st_mrk_model_R0.(cur_mrk).location=cur_MH*[cur_location_mrk';1];
    st_mrk_model_R0.(cur_mrk).location=st_mrk_model_R0.(cur_mrk).location(1:3)';
    st_mrk_model_R0.(cur_mrk).body='ground';
end

 %% Calcul des facteur de scaling
st_mrk_reel=zero2NaN(st_mrk_reel);
scale_factors=calcul_facteurs_scaling(st_mrk_reel,st_mrk_model_R0,st_protocole,nb_frame);

%% Application des scale factors aux bodies
st_model=application_scale_factor_body(st_model_init,scale_factors);

%% Application des scale factors aux centres articulaires
st_model=application_scale_factor_joint(st_model,scale_factors);

%% Application des scale factors aux marqueurs
st_model=application_scale_factor_marqueurs(st_model,scale_factors);

%% Application des scale factors aux fonctions associées aux centres articulaires
st_model=application_scale_factor_fonctions(st_model,scale_factors);

%% Application des scale factors aux contraintes de point
st_model=application_scale_factor_contraintes(st_model,scale_factors);

%% Application des scales factors aux centres de masse segmentaires
st_model=application_scale_factor_masses(st_model,scale_factors);

%% Scaling mass
<<<<<<< HEAD
[st_model,scale_factors.mass]=preserve_mass_distribution(st_model,cur_mass);

=======
% [st_model,scale_factors.mass]=preserve_mass_distribution(st_model,xls_raw,cur_sujet);
[st_model,scale_factors.mass]=preserve_mass_distribution(st_model,cur_mass);
>>>>>>> dev_diane_ENSAM
%% Application des scales factors aux matrices d'inertie
st_model=application_scale_factors_inerties(st_model,scale_factors);  

% %% Application des scales factors aux muscles
% st_model=application_scale_factor_muscles(st_model,scale_factors);
% 
% %% Application des scales factors aux wrap objects
% st_model=application_scale_factors_wraps(st_model,scale_factors);



%% Ecriture du modèle scalé
<<<<<<< HEAD
copyfile(geometry_path,fullfile(rep_global,cur_sujet,'modele','Geometry'))
=======
>>>>>>> dev_diane_ENSAM
myosim_scaled_path=fullfile(rep_global,cur_sujet,'modele',nom_sortie_model);
xml_writeOSIM_TJ(myosim_scaled_path,st_model,'OpenSimDocument');
struct_OSIM=st_model;
end