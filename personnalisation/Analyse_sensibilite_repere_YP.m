%% Test sensibilité repère vertèbre barycentre pédicule
rep_global='C:\Users\yoann\Desktop\Stage_Charpak\Test_Pipeline_perso_YP';
dir_regions=fullfile(rep_global,'info_global','DDR');
cur_sujet='gym_01_P';
rep_wrl=fullfile(rep_global,cur_sujet,'fichiers_wrl');
rep_wrl_os_corps_complet=fullfile(rep_wrl,'os','os_corps_complet');

%Lecture fichier ddr
File_regions_Lomb = 'Vertebre_L1.ddr';
Reg_lomb= lire_fichier_ddr(fullfile(dir_regions, File_regions_Lomb ));
Regions_Lomb1=RegtyI2tyII(Reg_lomb,'Polygones');

%Lecture wrl
L1 = lire_fichier_vrml(fullfile(rep_wrl,'Vertebre_L1.wrl'));

%Calcul des points utilises pour creation du repere
[Plat_inf_L1] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb1.plat_inf.Polygones,L1);
CentrePI_L1 = barycentre(Plat_inf_L1.Noeuds); %en mm

[Plat_sup_L1] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb1.plat_sup.Polygones,L1);
CentrePS_L1 = barycentre(Plat_sup_L1.Noeuds); %en mm

[Pedicule_G_L1] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb1.pedicule_g.Polygones,L1);
CentrePedG_L1 = barycentre(Pedicule_G_L1.Noeuds); %en mm

[Pedicule_D_L1] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb1.pedicule_d.Polygones,L1);
CentrePedD_L1 = barycentre(Pedicule_D_L1.Noeuds); %en mm

%% Boucle pour créer une centaine de repères avec un rand dans la position des barycentres des pedicules (+-1mm)
%Repère pour comparaison
Repere_base=calcul_reperes_harmo_YP('lombaire',CentrePI_L1,CentrePS_L1,CentrePedG_L1,CentrePedD_L1);
Angle_repere_base=axemobile_xyz(Repere_base(1:3,1:3));

list_reperes=cell(500,1);
Angles=zeros(500,3);
for i=1:500
    CentrePedG_L1_tmp=CentrePedG_L1+rand(1)*2-1;
    CentrePedD_L1_tmp=CentrePedD_L1+rand(1)*2-1;
    CentrePI_L1_tmp=CentrePI_L1+rand(1)*2-1;
    CentrePS_L1_tmp=CentrePS_L1+rand(1)*2-1;
    list_reperes{i}=calcul_reperes_harmo_YP('lombaire',CentrePI_L1_tmp,CentrePS_L1_tmp,CentrePedG_L1_tmp,CentrePedD_L1_tmp);
    Angles(i,:)=Angle_repere_base-axemobile_xyz(list_reperes{i}(1:3,1:3));
end
%disp(Angles);

%% Comparaison des repères
MaxRotX=max(Angles(:,1))
MaxRotY=max(Angles(:,2))
MaxRotZ=max(Angles(:,3))

