% function MH_transfo=transfo_scale_EOS(rep_global,cur_sujet,cur_st_model,fichiers_wrl,st_model_scale)
clear
close
%% Donnees test TM
% rep_global='E:\These_Thibault_Marsan\BDD_Tennis_de_Table\Data_pour_tests\Test_Pipeline';
% cur_sujet='TdT_B_B003_P2';
% cur_st_model_muscles=load('C:\Users\visiteur\Desktop\data_test_perso_muscle\cur_st_model');
% st_model_EOS=cur_st_model_muscles.cur_st_model;
% cur_st_model_scale=load('C:\Users\visiteur\Desktop\data_test_perso_muscle\model_scale_init');
% st_model_scale=cur_st_model_scale.model_scale_init;
% rep_wrl='E:\These_Thibault_Marsan\BDD_Tennis_de_Table\Data_pour_tests\Test_Pipeline\TdT_B_B003_P2\fichiers_wrl';
% rep_geometry='E:\These_Thibault_Marsan\BDD_Tennis_de_Table\1_Structure_Data\BDD_pretraitee\info_global\Geometry';

%% Donnees test YP
rep_global='C:\Users\yoann\Desktop\Stage_Charpak\Test_Pipeline_muscles';
cur_sujet='TdT_B_B003_P2';
cur_st_model_muscles=load('C:\Users\yoann\Desktop\Stage_Charpak\Test_Pipeline_muscles\cur_st_model');
st_model_EOS=cur_st_model_muscles.cur_st_model;
cur_st_model_scale=load('C:\Users\yoann\Desktop\Stage_Charpak\Test_Pipeline_muscles\model_scale_init');
st_model_scale=cur_st_model_scale.model_scale_init;
rep_wrl='C:\Users\yoann\Desktop\Stage_Charpak\Test_Pipeline_muscles\TdT_B_B003_P2\fichiers_wrl';
rep_geometry='C:\Users\yoann\Desktop\Stage_Charpak\Test_Pipeline_muscles\info_global\Geometry';

% A enlever lors de l'appel de la fonction ==> mettre bodies_name dans les
% arguments d'entrée
[bodies]=extract_KinChainData_ModelOS(st_model_EOS);
bodies_name=fieldnames(bodies);
%
[~,list_os_concernes]=PathContent(fullfile(rep_wrl,'os','os_corps_complet'));
fich_test_bassin=list_os_concernes{1}; % faire boucle
nom_segment='pelvis'; % ça va être galère à gérer
%% Ouverture des fichiers stl et wrl des modèles scalés et EOS
% Modèle scalé
ind_seg=strcmp(bodies_name,nom_segment);
objet_stl_tot=creation_objet_stl_tot(st_model_scale,ind_seg,rep_geometry,nom_segment,bodies_name);
% figure('Name','Scale')
% pcshow(objet_stl_tot.Noeuds,'red','MarkerSize',8);
% Modèle EOS
data_wrl=lire_fichier_wrml(fullfile(rep_wrl,'os','os_corps_complet',fich_test_bassin));
% figure('Name','EOS')
% pcshow(data_wrl.Noeuds./1000,'blue','MarkerSize',8)
%% 1ère étape :
% calculer repère d'inertie et trouver axes principaux, faire
% passer plan pour symétrie, 
% Scale
[MI3D_scale,rep_inertie_scale]=repere_inertie(objet_stl_tot.Noeuds);
% Dans rep_inertie : OR3D = barycentre des points = origine du repère,
% M2DRIN = matrice de la transformation
[~,coord_principal_scale]=max(rep_inertie_scale.MR2DRIN(:,1));
Moitie_points_scale_pos=MI3D_scale(MI3D_scale(:,coord_principal_scale)>0,:);
Moitie_points_scale_neg=MI3D_scale(MI3D_scale(:,coord_principal_scale)<0,:);
% Moitie_points_scale_axe2pos=MI3D_scale(MI3D_scale(:,2)>0,:);
% Moitie_points_scale_axe2neg=MI3D_scale(MI3D_scale(:,2)<0,:);
% centre_pos_scale_axe2=barycentre(Moitie_points_scale_axe2pos);
% centre_neg_scale_axe2=barycentre(Moitie_points_scale_axe2neg);

centre_pos_scale=barycentre(Moitie_points_scale_pos);
centre_neg_scale=barycentre(Moitie_points_scale_neg);
% figure('Name','Scale moitié')
% xlabel('x')
% ylabel('y')
% zlabel('z')
% hold on
% pcshow(Moitie_points_scale_pos,'red','MarkerSize',8)
% pcshow(Moitie_points_scale_neg,'blue','MarkerSize',8)
% EOS
[MI3D_EOS,rep_inertie_EOS]=repere_inertie(data_wrl.Noeuds./1000);
[~,coord_principal_EOS]=max(rep_inertie_EOS.MR2DRIN(:,1));
Moitie_points_EOS_pos=MI3D_EOS(MI3D_EOS(:,coord_principal_EOS)>0,:);
Moitie_points_EOS_neg=MI3D_EOS(MI3D_EOS(:,coord_principal_EOS)<0,:);
% figure('Name','EOS moitié')
% xlabel('x')
% ylabel('y')
% zlabel('z')
% hold on
% pcshow(Moitie_points_EOS_pos,'red','MarkerSize',8)
% pcshow(Moitie_points_EOS_neg,'blue','MarkerSize',8)

centre_pos_EOS=barycentre(Moitie_points_EOS_pos);
centre_neg_EOS=barycentre(Moitie_points_EOS_neg);
 % Reconstruire MH à partir de OR3D et ...
% Utiliser pcdenoise, pcdownsample, pcregrigid, pctransform
%% 2ème étape : Faire recalage rigide (cf Charlotte)
% calculer centroïdes points pour recaler à peu près les maillages,
% effectuer un scaling

%% 3ème étape : 
% ICP avec la fonction pcregrigid.m de matlab. Permet d'ajuster les
% maillages
ratio_noeuds=(size(MI3D_EOS,1)-size(MI3D_scale,1))/size(MI3D_EOS,1);
maillage_EOS=pointCloud(MI3D_EOS);
maillage_EOS_denoise=pcdenoise(maillage_EOS);
maillage_EOS_down=pcdownsample(maillage_EOS_denoise,'random',1-ratio_noeuds);
% pcshow(maillage_EOS_down)
maillage_scale=pointCloud(MI3D_scale);
[s,r,t]=pcregrigid(maillage_EOS,maillage_scale);
figure
hold on
pcshow(maillage_scale.Location,'red','MarkerSize',8)
pcshow(r.Location,'blue','MarkerSize',8)
%% 4ème étape : 
% Krigeage
% end